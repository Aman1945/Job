
import React, { useMemo } from 'react';
import { Order, OrderStatus } from '../types';
import { 
  Activity, Clock, Box, Truck, CheckCircle2, 
  MapPin, User, ChevronRight, Zap, ArrowUpRight,
  ShieldCheck, AlertCircle, Split
} from 'lucide-react';

interface LiveOrderViewProps {
  orders: Order[];
  onSelectOrder: (id: string) => void;
}

const LiveOrderView: React.FC<LiveOrderViewProps> = ({ orders, onSelectOrder }) => {
  const activeOrders = useMemo(() => {
    // Keep PART_PACKED and PART_ACCEPTED orders "open" and visible
    return orders.filter(o => 
      o.status !== OrderStatus.DELIVERED && 
      o.status !== OrderStatus.REJECTED &&
      o.status !== OrderStatus.RETURNED_TO_WH
    ).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [orders]);

  const recentHistory = useMemo(() => {
    const allHistory = orders.flatMap(o => (o.statusHistory || []).map(h => ({
      orderId: o.id,
      customerName: o.customerName,
      ...h
    })));
    return allHistory.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()).slice(0, 10);
  }, [orders]);

  const getProgress = (status: OrderStatus) => {
    switch(status) {
      case OrderStatus.PENDING_CREDIT_APPROVAL: return 10;
      case OrderStatus.PENDING_PACKING: return 25;
      case OrderStatus.PART_PACKED: return 35; // Special partial step
      case OrderStatus.PENDING_LOGISTICS: return 45;
      case OrderStatus.READY_FOR_BILLING: return 60;
      case OrderStatus.READY_FOR_DISPATCH: return 75;
      case OrderStatus.PICKED_UP: return 80;
      case OrderStatus.OUT_FOR_DELIVERY: return 90;
      case OrderStatus.PART_ACCEPTED: return 95; // Special partial end-stage
      default: return 0;
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="bg-slate-900 rounded-[40px] p-8 text-white shadow-2xl relative overflow-hidden group">
        <Activity className="absolute -right-6 -bottom-6 w-48 h-48 opacity-10 group-hover:scale-110 transition-transform duration-700 text-indigo-400" />
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <span className="w-3 h-3 bg-rose-500 rounded-full animate-pulse" />
              <h2 className="text-3xl font-black tracking-tight">Live Pulse Command Center</h2>
            </div>
            <p className="text-sm text-slate-400 font-medium tracking-tight uppercase">Monitoring {activeOrders.length} active supply missions (Including Partials)</p>
          </div>
          <div className="flex gap-4">
             <div className="bg-white/5 border border-white/10 p-4 rounded-3xl flex items-center gap-4 px-6">
                <div className="text-right">
                   <p className="text-2xl font-black">{activeOrders.length}</p>
                   <p className="text-[10px] font-bold text-slate-400 uppercase">In Flight</p>
                </div>
                <div className="w-10 h-10 bg-indigo-500/20 rounded-2xl flex items-center justify-center text-indigo-400">
                   <Zap size={20} />
                </div>
             </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div className="lg:col-span-3 space-y-6">
          <div className="flex items-center justify-between px-2">
             <h3 className="text-xs font-black text-slate-400 uppercase tracking-widest">Active Missions Dashboard</h3>
             <div className="flex items-center gap-2 text-[10px] font-bold text-slate-400 uppercase">
                <span className="w-2 h-2 rounded-full bg-emerald-500" /> Auto-Sync: 5s
             </div>
          </div>

          <div className="grid grid-cols-1 gap-6">
            {activeOrders.map(order => {
              const progress = getProgress(order.status);
              const isPartial = order.status === OrderStatus.PART_PACKED || order.status === OrderStatus.PART_ACCEPTED;
              
              return (
                <div 
                  key={order.id} 
                  onClick={() => onSelectOrder(order.id)}
                  className={`bg-white rounded-[40px] border p-8 shadow-sm hover:shadow-xl hover:border-indigo-200 transition-all cursor-pointer group relative overflow-hidden ${isPartial ? 'border-orange-200 bg-orange-50/5' : 'border-slate-200'}`}
                >
                  <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6 mb-8">
                    <div className="flex items-center gap-4">
                      <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shadow-lg transition-colors ${
                        order.status === OrderStatus.OUT_FOR_DELIVERY || order.status === OrderStatus.PICKED_UP ? 'bg-orange-600 text-white' : 
                        order.status === OrderStatus.PENDING_LOGISTICS ? 'bg-indigo-600 text-white' :
                        order.status === OrderStatus.PART_PACKED || order.status === OrderStatus.PART_ACCEPTED ? 'bg-orange-500 text-white' :
                        'bg-slate-100 text-slate-400 group-hover:bg-indigo-50 group-hover:text-indigo-600'
                      }`}>
                         {order.status === OrderStatus.OUT_FOR_DELIVERY || order.status === OrderStatus.PICKED_UP ? <Truck size={24} /> : order.status === OrderStatus.PENDING_PACKING ? <Box size={24} /> : <Clock size={24} />}
                      </div>
                      <div>
                         <div className="flex items-center gap-2">
                           <span className="font-black text-indigo-600 font-mono text-base">{order.id}</span>
                           <span className={`text-[9px] font-black px-2 py-0.5 rounded-lg uppercase border ${
                             order.status === OrderStatus.OUT_FOR_DELIVERY || order.status === OrderStatus.PICKED_UP ? 'bg-orange-50 text-orange-600 border-orange-100' : 
                             order.status === OrderStatus.PENDING_PACKING ? 'bg-blue-50 text-blue-600 border-blue-100' :
                             order.status === OrderStatus.PART_PACKED || order.status === OrderStatus.PART_ACCEPTED ? 'bg-orange-100 text-orange-700 border-orange-200' :
                             'bg-slate-100 text-slate-600 border-slate-200'
                           }`}>
                             {order.status}
                           </span>
                         </div>
                         <h4 className="text-xl font-black text-slate-900 mt-1">{order.customerName}</h4>
                      </div>
                    </div>
                    <div className="text-left md:text-right">
                       <p className="text-2xl font-black text-slate-900">₹{order.items.reduce((s,i)=>s+(i.price*(i.packedQuantity || i.quantity)),0).toLocaleString()}</p>
                       <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1">Consolidated Value</p>
                    </div>
                  </div>

                  <div className="space-y-4">
                    <div className="flex items-center justify-between px-1">
                      <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Journey Progress</p>
                      <p className={`text-[10px] font-black uppercase tracking-widest ${isPartial ? 'text-orange-600' : 'text-indigo-600'}`}>
                        {progress}% - {isPartial ? 'Partial Load Action Required' : 'On Track'}
                      </p>
                    </div>
                    <div className="w-full h-3 bg-slate-100 rounded-full overflow-hidden shadow-inner flex p-0.5">
                       <div 
                         className={`h-full rounded-full transition-all duration-1000 shadow-lg ${isPartial ? 'bg-orange-500 shadow-orange-500/50' : 'bg-indigo-600 shadow-indigo-500/50'}`} 
                         style={{ width: `${progress}%` }} 
                       />
                    </div>
                    <div className="flex justify-between text-[8px] font-black text-slate-300 uppercase tracking-widest px-1">
                       <span>Credit</span>
                       <span>Packing</span>
                       <span>Logistics</span>
                       <span>Billing</span>
                       <span>Final</span>
                    </div>
                  </div>

                  <div className="absolute top-8 right-8 text-slate-200 group-hover:text-indigo-600 group-hover:translate-x-1 group-hover:-translate-y-1 transition-all">
                     <ArrowUpRight size={24} />
                  </div>
                </div>
              );
            })}
            {activeOrders.length === 0 && (
              <div className="py-32 text-center bg-white rounded-[40px] border-2 border-dashed border-slate-200">
                 <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6 text-slate-200">
                    <ShieldCheck size={48} />
                 </div>
                 <h4 className="text-xl font-black text-slate-900 uppercase">Queue Clear</h4>
                 <p className="text-sm text-slate-400 font-medium mt-1">All orders are either delivered or pending initiation.</p>
              </div>
            )}
          </div>
        </div>

        <div className="space-y-8">
           <div className="flex items-center gap-3 px-2">
              <Activity size={16} className="text-rose-500" />
              <h3 className="text-xs font-black text-slate-400 uppercase tracking-widest">Global Status Feed</h3>
           </div>
           
           <div className="bg-white rounded-[40px] border border-slate-200 p-8 shadow-sm h-full max-h-[1000px] overflow-y-auto">
              <div className="space-y-10 relative">
                 <div className="absolute left-[13px] top-2 bottom-2 w-0.5 bg-slate-100" />
                 {recentHistory.map((h, i) => (
                   <div key={i} className="relative flex items-start gap-4">
                      <div className={`w-7 h-7 rounded-lg border-4 border-white shadow-md flex items-center justify-center z-10 ${
                        h.status === OrderStatus.DELIVERED ? 'bg-emerald-500 text-white' : 
                        h.status === OrderStatus.PART_PACKED || h.status === OrderStatus.PART_ACCEPTED ? 'bg-orange-500 text-white' :
                        h.status === OrderStatus.REJECTED ? 'bg-rose-500 text-white' :
                        'bg-slate-900 text-white'
                      }`}>
                         {h.status === OrderStatus.DELIVERED ? <CheckCircle2 size={12} /> : (h.status === OrderStatus.PART_PACKED || h.status === OrderStatus.PART_ACCEPTED) ? <Split size={12} /> : h.status === OrderStatus.REJECTED ? <AlertCircle size={12} /> : <Zap size={10} />}
                      </div>
                      <div className="flex-1 min-w-0">
                         <p className="text-[10px] font-black text-slate-900 truncate uppercase">{h.customerName}</p>
                         <div className="flex items-center gap-1.5 mt-0.5">
                            <span className="text-[9px] font-black text-indigo-600 font-mono">{h.orderId}</span>
                            <span className="text-slate-300">•</span>
                            <span className="text-[9px] font-bold text-slate-400">{new Date(h.timestamp).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'})}</span>
                         </div>
                         <p className="text-[10px] font-bold text-slate-500 mt-1">
                            Status moved to <span className="text-slate-900 font-black">{h.status}</span>
                         </p>
                      </div>
                   </div>
                 ))}
              </div>
           </div>
        </div>
      </div>
    </div>
  );
};

export default LiveOrderView;
