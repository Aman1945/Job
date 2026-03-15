
import React, { useState, useMemo, useRef } from 'react';
import { Order, OrderStatus, User, QCDetails } from '../types';
import { 
  ShieldCheck, 
  Search, 
  ChevronRight, 
  Thermometer, 
  Box, 
  Scale, 
  Tag, 
  Camera, 
  CheckCircle2, 
  XCircle, 
  AlertCircle,
  FileText,
  History,
  Activity,
  ArrowRight,
  UserCheck,
  FileCheck
} from 'lucide-react';

interface QualityControlViewProps {
  orders: Order[];
  currentUser: User;
  onUpdateOrder: (order: Order) => void;
  onSelectOrder: (id: string) => void;
}

const QualityControlView: React.FC<QualityControlViewProps> = ({ orders, currentUser, onUpdateOrder, onSelectOrder }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [activeOrderId, setActiveOrderId] = useState<string | null>(null);
  const [qcForm, setQcForm] = useState<Partial<QCDetails>>({
    tempVerified: false,
    actualTemp: -18,
    packagingIntact: false,
    weightVerified: false,
    labelClarity: false,
    invoiceDcAttached: false,
    qcRemarks: ''
  });
  const [qcImage, setQcImage] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const pendingQC = useMemo(() => {
    return orders.filter(o => 
      o.status === OrderStatus.PENDING_QC || (o.status === OrderStatus.PART_PACKED)
    ).filter(o => 
      o.id.toLowerCase().includes(searchTerm.toLowerCase()) || 
      o.customerName.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }, [orders, searchTerm]);

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => setQcImage(reader.result as string);
      reader.readAsDataURL(file);
    }
  };

  const submitQC = async (passed: boolean) => {
    if (!activeOrderId) return;
    
    const timestamp = new Date().toISOString();
    // After QC, order moves to READY_FOR_BILLING to have logistics costs defined
    const nextStatus = passed ? OrderStatus.READY_FOR_BILLING : OrderStatus.PENDING_PACKING;
    
    const order = orders.find(o => o.id === activeOrderId);
    if (!order) return;

    const qcDetails: QCDetails = {
      tempVerified: !!qcForm.tempVerified,
      actualTemp: qcForm.actualTemp,
      packagingIntact: !!qcForm.packagingIntact,
      weightVerified: !!qcForm.weightVerified,
      labelClarity: !!qcForm.labelClarity,
      invoiceDcAttached: !!qcForm.invoiceDcAttached,
      qcPassed: passed,
      qcAgentId: currentUser.name,
      qcTimestamp: timestamp,
      qcRemarks: qcForm.qcRemarks,
      qcImage: qcImage || undefined
    };

    onUpdateOrder({
      ...order,
      status: nextStatus,
      qc: qcDetails,
      statusHistory: [...(order.statusHistory || []), { status: nextStatus, timestamp }]
    });

    setActiveOrderId(null);
    setQcImage(null);
    setQcForm({
      tempVerified: false,
      actualTemp: -18,
      packagingIntact: false,
      weightVerified: false,
      labelClarity: false,
      invoiceDcAttached: false,
      qcRemarks: ''
    });
    alert(passed ? "QC Approved. Moving to Logistics Costing / Billing." : "QC Rejected. Sent back to Packing.");
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-20">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Quality Control Terminal</h2>
          <p className="text-sm text-slate-500 font-medium">Verify cold chain, weight accuracy, and packaging standards</p>
        </div>
        <div className="flex items-center gap-4 bg-white border border-slate-200 px-6 py-3 rounded-2xl shadow-sm">
           <Activity size={18} className="text-emerald-500" />
           <span className="text-[10px] font-black uppercase text-slate-400 tracking-widest">QC Force: {currentUser.name}</span>
        </div>
      </div>

      <div className="relative max-w-md group">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-indigo-600 transition-colors" size={18} />
        <input 
          type="text" 
          placeholder="Search Active Missions..." 
          className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-indigo-500/10 outline-none transition-all"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="space-y-6">
          <h3 className="text-xs font-black text-slate-400 uppercase tracking-widest px-2">Awaiting Inspection ({pendingQC.length})</h3>
          <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden divide-y">
            {pendingQC.map(order => (
              <div 
                key={order.id} 
                onClick={() => setActiveOrderId(order.id)}
                className={`p-8 flex items-center justify-between hover:bg-slate-50 transition-all cursor-pointer group ${activeOrderId === order.id ? 'bg-indigo-50/50 ring-2 ring-inset ring-indigo-500/20' : ''}`}
              >
                <div className="flex items-center gap-6">
                  <div className={`w-14 h-14 rounded-2xl flex items-center justify-center transition-all ${activeOrderId === order.id ? 'bg-indigo-600 text-white' : 'bg-slate-50 text-slate-400 group-hover:bg-indigo-50 group-hover:text-indigo-600'}`}>
                    <ShieldCheck size={28} />
                  </div>
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="font-mono font-black text-indigo-600">{order.id}</span>
                      <span className="text-[9px] font-black px-2 py-0.5 rounded-lg bg-emerald-50 text-emerald-600 border border-emerald-100 uppercase">{order.warehouseSource}</span>
                    </div>
                    <h4 className="text-lg font-black text-slate-900">{order.customerName}</h4>
                    <p className="text-[10px] text-slate-400 font-bold uppercase mt-1">Load: {order.items.length} SKUs • {order.packedBoxes || 0} Boxes</p>
                  </div>
                </div>
                <ChevronRight className={`text-slate-300 group-hover:text-indigo-600 transition-all ${activeOrderId === order.id ? 'rotate-90' : ''}`} />
              </div>
            ))}
            {pendingQC.length === 0 && (
              <div className="p-20 text-center space-y-4">
                <CheckCircle2 size={48} className="text-slate-100 mx-auto" />
                <p className="text-[10px] font-black text-slate-300 uppercase tracking-widest italic">All outward missions cleared QC</p>
              </div>
            )}
          </div>
        </div>

        <div className="space-y-6">
          {activeOrderId ? (
            <div className="bg-slate-900 rounded-[44px] p-10 text-white shadow-2xl space-y-10 border border-slate-800 animate-in slide-in-from-right-4">
              <div className="flex items-center justify-between border-b border-white/10 pb-6">
                <div>
                  <h4 className="text-2xl font-black tracking-tight">Standard Inspection</h4>
                  <p className="text-xs text-slate-400 font-bold uppercase mt-1">Order Ref: {activeOrderId}</p>
                </div>
                <button onClick={() => setActiveOrderId(null)} className="p-2 text-slate-500 hover:text-white transition-colors">
                  <XCircle size={24} />
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                 <QCCheckbox 
                   icon={<Thermometer size={18}/>} 
                   label="Temperature Standard" 
                   subtext="Frozen: -18°C / Fresh: 0-4°C"
                   checked={qcForm.tempVerified} 
                   onChange={(v: boolean) => setQcForm({...qcForm, tempVerified: v})} 
                 />
                 <QCCheckbox 
                   icon={<Box size={18}/>} 
                   label="Packaging Integrity" 
                   subtext="No leaks, damage or dents"
                   checked={qcForm.packagingIntact} 
                   onChange={(v: boolean) => setQcForm({...qcForm, packagingIntact: v})} 
                 />
                 <QCCheckbox 
                   icon={<Scale size={18}/>} 
                   label="Net Weight Verified" 
                   subtext="Match vs Packing Slip"
                   checked={qcForm.weightVerified} 
                   onChange={(v: boolean) => setQcForm({...qcForm, weightVerified: v})} 
                 />
                 <QCCheckbox 
                   icon={<Tag size={18}/>} 
                   label="Label & Batch Clarity" 
                   subtext="Legible expiry & barcode"
                   checked={qcForm.labelClarity} 
                   onChange={(v: boolean) => setQcForm({...qcForm, labelClarity: v})} 
                 />
                 <QCCheckbox 
                   icon={<FileCheck size={18}/>} 
                   label="Invoice / DC Attached" 
                   subtext="Physical copies with load"
                   checked={qcForm.invoiceDcAttached} 
                   onChange={(v: boolean) => setQcForm({...qcForm, invoiceDcAttached: v})} 
                 />
              </div>

              <div className="space-y-4">
                 <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Visual Verification (Photo)</label>
                 <div 
                   onClick={() => fileInputRef.current?.click()}
                   className={`aspect-video rounded-[32px] border-4 border-dashed transition-all flex flex-col items-center justify-center gap-3 cursor-pointer overflow-hidden ${qcImage ? 'border-emerald-500 bg-white/5' : 'border-white/10 bg-white/5 hover:bg-white/10 hover:border-indigo-500'}`}
                 >
                    {qcImage ? (
                      <img src={qcImage} className="w-full h-full object-cover" />
                    ) : (
                      <>
                        <Camera size={32} className="text-indigo-400" />
                        <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Snapshot Required</p>
                      </>
                    )}
                 </div>
                 <input type="file" ref={fileInputRef} className="hidden" accept="image/*" onChange={handleImageUpload} />
              </div>

              <div className="space-y-4 pt-6 border-t border-white/10">
                 <textarea 
                   className="w-full bg-white/5 border border-white/10 rounded-3xl p-6 text-sm font-bold focus:ring-2 focus:ring-indigo-500/50 outline-none transition-all resize-none text-white h-24"
                   placeholder="Inspector remarks (mandatory for rejections)..."
                   value={qcForm.qcRemarks}
                   onChange={e => setQcForm({...qcForm, qcRemarks: e.target.value})}
                 />
                 <div className="grid grid-cols-2 gap-4">
                    <button 
                      onClick={() => submitQC(true)}
                      disabled={!qcForm.tempVerified || !qcForm.packagingIntact || !qcForm.weightVerified || !qcForm.labelClarity || !qcForm.invoiceDcAttached || !qcImage}
                      className="bg-emerald-500 text-white py-5 rounded-[28px] font-black text-xs uppercase tracking-widest shadow-xl shadow-emerald-500/20 hover:bg-emerald-400 active:scale-95 transition-all disabled:opacity-20 flex items-center justify-center gap-2"
                    >
                       <CheckCircle2 size={18}/> Approve Load
                    </button>
                    <button 
                      onClick={() => submitQC(false)}
                      className="bg-white/5 border border-rose-500/30 text-rose-500 py-5 rounded-[28px] font-black text-xs uppercase tracking-widest hover:bg-rose-50/10 active:scale-95 transition-all flex items-center justify-center gap-2"
                    >
                       <XCircle size={18}/> Return Load
                    </button>
                 </div>
              </div>
            </div>
          ) : (
            <div className="bg-white rounded-[44px] p-12 border border-slate-200 shadow-sm flex flex-col items-center justify-center text-center space-y-6 min-h-[600px]">
               <div className="w-24 h-24 bg-slate-50 rounded-[32px] flex items-center justify-center text-slate-200">
                  <ShieldCheck size={48} />
               </div>
               <div>
                  <h4 className="text-xl font-black text-slate-900 uppercase">Awaiting Selection</h4>
                  <p className="text-sm text-slate-400 font-medium mt-1">Select an outward mission from the pending queue to begin quality verification protocol.</p>
               </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const QCCheckbox = ({ icon, label, subtext, checked, onChange }: any) => (
  <button 
    onClick={() => onChange(!checked)}
    className={`p-5 rounded-3xl border-2 transition-all text-left flex items-start gap-4 ${checked ? 'bg-indigo-600 border-indigo-500 text-white' : 'bg-white/5 border-white/10 text-slate-400 hover:bg-white/10'}`}
  >
     <div className={`mt-1 transition-all ${checked ? 'text-white' : 'text-indigo-400'}`}>{icon}</div>
     <div className="flex-1">
        <p className="text-[10px] font-black uppercase tracking-widest">{label}</p>
        <p className={`text-[9px] font-medium leading-tight mt-1 ${checked ? 'text-indigo-100' : 'text-slate-500'}`}>{subtext}</p>
     </div>
     <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center transition-all ${checked ? 'bg-white border-white' : 'border-white/20'}`}>
        {checked && <CheckCircle2 size={12} className="text-indigo-600" />}
     </div>
  </button>
);

export default QualityControlView;
