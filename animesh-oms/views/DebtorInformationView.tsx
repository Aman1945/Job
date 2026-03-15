
import React, { useState, useMemo } from 'react';
import { ODMaster, User, AgingBuckets, UserRole, InvoiceDetail, ReminderLog } from '../types';
import { 
  Search, 
  ChevronDown, 
  ChevronUp, 
  Send, 
  MessageSquare, 
  Mail, 
  Smartphone, 
  AlertCircle, 
  CheckCircle2, 
  History, 
  Clock, 
  Filter,
  ArrowUpRight,
  TrendingDown,
  TrendingUp,
  X,
  FileText,
  DollarSign,
  User as UserIcon,
  ShieldCheck,
  AlertTriangle,
  // Added missing icons to resolve "Cannot find name" errors
  Wallet,
  Target,
  Activity,
  ShieldAlert
} from 'lucide-react';
import { sendWhatsAppNotification, WHATSAPP_MESSAGES } from '../services/whatsappService';
import { sendEmailNotification, EMAIL_TEMPLATES } from '../services/emailService';

interface DebtorInformationViewProps {
  odMaster: ODMaster[];
  currentUser: User;
  onUpdateOdMaster: (od: ODMaster[]) => void;
}

const AGING_BUCKETS_KEYS: (keyof AgingBuckets)[] = [
  '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90', '90 to 120', '120 to 150', '150 to 180', '>180'
];

