import React, { useState, useMemo, useRef } from 'react';
import { Order, OrderStatus, User, UserRole, OrderItem } from '../types';
import { 
  Truck, CheckCircle2, XCircle, Camera, Package, 
  Upload, ArrowRight, ChevronRight, MapPin, 
  RotateCcw, Box, Fingerprint, Calendar, Clock, 
  FileText, CloudUpload, ShieldCheck, ShoppingBag, ListChecks, Archive
} from 'lucide-react';

interface DeliveryExecutionViewProps {
  orders: Order[];
  currentUser: User;
  onUpdateOrders: (orders: Order[]) => void;
  onOpenDetails: (id: string) => void;
}

const DeliveryExecutionView: React.FC<DeliveryExecutionViewProps> = ({ orders, currentUser, onUpdateOrders, onOpenDetails }) => {
  const [view, setView] = useState<'pickup' | 'in-custody' | 'on-the-way' | 'active-partials'>('pickup');
  const [activeOrderId, setActiveOrderId] = useState<string | null>(null);
  const [deliveryResult, setDeliveryResult] = useState<OrderStatus.DELIVERED | OrderStatus.PART_ACCEPTED | OrderStatus.REJECTED | null>(null);
  const [rejectionReason, setRejectionReason] = useState('');
  const [deliveryProof, setDeliveryProof] = useState<string | null>(null);
  const [isVaulting, setIsVaulting] = useState(false);
  const [processingOrderId, setProcessingOrderId] = useState<string | null>(null);
  const [tempDeliveredQuantities, setTempDeliveredQuantities] = useState<Record<string, number>>({});
  
  const fileInputRef = useRef<HTMLInputElement>(null);
  const isAdmin = currentUser.role === UserRole.ADMIN;

  const myOrders = useMemo(() => {
    return orders.filter(o => {
      if (!o.logistics?.deliveryAgentId) return false;
      if (isAdmin) return true;
      return o.logistics.deliveryAgentId.trim().toLowerCase() === currentUser.id?.trim().toLowerCase();
    });
  }, [orders, currentUser, isAdmin]);

  const pickupOrders = useMemo(() => myOrders.filter(o => o.status === OrderStatus.READY_FOR_DISPATCH), [myOrders]);
  const inCustodyOrders = useMemo(() => myOrders.filter(o => o.status === OrderStatus.PICKED_UP), [myOrders]);
  const activeDeliveries = useMemo(() => myOrders.filter(o => o.status === OrderStatus.OUT_FOR_DELIVERY), [myOrders]);
  const partiallyAccepted = useMemo(() => myOrders.filter(o => o.status === OrderStatus.PART_ACCEPTED), [myOrders]);

  const updateOrderStatus = async (orderId: string, nextStatus: OrderStatus, extra: Partial<Order> = {}) => {
    setProcessingOrderId(orderId);
    await new Promise(r => setTimeout(r, 800));
    const timestamp = new Date().toISOString();
    const updatedOrders = orders.map(o => o.id === orderId ? { ...o, status: nextStatus, statusHistory: [...o.statusHistory, { status: nextStatus, timestamp }], ...extra } : o);
    onUpdateOrders(updatedOrders);
    setProcessingOrderId(null);
  };

  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => setDeliveryProof(reader.result as string);
      reader.readAsDataURL(file);
    }
  };

  const submitFinalOutcome = async () => {
    if (!activeOrderId || !deliveryResult) return;
    if ((deliveryResult === OrderStatus.DELIVERED || deliveryResult === OrderStatus.PART_ACCEPTED) && !deliveryProof) {
      alert("Please capture Proof of Delivery (POD)");
      return;
    }
    setIsVaulting(true);
    await new Promise(r => setTimeout(r, 2000));
    const timestamp = new Date().toISOString();
    const activeOrder = orders.find(o => o.id === activeOrderId);
    const updatedOrders = orders.map(o => {
      if (o.id === activeOrderId) {
        const updatedItems = o.items.map(item => ({ ...item, deliveredQuantity: deliveryResult === OrderStatus.DELIVERED ? (item.packedQuantity ?? item.quantity) : (tempDeliveredQuantities[`${o.id}-${item.productId}`] ?? 0) }));
        return { ...o, status: deliveryResult, deliveryProof: deliveryProof || undefined, rejectionReason: deliveryResult === OrderStatus.REJECTED ? rejectionReason : undefined, items: updatedItems, vaultTimestamp: timestamp, cloudStoragePath: `NexusOMS/Vault/${activeOrder?.customerName}/${timestamp.split('T')[0]}/${activeOrderId}`, statusHistory: [...o.statusHistory, { status: deliveryResult, timestamp }] };
      }
      return o;
    });
    onUpdateOrders(updatedOrders);
    setIsVaulting(false);
    setActiveOrderId(null);
    setDeliveryResult(null);
    setDeliveryProof(null);
  };

  const renderOrderCard = (order: Order, stage: string) => {
    return (
      <div key={order.id} className="bg-white rounded-[40px] border border-slate-100 shadow-sm overflow-hidden p-6 hover:shadow-md transition-all">
        <div className="flex justify-between items-start mb-4">
          <div className="flex flex-col">
            <span className="text-[10px] font-black text-emerald-600 font-mono tracking-widest">{order.id}</span>
            <h4 className="text-lg font-black text-slate-900 mt-1 leading-tight">{order.customerName}</h4>
            <div className="flex items-center gap-1.5 text-slate-400 text-[10px] font-black uppercase mt-1"><MapPin size={10} className="text-emerald-500" /> Dispatch Location</div>
          </div>
          <div className="text-right"><p className="text-lg font-black text-slate-900">₹{order.items.reduce((s,i)=>s+(i.price*(i.packedQuantity ?? i.quantity)),0).toLocaleString()}</p><p className="text-[9px] font-bold text-slate-400 uppercase">{order.packedBoxes || 0} Box Units</p></div>
        </div>

        {stage === 'pickup' && (
          <button onClick={() => updateOrderStatus(order.id, OrderStatus.PICKED_UP)} disabled={processingOrderId === order.id} className="w-full bg-emerald-600 text-white py-4 rounded-2xl text-[11px] font-black uppercase tracking-widest hover:bg-emerald-500 transition-all flex items-center justify-center gap-2">
            {processingOrderId === order.id ? <Clock className="animate-spin" size={16} /> : <CheckCircle2 size={16} />} Confirm Consignment Taken
          </button>
        )}

        {stage === 'in-custody' && (
          <button onClick={() => updateOrderStatus(order.id, OrderStatus.OUT_FOR_DELIVERY)} disabled={processingOrderId === order.id} className="w-full bg-indigo-600 text-white py-4 rounded-2xl text-[11px] font-black uppercase tracking-widest hover:bg-indigo-500 transition-all flex items-center justify-center gap-2">
            {processingOrderId === order.id ? <Clock className="animate-spin" size={16} /> : <Truck size={16} />} Start Delivery Mission
          </button>
        )}

        {stage === 'on-the-way' && (
          <button onClick={() => setActiveOrderId(order.id)} className="w-full bg-emerald-500 text-white py-4 rounded-2xl text-[11px] font-black uppercase tracking-widest hover:bg-emerald-400 shadow-lg transition-all flex items-center justify-center gap-2"><CheckCircle2 size={16} /> Mark Fulfillment</button>
        )}

        {stage === 'partials' && (
          <div className="w-full bg-amber-50 text-amber-700 py-3 px-4 rounded-2xl text-[10px] font-black uppercase tracking-widest flex items-center justify-between border border-amber-100">
             <span className="flex items-center gap-2 font-black"><Archive size={14}/> KEPT OPEN: PARTIAL</span>
             <button onClick={() => onOpenDetails(order.id)} className="text-emerald-600 underline">Trace History</button>
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="max-w-md mx-auto space-y-6 pb-24 animate-in fade-in duration-500">
      <div className="flex bg-slate-200 p-1.5 rounded-3xl border border-slate-300 shadow-inner">
        {[
          { id: 'pickup', label: 'Invoiced', count: pickupOrders.length },
          { id: 'in-custody', label: 'Loaded', count: inCustodyOrders.length },
          { id: 'on-the-way', label: 'Transit', count: activeDeliveries.length },
          { id: 'active-partials', label: 'Open', count: partiallyAccepted.length }
        ].map(tab => (
          <button key={tab.id} onClick={() => setView(tab.id as any)} className={`flex-1 py-3 rounded-2xl text-[9px] font-black uppercase tracking-widest transition-all ${view === tab.id ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>{tab.label} ({tab.count})</button>
        ))}
      </div>

      <div className="space-y-4">
        {view === 'pickup' && pickupOrders.map(o => renderOrderCard(o, 'pickup'))}
        {view === 'in-custody' && inCustodyOrders.map(o => renderOrderCard(o, 'in-custody'))}
        {view === 'on-the-way' && activeDeliveries.map(o => renderOrderCard(o, 'on-the-way'))}
        {view === 'active-partials' && partiallyAccepted.map(o => renderOrderCard(o, 'partials'))}
        {((view === 'pickup' && pickupOrders.length === 0) || (view === 'in-custody' && inCustodyOrders.length === 0) || (view === 'on-the-way' && activeDeliveries.length === 0) || (view === 'active-partials' && partiallyAccepted.length === 0)) && (
          <div className="py-24 text-center"><div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6 text-slate-200 shadow-inner"><ShoppingBag size={48} /></div><p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Everything Processed</p></div>
        )}
      </div>

      {activeOrderId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-emerald-950/90 backdrop-blur-md animate-in fade-in">
          <div className="bg-white w-full max-w-sm rounded-[44px] p-8 shadow-2xl relative overflow-hidden border border-white/20">
            {isVaulting ? (
              <div className="py-16 text-center space-y-8"><CloudUpload className="text-emerald-600 animate-bounce mx-auto" size={80} /><h4 className="text-2xl font-black text-slate-900 tracking-tighter">Archiving POD...</h4><div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden max-w-[240px] mx-auto shadow-inner"><div className="h-full bg-emerald-600 animate-[progress_2s_ease-in-out]" style={{width: '100%'}} /></div></div>
            ) : (
              <div className="space-y-8 max-h-[80vh] overflow-y-auto no-scrollbar">
                <div className="flex items-center justify-between"><h4 className="text-2xl font-black text-slate-900 tracking-tight">Mission Closing</h4><button onClick={() => setActiveOrderId(null)} className="p-2 text-slate-400 hover:text-rose-500"><XCircle size={24} /></button></div>
                <div className="space-y-3">
                  <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Mission Outcome</label>
                  <div className="grid grid-cols-1 gap-2">
                    {[
                      { id: OrderStatus.DELIVERED, label: 'Success (Full)', icon: <CheckCircle2 size={16} />, color: 'text-emerald-600 bg-emerald-50' },
                      { id: OrderStatus.PART_ACCEPTED, label: 'Success (Part)', icon: <ListChecks size={16} />, color: 'text-amber-600 bg-amber-50' },
                      { id: OrderStatus.REJECTED, label: 'Mission Refused', icon: <XCircle size={16} />, color: 'text-rose-600 bg-rose-50' }
                    ].map(btn => (
                      <button key={btn.id} onClick={() => setDeliveryResult(btn.id as any)} className={`flex items-center gap-3 p-4 rounded-2xl border-2 transition-all ${deliveryResult === btn.id ? `border-emerald-600 ${btn.color} font-black scale-[1.02]` : 'border-slate-50 text-slate-400 font-bold'}`}>{btn.icon} <span className="text-xs uppercase tracking-widest">{btn.label}</span></button>
                    ))}
                  </div>
                </div>
                {(deliveryResult === OrderStatus.DELIVERED || deliveryResult === OrderStatus.PART_ACCEPTED) && (
                   <div className="aspect-video bg-emerald-50 rounded-3xl border-4 border-dashed border-emerald-200 flex items-center justify-center relative overflow-hidden group cursor-pointer" onClick={() => fileInputRef.current?.click()}>
                     {deliveryProof ? (<img src={deliveryProof} className="w-full h-full object-cover" />) : (<div className="text-center space-y-2"><Camera size={32} className="text-emerald-300 mx-auto" /><p className="text-[9px] font-black text-emerald-400 uppercase tracking-widest">Snapshot POD Required</p></div>)}
                     <input type="file" accept="image/*" className="hidden" ref={fileInputRef} onChange={handlePhotoUpload} />
                   </div>
                )}
                <button onClick={submitFinalOutcome} disabled={!deliveryResult || ((deliveryResult === OrderStatus.DELIVERED || deliveryResult === OrderStatus.PART_ACCEPTED) && !deliveryProof)} className="w-full bg-emerald-600 text-white py-5 rounded-3xl font-black text-xs uppercase tracking-[0.2em] shadow-xl shadow-emerald-500/20 active:scale-95 transition-all disabled:opacity-20">Securely Vault POD & Close</button>
              </div>
            )}
          </div>
        </div>
      )}
      <style>{`@keyframes progress { 0% { width: 0%; } 100% { width: 100%; } }`}</style>
    </div>
  );
};

export default DeliveryExecutionView;