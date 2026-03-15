
import React, { useState, useRef, useMemo } from 'react';
import { User, UserRole, ConsumablePurchase } from '../types';
import { 
  ShoppingCart, 
  Plus, 
  History, 
  FileText, 
  CheckCircle2, 
  XCircle, 
  Upload, 
  Download, 
  Clock, 
  DollarSign, 
  Package, 
  ShieldCheck,
  User as UserIcon,
  Search,
  ChevronRight,
  Filter,
  ArrowRight,
  Calendar
} from 'lucide-react';
import { sendWhatsAppNotification, WHATSAPP_MESSAGES } from '../services/whatsappService';

interface ConsumablePurchaseViewProps {
  currentUser: User;
  purchases: ConsumablePurchase[];
  onUpdatePurchases: (purchases: ConsumablePurchase[]) => void;
}

const ConsumablePurchaseView: React.FC<ConsumablePurchaseViewProps> = ({ currentUser, purchases, onUpdatePurchases }) => {
  const [activeTab, setActiveTab] = useState<'Raise' | 'History' | 'Approvals'>('History');
  const [searchTerm, setSearchTerm] = useState('');
  const piFileRef = useRef<HTMLInputElement>(null);

  // Form state
  const [form, setForm] = useState({
    itemName: '',
    purpose: '',
    qty: 0,
    ratePerPcs: 0,
    durationDays: '',
    vendor: '',
    piAttachment: '',
    piFileName: ''
  });

  const totalValue = form.qty * form.ratePerPcs;

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setForm(prev => ({ ...prev, piAttachment: reader.result as string, piFileName: file.name }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRaiseRequest = async () => {
    if (!form.itemName || !form.qty || !form.ratePerPcs || !form.vendor) {
      alert("All fields are mandatory.");
      return;
    }

    const newPurchase: ConsumablePurchase = {
      id: 'CP-' + Math.floor(Math.random() * 90000 + 10000),
      requesterId: currentUser.id,
      requesterName: currentUser.name,
      itemName: form.itemName,
      purpose: form.purpose,
      qty: form.qty,
      ratePerPcs: form.ratePerPcs,
      durationDays: form.durationDays,
      totalValue: totalValue,
      vendor: form.vendor,
      piAttachment: form.piAttachment || undefined,
      piFileName: form.piFileName || undefined,
      status: 'Pending Approval',
      createdAt: new Date().toISOString()
    };

    onUpdatePurchases([newPurchase, ...purchases]);
    
    // ARRANGE WHATSAPP NOTIFICATION
    await sendWhatsAppNotification(
      currentUser, 
      WHATSAPP_MESSAGES.CONSUMABLE_RAISED(newPurchase.id, newPurchase.itemName, newPurchase.qty)
    );

    setForm({ itemName: '', purpose: '', qty: 0, ratePerPcs: 0, durationDays: '', vendor: '', piAttachment: '', piFileName: '' });
    setActiveTab('History');
  };

  const handleApproval = async (id: string, approved: boolean) => {
    const targetPurchase = purchases.find(p => p.id === id);
    if (!targetPurchase) return;

    const updated = purchases.map(p => {
      if (p.id === id) {
        return {
          ...p,
          status: (approved ? 'Approved' : 'Rejected') as any,
          approvedBy: currentUser.name
        };
      }
      return p;
    });
    onUpdatePurchases(updated);

    // ARRANGE WHATSAPP NOTIFICATION TO REQUESTER (Dhiraj)
    if (targetPurchase.requesterId.includes('dhiraj')) {
      const dhirajMock = { id: 'dhiraj@bigsams.in', name: 'Dhiraj', whatsappNumber: '+919123456789' } as User;
      const message = approved 
        ? WHATSAPP_MESSAGES.CONSUMABLE_APPROVED(id, currentUser.name)
        : WHATSAPP_MESSAGES.CONSUMABLE_REJECTED(id, currentUser.name);
      
      await sendWhatsAppNotification(dhirajMock, message);
    }
  };

  const isAdmin = currentUser.role === UserRole.ADMIN;
  const isDhiraj = currentUser.name.toLowerCase() === 'dhiraj';

  const filteredHistory = purchases.filter(p => 
    p.itemName.toLowerCase().includes(searchTerm.toLowerCase()) || 
    p.vendor.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.id.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Grouping logic for history
  const groupedHistory = useMemo(() => {
    const groups: Record<string, { items: ConsumablePurchase[], total: number }> = {};
    
    filteredHistory.forEach(p => {
      const date = new Date(p.createdAt);
      const monthYear = date.toLocaleString('default', { month: 'long', year: 'numeric' });
      
      if (!groups[monthYear]) {
        groups[monthYear] = { items: [], total: 0 };
      }
      groups[monthYear].items.push(p);
      groups[monthYear].total += p.totalValue;
    });

    // Convert to sorted array
    return Object.entries(groups).sort((a, b) => {
      // Sort by date descending (latest month first)
      return new Date(b[1].items[0].createdAt).getTime() - new Date(a[1].items[0].createdAt).getTime();
    });
  }, [filteredHistory]);

  const pendingApprovals = purchases.filter(p => p.status === 'Pending Approval');

  const downloadFile = (dataUri: string, fileName: string) => {
    const link = document.createElement('a');
    link.href = dataUri;
    link.download = fileName;
    link.click();
  };

  return (
    <div className="max-w-[1400px] mx-auto space-y-8 animate-in fade-in duration-500 pb-24">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight flex items-center gap-3">
             <ShoppingCart className="text-indigo-600" /> Kurla Consumable Hub
          </h2>
          <p className="text-sm text-slate-500 font-medium">Manage and audit consumable purchase requisitions</p>
        </div>
        <div className="flex bg-slate-200 p-1 rounded-2xl border border-slate-300 shadow-inner overflow-x-auto no-scrollbar">
           {(isAdmin || isDhiraj) && <button onClick={() => setActiveTab('Raise')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeTab === 'Raise' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>Raise Request</button>}
           <button onClick={() => setActiveTab('History')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeTab === 'History' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>Purchase History</button>
           {isAdmin && <button onClick={() => setActiveTab('Approvals')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeTab === 'Approvals' ? 'bg-white shadow-md text-rose-600' : 'text-slate-500'}`}>Approvals ({pendingApprovals.length})</button>}
        </div>
      </div>

      {activeTab === 'Raise' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-10 animate-in slide-in-from-bottom-6">
           <div className="lg:col-span-2 space-y-8">
              <div className="bg-white rounded-[44px] border border-slate-200 p-10 shadow-sm space-y-10">
                 <div className="flex items-center justify-between border-b pb-8">
                    <h3 className="text-2xl font-black tracking-tight flex items-center gap-3">
                       <Plus className="text-indigo-600" /> New Consumable Requisition
                    </h3>
                    <div className="bg-indigo-50 border border-indigo-100 px-6 py-3 rounded-2xl">
                       <p className="text-[10px] font-black text-indigo-600 uppercase tracking-widest text-center">ARRANGEMENT: WHATSAPP ACTIVE</p>
                    </div>
                 </div>

                 <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <FormInput label="Item Name" value={form.itemName} onChange={v => setForm({...form, itemName: v})} placeholder="e.g. Sanitizer, Thermacol, etc." />
                    <FormInput label="Purpose" value={form.purpose} onChange={v => setForm({...form, purpose: v})} placeholder="Why is this needed?" />
                    <FormInput label="Quantity (Pcs/Units)" type="number" value={form.qty} onChange={v => setForm({...form, qty: parseFloat(v) || 0})} />
                    <FormInput label="Rate Per Pcs (₹)" type="number" value={form.ratePerPcs} onChange={v => setForm({...form, ratePerPcs: parseFloat(v) || 0})} />
                    <FormInput label="For how many days?" value={form.durationDays} onChange={v => setForm({...form, durationDays: v})} placeholder="Expected usage period" />
                    <FormInput label="Vendor Selection" value={form.vendor} onChange={v => setForm({...form, vendor: v})} placeholder="Supplier name" />
                 </div>

                 <div className="pt-10 border-t flex flex-col md:flex-row justify-between items-center gap-8">
                    <div className="flex-1 w-full space-y-4">
                       <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Proforma Invoice (PI) Copy</label>
                       <div 
                         onClick={() => piFileRef.current?.click()}
                         className={`aspect-[4/1] rounded-[24px] border-4 border-dashed transition-all flex flex-col items-center justify-center gap-2 cursor-pointer overflow-hidden ${form.piAttachment ? 'border-emerald-500 bg-white' : 'border-slate-100 bg-slate-50 hover:bg-indigo-50'}`}
                       >
                          {form.piAttachment ? (
                            <><CheckCircle2 className="text-emerald-500" /><p className="text-[10px] font-black uppercase text-emerald-600">Document Locked: {form.piFileName}</p></>
                          ) : (
                            <><Upload className="text-slate-300"/><p className="text-[10px] font-black uppercase text-slate-400">Click to upload PI copy</p></>
                          )}
                          <input type="file" ref={piFileRef} className="hidden" accept="image/*,.pdf" onChange={handleFileChange} />
                       </div>
                    </div>
                    <div className="text-right shrink-0">
                       <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Calculated Requisition Total</p>
                       <p className="text-5xl font-black text-slate-900 tracking-tighter">₹{totalValue.toLocaleString()}</p>
                    </div>
                 </div>

                 <button 
                   onClick={handleRaiseRequest}
                   className="w-full bg-slate-900 text-white py-6 rounded-[28px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-600 transition-all active:scale-95 flex items-center justify-center gap-3"
                 >
                    Commit Requisition <ArrowRight size={18} />
                 </button>
              </div>
           </div>

           <div className="space-y-6">
              <div className="bg-indigo-950 rounded-[44px] p-10 text-white shadow-2xl border border-indigo-900 space-y-8">
                 <h4 className="text-xl font-black flex items-center gap-3 text-emerald-400"><ShieldCheck /> Notification Logic</h4>
                 <div className="space-y-6">
                    <p className="text-sm text-indigo-200/80 leading-relaxed font-medium italic">"Arrangement configured: A secure WhatsApp confirmation is sent to Dhiraj upon submission and when Animesh updates the mission status."</p>
                    <div className="p-6 bg-white/5 rounded-3xl border border-white/5 space-y-4">
                       <div className="flex justify-between items-center"><span className="text-[10px] font-black uppercase text-slate-500">Alert Type</span><span className="text-sm font-black text-white">WhatsApp Mobile</span></div>
                       <div className="flex justify-between items-center"><span className="text-[10px] font-black uppercase text-slate-500">Security</span><span className="text-sm font-black text-emerald-400">Encrypted</span></div>
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}

      {activeTab === 'History' && (
        <div className="space-y-10 animate-in fade-in duration-500">
           <div className="relative max-w-md group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-indigo-600 transition-colors" size={18} />
              <input type="text" placeholder="Search item, vendor or PO ref..." className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium focus:ring-4 focus:ring-indigo-500/10 outline-none transition-all shadow-sm" value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
           </div>

           {groupedHistory.map(([month, group]) => (
             <div key={month} className="space-y-4 animate-in slide-in-from-left-2">
                <div className="flex items-center justify-between px-6">
                   <div className="flex items-center gap-3">
                      <div className="w-1.5 h-6 bg-indigo-600 rounded-full" />
                      <h3 className="text-xl font-black text-slate-900 tracking-tight uppercase">{month}</h3>
                   </div>
                   <div className="bg-white border border-slate-200 px-6 py-2 rounded-2xl shadow-sm">
                      <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Monthly Aggregate</p>
                      <p className="text-lg font-black text-indigo-600">₹{group.total.toLocaleString()}</p>
                   </div>
                </div>

                <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
                   <div className="overflow-x-auto">
                      <table className="w-full text-left">
                         <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                            <tr>
                               <th className="px-8 py-6">Date & Mission Ref</th>
                               <th className="px-6 py-6">Consumable Detail</th>
                               <th className="px-6 py-6">Vendor & Duration</th>
                               <th className="px-6 py-6 text-center">Status</th>
                               <th className="px-6 py-6 text-center">PI Doc</th>
                               <th className="px-8 py-6 text-right">Line Total</th>
                            </tr>
                         </thead>
                         <tbody className="divide-y text-sm font-bold text-slate-700">
                            {group.items.map(p => (
                              <tr key={p.id} className="hover:bg-slate-50 transition-colors">
                                 <td className="px-8 py-6">
                                    <div className="flex flex-col">
                                       <span className="font-black text-slate-900">{new Date(p.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}</span>
                                       <span className="font-mono font-black text-indigo-600 uppercase text-[10px] mt-1 tracking-wider">{p.id}</span>
                                    </div>
                                 </td>
                                 <td className="px-6 py-6">
                                    <p className="text-slate-900 font-black">{p.itemName}</p>
                                    <p className="text-[10px] text-slate-400 font-bold uppercase mt-1">QTY: {p.qty} | Purpose: {p.purpose}</p>
                                 </td>
                                 <td className="px-6 py-6">
                                    <p className="text-slate-700">{p.vendor}</p>
                                    <p className="text-[10px] text-indigo-500 font-black uppercase mt-1">{p.durationDays || 'Standard Duration'}</p>
                                 </td>
                                 <td className="px-6 py-6 text-center">
                                    <span className={`inline-block px-3 py-1 rounded-lg text-[9px] font-black uppercase border ${
                                      p.status === 'Approved' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 
                                      p.status === 'Rejected' ? 'bg-rose-50 text-rose-600 border-rose-100' :
                                      'bg-amber-50 text-amber-600 border-amber-100'
                                    }`}>
                                      {p.status}
                                    </span>
                                 </td>
                                 <td className="px-6 py-6 text-center">
                                    {p.piAttachment ? (
                                      <button onClick={() => downloadFile(p.piAttachment!, p.piFileName || 'PI_COPY.png')} className="p-2.5 bg-indigo-50 text-indigo-600 rounded-xl hover:bg-indigo-600 hover:text-white transition-all">
                                         <FileText size={16}/>
                                      </button>
                                    ) : '-'}
                                 </td>
                                 <td className="px-8 py-6 text-right font-black text-slate-900">₹{p.totalValue.toLocaleString()}</td>
                              </tr>
                            ))}
                         </tbody>
                      </table>
                   </div>
                </div>
             </div>
           ))}

           {groupedHistory.length === 0 && (
              <div className="bg-white rounded-[40px] border border-slate-200 p-24 text-center">
                 <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6 text-slate-200">
                    <History size={48} />
                 </div>
                 <p className="text-[10px] font-black text-slate-300 uppercase italic">No purchase history found.</p>
              </div>
           )}
        </div>
      )}

      {activeTab === 'Approvals' && isAdmin && (
        <div className="space-y-6 animate-in slide-in-from-top-6">
           {pendingApprovals.map(p => (
             <div key={p.id} className="bg-white rounded-[40px] border border-slate-200 p-10 shadow-sm flex flex-col md:flex-row items-center justify-between gap-10 group hover:border-rose-200 transition-all">
                <div className="flex items-center gap-8">
                   <div className="w-16 h-16 bg-amber-50 text-amber-600 rounded-3xl flex items-center justify-center group-hover:bg-rose-50 group-hover:text-rose-600 transition-colors">
                      <Clock size={32} />
                   </div>
                   <div>
                      <div className="flex items-center gap-3 mb-1">
                         <span className="font-mono font-black text-indigo-600">{p.id}</span>
                         <span className="bg-slate-100 text-slate-500 px-2 py-0.5 rounded text-[8px] font-black uppercase">Pending Approval</span>
                      </div>
                      <h4 className="text-2xl font-black text-slate-900">{p.itemName}</h4>
                      <p className="text-xs font-bold text-slate-400 mt-1 uppercase tracking-widest">Raised by <span className="text-slate-900">{p.requesterName}</span> for <span className="text-slate-900">{p.vendor}</span></p>
                   </div>
                </div>

                <div className="flex flex-col items-center gap-2">
                   <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Requisition Value</p>
                   <p className="text-3xl font-black text-slate-900 tracking-tighter">₹{p.totalValue.toLocaleString()}</p>
                </div>

                <div className="flex gap-4 w-full md:w-auto">
                   {p.piAttachment && (
                      <button onClick={() => downloadFile(p.piAttachment!, p.piFileName || 'PI.png')} className="px-6 py-4 bg-slate-100 text-slate-600 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-slate-200 transition-all flex items-center gap-2">
                         <FileText size={16}/> View PI
                      </button>
                   )}
                   <button onClick={() => handleApproval(p.id, false)} className="px-6 py-4 bg-rose-50 text-rose-600 border border-rose-100 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-rose-600 hover:text-white transition-all flex items-center gap-2">
                      <XCircle size={16}/> Reject
                   </button>
                   <button onClick={() => handleApproval(p.id, true)} className="px-10 py-4 bg-emerald-600 text-white rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-emerald-50 transition-all flex items-center gap-2 shadow-xl shadow-emerald-500/20">
                      <CheckCircle2 size={16}/> Approve PO
                   </button>
                </div>
             </div>
           ))}
           {pendingApprovals.length === 0 && (
              <div className="py-32 text-center bg-white rounded-[40px] border-2 border-dashed border-slate-200">
                 <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6 text-slate-200">
                    <ShieldCheck size={48} />
                 </div>
                 <h4 className="text-xl font-black text-slate-900 uppercase">Approvals Clear</h4>
                 <p className="text-sm text-slate-400 font-medium mt-1">All consumable PO missions are either approved or rejected.</p>
              </div>
           )}
        </div>
      )}
    </div>
  );
};

const FormInput = ({ label, value, onChange, placeholder, type = 'text' }: any) => (
  <div className="space-y-2">
     <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">{label}</label>
     <input 
        type={type} 
        className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-indigo-600 outline-none transition-all shadow-inner"
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
     />
  </div>
);

export default ConsumablePurchaseView;