const DebtorInformationView: React.FC<DebtorInformationViewProps> = ({ odMaster, currentUser, onUpdateOdMaster }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [expandedRows, setExpandedRows] = useState<Set<string>>(new Set());
  const [selectedOD, setSelectedOD] = useState<ODMaster | null>(null);
  const [showReminderModal, setShowReminderModal] = useState(false);
  const [isSending, setIsSending] = useState(false);
  const [bulkSelection, setBulkSelection] = useState<Set<string>>(new Set());
  const [filterBucket, setFilterBucket] = useState<string>('All');

  // RBAC: Sales Manager sees only mapped customers. Admin sees everything.
  const filteredData = useMemo(() => {
    let base = odMaster;
    if (currentUser.role === UserRole.SALES) {
      base = base.filter(o => o.employeeResponsible === currentUser.name || o.salesManager === currentUser.name);
    }

    if (filterBucket !== 'All') {
      base = base.filter(o => o.aging[filterBucket as keyof AgingBuckets] > 0);
    }

    return base.filter(o => 
      o.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      o.customerId.toLowerCase().includes(searchTerm.toLowerCase())
    ).sort((a, b) => b.overdueAmt - a.overdueAmt);
  }, [odMaster, currentUser, searchTerm, filterBucket]);

  const kpis = useMemo(() => {
    const totalO = filteredData.reduce((s, o) => s + o.outstandingAmt, 0);
    const totalOD = filteredData.reduce((s, o) => s + o.overdueAmt, 0);
    const critical = filteredData.filter(o => o.aging['>45'] > 0 || o.aging['>180'] > 0 || o.aging['150 to 180'] > 0).length;
    const target = totalOD * 0.85; // Mock target
    const achieved = totalOD * 0.12; // Mock achievement
    return { totalO, totalOD, critical, target, achievedPct: (achieved/target)*100 };
  }, [filteredData]);

  const toggleExpand = (id: string) => {
    const newSet = new Set(expandedRows);
    if (newSet.has(id)) newSet.delete(id);
    else newSet.add(id);
    setExpandedRows(newSet);
  };

  const toggleBulk = (id: string) => {
    const newSet = new Set(bulkSelection);
    if (newSet.has(id)) newSet.delete(id);
    else newSet.add(id);
    setBulkSelection(newSet);
  };

  const handleSendReminder = async (od: ODMaster, mode: 'WhatsApp' | 'Email' | 'SMS') => {
    // Check for 24h duplicate prevention unless Admin
    const lastReminder = od.reminderHistory?.[od.reminderHistory.length - 1];
    if (lastReminder && currentUser.role !== UserRole.ADMIN) {
      const hoursSince = (new Date().getTime() - new Date(lastReminder.timestamp).getTime()) / (1000 * 60 * 60);
      if (hoursSince < 24) {
        alert(`Duplicate prevention: A reminder was already sent ${hoursSince.toFixed(1)}h ago. Please wait 24h or contact Admin for override.`);
        return;
      }
    }

    setIsSending(true);
    try {
      const timestamp = new Date().toISOString();
      const newLog: ReminderLog = { timestamp, mode, sender: currentUser.name, status: 'Sent' };
      
      // Simulate API call
      if (mode === 'WhatsApp') {
        const msg = WHATSAPP_MESSAGES.CUSTOMER_OVERDUE_ALERT(od.customerName, od.overdueAmt, "30+ Days");
        await sendWhatsAppNotification({ name: od.customerName, whatsappNumber: '+919999999999' }, msg);
      } else if (mode === 'Email') {
        // Fix: Changed od.id to od.customerId as the ODMaster interface uses customerId
        await sendEmailNotification({ name: od.customerName, email: 'finance@client.corp' }, `Payment Reminder - ${od.customerId}`, `Dear ${od.customerName}, please settle ₹${od.overdueAmt}`, []);
      }

      const updated = odMaster.map(o => o.customerId === od.customerId ? { ...o, reminderHistory: [...(o.reminderHistory || []), newLog] } : o);
      onUpdateOdMaster(updated);
      setShowReminderModal(false);
      setSelectedOD(null);
    } catch (e) {
      console.error(e);
    } finally {
      setIsSending(false);
    }
  };

  const handleBulkReminder = async () => {
    if (bulkSelection.size === 0) return;
    if (!window.confirm(`Send WhatsApp reminders to ${bulkSelection.size} selected customers?`)) return;

    setIsSending(true);
    const selectedList = odMaster.filter(o => bulkSelection.has(o.customerId));
    
    for (const od of selectedList) {
      const msg = WHATSAPP_MESSAGES.CUSTOMER_OVERDUE_ALERT(od.customerName, od.overdueAmt, filterBucket === 'All' ? 'various' : filterBucket);
      await sendWhatsAppNotification({ name: od.customerName, whatsappNumber: '+910000000000' }, msg);
      // Log it
      const timestamp = new Date().toISOString();
      const newLog: ReminderLog = { timestamp, mode: 'WhatsApp', sender: currentUser.name, status: 'Sent' };
      od.reminderHistory = [...(od.reminderHistory || []), newLog];
    }

    onUpdateOdMaster([...odMaster]);
    setBulkSelection(new Set());
    setIsSending(false);
    alert(`Bulk dispatch complete for ${selectedList.length} accounts.`);
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-32">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight flex items-center gap-3">
             <Wallet className="text-indigo-600" /> Debtor Intelligence Registry
          </h2>
          <p className="text-sm text-slate-500 font-medium">Real-time outstanding tracking & automated recovery missions</p>
        </div>
        <div className="flex gap-4">
           {bulkSelection.size > 0 && (
             <button 
               onClick={handleBulkReminder}
               className="bg-[#25D366] text-white px-8 py-3 rounded-2xl font-black text-[10px] uppercase tracking-widest shadow-xl shadow-emerald-500/20 flex items-center gap-2 animate-in zoom-in"
             >
                <MessageSquare size={16}/> Dispatch Bulk Reminder ({bulkSelection.size})
             </button>
           )}
           <div className="bg-white border border-slate-200 px-6 py-2 rounded-2xl flex items-center gap-3 shadow-sm">
              <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
              <span className="text-[10px] font-black uppercase text-slate-400">Tally Sync: Active</span>
           </div>
        </div>
      </div>

      {/* KPI Section */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
         <KpiCard label="Total Outstanding" value={`₹${(kpis.totalO/100000).toFixed(1)}L`} icon={<DollarSign size={16}/>} color="indigo" />
         <KpiCard label="Total Overdue" value={`₹${(kpis.totalOD/100000).toFixed(1)}L`} icon={<TrendingDown size={16}/>} color="rose" />
         <KpiCard label="Collection Target" value={`₹${(kpis.target/100000).toFixed(1)}L`} icon={<Target size={16}/>} color="amber" />
         <KpiCard label="Achieved %" value={`${kpis.achievedPct.toFixed(1)}%`} icon={<Activity size={16}/>} color="emerald" />
         <KpiCard label="Critical Accounts" value={`${kpis.critical}`} icon={<AlertTriangle size={16}/>} color="rose" bad />
      </div>

      <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
        <div className="relative w-full max-w-md group">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-indigo-600 transition-colors" size={18} />
          <input 
            type="text" 
            placeholder="Trace Entity Name or Code..." 
            className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-bold shadow-sm focus:ring-4 focus:ring-indigo-500/10 outline-none transition-all"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className="flex items-center gap-2 bg-slate-200 p-1.5 rounded-2xl border border-slate-300">
           {['All', '30 to 45', '45 to 90', '>180'].map(b => (
             <button 
               key={b} 
               onClick={() => setFilterBucket(b)}
               className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${filterBucket === b ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500 hover:text-slate-700'}`}
             >
                {b}
             </button>
           ))}
        </div>
      </div>

      <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left whitespace-nowrap">
            <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
              <tr>
                <th className="px-6 py-6 w-12"><input type="checkbox" className="rounded" onChange={(e) => { if(e.target.checked) setBulkSelection(new Set(filteredData.map(d=>d.customerId))); else setBulkSelection(new Set()); }} /></th>
                <th className="px-6 py-6">Manager / Entity</th>
                <th className="px-6 py-6 text-center">Credit terms</th>
                <th className="px-6 py-6 text-right">Limit</th>
                <th className="px-6 py-6 text-right">O/s Amt</th>
                <th className="px-6 py-6 text-right text-rose-500 font-black">OD Amt</th>
                <th className="px-6 py-6 text-center">Daily Diff.</th>
                {AGING_BUCKETS_KEYS.map(b => (
                  <th key={b} className="px-4 py-6 text-center font-bold text-slate-400">{b}</th>
                ))}
                <th className="px-8 py-6 text-right">Ops</th>
              </tr>
            </thead>
            <tbody className="divide-y text-xs font-bold text-slate-700">
              {filteredData.map(od => (
                <React.Fragment key={od.customerId}>
                  <tr className={`hover:bg-indigo-50/20 transition-all group ${expandedRows.has(od.customerId) ? 'bg-indigo-50/10' : ''}`}>
                    <td className="px-6 py-6"><input type="checkbox" className="rounded" checked={bulkSelection.has(od.customerId)} onChange={() => toggleBulk(od.customerId)} /></td>
                    <td className="px-6 py-6 cursor-pointer" onClick={() => toggleExpand(od.customerId)}>
                       <div className="flex items-center gap-4">
                          <div className={`w-8 h-8 rounded-lg flex items-center justify-center transition-all ${expandedRows.has(od.customerId) ? 'bg-indigo-600 text-white shadow-lg' : 'bg-slate-100 text-slate-300'}`}>
                             {expandedRows.has(od.customerId) ? <ChevronUp size={14}/> : <ChevronDown size={14}/>}
                          </div>
                          <div>
                             <p className="text-slate-900 font-black">{od.customerName}</p>
                             <p className="text-[9px] text-slate-400 font-black uppercase mt-1">Mgr: {od.salesManager} • Code: {od.customerId}</p>
                          </div>
                       </div>
                    </td>
                    <td className="px-6 py-6 text-center">
                       <span className="text-[10px] font-black text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded border border-indigo-100">{od.creditDays}</span>
                    </td>
                    <td className="px-6 py-6 text-right">₹{od.creditLimit.toLocaleString()}</td>
                    <td className="px-6 py-6 text-right font-black">₹{od.outstandingAmt.toLocaleString()}</td>
                    <td className="px-6 py-6 text-right font-black text-rose-600">₹{od.overdueAmt.toLocaleString()}</td>
                    <td className={`px-6 py-6 text-center ${od.diffYesterdayToday > 0 ? 'text-rose-500' : 'text-emerald-500'}`}>
                       <div className="flex items-center justify-center gap-1">
                          {od.diffYesterdayToday > 0 ? <TrendingUp size={10}/> : <TrendingDown size={10}/>}
                          ₹{Math.abs(od.diffYesterdayToday).toLocaleString()}
                       </div>
                    </td>
                    {AGING_BUCKETS_KEYS.map((bucket, idx) => {
                      const val = od.aging[bucket];
                      const isCritical = (idx >= 4 && val > 0); // >45 days
                      const isEmergency = (idx >= 8 && val > 0); // >180 days
                      return (
                        <td key={bucket} className={`px-4 py-6 text-center font-black ${isEmergency ? 'text-rose-600 bg-rose-50' : isCritical ? 'text-rose-400' : (val > 0 ? 'text-slate-900' : 'text-slate-200')}`}>
                           {val > 0 ? `₹${(val/1000).toFixed(0)}K` : '—'}
                        </td>
                      );
                    })}
                    <td className="px-8 py-6 text-right">
                       <button 
                         onClick={() => {setSelectedOD(od); setShowReminderModal(true);}}
                         className="p-2.5 bg-slate-900 text-white rounded-xl hover:bg-[#25D366] transition-all shadow-md group/btn flex items-center gap-2 ml-auto"
                       >
                          <Send size={14} className="group-hover/btn:scale-110" />
                          <span className="text-[9px] font-black uppercase tracking-widest hidden group-hover:block transition-all">Send Notice</span>
                       </button>
                    </td>
                  </tr>

                  {/* Expanded Detailed View: Invoice Wise */}
                  {expandedRows.has(od.customerId) && (
                    <tr className="bg-slate-50 border-y-2 border-slate-100">
                       <td colSpan={18} className="px-12 py-8 animate-in slide-in-from-top-4 duration-500">
                          <div className="bg-white rounded-[32px] border border-slate-200 shadow-xl overflow-hidden">
                             <div className="p-6 border-b bg-slate-50/50 flex items-center justify-between">
                                <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] flex items-center gap-2">
                                   <FileText size={14} className="text-indigo-600" /> Open Invoice Ledger
                                </h4>
                                <div className="flex gap-4">
                                   <div className="text-right">
                                      <p className="text-[9px] font-black text-slate-400 uppercase">Avg. Overdue Days</p>
                                      <p className="text-lg font-black text-rose-600">62 Days</p>
                                   </div>
                                </div>
                             </div>
                             <div className="overflow-x-auto">
                                <table className="w-full text-left text-xs">
                                   <thead className="bg-slate-50 text-[9px] font-black text-slate-400 uppercase border-b">
                                      <tr>
                                         <th className="px-6 py-4">Invoice No</th>
                                         <th className="px-6 py-4">Bill Date</th>
                                         <th className="px-6 py-4">Due Date</th>
                                         <th className="px-6 py-4 text-right">Bill Amt</th>
                                         <th className="px-6 py-4 text-right text-emerald-600">Received</th>
                                         <th className="px-6 py-4 text-right text-rose-600">Balance</th>
                                         <th className="px-8 py-4 text-right">Days Overdue</th>
                                      </tr>
                                   </thead>
                                   <tbody className="divide-y font-bold text-slate-700">
                                      {(od.invoices || mockInvoices).map((inv, ii) => (
                                        <tr key={ii} className="hover:bg-slate-50/50">
                                           <td className="px-6 py-4 font-mono font-black text-indigo-600 uppercase">{inv.invoiceNo}</td>
                                           <td className="px-6 py-4 text-slate-400">{inv.invoiceDate}</td>
                                           <td className="px-6 py-4">{inv.dueDate}</td>
                                           <td className="px-6 py-4 text-right">₹{inv.billAmount.toLocaleString()}</td>
                                           <td className="px-6 py-4 text-right text-emerald-600">₹{inv.receivedAmount.toLocaleString()}</td>
                                           <td className="px-6 py-4 text-right font-black text-slate-900">₹{inv.balanceAmount.toLocaleString()}</td>
                                           <td className="px-8 py-4 text-right">
                                              <span className={`px-3 py-1 rounded-lg text-[9px] font-black uppercase ${inv.daysOverdue > 45 ? 'bg-rose-50 text-rose-600 border border-rose-100' : 'bg-slate-100 text-slate-500'}`}>
                                                 {inv.daysOverdue} Days Late
                                              </span>
                                           </td>
                                        </tr>
                                      ))}
                                   </tbody>
                                </table>
                             </div>
                             
                             {/* Reminder Audit Trail */}
                             <div className="p-6 bg-slate-900 text-white border-t border-slate-800">
                                <h5 className="text-[9px] font-black uppercase text-indigo-400 mb-6 tracking-widest flex items-center gap-2"><History size={12}/> Recovery Audit Trail</h5>
                                <div className="flex gap-6 overflow-x-auto no-scrollbar pb-2">
                                   {(od.reminderHistory || []).map((log, li) => (
                                     <div key={li} className="bg-white/5 border border-white/10 p-3 rounded-2xl shrink-0 min-w-[180px]">
                                        <div className="flex justify-between items-center mb-2">
                                           <span className="text-[8px] font-black uppercase text-slate-500">{log.mode}</span>
                                           <span className="text-[8px] font-black uppercase text-emerald-400">{log.status}</span>
                                        </div>
                                        <p className="text-[10px] font-bold text-white mb-1">{new Date(log.timestamp).toLocaleString()}</p>
                                        <p className="text-[8px] font-black text-slate-400 uppercase">Sender: {log.sender}</p>
                                     </div>
                                   ))}
                                   {(!od.reminderHistory || od.reminderHistory.length === 0) && (
                                      <p className="text-[10px] text-slate-500 italic">No recovery missions dispatched yet.</p>
                                   )}
                                </div>
                             </div>
                          </div>
                       </td>
                    </tr>
                  )}
                </React.Fragment>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Reminder Dispatch Modal */}
      {showReminderModal && selectedOD && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-slate-900/80 backdrop-blur-sm animate-in fade-in">
           <div className="bg-white w-full max-w-2xl rounded-[50px] p-12 shadow-2xl relative animate-in zoom-in-95 border border-white/10">
              <button onClick={() => {setShowReminderModal(false); setSelectedOD(null);}} className="absolute top-10 right-10 p-3 bg-slate-50 text-slate-400 hover:text-rose-500 rounded-2xl transition-all">
                 <X size={24}/>
              </button>

              <div className="flex items-center gap-8 mb-12 border-b border-slate-100 pb-10">
                 <div className="w-20 h-20 bg-rose-50 text-rose-600 rounded-[32px] flex items-center justify-center shadow-xl">
                    <ShieldAlert size={40} />
                 </div>
                 <div>
                    <h3 className="text-3xl font-black text-slate-900 tracking-tight">{selectedOD.customerName}</h3>
                    <p className="text-sm font-black text-rose-500 uppercase tracking-widest mt-1">Pending Recovery: ₹{selectedOD.overdueAmt.toLocaleString()}</p>
                 </div>
              </div>

              <div className="space-y-10">
                 <div className="bg-slate-50 p-8 rounded-[40px] border border-slate-100 space-y-6">
                    <h4 className="text-[10px] font-black uppercase tracking-[0.3em] text-slate-400">Communication Context</h4>
                    <p className="text-sm text-slate-600 leading-relaxed font-medium italic">
                      "Subject: Urgent Settlement Required. Dear Fin-Dept, your account is currently ₹{selectedOD.overdueAmt.toLocaleString()} past due. Oldest Invoice {mockInvoices[0].invoiceNo} (₹{mockInvoices[0].balanceAmount.toLocaleString()}) is {mockInvoices[0].daysOverdue} days late. Please settle via UPI or Bank Transfer..."
                    </p>
                    <div className="flex items-center gap-2 text-indigo-600 text-[10px] font-black uppercase px-4 py-2 bg-indigo-50 rounded-xl w-fit">
                       <ShieldCheck size={14}/> Verified Template Alpha-1
                    </div>
                 </div>

                 <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
                    <ReminderBtn mode="WhatsApp" icon={<MessageSquare size={24}/>} color="#25D366" onClick={() => handleSendReminder(selectedOD, 'WhatsApp')} disabled={isSending} />
                    <ReminderBtn mode="Email" icon={<Mail size={24}/>} color="#4f46e5" onClick={() => handleSendReminder(selectedOD, 'Email')} disabled={isSending} />
                    <ReminderBtn mode="SMS" icon={<Smartphone size={24}/>} color="#334155" onClick={() => handleSendReminder(selectedOD, 'SMS')} disabled={isSending} />
                 </div>

                 <div className="flex items-start gap-4 p-6 bg-amber-50 rounded-[32px] border border-amber-100">
                    <div className="mt-1"><AlertTriangle size={24} className="text-amber-600 shrink-0" /></div>
                    <div className="space-y-1">
                       <p className="text-xs font-black text-amber-800 uppercase tracking-widest">Compliance Engine Active</p>
                       <p className="text-[11px] text-amber-700/80 leading-relaxed font-medium">Duplicate prevention: Reminders are limited to once per 24-hour cycle to avoid communication fatigue.</p>
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}

    </div>
  );
};

const ReminderBtn = ({ mode, icon, color, onClick, disabled }: any) => (
  <button 
    onClick={onClick}
    disabled={disabled}
    className="flex flex-col items-center justify-center gap-4 p-8 rounded-[40px] border-2 border-transparent hover:border-slate-200 bg-slate-50 transition-all hover:bg-white hover:shadow-xl group active:scale-95 disabled:opacity-30"
  >
     <div className="transition-all group-hover:scale-110" style={{ color }}>{icon}</div>
     <span className="text-[10px] font-black uppercase tracking-widest text-slate-400 group-hover:text-slate-900">{mode}</span>
  </button>
);

const KpiCard = ({ label, value, icon, color, bad }: any) => {
  const colors: any = {
    indigo: 'bg-indigo-50 text-indigo-600 border-indigo-100',
    rose: 'bg-rose-50 text-rose-600 border-rose-100',
    emerald: 'bg-emerald-50 text-emerald-600 border-emerald-100',
    amber: 'bg-amber-50 text-amber-600 border-amber-100'
  };

  return (
    <div className={`p-7 rounded-[40px] border shadow-sm transition-all hover:scale-105 group ${colors[color]}`}>
       <div className="flex items-center justify-between mb-4 opacity-70">
          <p className="text-[9px] font-black uppercase tracking-[0.2em]">{label}</p>
          {icon}
       </div>
       <div className="flex items-end justify-between">
          <p className="text-3xl font-black tracking-tighter">{value}</p>
          {bad && <span className="animate-ping w-2 h-2 rounded-full bg-rose-500" />}
       </div>
    </div>
  );
};

// Mock data for invoice details when not provided in Tally sync
const mockInvoices: InvoiceDetail[] = [
  { invoiceNo: 'INV/2024/0441', invoiceDate: '2024-01-10', dueDate: '2024-02-10', billAmount: 145000, receivedAmount: 45000, balanceAmount: 100000, daysOverdue: 62 },
  { invoiceNo: 'INV/2024/0452', invoiceDate: '2024-02-15', dueDate: '2024-03-15', billAmount: 85000, receivedAmount: 0, balanceAmount: 85000, daysOverdue: 28 },
];

export default DebtorInformationView;
