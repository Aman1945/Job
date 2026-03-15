
import React, { useState, useMemo, useRef } from 'react';
import { ProcurementItem, Product, User, UserRole } from '../types';
import { 
  CheckSquare, 
  Trash2, 
  Plus, 
  Search, 
  CheckCircle2, 
  FileText, 
  Tag, 
  ArrowRight,
  ShieldCheck,
  Send,
  X,
  Globe,
  Ship,
  Calendar,
  AlertTriangle,
  MapPin,
  Anchor,
  Package,
  Info,
  ExternalLink,
  ChevronRight,
  Clock,
  LayoutDashboard,
  Building2,
  FileCheck
} from 'lucide-react';

interface ProcurementViewProps {
  procurement: ProcurementItem[];
  products: Product[];
  currentUser: User;
  onUpdate: (items: ProcurementItem[]) => void;
}

const ProcurementView: React.FC<ProcurementViewProps> = ({ procurement, products, currentUser, onUpdate }) => {
  const [activeTab, setActiveTab] = useState<'Summary' | 'Raise_SIP'>('Summary');
  const [selectedRTVId, setSelectedRTVId] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [activeType, setActiveType] = useState<'Domestic' | 'Import'>('Import');
  
  // Detail View State
  const [detailViewId, setDetailViewId] = useState<string | null>(null);

  // Form State
  const [newEntry, setNewEntry] = useState<Partial<ProcurementItem>>({
    supplierName: '',
    skuCode: '',
    type: 'Import',
    sipChecked: false,
    labelsChecked: false,
    docsChecked: false,
    portOfLoading: '',
    portOfDischarge: '',
    modeOfTransport: 'Sea',
    countryOfOrigin: '',
    supplierAddress: '',
    productDescription: '',
    hsCode: '',
    quantity: 0,
    uom: 'KG',
    productSpecs: '',
    validityDate: ''
  });

  const isProcurementHead = currentUser.role === UserRole.PROCUREMENT_HEAD || currentUser.role === UserRole.ADMIN;
  const isProcurementStaff = currentUser.role === UserRole.PROCUREMENT || currentUser.role === UserRole.ADMIN;

  const filteredItems = useMemo(() => {
    return (procurement || [])
      .filter(item => 
        item.supplierName.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.skuName.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.skuCode.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.id.toLowerCase().includes(searchTerm.toLowerCase())
      )
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [procurement, searchTerm]);

  const handleAdd = () => {
    if (!newEntry.supplierName || !newEntry.skuCode) {
      alert("Supplier and SKU are mandatory.");
      return;
    }
    
    const product = products.find(p => p.skuCode === newEntry.skuCode);
    const item: ProcurementItem = {
      id: 'PRC-' + Math.floor(Math.random() * 9000 + 1000),
      supplierName: newEntry.supplierName!,
      skuCode: newEntry.skuCode!,
      skuName: product ? product.name : 'Unknown SKU',
      status: 'Pending',
      createdAt: new Date().toISOString(),
      ...newEntry
    } as ProcurementItem;

    onUpdate([item, ...procurement]);
    setActiveTab('Summary');
    setNewEntry({ type: activeType, sipChecked: false, labelsChecked: false, docsChecked: false });
  };

  const getValidityDays = (date?: string) => {
    if (!date) return null;
    const diffTime = new Date(date).getTime() - new Date().getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  const toggleCheck = (itemId: string, field: keyof ProcurementItem) => {
    if (isProcurementHead && !isProcurementStaff) return;
    const updated = procurement.map(item => {
      if (item.id === itemId && item.status === 'Pending') {
        return { ...item, [field]: !item[field] };
      }
      return item;
    });
    onUpdate(updated);
  };

  const deleteItem = (itemId: string) => {
    if (window.confirm('Delete this procurement mission?')) {
      onUpdate(procurement.filter(i => i.id !== itemId));
    }
  };

  const detailItem = useMemo(() => {
    return procurement.find(p => p.id === detailViewId);
  }, [procurement, detailViewId]);

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-20">
      {/* Dynamic Tab Switcher */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-4xl font-black text-slate-900 tracking-tighter">Procurement Terminal</h2>
          <p className="text-sm text-slate-500 font-medium mt-1">GIT Registry & Strategic Inbound Planning (SIP)</p>
        </div>
        <div className="flex bg-slate-200 p-1.5 rounded-[24px] border border-slate-300 shadow-inner">
           <button 
             onClick={() => setActiveTab('Summary')} 
             className={`px-8 py-3 rounded-2xl text-[11px] font-black uppercase tracking-widest transition-all flex items-center gap-2 ${activeTab === 'Summary' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}
           >
             <LayoutDashboard size={14}/> GIT Summary
           </button>
           <button 
             onClick={() => setActiveTab('Raise_SIP')} 
             className={`px-8 py-3 rounded-2xl text-[11px] font-black uppercase tracking-widest transition-all flex items-center gap-2 ${activeTab === 'Raise_SIP' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}
           >
             <Plus size={16}/> Raise Inbound
           </button>
        </div>
      </div>

      {activeTab === 'Summary' && (
        <div className="space-y-8">
          <div className="relative group max-w-md">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-indigo-600 transition-colors" size={18} />
            <input 
              type="text" 
              placeholder="Search GIT Database..." 
              className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-indigo-500/10 outline-none transition-all"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left min-w-[1200px]">
                <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                  <tr>
                    <th className="px-10 py-6">Mission / Type</th>
                    <th className="px-6 py-6">Vendor & Origin</th>
                    <th className="px-6 py-6">Product / HS</th>
                    <th className="px-6 py-6 text-center">Checks</th>
                    <th className="px-6 py-6 text-center">Validity Tracking</th>
                    <th className="px-6 py-6 text-center">Status</th>
                    <th className="px-10 py-6 text-right">Operations</th>
                  </tr>
                </thead>
                <tbody className="divide-y text-sm font-bold text-slate-700">
                  {filteredItems.map(item => {
                    const daysLeft = getValidityDays(item.validityDate);
                    return (
                      <tr key={item.id} className="hover:bg-slate-50/50 transition-all group">
                        <td className="px-10 py-8">
                           <div className="flex items-center gap-4">
                              <div className={`w-12 h-12 rounded-xl flex items-center justify-center border-2 ${item.type === 'Import' ? 'bg-indigo-50 border-indigo-100 text-indigo-600' : 'bg-emerald-50 border-emerald-100 text-emerald-600'}`}>
                                 {item.type === 'Import' ? <Globe size={20}/> : <Ship size={20}/>}
                              </div>
                              <div>
                                 <span className="font-mono font-black text-slate-900 text-base">{item.id}</span>
                                 <p className={`text-[8px] font-black uppercase mt-1 px-1.5 py-0.5 rounded border inline-block ${item.type === 'Import' ? 'text-indigo-600 border-indigo-100 bg-white' : 'text-emerald-600 border-emerald-100 bg-white'}`}>
                                    {item.type}
                                 </p>
                              </div>
                           </div>
                        </td>
                        <td className="px-6 py-8">
                           <p className="font-black text-slate-900 leading-tight">{item.supplierName}</p>
                           {item.type === 'Import' && <p className="text-[9px] text-slate-400 font-bold uppercase mt-1 flex items-center gap-1"><MapPin size={10}/> {item.countryOfOrigin || 'Unknown'}</p>}
                        </td>
                        <td className="px-6 py-8">
                           <p className="text-slate-700">{item.skuName}</p>
                           {item.hsCode && <p className="text-[10px] font-mono font-black text-indigo-600 mt-1 uppercase">HS: {item.hsCode}</p>}
                        </td>
                        <td className="px-6 py-8">
                           <div className="flex justify-center gap-2">
                             <CheckIcon active={item.sipChecked} title="SIP" />
                             <CheckIcon active={item.labelsChecked} title="LBL" />
                             <CheckIcon active={item.docsChecked} title="DOC" />
                           </div>
                        </td>
                        <td className={`px-6 py-8 text-center ${!item.validityDate && item.type === 'Import' ? 'bg-rose-50 border-x border-rose-100' : ''}`}>
                           {item.validityDate ? (
                             <div className="flex flex-col items-center">
                                <span className={`text-xs font-black px-3 py-1 rounded-full ${daysLeft !== null && daysLeft <= 7 ? 'bg-rose-600 text-white animate-pulse' : 'bg-slate-100 text-slate-900'}`}>
                                   {daysLeft !== null && daysLeft > 0 ? `${daysLeft} Days Remaining` : 'EXPIRED'}
                                </span>
                                <span className="text-[9px] text-slate-400 font-bold uppercase mt-1">Exp: {new Date(item.validityDate).toLocaleDateString()}</span>
                             </div>
                           ) : item.type === 'Import' ? (
                             <div className="flex items-center justify-center gap-1.5 text-rose-600">
                                <AlertTriangle size={14}/>
                                <span className="text-[9px] font-black uppercase tracking-widest">Missing Validity</span>
                             </div>
                           ) : '-'}
                        </td>
                        <td className="px-6 py-8 text-center">
                           <span className={`inline-block px-3 py-1 rounded-lg text-[9px] font-black uppercase tracking-widest border ${
                             item.status === 'Approved' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 
                             item.status === 'Awaiting Head Approval' ? 'bg-indigo-50 text-indigo-600 border-indigo-100' :
                             'bg-amber-50 text-amber-600 border-amber-100'
                           }`}>{item.status}</span>
                        </td>
                        <td className="px-10 py-8 text-right">
                           <div className="flex justify-end gap-2">
                              <button 
                                onClick={() => setDetailViewId(item.id)}
                                className="px-4 py-2 bg-slate-900 text-white rounded-xl text-[10px] font-black uppercase flex items-center gap-2 hover:bg-indigo-600 transition-all shadow-md"
                              >
                                <ExternalLink size={12}/> Details
                              </button>
                              <button onClick={() => deleteItem(item.id)} className="p-2 text-slate-200 hover:text-rose-500 transition-colors opacity-0 group-hover:opacity-100"><Trash2 size={16}/></button>
                           </div>
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

      {activeTab === 'Raise_SIP' && (
        <div className="bg-white rounded-[44px] border border-slate-200 shadow-xl overflow-hidden animate-in slide-in-from-bottom-10 duration-500">
           <div className={`p-10 border-b flex items-center justify-between ${activeType === 'Import' ? 'bg-indigo-600 text-white' : 'bg-emerald-600 text-white'}`}>
              <div>
                 <h3 className="text-3xl font-black tracking-tighter">Strategic Inbound Entry</h3>
                 <p className="text-sm opacity-80 font-medium">Define logistical particulars for {activeType} GIT missions</p>
              </div>
              <div className="flex bg-white/20 p-1 rounded-2xl border border-white/20 backdrop-blur-md">
                 <button onClick={() => {setActiveType('Domestic'); setNewEntry({...newEntry, type:'Domestic'})}} className={`px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeType === 'Domestic' ? 'bg-white text-emerald-600 shadow-lg' : 'text-white/60'}`}>Local</button>
                 <button onClick={() => {setActiveType('Import'); setNewEntry({...newEntry, type:'Import'})}} className={`px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeType === 'Import' ? 'bg-white text-indigo-600 shadow-lg' : 'text-white/60'}`}>Import</button>
              </div>
           </div>

           <div className="p-10 space-y-12">
              {/* Category 1: Shipping Details */}
              <section className="space-y-8">
                 <div className="flex items-center gap-3">
                    <div className={`w-1.5 h-6 rounded-full ${activeType === 'Import' ? 'bg-indigo-600' : 'bg-emerald-600'}`} />
                    <h4 className="text-xs font-black text-slate-400 uppercase tracking-[0.3em]">1. Shipping Logistics</h4>
                 </div>
                 <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                    <FormInput label="Port of Loading" value={newEntry.portOfLoading} onChange={v => setNewEntry({...newEntry, portOfLoading: v})} placeholder="Departure point..." />
                    <FormInput label="Port of Discharge" value={newEntry.portOfDischarge} onChange={v => setNewEntry({...newEntry, portOfDischarge: v})} placeholder="Arrival terminal..." />
                    <div className="space-y-2">
                       <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Mode of Transport</label>
                       <select 
                         className="w-full border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-black focus:border-indigo-600 outline-none appearance-none bg-slate-50 transition-all"
                         value={newEntry.modeOfTransport}
                         onChange={e => setNewEntry({...newEntry, modeOfTransport: e.target.value as any})}
                       >
                          <option value="Sea">SEA Vessel</option>
                          <option value="Air">AIR Freight</option>
                          <option value="Road">ROAD Logistics</option>
                       </select>
                    </div>
                 </div>
              </section>

              {/* Category 2: Supplier / Exporter Information */}
              <section className="space-y-8 pt-8 border-t border-slate-100">
                 <div className="flex items-center gap-3">
                    <div className={`w-1.5 h-6 rounded-full ${activeType === 'Import' ? 'bg-indigo-600' : 'bg-emerald-600'}`} />
                    <h4 className="text-xs font-black text-slate-400 uppercase tracking-[0.3em]">2. Exporter Identity</h4>
                 </div>
                 <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    <FormInput label="Supplier Company Name" value={newEntry.supplierName} onChange={v => setNewEntry({...newEntry, supplierName: v})} placeholder="Enter official entity..." />
                    <FormInput label="Country of Origin" value={newEntry.countryOfOrigin} onChange={v => setNewEntry({...newEntry, countryOfOrigin: v})} placeholder="Manufacturer nation..." />
                    <FormInput label="Address & Contact Details" value={newEntry.supplierAddress} onChange={v => setNewEntry({...newEntry, supplierAddress: v})} placeholder="Full physical location..." />
                 </div>
              </section>

              {/* Category 3: Product Details */}
              <section className="space-y-8 pt-8 border-t border-slate-100">
                 <div className="flex items-center gap-3">
                    <div className={`w-1.5 h-6 rounded-full ${activeType === 'Import' ? 'bg-indigo-600' : 'bg-emerald-600'}`} />
                    <h4 className="text-xs font-black text-slate-400 uppercase tracking-[0.3em]">3. Product Particulars</h4>
                 </div>
                 <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    <div className="space-y-2">
                       <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Organization Material Link</label>
                       <select 
                         className="w-full border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-black focus:border-indigo-600 outline-none appearance-none bg-slate-50 transition-all"
                         value={newEntry.skuCode}
                         onChange={e => setNewEntry({...newEntry, skuCode: e.target.value})}
                       >
                          <option value="">Select Master SKU...</option>
                          {products.map(p => <option key={p.skuCode} value={p.skuCode}>{p.skuCode} - {p.name}</option>)}
                       </select>
                    </div>
                    <FormInput label="Product Name & Description" value={newEntry.productDescription} onChange={v => setNewEntry({...newEntry, productDescription: v})} />
                    <FormInput label="HS Code (Harmonized System)" value={newEntry.hsCode} onChange={v => setNewEntry({...newEntry, hsCode: v})} placeholder="8-digit system code..." />
                    <div className="grid grid-cols-2 gap-4">
                       <FormInput label="Quantity" type="number" value={newEntry.quantity} onChange={v => setNewEntry({...newEntry, quantity: parseFloat(v) || 0})} />
                       <FormInput label="UOM" value={newEntry.uom} onChange={v => setNewEntry({...newEntry, uom: v})} placeholder="KG/PCS" />
                    </div>
                    <FormInput label="Product Specifications" value={newEntry.productSpecs} onChange={v => setNewEntry({...newEntry, productSpecs: v})} placeholder="Grade, Weight range, Temperature..." />
                    <div className="space-y-2 bg-rose-50 p-4 rounded-3xl border border-rose-100">
                       <label className="text-[10px] font-black text-rose-600 uppercase tracking-widest px-1 flex items-center gap-1"><Clock size={12}/> Validity Date (Highlighted)</label>
                       <input 
                         type="date" 
                         className="w-full bg-white border-2 border-rose-200 rounded-2xl px-6 py-3 text-sm font-black focus:border-rose-500 outline-none" 
                         value={newEntry.validityDate} 
                         onChange={e => setNewEntry({...newEntry, validityDate: e.target.value})} 
                       />
                    </div>
                 </div>
              </section>

              <div className="pt-10 border-t flex justify-end gap-4">
                 <button onClick={() => setActiveTab('Summary')} className="px-10 py-5 text-[10px] font-black uppercase text-slate-400 tracking-widest hover:text-rose-600 transition-all">Abort Mission</button>
                 <button 
                   onClick={handleAdd}
                   className={`px-16 py-5 rounded-[28px] text-white font-black text-xs uppercase tracking-[0.25em] shadow-xl active:scale-95 transition-all ${activeType === 'Import' ? 'bg-indigo-600 hover:bg-indigo-700 shadow-indigo-500/20' : 'bg-emerald-600 hover:bg-emerald-700 shadow-emerald-500/20'}`}
                 >
                   Commit Inbound Log
                 </button>
              </div>
           </div>
        </div>
      )}

      {/* Detail Overlay View */}
      {detailViewId && detailItem && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-slate-950/90 backdrop-blur-md animate-in fade-in duration-300">
           <div className="bg-white w-full max-w-5xl rounded-[50px] overflow-hidden shadow-2xl relative animate-in zoom-in-95 duration-500 border border-white/20">
              <button 
                onClick={() => setDetailViewId(null)}
                className="absolute top-8 right-8 p-3 bg-slate-50 text-slate-400 hover:text-rose-500 hover:bg-rose-50 rounded-2xl transition-all z-10"
              >
                 <X size={24}/>
              </button>

              <div className="grid grid-cols-1 lg:grid-cols-3 h-full max-h-[90vh]">
                 {/* Sidebar Profile */}
                 <div className="bg-slate-900 p-12 text-white flex flex-col justify-between overflow-y-auto no-scrollbar">
                    <div className="space-y-10">
                       <div className="w-20 h-20 bg-indigo-500 rounded-[32px] flex items-center justify-center shadow-2xl shadow-indigo-500/30">
                          {detailItem.type === 'Import' ? <Globe size={40}/> : <Ship size={40}/>}
                       </div>
                       <div>
                          <span className="text-[10px] font-black text-indigo-400 uppercase tracking-[0.3em]">Mission ID</span>
                          <h3 className="text-4xl font-black tracking-tighter mt-1">{detailItem.id}</h3>
                          <p className="text-sm text-slate-400 font-bold uppercase mt-2">{detailItem.type} Inbound Flow</p>
                       </div>
                       <div className="space-y-4 pt-10 border-t border-white/10">
                          <div className="flex justify-between items-center"><span className="text-[10px] font-black text-slate-500 uppercase">Created</span><span className="text-xs font-bold">{new Date(detailItem.createdAt).toLocaleDateString()}</span></div>
                          <div className="flex justify-between items-center"><span className="text-[10px] font-black text-slate-500 uppercase">Current Stage</span><span className="text-xs font-black text-emerald-400 uppercase">{detailItem.status}</span></div>
                          <div className="flex justify-between items-center"><span className="text-[10px] font-black text-slate-500 uppercase">Inspector</span><span className="text-xs font-bold">{detailItem.approvedBy || 'Pending'}</span></div>
                       </div>
                    </div>

                    <div className="pt-10">
                       <div className="bg-white/5 border border-white/10 p-6 rounded-[32px] text-center">
                          <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">GIT Health Score</p>
                          <p className="text-4xl font-black text-white">96.4%</p>
                       </div>
                    </div>
                 </div>

                 {/* Main Content Detail Grid */}
                 <div className="lg:col-span-2 p-12 overflow-y-auto no-scrollbar space-y-12">
                    <div className="flex items-center justify-between">
                       <h4 className="text-2xl font-black text-slate-900 tracking-tight">Consignment Audit Details</h4>
                       {getValidityDays(detailItem.validityDate) !== null && (
                          <div className={`px-6 py-2 rounded-2xl border font-black text-xs uppercase flex items-center gap-2 ${getValidityDays(detailItem.validityDate)! <= 7 ? 'bg-rose-50 text-rose-600 border-rose-100 animate-pulse' : 'bg-emerald-50 text-emerald-600 border-emerald-100'}`}>
                             <Clock size={16}/> {getValidityDays(detailItem.validityDate)! > 0 ? `${getValidityDays(detailItem.validityDate)} Days to Expiry` : 'Mission Expired'}
                          </div>
                       )}
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
                       {/* Logistics Section */}
                       <div className="space-y-6">
                          <h5 className="text-[10px] font-black text-indigo-600 uppercase tracking-widest flex items-center gap-2"><Anchor size={14}/> Shipping & Transit</h5>
                          <DetailRow label="Port of Loading" value={detailItem.portOfLoading} />
                          <DetailRow label="Port of Discharge" value={detailItem.portOfDischarge} />
                          <DetailRow label="Mode" value={detailItem.modeOfTransport} />
                       </div>

                       {/* Exporter Section */}
                       <div className="space-y-6">
                          <h5 className="text-[10px] font-black text-indigo-600 uppercase tracking-widest flex items-center gap-2"><Building2 size={14}/> Exporter Particulars</h5>
                          <DetailRow label="Entity" value={detailItem.supplierName} />
                          <DetailRow label="Origin" value={detailItem.countryOfOrigin} />
                          <DetailRow label="Address" value={detailItem.supplierAddress} />
                       </div>

                       {/* Product Section */}
                       <div className="md:col-span-2 space-y-6 pt-10 border-t border-slate-100">
                          <h5 className="text-[10px] font-black text-indigo-600 uppercase tracking-widest flex items-center gap-2"><Package size={14}/> Product Specifications</h5>
                          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
                             <DetailRow label="SKU Code" value={detailItem.skuCode} isMono />
                             <DetailRow label="HSN / HS" value={detailItem.hsCode} isMono />
                             <DetailRow label="Volume" value={`${detailItem.quantity} ${detailItem.uom}`} />
                             <DetailRow label="Validity" value={detailItem.validityDate} />
                          </div>
                          <DetailRow label="Full Description" value={detailItem.productDescription} />
                          <DetailRow label="Technical Specs" value={detailItem.productSpecs} />
                       </div>

                       {/* Checklist Compliance */}
                       <div className="md:col-span-2 space-y-6 pt-10 border-t border-slate-100">
                          <h5 className="text-[10px] font-black text-indigo-600 uppercase tracking-widest flex items-center gap-2"><FileCheck size={14}/> Compliance Verification</h5>
                          <div className="grid grid-cols-3 gap-6">
                             <ComplianceCard label="SIP Protocol" active={detailItem.sipChecked} />
                             <ComplianceCard label="Label Audit" active={detailItem.labelsChecked} />
                             <ComplianceCard label="Documentation" active={detailItem.docsChecked} />
                          </div>
                       </div>
                    </div>

                    <div className="pt-10 flex gap-4">
                       <button 
                         onClick={() => setDetailViewId(null)}
                         className="flex-1 py-5 rounded-[28px] border-2 border-slate-100 font-black text-xs uppercase tracking-widest text-slate-400 hover:bg-slate-50 transition-all"
                       >
                          Close Detail View
                       </button>
                       {detailItem.status === 'Pending' && isProcurementStaff && (
                         <button className="flex-[2] py-5 rounded-[28px] bg-indigo-600 text-white font-black text-xs uppercase tracking-[0.2em] shadow-xl shadow-indigo-600/20 hover:bg-indigo-700 transition-all flex items-center justify-center gap-3">
                            <Send size={18}/> Submit for Global Approval
                         </button>
                       )}
                    </div>
                 </div>
              </div>
           </div>
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
        className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-indigo-600 outline-none transition-all"
        value={value === 0 && type === 'number' ? '' : value || ''}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
     />
  </div>
);

const DetailRow = ({ label, value, isMono }: { label: string, value?: any, isMono?: boolean }) => (
  <div className="space-y-1">
     <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">{label}</p>
     <p className={`text-sm font-bold text-slate-900 ${isMono ? 'font-mono tracking-tight' : ''}`}>{value || '—'}</p>
  </div>
);

const ComplianceCard = ({ label, active }: { label: string, active: boolean }) => (
  <div className={`p-6 rounded-3xl border-2 flex flex-col items-center gap-3 text-center transition-all ${active ? 'bg-emerald-50 border-emerald-100 text-emerald-600 shadow-sm' : 'bg-slate-50 border-slate-100 text-slate-300'}`}>
     {active ? <CheckCircle2 size={24}/> : <Info size={24}/>}
     <p className="text-[10px] font-black uppercase tracking-widest">{label}</p>
     <span className="text-[8px] font-black uppercase">{active ? 'VERIFIED' : 'PENDING'}</span>
  </div>
);

const CheckIcon = ({ active, title }: { active: boolean, title: string }) => (
  <div className={`w-8 h-8 rounded-lg flex items-center justify-center border transition-all ${active ? 'bg-emerald-500 border-emerald-400 text-white shadow-md' : 'bg-slate-50 border-slate-100 text-slate-200'}`} title={title}>
     {active ? <CheckCircle2 size={16}/> : <div className="w-1.5 h-1.5 rounded-full bg-slate-200" />}
  </div>
);

export default ProcurementView;
