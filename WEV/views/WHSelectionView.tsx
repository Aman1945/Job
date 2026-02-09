
import React, { useMemo, useState } from 'react';
import { Order, OrderStatus } from '../types';
import { Warehouse, ArrowRight, MapPin, CheckCircle2, Search, Clock, Box, ShoppingCart, Tag, RefreshCcw } from 'lucide-react';

interface WHSelectionViewProps {
  orders: Order[];
  onUpdateOrders: (orders: Order[]) => void;
  onSelectOrder: (id: string) => void;
}

const WHSelectionView: React.FC<WHSelectionViewProps> = ({ orders, onUpdateOrders, onSelectOrder }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [isProcessing, setIsProcessing] = useState<string | null>(null);

  const pendingOrders = useMemo(() => 
    orders.filter(o => 
      o.status === OrderStatus.PENDING_WH_SELECTION &&
      (o.id.toLowerCase().includes(searchTerm.toLowerCase()) || o.customerName.toLowerCase().includes(searchTerm.toLowerCase()))
    ), 
  [orders, searchTerm]);

  const coldRooms: Order['warehouseSource'][] = [
    'IOPL Kurla',
    'IOPL DP WORLD',
    'IOPL Arihant Delhi',
    'IOPL Jolly Bng'
  ];

  const handleAssign = async (order: Order, source: Order['warehouseSource']) => {
    setIsProcessing(order.id);
    await new Promise(r => setTimeout(r, 800));

    const nextStatus = OrderStatus.PENDING_PACKING;
    const updated = orders.map(o => o.id === order.id ? {
      ...o,
      status: nextStatus,
      warehouseSource: source,
      statusHistory: [...o.statusHistory, { status: nextStatus, timestamp: new Date().toISOString() }]
    } : o);

    onUpdateOrders(updated);
    setIsProcessing(null);
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Warehouse Selection Terminal</h2>
          <p className="text-sm text-slate-500 font-medium">Assign cold-room facilities for missions</p>
        </div>
      </div>

      <div className="relative max-w-md group">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
        <input 
          type="text" 
          placeholder="Trace by ID or Client..." 
          className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      <div className="grid grid-cols-1 gap-8">
        {pendingOrders.map(order => (
          <div key={order.id} className={`bg-white rounded-[40px] border p-10 shadow-sm hover:border-indigo-200 transition-all group overflow-hidden relative flex flex-col gap-8 ${order.isSTN ? 'border-indigo-100 shadow-indigo-500/5' : 'border-slate-200'}`}>
            <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-8">
              <div className="flex items-center gap-6">
                 <div className={`w-16 h-16 rounded-[28px] flex items-center justify-center transition-all ${order.isSTN ? 'bg-indigo-50 text-indigo-600' : 'bg-slate-50 text-slate-400 group-hover:bg-indigo-50 group-hover:text-indigo-600'}`}>
                    {order.isSTN ? <RefreshCcw size={32} /> : <Warehouse size={32} />}
                 </div>
                 <div>
                    <div className="flex items-center gap-2 mb-1">
                       <span className="font-mono font-black text-indigo-600 uppercase text-lg">{order.id}</span>
                       <span className={`text-[9px] font-black px-2 py-0.5 rounded-lg border uppercase ${order.isSTN ? 'bg-indigo-50 text-indigo-600 border-indigo-100' : 'bg-emerald-50 text-emerald-600 border-emerald-100'}`}>
                         {order.isSTN ? 'Stock Transfer' : 'Direct Supply'}
                       </span>
                    </div>
                    <h4 className="text-2xl font-black text-slate-900">{order.customerName}</h4>
                    <p className="text-xs font-bold text-slate-400 mt-1 uppercase tracking-widest">Awaiting Facility Finalization</p>
                 </div>
              </div>

              {!order.isSTN && (
                <div className="text-right shrink-0">
                  <p className="text-3xl font-black text-slate-900 tracking-tighter">₹{order.items.reduce((s,i)=>s+(i.price*i.quantity),0).toLocaleString()}</p>
                  <p className="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] mt-1">Consolidated Value</p>
                </div>
              )}
            </div>

            {/* SKU Details */}
            <div className="bg-slate-50/50 rounded-[32px] border border-slate-100 p-8">
               <h5 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-6 flex items-center gap-2">
                  <ShoppingCart size={14} className="text-indigo-500" /> Order SKU Inventory Breakdown
               </h5>
               <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {order.items.map((item, idx) => (
                    <div key={idx} className="flex items-center gap-4 bg-white p-4 rounded-2xl border border-slate-100 shadow-sm transition-all hover:shadow-md">
                       <div className="w-10 h-10 bg-indigo-50 text-indigo-600 rounded-xl flex items-center justify-center shrink-0">
                          <Box size={18} />
                       </div>
                       <div className="min-w-0 flex-1">
                          <p className="text-xs font-black text-slate-900 truncate leading-tight">{item.productName}</p>
                          <div className="flex items-center gap-2 mt-1">
                             <span className="text-[9px] font-black text-indigo-600 bg-indigo-50 px-1.5 py-0.5 rounded border border-indigo-100 uppercase">{item.skuCode}</span>
                             <span className="text-[9px] font-black text-slate-400 uppercase">{item.quantity} {item.unit}</span>
                          </div>
                       </div>
                    </div>
                  ))}
               </div>
            </div>

            <div className="flex flex-col md:flex-row items-center gap-6 pt-4">
              <div className="flex-1 w-full">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4 px-1">
                  {order.isSTN ? `Confirm Source Facility: ${order.fromWarehouse}` : 'Select Facility to Route Stock'}
                </p>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
                  {order.isSTN ? (
                    <button 
                      onClick={() => handleAssign(order, order.fromWarehouse as any)}
                      disabled={isProcessing === order.id}
                      className="px-6 py-4 rounded-2xl border-2 border-indigo-600 bg-indigo-600 text-white text-[10px] font-black uppercase tracking-widest transition-all text-center flex items-center justify-center shadow-lg active:scale-95"
                    >
                      Confirm {order.fromWarehouse}
                    </button>
                  ) : (
                    coldRooms.map(room => (
                      <button 
                        key={room}
                        disabled={isProcessing === order.id}
                        onClick={() => handleAssign(order, room)}
                        className="px-4 py-4 rounded-2xl border-2 border-slate-100 bg-slate-50 text-[10px] font-black uppercase tracking-widest text-slate-500 hover:border-indigo-600 hover:bg-white hover:text-indigo-600 transition-all text-center flex items-center justify-center disabled:opacity-30 shadow-sm active:scale-95"
                      >
                        {room}
                      </button>
                    ))
                  )}
                </div>
              </div>
              <div className="shrink-0 w-full md:w-auto">
                 <button onClick={() => onSelectOrder(order.id)} className="w-full md:w-auto px-8 py-4 bg-slate-900 text-white rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-indigo-600 transition-all flex items-center justify-center gap-2 shadow-xl">
                   Full Audit <ArrowRight size={14}/>
                 </button>
              </div>
            </div>

            {isProcessing === order.id && (
              <div className="absolute inset-0 bg-white/60 backdrop-blur-[2px] z-10 flex items-center justify-center">
                 <div className="bg-white p-8 rounded-[32px] shadow-2xl border border-slate-100 flex items-center gap-4 animate-in zoom-in-95">
                    <div className="w-8 h-8 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin" />
                    <span className="text-sm font-black uppercase tracking-[0.2em] text-indigo-600">Assigning Warehouse Facility...</span>
                 </div>
              </div>
            )}
          </div>
        ))}

        {pendingOrders.length === 0 && (
          <div className="py-32 text-center bg-white rounded-[40px] border-2 border-dashed border-slate-200">
             <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6 text-slate-200 shadow-inner">
                <CheckCircle2 size={48} />
             </div>
             <h4 className="text-xl font-black text-slate-900 uppercase tracking-widest">Selection Queue Clear</h4>
             <p className="text-sm text-slate-400 font-medium mt-2 tracking-tight">All supply and transfer missions have been facilities assigned.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default WHSelectionView;
