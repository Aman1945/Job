
import React, { useState, useMemo, useRef } from 'react';
import { Customer, Product, RTVReturn, RTVItem, User, UserRole, Order } from '../types';
import { 
  RotateCcw, 
  Plus, 
  Search, 
  FileText, 
  Camera, 
  Upload, 
  CheckCircle2, 
  XCircle, 
  AlertTriangle,
  History,
  DollarSign,
  Package,
  Calendar,
  UserCircle,
  ShieldCheck,
  ChevronRight,
  ChevronLeft,
  X,
  Trash2,
  Image as ImageIcon,
  // Added missing ArrowRight import
  ArrowRight
} from 'lucide-react';

interface RTVViewProps {
  customers: Customer[];
  products: Product[];
  orders: Order[];
  returns: RTVReturn[];
  currentUser: User;
  onUpdateReturns: (returns: RTVReturn[]) => void;
}

const RTVView: React.FC<RTVViewProps> = ({ customers, products, orders, returns, currentUser, onUpdateReturns }) => {
  const [activeTab, setActiveTab] = useState<'Registry' | 'Log_Entry' | 'QC_Inspection'>('Registry');
  const [selectedRTVId, setSelectedRTVId] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Create Form State
  const [newRTV, setNewRTV] = useState<Partial<RTVReturn>>({
    customerId: '',
    dnNumber: '',
    receiptDate: new Date().toISOString().split('T')[0],
    receiptPhotos: [],
    items: []
  });

  const dnFileRef = useRef<HTMLInputElement>(null);
  const receiptPhotoRef = useRef<HTMLInputElement>(null);
  const itemPhotoRef = useRef<HTMLInputElement>(null);
  const [activeItemIdx, setActiveItemIdx] = useState<number | null>(null);

  // Helper: Automatic Valuation Lookup
  const getHistoricalRate = (custId: string, skuCode: string, batchNo: string): number => {
    // Search through order history to find exact customer/sku/batch match
    const pastOrder = orders.find(o => 
      o.customerId === custId && 
      o.items.some(i => (i.skuCode === skuCode || i.productId === skuCode) && i.batches?.some(b => b.batch === batchNo))
    );
    
    if (pastOrder) {
      const item = pastOrder.items.find(i => i.skuCode === skuCode || i.productId === skuCode);
      return item?.price || 0;
    }

    // Fallback to current base rate if no history found
    const product = products.find(p => p.skuCode === skuCode || p.id === skuCode);
    return product?.baseRate || 0;
  };

  const handleCreateRTV = () => {
    if (!newRTV.customerId || !newRTV.dnNumber || (newRTV.items || []).length === 0) {
      alert("Please ensure Customer, DN Number, and at least one SKU are defined.");
      return;
    }

    const customer = customers.find(c => c.id === newRTV.customerId);
    const rtv: RTVReturn = {
      id: 'RTV-' + Math.floor(Math.random() * 90000 + 10000),
      customerId: newRTV.customerId!,
      customerName: customer?.name || 'Unknown',
      dnNumber: newRTV.dnNumber!,
      dnAttachment: (newRTV as any).dnAttachment,
      receiptDate: newRTV.receiptDate!,
      receiptPhotos: newRTV.receiptPhotos || [],
      items: (newRTV.items || []).map(item => ({
        ...item,
        isExpired: false, // Default
        condition: 'Usable',
        receivedQuantity: 0, // Set by QC later
        lineValuation: 0
      })),
      status: 'QC_Pending',
      createdAt: new Date().toISOString(),
      totalValuation: 0
    };

    onUpdateReturns([rtv, ...returns]);
    setActiveTab('Registry');
    setNewRTV({ customerId: '', dnNumber: '', receiptDate: new Date().toISOString().split('T')[0], items: [] });
  };

  const handleQCSubmit = (id: string) => {
    const target = returns.find(r => r.id === id);
    if (!target) return;

    const updated = returns.map(r => {
      if (r.id === id) {
        const totalVal = r.items.reduce((sum, item) => sum + (item.receivedQuantity * item.unitPrice), 0);
        return { 
          ...r, 
          status: 'Completed' as const, 
          totalValuation: totalVal, 
          inspectedBy: currentUser.name, 
          inspectionDate: new Date().toISOString() 
        };
      }
      return r;
    });

    onUpdateReturns(updated);
    setSelectedRTVId(null);
  };

  const addItemToNewRTV = () => {
    setNewRTV({
      ...newRTV,
      items: [
        ...(newRTV.items || []),
        { productId: '', skuCode: '', productName: '', batchNo: '', dnQuantity: 0, receivedQuantity: 0, condition: 'Usable', isExpired: false, unitPrice: 0, lineValuation: 0 }
      ]
    });
  };

  const updateNewRTVItem = (idx: number, field: keyof RTVItem, value: any) => {
    const items = [...(newRTV.items || [])];
    items[idx] = { ...items[idx], [field]: value };
    
    // Auto-update price if Batch or SKU changes
    if (field === 'productId' || field === 'batchNo') {
      const prod = products.find(p => p.id === items[idx].productId);
      if (prod) {
        items[idx].skuCode = prod.skuCode;
        items[idx].productName = prod.name;
        if (items[idx].batchNo && newRTV.customerId) {
          items[idx].unitPrice = getHistoricalRate(newRTV.customerId, prod.skuCode, items[idx].batchNo);
        }
      }
    }
    
    setNewRTV({ ...newRTV, items });
  };

  const filteredRegistry = useMemo(() => {
    return returns.filter(r => 
      r.id.toLowerCase().includes(searchTerm.toLowerCase()) || 
      r.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      r.dnNumber.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }, [returns, searchTerm]);

  return (
    <div className="max-w-7xl mx-auto space-y-8 pb-24 animate-in fade-in duration-500">
      
      {/* Header & Tabs */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight flex items-center gap-3">
             <RotateCcw className="text-rose-500" /> RTV Protocol Hub
          </h2>
          <p className="text-sm text-slate-500 font-medium">Manage Customer Returns, Debit Notes & Quality Verification</p>
        </div>
        <div className="flex bg-slate-200 p-1 rounded-2xl border border-slate-300 shadow-inner">
           <button onClick={() => {setActiveTab('Registry'); setSelectedRTVId(null);}} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeTab === 'Registry' ? 'bg-white shadow-md text-rose-600' : 'text-slate-500'}`}>History Registry</button>
           <button onClick={() => setActiveTab('Log_Entry')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeTab === 'Log_Entry' ? 'bg-white shadow-md text-rose-600' : 'text-slate-500'}`}>Receipt Entry</button>
        </div>
      </div>

      {activeTab === 'Registry' && (
        <div className="space-y-6 animate-in slide-in-from-left-4">
           <div className="relative max-w-md group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-rose-600 transition-colors" size={18} />
              <input 
                type="text" 
                placeholder="Search RTV Ref, Client or DN..." 
                className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-rose-500/10 outline-none transition-all"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
           </div>

           <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
              <div className="overflow-x-auto">
                 <table className="w-full text-left">
                    <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                       <tr>
                          <th className="px-8 py-6">RTV Ref</th>
                          <th className="px-6 py-6">Customer Entity</th>
                          <th className="px-6 py-6 text-center">Debit Note</th>
                          <th className="px-6 py-6 text-center">Receipt Date</th>
                          <th className="px-6 py-6 text-center">Status</th>
                          <th className="px-6 py-6 text-right">Settlement Value</th>
                          <th className="px-8 py-6 text-right">Ops</th>
                       </tr>
                    </thead>
                    <tbody className="divide-y text-sm font-bold text-slate-700">
                       {filteredRegistry.map(rtv => (
                         <tr key={rtv.id} className="hover:bg-slate-50/50 transition-colors group">
                            <td className="px-8 py-6">
                               <p className="font-mono font-black text-rose-600 uppercase">{rtv.id}</p>
                               <p className="text-[9px] text-slate-400 font-bold uppercase mt-1">{rtv.items.length} SKUs Detected</p>
                            </td>
                            <td className="px-6 py-6 font-black text-slate-900">{rtv.customerName}</td>
                            <td className="px-6 py-6 text-center">
                               <span className="text-[10px] font-black text-indigo-600 bg-indigo-50 px-2 py-1 rounded-lg border border-indigo-100">#{rtv.dnNumber}</span>
                            </td>
                            <td className="px-6 py-6 text-center text-slate-400">{rtv.receiptDate}</td>
                            <td className="px-6 py-6 text-center">
                               <span className={`inline-block px-3 py-1 rounded-lg text-[9px] font-black uppercase border ${
                                 rtv.status === 'Completed' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 
                                 rtv.status === 'QC_Pending' ? 'bg-amber-50 text-amber-600 border-amber-100 animate-pulse' :
                                 'bg-slate-100 text-slate-500 border-slate-200'
                               }`}>
                                 {rtv.status}
                               </span>
                            </td>
                            <td className="px-6 py-6 text-right font-black text-slate-900">₹{rtv.totalValuation.toLocaleString()}</td>
                            <td className="px-8 py-6 text-right">
                               <button 
                                 onClick={() => {setSelectedRTVId(rtv.id); setActiveTab('QC_Inspection');}} 
                                 className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${rtv.status === 'QC_Pending' ? 'bg-rose-600 text-white shadow-lg hover:bg-rose-700' : 'bg-slate-100 text-slate-400'}`}
                               >
                                 {rtv.status === 'QC_Pending' ? 'Audit Now' : 'View Audit'}
                               </button>
                            </td>
                         </tr>
                       ))}
                       {filteredRegistry.length === 0 && (
                         <tr><td colSpan={7} className="px-8 py-32 text-center text-slate-300 font-black uppercase italic tracking-widest">No RTV missions in log.</td></tr>
                       )}
                    </tbody>
                 </table>
              </div>
           </div>
        </div>
      )}

      {activeTab === 'Log_Entry' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-10 animate-in slide-in-from-bottom-6">
           <div className="lg:col-span-2 space-y-8">
              <div className="bg-white rounded-[44px] border border-slate-200 p-10 shadow-sm space-y-10">
                 <div className="flex items-center justify-between border-b pb-8">
                    <h3 className="text-2xl font-black tracking-tight flex items-center gap-3">
                       <Plus className="text-rose-600" /> New Return Receipt Log
                    </h3>
                    <div className="text-right">
                       <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Receipt Identity</p>
                       <input type="date" value={newRTV.receiptDate} className="font-black text-slate-900 border-b border-rose-200 outline-none" onChange={e => setNewRTV({...newRTV, receiptDate: e.target.value})} />
                    </div>
                 </div>

                 <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <div className="space-y-2">
                       <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Customer Selection</label>
                       <select 
                         className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold outline-none focus:border-rose-600 transition-all appearance-none"
                         value={newRTV.customerId}
                         onChange={e => setNewRTV({...newRTV, customerId: e.target.value})}
                       >
                          <option value="">Select Target Client...</option>
                          {customers.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                       </select>
                    </div>
                    <div className="space-y-2">
                       <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Customer Debit Note #</label>
                       <input 
                         type="text" 
                         className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-rose-600 outline-none" 
                         value={newRTV.dnNumber}
                         onChange={e => setNewRTV({...newRTV, dnNumber: e.target.value})}
                         placeholder="e.g. DN/2024/001"
                       />
                    </div>
                 </div>

                 {/* SKU Line Items Area */}
                 <div className="space-y-6 pt-6 border-t border-slate-100">
                    <div className="flex items-center justify-between">
                       <h4 className="text-xs font-black text-slate-400 uppercase tracking-widest flex items-center gap-2"><Package size={14}/> Claimed Item List (Per DN)</h4>
                       <button onClick={addItemToNewRTV} className="bg-slate-900 text-white px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-rose-600 transition-all flex items-center gap-2">
                          <Plus size={14}/> Add SKU
                       </button>
                    </div>

                    <div className="space-y-4">
                       {(newRTV.items || []).map((item, idx) => (
                         <div key={idx} className="bg-slate-50 p-6 rounded-3xl border border-slate-100 grid grid-cols-1 md:grid-cols-4 gap-4 items-end animate-in zoom-in-95 group">
                            <div className="md:col-span-1 space-y-1">
                               <label className="text-[8px] font-black text-slate-400 uppercase">SKU Identity</label>
                               <select className="w-full bg-white border border-slate-200 rounded-xl px-3 py-2 text-xs font-bold" value={item.productId} onChange={e => updateNewRTVItem(idx, 'productId', e.target.value)}>
                                  <option value="">Select SKU...</option>
                                  {products.map(p => <option key={p.id} value={p.id}>{p.skuCode} - {p.name}</option>)}
                               </select>
                            </div>
                            <div className="space-y-1">
                               <label className="text-[8px] font-black text-slate-400 uppercase">Batch #</label>
                               <input type="text" className="w-full bg-white border border-slate-200 rounded-xl px-3 py-2 text-xs font-black uppercase" placeholder="BATCH" value={item.batchNo} onChange={e => updateNewRTVItem(idx, 'batchNo', e.target.value)} />
                            </div>
                            <div className="space-y-1">
                               <label className="text-[8px] font-black text-slate-400 uppercase">DN Quantity</label>
                               <input type="number" className="w-full bg-white border border-slate-200 rounded-xl px-3 py-2 text-xs font-black" placeholder="0" value={item.dnQuantity || ''} onChange={e => updateNewRTVItem(idx, 'dnQuantity', parseFloat(e.target.value) || 0)} />
                            </div>
                            <div className="flex items-center gap-2">
                               <div className="flex-1 space-y-1">
                                  <label className="text-[8px] font-black text-slate-400 uppercase">Hist. Rate</label>
                                  <div className="w-full bg-slate-100 border border-slate-200 rounded-xl px-3 py-2 text-xs font-black text-rose-600">₹{item.unitPrice}</div>
                               </div>
                               <button onClick={() => setNewRTV({...newRTV, items: newRTV.items?.filter((_, i) => i !== idx)})} className="p-2 text-slate-300 hover:text-rose-500 opacity-0 group-hover:opacity-100 transition-all"><Trash2 size={16}/></button>
                            </div>
                         </div>
                       ))}
                       {(newRTV.items || []).length === 0 && (
                          <div className="py-20 text-center border-2 border-dashed border-slate-100 rounded-[40px] text-slate-300 font-black uppercase text-[10px] italic">No items added to receipt log.</div>
                       )}
                    </div>
                 </div>

                 <div className="pt-10 border-t border-slate-100">
                    <button onClick={handleCreateRTV} className="w-full bg-rose-600 text-white py-6 rounded-[28px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-rose-500 transition-all active:scale-95 flex items-center justify-center gap-3">
                       Commit Log to QC Pipeline <ArrowRight size={18} />
                    </button>
                 </div>
              </div>
           </div>

           <div className="space-y-6">
              <div className="bg-slate-900 rounded-[44px] p-10 text-white shadow-2xl sticky top-8 border border-slate-800 space-y-8">
                 <h4 className="text-xl font-black flex items-center gap-3"><FileText className="text-rose-400" /> Evidence Capture</h4>
                 
                 <div className="space-y-6">
                    <div className="space-y-4">
                       <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Debit Note Attachment</label>
                       <div 
                         onClick={() => dnFileRef.current?.click()}
                         className={`aspect-video rounded-[32px] border-4 border-dashed transition-all flex flex-col items-center justify-center gap-2 cursor-pointer overflow-hidden ${(newRTV as any).dnAttachment ? 'border-emerald-500 bg-white/5' : 'border-white/10 bg-white/5 hover:bg-white/10'}`}
                       >
                          {(newRTV as any).dnAttachment ? <CheckCircle2 className="text-emerald-400" size={32}/> : <><Upload size={24} className="text-rose-400"/><p className="text-[10px] font-black text-slate-400 uppercase">Upload DN Copy</p></>}
                       </div>
                       <input type="file" ref={dnFileRef} className="hidden" accept="image/*,.pdf" onChange={e => {
                         const file = e.target.files?.[0];
                         if (file) {
                           const reader = new FileReader();
                           reader.onloadend = () => setNewRTV({ ...newRTV, dnAttachment: reader.result as string } as any);
                           reader.readAsDataURL(file);
                         }
                       }} />
                    </div>

                    <div className="space-y-4">
                       <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Consignment Receipt Photos</label>
                       <div 
                         onClick={() => receiptPhotoRef.current?.click()}
                         className="grid grid-cols-2 gap-3"
                       >
                          {(newRTV.receiptPhotos || []).map((p, i) => (
                             <div key={i} className="aspect-square rounded-2xl bg-white/5 border border-white/10 overflow-hidden"><img src={p} className="w-full h-full object-cover" /></div>
                          ))}
                          <div className="aspect-square rounded-2xl border-2 border-dashed border-white/10 flex flex-col items-center justify-center gap-2 hover:bg-white/5 cursor-pointer transition-all">
                             <Camera size={20} className="text-rose-400" />
                             <p className="text-[8px] font-black text-slate-500 uppercase">Add Photo</p>
                          </div>
                       </div>
                       <input type="file" ref={receiptPhotoRef} className="hidden" accept="image/*" onChange={e => {
                         const file = e.target.files?.[0];
                         if (file) {
                           const reader = new FileReader();
                           reader.onloadend = () => setNewRTV({ ...newRTV, receiptPhotos: [...(newRTV.receiptPhotos || []), reader.result as string] });
                           reader.readAsDataURL(file);
                         }
                       }} />
                    </div>
                 </div>
                 
                 <div className="p-6 bg-white/5 rounded-3xl border border-white/5 space-y-4">
                    <div className="flex items-center gap-3 text-rose-400">
                       <AlertTriangle size={18}/>
                       <p className="text-[9px] font-black uppercase tracking-widest">Protocol Notice</p>
                    </div>
                    <p className="text-[11px] text-slate-400 leading-relaxed font-medium">Receipt photos should capture the condition of containers/boxes before physical inspection begins.</p>
                 </div>
              </div>
           </div>
        </div>
      )}

      {activeTab === 'QC_Inspection' && selectedRTVId && (
        <div className="space-y-8 animate-in zoom-in-95">
           {returns.filter(r => r.id === selectedRTVId).map(rtv => (
             <div key={rtv.id} className="space-y-10">
                <div className="bg-slate-900 rounded-[50px] p-10 text-white shadow-2xl flex flex-col md:flex-row justify-between items-center gap-8 relative overflow-hidden group">
                   <ShieldCheck className="absolute -right-6 -bottom-6 w-64 h-64 opacity-10 text-rose-400 group-hover:scale-110 transition-transform duration-1000" />
                   <div className="flex items-center gap-8 relative z-10">
                      <div className="w-20 h-20 bg-rose-600 rounded-[32px] flex items-center justify-center shadow-xl">
                         <ShieldCheck size={40} />
                      </div>
                      <div>
                         <h3 className="text-3xl font-black tracking-tight">{rtv.customerName}</h3>
                         <p className="text-rose-400 font-black uppercase tracking-widest text-xs mt-1">Audit Mission: {rtv.id} • DN: #{rtv.dnNumber}</p>
                      </div>
                   </div>
                   <div className="text-center md:text-right relative z-10">
                      <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Receipt Verified</p>
                      <p className="text-2xl font-black text-white">{rtv.receiptDate}</p>
                   </div>
                </div>

                <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm overflow-hidden p-10 space-y-10">
                   <div className="flex items-center justify-between border-b pb-8">
                      <h4 className="text-xs font-black text-slate-400 uppercase tracking-widest flex items-center gap-3"><Package size={16} className="text-rose-600"/> Physical Inspection Ledger</h4>
                      <p className="text-[9px] font-bold text-slate-400 italic">* All photo evidence is captured SKU-wise</p>
                   </div>

                   <div className="space-y-8">
                      {rtv.items.map((item, i) => (
                        <div key={i} className="bg-slate-50 rounded-[40px] p-8 border border-slate-100 grid grid-cols-1 xl:grid-cols-5 gap-8">
                           {/* SKU Visual Evidence */}
                           <div className="xl:col-span-1">
                              <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest block mb-4">Inspection Proof</label>
                              <div 
                                onClick={() => {setActiveItemIdx(i); itemPhotoRef.current?.click();}}
                                className={`aspect-square rounded-[32px] border-4 border-dashed transition-all flex flex-col items-center justify-center gap-3 cursor-pointer overflow-hidden ${item.itemPhoto ? 'border-emerald-500 bg-white' : 'border-slate-200 bg-white hover:border-rose-400'}`}
                              >
                                 {item.itemPhoto ? (
                                   <img src={item.itemPhoto} className="w-full h-full object-cover" />
                                 ) : (
                                   <>
                                     <Camera size={28} className="text-slate-300" />
                                     <p className="text-[9px] font-black text-slate-400 uppercase">Snapshot SKU</p>
                                   </>
                                 )}
                              </div>
                           </div>

                           {/* Inspection Details */}
                           <div className="xl:col-span-4 space-y-6">
                              <div className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-200 pb-4">
                                 <div>
                                    <h5 className="text-xl font-black text-slate-900">{item.productName}</h5>
                                    <p className="text-[10px] font-black text-rose-600 uppercase mt-1">SKU: {item.skuCode} • Batch: {item.batchNo}</p>
                                 </div>
                                 <div className="text-right">
                                    <p className="text-xs font-black uppercase text-slate-400">Billing Value</p>
                                    <p className="text-lg font-black text-slate-900">₹{(item.receivedQuantity * item.unitPrice).toLocaleString()}</p>
                                 </div>
                              </div>

                              <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                                 <div className="space-y-2">
                                    <label className="text-[9px] font-black text-slate-400 uppercase">Claimed (DN)</label>
                                    <div className="bg-white border border-slate-200 p-4 rounded-2xl font-black text-lg text-slate-400">{item.dnQuantity}</div>
                                 </div>
                                 <div className="space-y-2">
                                    <label className="text-[9px] font-black text-indigo-600 uppercase">Actually Found</label>
                                    <input 
                                       type="number" 
                                       className="w-full bg-indigo-50 border-2 border-indigo-100 p-4 rounded-2xl font-black text-lg focus:border-indigo-500 outline-none" 
                                       value={item.receivedQuantity || ''}
                                       onChange={e => {
                                          const items = [...rtv.items];
                                          items[i].receivedQuantity = parseFloat(e.target.value) || 0;
                                          onUpdateReturns(returns.map(r => r.id === rtv.id ? {...r, items} : r));
                                       }}
                                    />
                                 </div>
                                 <div className="space-y-2">
                                    <label className="text-[9px] font-black text-slate-400 uppercase">Item Condition</label>
                                    <select 
                                       className="w-full bg-white border border-slate-200 p-4 rounded-2xl font-black text-sm outline-none"
                                       value={item.condition}
                                       onChange={e => {
                                          const items = [...rtv.items];
                                          items[i].condition = e.target.value as any;
                                          onUpdateReturns(returns.map(r => r.id === rtv.id ? {...r, items} : r));
                                       }}
                                    >
                                       <option value="Usable">Usable</option>
                                       <option value="Damaged">Damaged / Leaky</option>
                                       <option value="Expired">Expired</option>
                                    </select>
                                 </div>
                                 <div className="space-y-2">
                                    <label className="text-[9px] font-black text-slate-400 uppercase">Inspector Remarks</label>
                                    <input 
                                       type="text" 
                                       className="w-full bg-white border border-slate-200 p-4 rounded-2xl font-black text-sm outline-none"
                                       value={item.remarks || ''}
                                       onChange={e => {
                                          const items = [...rtv.items];
                                          items[i].remarks = e.target.value;
                                          onUpdateReturns(returns.map(r => r.id === rtv.id ? {...r, items} : r));
                                       }}
                                       placeholder="Add details..."
                                    />
                                 </div>
                              </div>
                           </div>
                        </div>
                      ))}
                   </div>

                   <div className="pt-10 border-t flex flex-col md:flex-row justify-between items-center gap-10">
                      <div>
                         <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Final Settlement Aggregate</p>
                         <p className="text-5xl font-black text-slate-900 tracking-tighter">
                            {/* Fix: changed "item.unitPrice" to "i.unitPrice" to match iterator name */}
                            ₹{rtv.items.reduce((s,i) => s + (i.receivedQuantity * i.unitPrice), 0).toLocaleString()}
                         </p>
                      </div>
                      <div className="flex gap-4">
                         <button onClick={() => setSelectedRTVId(null)} className="px-10 py-5 text-[10px] font-black uppercase text-slate-400 tracking-widest hover:text-rose-600 transition-all">Abort Audit</button>
                         <button 
                           onClick={() => handleQCSubmit(rtv.id)}
                           disabled={rtv.items.some(i => i.receivedQuantity === 0 && i.dnQuantity > 0)}
                           className="bg-slate-900 text-white px-20 py-5 rounded-[28px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-emerald-600 transition-all flex items-center justify-center gap-4 active:scale-95 disabled:opacity-20"
                         >
                            Approve & Close Audit <CheckCircle2 size={18}/>
                         </button>
                      </div>
                   </div>
                </div>
             </div>
           ))}
           <input type="file" ref={itemPhotoRef} className="hidden" accept="image/*" onChange={e => {
              const file = e.target.files?.[0];
              if (file && activeItemIdx !== null && selectedRTVId) {
                const reader = new FileReader();
                reader.onloadend = () => {
                   const updatedReturns = returns.map(r => {
                      if (r.id === selectedRTVId) {
                         const items = [...r.items];
                         items[activeItemIdx].itemPhoto = reader.result as string;
                         return { ...r, items };
                      }
                      return r;
                   });
                   onUpdateReturns(updatedReturns);
                   setActiveItemIdx(null);
                };
                reader.readAsDataURL(file);
              }
           }} />
        </div>
      )}
    </div>
  );
};

export default RTVView;
