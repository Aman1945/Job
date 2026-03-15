
import React, { useState, useMemo, useRef } from 'react';
import { PackagingMaterial, PackagingTransaction, User, UserRole } from '../types';
import { 
  Package, 
  ArrowUpRight, 
  ArrowDownLeft, 
  Activity, 
  Plus, 
  Search, 
  Calendar, 
  FileText, 
  Download, 
  FileUp, 
  X, 
  AlertTriangle, 
  CheckCircle2,
  AlertCircle,
  Truck,
  Layers,
  MoreVertical
} from 'lucide-react';

interface PackagingInventoryViewProps {
  materials: PackagingMaterial[];
  transactions: PackagingTransaction[];
  onUpdateMaterials: (m: PackagingMaterial[]) => void;
  onUpdateTransactions: (t: PackagingTransaction[]) => void;
  currentUser: User;
}

const PackagingInventoryView: React.FC<PackagingInventoryViewProps> = ({ 
  materials, transactions, onUpdateMaterials, onUpdateTransactions, currentUser 
}) => {
  const [activeTab, setActiveTab] = useState<'Health' | 'Inward' | 'Outward'>('Health');
  const [searchTerm, setSearchTerm] = useState('');
  const [isAddingInward, setIsAddingInward] = useState(false);
  const [selectedOutId, setSelectedOutId] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Form states
  const [inwardForm, setInwardForm] = useState<Partial<PackagingTransaction>>({
    materialId: '',
    qty: 0,
    batch: '',
    vendorName: '',
    referenceNo: '',
    date: new Date().toISOString().split('T')[0]
  });
  const [inwardAttachment, setInwardAttachment] = useState<string | null>(null);
  const [outwardQty, setOutwardQty] = useState<number>(0);

  const filteredMaterials = useMemo(() => {
    return materials.filter(m => m.name.toLowerCase().includes(searchTerm.toLowerCase()));
  }, [materials, searchTerm]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => setInwardAttachment(reader.result as string);
      reader.readAsDataURL(file);
    }
  };

  const handleInwardSubmit = () => {
    if (!inwardForm.materialId || !inwardForm.qty) return;

    const newTx: PackagingTransaction = {
      id: 'TX-IN-' + Math.floor(Math.random() * 90000 + 10000),
      materialId: inwardForm.materialId,
      type: 'IN',
      qty: inwardForm.qty,
      batch: inwardForm.batch,
      mfgDate: (inwardForm as any).mfgDate,
      expDate: (inwardForm as any).expDate,
      vendorName: inwardForm.vendorName,
      referenceNo: inwardForm.referenceNo,
      attachment: inwardAttachment || undefined,
      date: inwardForm.date || new Date().toISOString()
    };

    const updatedMaterials = materials.map(m => 
      m.id === inwardForm.materialId ? { ...m, balance: m.balance + (inwardForm.qty || 0), lastMovementDate: newTx.date } : m
    );

    onUpdateTransactions([newTx, ...transactions]);
    onUpdateMaterials(updatedMaterials);
    setIsAddingInward(false);
    setInwardForm({ materialId: '', qty: 0, date: new Date().toISOString().split('T')[0] });
    setInwardAttachment(null);
  };

  const handleOutwardSubmit = () => {
    if (!selectedOutId || !outwardQty) return;
    const material = materials.find(m => m.id === selectedOutId);
    if (!material || material.balance < outwardQty) {
      alert("Insufficient stock balance.");
      return;
    }

    const newTx: PackagingTransaction = {
      id: 'TX-OUT-' + Math.floor(Math.random() * 90000 + 10000),
      materialId: selectedOutId,
      type: 'OUT',
      qty: outwardQty,
      date: new Date().toISOString()
    };

    const updatedMaterials = materials.map(m => 
      m.id === selectedOutId ? { ...m, balance: m.balance - outwardQty, lastMovementDate: newTx.date } : m
    );

    onUpdateTransactions([newTx, ...transactions]);
    onUpdateMaterials(updatedMaterials);
    setSelectedOutId(null);
    setOutwardQty(0);
    alert("Consumption logged successfully.");
  };

  const getStatus = (m: PackagingMaterial) => {
    const isLow = m.balance <= m.moq;
    const isStagnant = m.lastMovementDate ? (new Date().getTime() - new Date(m.lastMovementDate).getTime()) / (1000 * 60 * 60 * 24) > 30 : false;
    const isOverage = m.balance > m.moq * 10;

    if (isLow) return { label: 'LOW STOCK', color: 'bg-rose-50 text-rose-700 border-rose-100', icon: <AlertCircle size={12}/> };
    if (isStagnant || isOverage) return { label: isOverage ? 'OVERAGE' : 'STAGNANT', color: 'bg-orange-50 text-orange-700 border-orange-100', icon: <AlertTriangle size={12}/> };
    return { label: 'HEALTHY', color: 'bg-emerald-50 text-emerald-700 border-emerald-100', icon: <CheckCircle2 size={12}/> };
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-24">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Packaging Lifecycle Hub</h2>
          <p className="text-sm text-slate-500 font-medium">Manage Poly, Vacuum, and Carton inventory levels</p>
        </div>
        <div className="flex bg-slate-200 p-1 rounded-2xl border border-slate-300 shadow-inner">
           <button onClick={() => setActiveTab('Health')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeTab === 'Health' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Stock Health</button>
           <button onClick={() => setActiveTab('Inward')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeTab === 'Inward' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Inbound Entry</button>
           <button onClick={() => setActiveTab('Outward')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeTab === 'Outward' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Outbound (Usage)</button>
        </div>
      </div>

      <div className="relative group max-w-md">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
        <input 
          type="text" 
          placeholder="Filter packaging SKU..." 
          className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {activeTab === 'Health' && (
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
           <div className="lg:col-span-3">
              <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
                <div className="overflow-x-auto">
                   <table className="w-full text-left">
                      <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                         <tr>
                            <th className="px-8 py-6">Material Description</th>
                            <th className="px-6 py-6">Category</th>
                            <th className="px-6 py-6 text-center">MOQ Limit</th>
                            <th className="px-6 py-6 text-center">Live Balance</th>
                            <th className="px-6 py-6 text-center">Status</th>
                            <th className="px-8 py-6 text-right">Last Movement</th>
                         </tr>
                      </thead>
                      <tbody className="divide-y text-sm font-bold text-slate-700">
                         {filteredMaterials.map(m => {
                           const status = getStatus(m);
                           return (
                             <tr key={m.id} className="hover:bg-slate-50/50 transition-colors group">
                                <td className="px-8 py-6">
                                   <p className="text-slate-900 font-black">{m.name}</p>
                                   <p className="text-[9px] text-slate-400 font-black uppercase mt-1">ID: {m.id}</p>
                                </td>
                                <td className="px-6 py-6">
                                   <span className="text-[10px] font-black uppercase text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded border border-indigo-100">{m.category}</span>
                                </td>
                                <td className="px-6 py-6 text-center font-mono text-slate-400">{m.moq} {m.unit}</td>
                                <td className={`px-6 py-6 text-center font-black ${m.balance <= m.moq ? 'text-rose-600' : 'text-slate-900'}`}>{m.balance} {m.unit}</td>
                                <td className="px-6 py-6">
                                   <div className={`flex items-center justify-center gap-1.5 px-3 py-1 rounded-lg border text-[9px] font-black uppercase ${status.color}`}>
                                      {status.icon} {status.label}
                                   </div>
                                </td>
                                <td className="px-8 py-6 text-right text-slate-400 font-medium">{m.lastMovementDate || 'Never'}</td>
                             </tr>
                           );
                         })}
                      </tbody>
                   </table>
                </div>
              </div>
           </div>
           <div className="space-y-6">
              <div className="bg-slate-900 rounded-[40px] p-8 text-white shadow-2xl relative overflow-hidden border border-slate-800 group">
                 <Layers className="absolute -right-6 -bottom-6 w-32 h-32 opacity-10 group-hover:scale-110 transition-transform duration-700" />
                 <h4 className="text-xl font-black mb-6 flex items-center gap-3"><Activity className="text-emerald-400" /> Summary</h4>
                 <div className="space-y-6">
                    <div className="p-4 bg-white/5 rounded-2xl border border-white/5 flex justify-between items-center">
                       <span className="text-[10px] font-black uppercase text-slate-400">Low Stock SKUs</span>
                       <span className="text-xl font-black text-rose-400">{materials.filter(m => m.balance <= m.moq).length}</span>
                    </div>
                    <div className="p-4 bg-white/5 rounded-2xl border border-white/5 flex justify-between items-center">
                       <span className="text-[10px] font-black uppercase text-slate-400">Total Material Types</span>
                       <span className="text-xl font-black">{materials.length}</span>
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}

      {activeTab === 'Inward' && (
        <div className="space-y-8 animate-in slide-in-from-left-4">
           <div className="bg-emerald-900 rounded-[40px] p-10 text-white shadow-2xl flex items-center justify-between">
              <div>
                 <h3 className="text-3xl font-black tracking-tight">Material Receiving Terminal</h3>
                 <p className="text-sm text-emerald-300/60 font-medium">Log incoming packaging shipments and challans</p>
              </div>
              <button 
                onClick={() => setIsAddingInward(true)}
                className="bg-white text-emerald-900 px-10 py-5 rounded-2xl font-black text-xs uppercase tracking-widest shadow-xl hover:bg-emerald-50 active:scale-95 transition-all flex items-center gap-3"
              >
                <Plus size={20}/> New Inbound Entry
              </button>
           </div>

           {isAddingInward && (
             <div className="bg-white rounded-[44px] border border-slate-200 shadow-xl p-10 animate-in zoom-in-95 duration-300">
                <div className="flex items-center justify-between mb-10 border-b pb-6">
                   <h4 className="text-xl font-black text-slate-900 uppercase tracking-tight">Consignment Particulars</h4>
                   <button onClick={() => setIsAddingInward(false)} className="p-2 text-slate-300 hover:text-rose-500 transition-colors"><X size={24}/></button>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                   <div className="space-y-2">
                      <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Material SKU</label>
                      <select 
                        className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold outline-none appearance-none focus:border-emerald-600 transition-all"
                        value={inwardForm.materialId}
                        onChange={e => setInwardForm({...inwardForm, materialId: e.target.value})}
                      >
                         <option value="">Select Packaging Material...</option>
                         {materials.map(m => <option key={m.id} value={m.id}>{m.name}</option>)}
                      </select>
                   </div>
                   <div className="space-y-2">
                      <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Quantity Received</label>
                      <input type="number" className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-emerald-600 outline-none" value={inwardForm.qty || ''} onChange={e => setInwardForm({...inwardForm, qty: Number(e.target.value)})} />
                   </div>
                   <div className="space-y-2">
                      <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Vendor / Source</label>
                      <input type="text" className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-emerald-600 outline-none" value={inwardForm.vendorName || ''} onChange={e => setInwardForm({...inwardForm, vendorName: e.target.value})} />
                   </div>
                   <div className="space-y-2">
                      <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Challan / Invoice No</label>
                      <input type="text" className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-emerald-600 outline-none" value={inwardForm.referenceNo || ''} onChange={e => setInwardForm({...inwardForm, referenceNo: e.target.value})} />
                   </div>
                   <div className="space-y-2">
                      <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Batch Number</label>
                      <input type="text" className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-emerald-600 outline-none" value={inwardForm.batch || ''} onChange={e => setInwardForm({...inwardForm, batch: e.target.value})} />
                   </div>
                   <div className="space-y-2">
                      <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Receiving Date</label>
                      <input type="date" className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-emerald-600 outline-none" value={inwardForm.date} onChange={e => setInwardForm({...inwardForm, date: e.target.value})} />
                   </div>
                </div>
                
                <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-10 border-t pt-10">
                   <div className="space-y-4">
                      <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Challan Copy Attachment</label>
                      <div 
                        onClick={() => fileInputRef.current?.click()}
                        className="aspect-[3/1] bg-slate-50 border-4 border-dashed border-slate-100 rounded-[32px] flex flex-col items-center justify-center gap-2 cursor-pointer hover:bg-emerald-50 hover:border-emerald-200 transition-all overflow-hidden relative"
                      >
                         {inwardAttachment ? (
                           <>
                             <img src={inwardAttachment} className="absolute inset-0 w-full h-full object-contain p-4" />
                             <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm opacity-0 hover:opacity-100 flex items-center justify-center transition-opacity">
                                <p className="text-white text-[10px] font-black uppercase">Replace File</p>
                             </div>
                           </>
                         ) : (
                           <>
                             <FileUp className="text-slate-300" size={32}/>
                             <p className="text-[10px] font-black text-slate-400 uppercase">Click to upload doc</p>
                           </>
                         )}
                         <input type="file" ref={fileInputRef} className="hidden" onChange={handleFileChange} accept="image/*,.pdf" />
                      </div>
                   </div>
                   <div className="flex items-end">
                      <button 
                        onClick={handleInwardSubmit}
                        disabled={!inwardForm.materialId || !inwardForm.qty}
                        className="w-full bg-emerald-600 text-white py-6 rounded-3xl font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-emerald-500 active:scale-95 transition-all disabled:opacity-30"
                      >
                        Execute Stock Inbound
                      </button>
                   </div>
                </div>
             </div>
           )}

           <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
              <h4 className="p-8 text-xs font-black text-slate-400 uppercase tracking-widest border-b bg-slate-50/50">Recent Receiving History</h4>
              <div className="overflow-x-auto">
                 <table className="w-full text-left">
                    <thead className="bg-white text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                       <tr>
                          <th className="px-8 py-5">Date</th>
                          <th className="px-6 py-5">Material SKU</th>
                          <th className="px-6 py-5 text-center">Batch</th>
                          <th className="px-6 py-5">Vendor</th>
                          <th className="px-6 py-5 text-center">Qty In</th>
                          <th className="px-8 py-5 text-right">Challan Ref</th>
                       </tr>
                    </thead>
                    <tbody className="divide-y text-xs font-bold text-slate-700">
                       {transactions.filter(t => t.type === 'IN').map(tx => {
                         const mat = materials.find(m => m.id === tx.materialId);
                         return (
                           <tr key={tx.id} className="hover:bg-slate-50 transition-colors">
                              <td className="px-8 py-5 text-slate-400">{tx.date}</td>
                              <td className="px-6 py-5 text-slate-900 font-black">{mat?.name}</td>
                              <td className="px-6 py-5 text-center font-mono text-indigo-600">{tx.batch || 'N/A'}</td>
                              <td className="px-6 py-5">{tx.vendorName}</td>
                              <td className="px-6 py-5 text-center text-emerald-600 font-black">+{tx.qty}</td>
                              <td className="px-8 py-5 text-right flex justify-end items-center gap-2">
                                 <span className="text-slate-400">{tx.referenceNo}</span>
                                 {tx.attachment && <button onClick={() => tx.attachment && downloadFile(tx.attachment, `Challan_${tx.id}.png`)} className="p-1.5 bg-emerald-50 text-emerald-600 rounded-lg hover:bg-emerald-600 hover:text-white transition-all"><Download size={14}/></button>}
                              </td>
                           </tr>
                         );
                       })}
                    </tbody>
                 </table>
              </div>
           </div>
        </div>
      )}

      {activeTab === 'Outward' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-10 animate-in slide-in-from-right-4">
           <div className="lg:col-span-2 space-y-6">
              <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm p-10">
                 <h3 className="text-xs font-black text-slate-400 uppercase tracking-widest mb-10 border-b pb-4">Packaging Consumption Log (Usage)</h3>
                 <div className="grid grid-cols-1 gap-4">
                    {filteredMaterials.map(m => (
                      <label 
                        key={m.id} 
                        className={`flex items-center justify-between p-6 rounded-3xl border-2 transition-all cursor-pointer ${selectedOutId === m.id ? 'border-indigo-600 bg-indigo-50 shadow-lg scale-[1.01]' : 'border-slate-50 bg-slate-50/30 hover:border-slate-200'}`}
                      >
                         <div className="flex items-center gap-6">
                            <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all ${selectedOutId === m.id ? 'border-indigo-600 bg-indigo-600' : 'border-slate-300 bg-white'}`}>
                               {selectedOutId === m.id && <div className="w-2 h-2 rounded-full bg-white"/>}
                            </div>
                            <input type="radio" className="hidden" checked={selectedOutId === m.id} onChange={() => setSelectedOutId(m.id)} />
                            <div>
                               <p className="font-black text-slate-900">{m.name}</p>
                               <p className="text-[10px] text-slate-400 font-bold uppercase">{m.category} • Balance: {m.balance} {m.unit}</p>
                            </div>
                         </div>
                         <div className="text-right">
                            <span className={`px-3 py-1 rounded-lg text-[9px] font-black border ${getStatus(m).color}`}>
                               {getStatus(m).label}
                            </span>
                         </div>
                      </label>
                    ))}
                 </div>
              </div>
           </div>
           
           <div className="space-y-6">
              <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl sticky top-8 border border-slate-800">
                 <h4 className="text-2xl font-black mb-10 flex items-center gap-3 tracking-tight"><ArrowUpRight className="text-indigo-400" /> Dispatch Usage</h4>
                 <div className="space-y-8">
                    <div className="space-y-2">
                       <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Selected Material</label>
                       <div className="bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-sm font-bold text-white min-h-[56px] flex items-center">
                          {selectedOutId ? materials.find(m => m.id === selectedOutId)?.name : <span className="text-slate-500 italic">Select from list...</span>}
                       </div>
                    </div>
                    <div className="space-y-2">
                       <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Quantity Used</label>
                       <input 
                         type="number" 
                         className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-indigo-500/50 outline-none transition-all text-white" 
                         placeholder="0"
                         value={outwardQty || ''}
                         onChange={e => setOutwardQty(Number(e.target.value))}
                       />
                    </div>
                    <button 
                      onClick={handleOutwardSubmit}
                      disabled={!selectedOutId || !outwardQty}
                      className="w-full bg-indigo-600 text-white py-6 rounded-3xl font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-500 active:scale-95 transition-all disabled:opacity-30 flex items-center justify-center gap-3"
                    >
                      <Download size={18}/> Commit Consumption
                    </button>
                    
                    <div className="p-6 bg-white/5 rounded-3xl border border-white/5 space-y-4">
                       <div className="flex items-center gap-3 text-indigo-400 mb-2">
                          <AlertCircle size={18}/>
                          <p className="text-[9px] font-black uppercase tracking-widest">Pre-dispatch Validation</p>
                       </div>
                       <p className="text-[11px] text-slate-400 leading-relaxed font-medium">Inventory will be decremented in real-time. Ensure the batch allocated to this usage matches the warehouse floor stock.</p>
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}
    </div>
  );
};

const downloadFile = (dataUri: string, fileName: string) => {
  const link = document.createElement('a');
  link.href = dataUri;
  link.download = fileName;
  link.click();
};

export default PackagingInventoryView;
