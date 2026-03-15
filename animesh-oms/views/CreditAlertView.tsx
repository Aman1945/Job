
import React, { useState, useMemo } from 'react';
import { ODMaster, Order, OrderStatus, User, AgingBuckets } from '../types';
import { 
  ShieldAlert, 
  Search, 
  MessageSquare, 
  Mail, 
  FileText, 
  ArrowRight, 
  CheckCircle2, 
  Clock, 
  AlertTriangle, 
  X, 
  Download,
  ExternalLink,
  Zap,
  TrendingDown,
  Info,
  Paperclip,
  ChevronDown,
  ChevronUp
} from 'lucide-react';
import { sendWhatsAppNotification, WHATSAPP_MESSAGES } from '../services/whatsappService';
import { sendEmailNotification, EMAIL_TEMPLATES } from '../services/emailService';

interface CreditAlertViewProps {
  odMaster: ODMaster[];
  orders: Order[];
  currentUser: User;
}

const CreditAlertView: React.FC<CreditAlertViewProps> = ({ odMaster, orders, currentUser }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedOD, setSelectedOD] = useState<ODMaster | null>(null);
  const [isSending, setIsSending] = useState(false);
  const [expandedRows, setExpandedRows] = useState<Set<string>>(new Set());

  const toggleRow = (id: string) => {
    const newSet = new Set(expandedRows);
    if (newSet.has(id)) newSet.delete(id);
    else newSet.add(id);
    setExpandedRows(newSet);
  };

  const filteredOD = useMemo(() => {
    return odMaster.filter(o => 
      o.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      o.customerId.toLowerCase().includes(searchTerm.toLowerCase())
    ).sort((a, b) => b.overdueAmt - a.overdueAmt);
  }, [odMaster, searchTerm]);

  const customerInvoices = useMemo(() => {
    if (!selectedOD) return [];
    return orders.filter(o => 
      o.customerId === selectedOD.customerId && 
      o.invoiceNo && 
      o.status !== OrderStatus.REJECTED
    );
  }, [selectedOD, orders]);

  const handleSendAlert = async (type: 'WHATSAPP' | 'MAIL') => {
    if (!selectedOD) return;
    setIsSending(true);
    
    try {
      if (type === 'WHATSAPP') {
        // replaced incompatible findLast with reverse().find() for cross-environment compatibility
        const message = WHATSAPP_MESSAGES.CUSTOMER_OVERDUE_ALERT(
          selectedOD.customerName, 
          selectedOD.overdueAmt,
          Object.entries(selectedOD.aging).reverse().find(([_, v]) => (v as number) > 0)?.[0] || 'Current'
        );
        await sendWhatsAppNotification({ name: selectedOD.customerName, whatsappNumber: '+910000000000' }, message);
      } else {
        const template = EMAIL_TEMPLATES.OVERDUE_NOTICE(
          selectedOD.customerName,
          selectedOD.overdueAmt,
          customerInvoices
        );
        await sendEmailNotification(
          { name: selectedOD.customerName, email: `finance@${selectedOD.customerId}.corp` },
          template.subject,
          template.body,
          template.attachments
        );
      }
    } catch (err) {
      console.error(err);
    } finally {
      setIsSending(false);
      setSelectedOD(null);
    }
  };

  const getAgingSeverity = (aging: AgingBuckets) => {
    if (aging['>180'] > 0 || aging['150 to 180'] > 0) return 'text-rose-600 bg-rose-50 border-rose-100';
    if (aging['90 to 120'] > 0 || aging['120 to 150'] > 0) return 'text-orange-600 bg-orange-50 border-orange-100';
    return 'text-amber-600 bg-amber-50 border-amber-100';
  };

  const agingBuckets: (keyof AgingBuckets)[] = [
    '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90', '90 to 120', '120 to 150', '150 to 180', '>180'
  ];

  return (
    <div className="max-w-[1600px] mx-auto space-y-8 animate-in fade-in duration-500 pb-24">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight flex items-center gap-3">
             <ShieldAlert className="text-rose-500" /> Credit Risk Terminal
          </h2>
          <p className="text-sm text-slate-500 font-medium">Monitor overdue balances and dispatch payment missions</p>
        </div>
        <div className="flex gap-4">
           <div className="bg-rose-50 border border-rose-100 px-6 py-3 rounded-2xl flex items-center gap-3">
              <TrendingDown className="text-rose-500" size={20} />
              <span className="text-[10px] font-black text-rose-700 uppercase tracking-widest">
                Total Overdue: ₹{odMaster.reduce((s, o) => s + o.overdueAmt, 0).toLocaleString()}
              </span>
           </div>
        </div>
      </div>

      <div className="relative max-w-md group">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-rose-500 transition-colors" size={18} />
        <input 
          type="text" 
          placeholder="Filter customer identity..." 
          className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
              <tr>
                <th className="px-8 py-6 w-12"></th>
                <th className="px-6 py-6">Customer Entity</th>
                <th className="px-6 py-6 text-center">Credit Terms</th>
                <th className="px-6 py-6 text-right">Limit</th>
                <th className="px-6 py-6 text-right">Outstanding</th>
                <th className="px-6 py-6 text-right text-rose-600 font-black">Overdue Total</th>
                <th className="px-8 py-6 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y text-sm font-bold text-slate-700">
              {filteredOD.map(od => (
                <React.Fragment key={od.customerId}>
                  <tr className="hover:bg-slate-50/50 transition-colors group">
                    <td className="px-8 py-6">
                       <button onClick={() => toggleRow(od.customerId)} className="p-2 bg-slate-50 rounded-xl text-slate-400 hover:text-rose-600 transition-all">
                          {expandedRows.has(od.customerId) ? <ChevronUp size={16}/> : <ChevronDown size={16}/>}
                       </button>
                    </td>
                    <td className="px-6 py-6">
                       <p className="text-slate-900 font-black">{od.customerName}</p>
                       <p className="text-[10px] text-slate-400 font-black uppercase mt-1">ID: {od.customerId} • {od.channel}</p>
                    </td>
                    <td className="px-6 py-6 text-center">
                       <span className="text-[10px] font-black text-indigo-600 bg-indigo-50 px-2 py-1 rounded-lg border border-indigo-100">{od.creditDays}</span>
                    </td>
                    <td className="px-6 py-6 text-right">₹{od.creditLimit.toLocaleString()}</td>
                    <td className="px-6 py-6 text-right">₹{od.outstandingAmt.toLocaleString()}</td>
                    <td className="px-6 py-6 text-right font-black text-rose-600">₹{od.overdueAmt.toLocaleString()}</td>
                    <td className="px-8 py-6 text-right">
                      <button 
                        onClick={() => setSelectedOD(od)}
                        className="bg-slate-900 text-white px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-rose-600 transition-all flex items-center gap-2 ml-auto active:scale-95"
                      >
                        <Zap size={14}/> Dispatch Notice
                      </button>
                    </td>
                  </tr>
                  
                  {/* Expanded Row for Aging Breakdown */}
                  {expandedRows.has(od.customerId) && (
                    <tr className="bg-slate-50/50 border-y-2 border-slate-100">
                       <td colSpan={7} className="px-12 py-6 animate-in slide-in-from-top-2 duration-300">
                          <div className="flex items-center gap-4 overflow-x-auto no-scrollbar pb-2">
                             <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm shrink-0 min-w-[120px]">
                                <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest mb-1">Status</p>
                                <span className={`inline-block px-2 py-0.5 rounded text-[9px] font-black uppercase border ${getAgingSeverity(od.aging)}`}>
                                  {/* replaced incompatible findLast with reverse().find() for compatibility */}
                                  {Object.entries(od.aging).reverse().find(([_, v]) => (v as number) > 0)?.[0] || 'Clean'}
                                </span>
                             </div>
                             {agingBuckets.map(bucket => (
                               <div key={bucket} className={`bg-white p-4 rounded-2xl border shadow-sm shrink-0 min-w-[140px] transition-all ${od.aging[bucket] > 0 ? 'border-rose-100 ring-4 ring-rose-500/5' : 'border-slate-100 opacity-60'}`}>
                                  <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest mb-1">{bucket} Days</p>
                                  <p className={`text-sm font-black ${od.aging[bucket] > 0 ? 'text-rose-600' : 'text-slate-300'}`}>
                                    ₹{od.aging[bucket].toLocaleString()}
                                  </p>
                               </div>
                             ))}
                          </div>
                       </td>
                    </tr>
                  )}
                </React.Fragment>
              ))}
              {filteredOD.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-8 py-32 text-center text-slate-300 font-bold uppercase tracking-widest italic">
                    No customer credit records matching search criteria.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Alert Dispatch Modal */}
      {selectedOD && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-slate-900/80 backdrop-blur-sm">
           <div className="bg-white w-full max-w-2xl rounded-[44px] p-10 shadow-2xl relative animate-in zoom-in-95">
              <button onClick={() => setSelectedOD(null)} className="absolute top-8 right-8 p-2 text-slate-400 hover:text-rose-500 transition-all"><X size={24}/></button>
              
              <div className="flex items-center gap-6 mb-10 border-b border-slate-100 pb-8">
                 <div className="w-16 h-16 bg-rose-50 text-rose-600 rounded-3xl flex items-center justify-center">
                    <ShieldAlert size={32} />
                 </div>
                 <div>
                    <h3 className="text-2xl font-black text-slate-900 tracking-tight">{selectedOD.customerName}</h3>
                    <p className="text-xs font-bold text-rose-500 uppercase tracking-widest mt-1">Total Overdue Claim: ₹{selectedOD.overdueAmt.toLocaleString()}</p>
                 </div>
              </div>

              <div className="space-y-8">
                 {/* Detailed Aging Breakdown in Modal */}
                 <div className="space-y-4">
                    <h4 className="text-[10px] font-black uppercase tracking-widest text-slate-400 flex items-center gap-2">
                       <Clock size={14} className="text-rose-500" /> Aging Exposure Profile
                    </h4>
                    <div className="grid grid-cols-3 gap-3">
                       {agingBuckets.map(bucket => (
                         /* fixed 'od' vs 'selectedOD' reference to avoid undefined error */
                         <div key={bucket} className={`p-3 rounded-xl border text-center ${selectedOD.aging[bucket] > 0 ? 'bg-rose-50 border-rose-100' : 'bg-slate-50 border-slate-100 opacity-40'}`}>
                            <p className="text-[8px] font-black text-slate-400 uppercase">{bucket}</p>
                            {/* fixed 'od' vs 'selectedOD' reference to avoid undefined error */}
                            <p className="text-[10px] font-black text-slate-900">₹{selectedOD.aging[bucket].toLocaleString()}</p>
                         </div>
                       ))}
                    </div>
                 </div>

                 <div className="bg-slate-50 p-6 rounded-3xl border border-slate-100 space-y-4">
                    <h4 className="text-[10px] font-black uppercase tracking-widest text-slate-400 flex items-center gap-2">
                       <FileText size={14} className="text-indigo-600" /> Linked Invoice Evidence ({customerInvoices.length})
                    </h4>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 max-h-40 overflow-y-auto pr-2 no-scrollbar">
                       {customerInvoices.map(inv => (
                         <div key={inv.id} className="bg-white p-3 rounded-xl border border-slate-200 flex items-center justify-between">
                            <span className="text-[10px] font-black text-indigo-600">{inv.invoiceNo}</span>
                            <span className="text-[10px] font-bold text-slate-400">₹{inv.items.reduce((s,i)=>s+(i.price*(i.packedQuantity||i.quantity)),0).toLocaleString()}</span>
                         </div>
                       ))}
                    </div>
                 </div>

                 <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <button 
                      onClick={() => handleSendAlert('WHATSAPP')}
                      disabled={isSending}
                      className="flex items-center justify-center gap-3 bg-[#25D366] text-white py-5 rounded-3xl font-black text-xs uppercase tracking-widest shadow-xl shadow-emerald-500/20 hover:bg-emerald-500 active:scale-95 transition-all disabled:opacity-50"
                    >
                       <MessageSquare size={18}/> WhatsApp Alert
                    </button>
                    <button 
                      onClick={() => handleSendAlert('MAIL')}
                      disabled={isSending}
                      className="flex items-center justify-center gap-3 bg-indigo-600 text-white py-5 rounded-3xl font-black text-xs uppercase tracking-widest shadow-xl shadow-indigo-600/20 hover:bg-indigo-700 active:scale-95 transition-all disabled:opacity-50"
                    >
                       <Mail size={18}/> Email Protocol
                    </button>
                 </div>

                 <div className="flex items-start gap-3 p-5 bg-amber-50 rounded-2xl border border-amber-100">
                    <div className="mt-0.5"><Info size={18} className="text-amber-600 shrink-0" /></div>
                    <p className="text-[10px] text-amber-700 leading-relaxed font-medium">
                       Dispatching alerts will include an automated summary of overdue aging buckets and PDF copies of all open invoices as attachments.
                    </p>
                 </div>
              </div>
           </div>
        </div>
      )}
    </div>
  );
};

export default CreditAlertView;
