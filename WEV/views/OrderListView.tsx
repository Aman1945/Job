
import React, { useState, useMemo } from 'react';
import { Order, OrderStatus, UserRole, User } from '../types';
import { Search, Filter, ArrowUpRight, Check, XCircle, Package, Truck, Receipt, ExternalLink, Clock, CheckCircle2, RefreshCcw } from 'lucide-react';

interface OrderListViewProps {
  orders: Order[];
  onSelect: (id: string) => void;
  onUpdateOrder: (order: Order) => void;
  currentUser: User;
  stageFilter?: OrderStatus;
}

const OrderListView: React.FC<OrderListViewProps> = ({ orders, onSelect, onUpdateOrder, currentUser, stageFilter }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>(stageFilter || 'all');
  const [processingId, setProcessingId] = useState<string | null>(null);

  const userRole = currentUser.role as UserRole;

  const filteredOrders = useMemo(() => {
    return orders.filter(o => {
      const searchLower = searchTerm.toLowerCase().trim();
      const matchesSearch = !searchLower || 
                            o.id.toLowerCase().includes(searchLower) || 
                            o.customerName.toLowerCase().includes(searchLower);
      
      const matchesManualFilter = (statusFilter === 'all' || o.status === statusFilter);
      
      if (!matchesSearch || !matchesManualFilter) return false;

      // STNs bypass Credit Control entirely
      if (stageFilter === OrderStatus.PENDING_CREDIT_APPROVAL && o.isSTN) return false;

      // If a hard stageFilter is passed, restrict to that status
      if (stageFilter && o.status !== stageFilter) return false;

      return true;
    });
  }, [orders, searchTerm, statusFilter, userRole, stageFilter]);

  const handleQuickAction = async (order: Order, nextStatus: OrderStatus, extraData: Partial<Order> = {}) => {
    setProcessingId(order.id);
    await new Promise(r => setTimeout(r, 600));
    
    const timestamp = new Date().toISOString();
    const updatedHistory = [...(order.statusHistory || []), { status: nextStatus, timestamp }];
    
    onUpdateOrder({ 
      ...order, 
      status: nextStatus, 
      statusHistory: updatedHistory,
      ...extraData 
    });
    setProcessingId(null);
  };

  const getQuickAction = (order: Order) => {
    const isAdmin = userRole === UserRole.ADMIN;
    const isProcessing = processingId === order.id;

    const actionBtn = (label: string, icon: React.ReactNode, nextStatus: OrderStatus, colorClass: string, extra: any = {}) => (
      <button 
        onClick={(e) => { e.stopPropagation(); handleQuickAction(order, nextStatus, extra); }}
        disabled={isProcessing}
        className={`${colorClass} px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest flex items-center gap-2 transition-all active:scale-95 disabled:opacity-50 shadow-lg whitespace-nowrap`}
      >
        {isProcessing ? <div className="w-3 h-3 border-2 border-current border-t-transparent rounded-full animate-spin" /> : icon}
        {label}
      </button>
    );

    if (order.status === OrderStatus.PENDING_CREDIT_APPROVAL) {
       return actionBtn('APPROVE', <Check size={14} />, OrderStatus.PENDING_PACKING, 'bg-emerald-600 text-white hover:bg-emerald-700 shadow-emerald-500/20');
    }
    if (order.status === OrderStatus.PENDING_PACKING) {
       return actionBtn('PACK LOAD', <Package size={14} />, OrderStatus.READY_FOR_BILLING, 'bg-indigo-600 text-white hover:bg-indigo-700 shadow-indigo-500/20');
    }

    return <span className="text-slate-300 italic text-[10px] font-bold uppercase tracking-widest">{order.status}</span>;
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md group">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
          <input 
            type="text"
            className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-10 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-emerald-500/10 focus:border-emerald-500 outline-none transition-all"
            placeholder="Trace Reference ID or Client..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b border-slate-100">
              <tr>
                <th className="px-8 py-6">Mission Ref</th>
                <th className="px-6 py-6">Entity Identity</th>
                <th className="px-6 py-6 text-center">Current Status</th>
                <th className="px-6 py-6 text-right">Reference Value (₹)</th>
                <th className="px-8 py-6 text-center">Workflow Action</th>
                <th className="px-8 py-6"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50 text-sm font-bold text-slate-700">
              {filteredOrders.length > 0 ? filteredOrders.map(order => (
                <tr key={order.id} onClick={() => onSelect(order.id)} className={`hover:bg-emerald-50/10 transition-all cursor-pointer group ${order.isSTN ? 'bg-indigo-50/5' : ''}`}>
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-2">
                       {order.isSTN ? <RefreshCcw size={14} className="text-indigo-600" /> : null}
                       <span className={`font-mono font-black text-base ${order.isSTN ? 'text-indigo-600' : 'text-emerald-600'}`}>{order.id}</span>
                    </div>
                  </td>
                  <td className="px-6 py-6">
                    <p className="text-slate-900">{order.customerName}</p>
                    {order.isSTN && <p className="text-[9px] font-black text-indigo-500 uppercase">INTERNAL STOCK TRANSFER</p>}
                  </td>
                  <td className="px-6 py-6 text-center"><span className="inline-block px-3 py-1 rounded-lg text-[9px] font-black uppercase tracking-wider bg-slate-100 text-slate-600">{order.status}</span></td>
                  <td className="px-6 py-6 text-right font-black text-slate-900">₹{order.items.reduce((sum, item) => sum + (item.price * (item.packedQuantity || item.quantity)), 0).toLocaleString()}</td>
                  <td className="px-8 py-6 text-center"><div className="flex justify-center">{getQuickAction(order)}</div></td>
                  <td className="px-8 py-6 text-right"><div className="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-300 group-hover:text-emerald-600 transition-all"><ArrowUpRight size={20} /></div></td>
                </tr>
              )) : (
                <tr><td colSpan={6} className="px-8 py-32 text-center text-slate-400 font-medium italic">Mission queue empty for this stage.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default OrderListView;
