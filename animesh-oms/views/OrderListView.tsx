
import React, { useState, useMemo } from 'react';
import { Order, OrderStatus, UserRole, User } from '../types';
import { 
  Search, 
  ArrowUpRight, 
  Check, 
  XCircle, 
  Eye, 
  ShieldAlert, 
  RefreshCcw, 
  ArrowUpDown, 
  ArrowUp, 
  ArrowDown,
  ChevronDown,
  ChevronUp,
  Package,
  Box,
  FileText,
  Filter
} from 'lucide-react';

interface OrderListViewProps {
  orders: Order[];
  onSelect: (id: string) => void;
  onUpdateOrder: (order: Order) => void;
  currentUser: User;
  stageFilter?: OrderStatus;
  multiStageFilter?: OrderStatus[];
}

type SortKey = 'id' | 'customerName' | 'status' | 'value';
type SortDirection = 'asc' | 'desc' | null;

const OrderListView: React.FC<OrderListViewProps> = ({ orders, onSelect, onUpdateOrder, currentUser, stageFilter, multiStageFilter }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>(stageFilter || 'all');
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [sortKey, setSortKey] = useState<SortKey>('id');
  const [sortDirection, setSortDirection] = useState<SortDirection>('desc');
  const [expandedOrders, setExpandedOrders] = useState<Set<string>>(new Set());

  const userRole = currentUser.role as UserRole;

  const toggleExpand = (e: React.MouseEvent, id: string) => {
    e.stopPropagation();
    const newSet = new Set(expandedOrders);
    if (newSet.has(id)) newSet.delete(id);
    else newSet.add(id);
    setExpandedOrders(newSet);
  };

  const handleSort = (key: SortKey) => {
    if (sortKey === key) {
      setSortDirection(prev => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(key);
      setSortDirection('asc');
    }
  };

  const getSortIcon = (key: SortKey) => {
    if (sortKey !== key) return <ArrowUpDown size={14} className="text-slate-300" />;
    return sortDirection === 'asc' ? <ArrowUp size={14} className="text-indigo-600" /> : <ArrowDown size={14} className="text-indigo-600" />;
  };

  const filteredAndSortedOrders = useMemo(() => {
    const filtered = orders.filter(o => {
      const searchLower = searchTerm.toLowerCase().trim();
      const matchesSearch = !searchLower || 
                            o.id.toLowerCase().includes(searchLower) || 
                            o.customerName.toLowerCase().includes(searchLower);
      
      const matchesManualFilter = (statusFilter === 'all' || o.status === statusFilter);
      
      if (!matchesSearch || !matchesManualFilter) return false;

      // STNs bypass Credit Control entirely
      if (stageFilter === OrderStatus.PENDING_CREDIT_APPROVAL && o.isSTN) return false;

      // Stage Filtering Logic
      if (multiStageFilter && multiStageFilter.length > 0) {
        if (!multiStageFilter.includes(o.status)) return false;
      } else if (stageFilter && o.status !== stageFilter) {
        return false;
      }

      return true;
    });

    if (!sortDirection) return filtered;

    return [...filtered].sort((a, b) => {
      let valA: any;
      let valB: any;

      switch (sortKey) {
        case 'id':
          valA = a.id;
          valB = b.id;
          break;
        case 'customerName':
          valA = a.customerName;
          valB = b.customerName;
          break;
        case 'status':
          valA = a.status;
          valB = b.status;
          break;
        case 'value':
          valA = a.items.reduce((sum, item) => sum + (item.price * (item.packedQuantity || item.quantity)), 0);
          valB = b.items.reduce((sum, item) => sum + (item.price * (item.packedQuantity || item.quantity)), 0);
          break;
        default:
          return 0;
      }

      if (valA < valB) return sortDirection === 'asc' ? -1 : 1;
      if (valA > valB) return sortDirection === 'asc' ? 1 : -1;
      return 0;
    });
  }, [orders, searchTerm, statusFilter, stageFilter, multiStageFilter, sortKey, sortDirection]);

  const handleQuickAction = async (order: Order, nextStatus: OrderStatus, extraData: Partial<Order> = {}) => {
    setProcessingId(order.id);
    await new Promise(r => setTimeout(r, 600));
    
    const timestamp = new Date().toISOString();
    const updatedHistory = [...(order.statusHistory || []), { status: nextStatus, timestamp, userName: currentUser.name }];
    
    onUpdateOrder({ 
      ...order, 
      status: nextStatus, 
      statusHistory: updatedHistory,
      ...extraData 
    });
    setProcessingId(null);
  };

  const getQuickAction = (order: Order) => {
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
       return actionBtn('APPROVE', <Check size={14} />, OrderStatus.PENDING_WH_SELECTION, 'bg-emerald-600 text-white hover:bg-emerald-700 shadow-emerald-500/20');
    }
    if (order.status === OrderStatus.PENDING_PACKING || order.status === OrderStatus.PART_PACKED || order.status === OrderStatus.BACKORDER) {
       return actionBtn('PUSH TO QC', <ShieldAlert size={14} />, OrderStatus.PENDING_QC, 'bg-indigo-600 text-white hover:bg-indigo-700 shadow-indigo-500/20');
    }

    return <span className="text-slate-300 italic text-[10px] font-bold uppercase tracking-widest">{order.status}</span>;
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="flex flex-1 items-center gap-4">
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

          {(!stageFilter || (multiStageFilter && multiStageFilter.length > 1)) && (
            <div className="relative group">
              <Filter className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
              <select
                className="appearance-none bg-white border border-slate-200 rounded-2xl pl-12 pr-10 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-emerald-500/10 focus:border-emerald-500 outline-none transition-all cursor-pointer min-w-[200px]"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option value="all">{multiStageFilter ? 'All Stage Statuses' : 'All Statuses'}</option>
                {Object.values(OrderStatus)
                  .filter(status => !multiStageFilter || multiStageFilter.includes(status))
                  .map(status => (
                    <option key={status} value={status}>{status}</option>
                  ))}
              </select>
              <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" size={16} />
            </div>
          )}
        </div>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b border-slate-100">
              <tr>
                <th className="px-6 py-6 w-12"></th>
                <th 
                  className="px-6 py-6 cursor-pointer hover:bg-slate-100/50 transition-colors group"
                  onClick={() => handleSort('id')}
                >
                  <div className="flex items-center gap-2">
                    Mission Ref {getSortIcon('id')}
                  </div>
                </th>
                <th 
                  className="px-6 py-6 cursor-pointer hover:bg-slate-100/50 transition-colors group"
                  onClick={() => handleSort('customerName')}
                >
                  <div className="flex items-center gap-2">
                    Entity & Order Summary {getSortIcon('customerName')}
                  </div>
                </th>
                <th 
                  className="px-6 py-6 text-center cursor-pointer hover:bg-slate-100/50 transition-colors group"
                  onClick={() => handleSort('status')}
                >
                  <div className="flex items-center justify-center gap-2">
                    Current Status {getSortIcon('status')}
                  </div>
                </th>
                <th 
                  className="px-6 py-6 text-right cursor-pointer hover:bg-slate-100/50 transition-colors group"
                  onClick={() => handleSort('value')}
                >
                  <div className="flex items-center justify-end gap-2">
                    Reference Value (₹) {getSortIcon('value')}
                  </div>
                </th>
                <th className="px-8 py-6 text-center">Workflow Action</th>
                <th className="px-8 py-6 text-right">Operations</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50 text-sm font-bold text-slate-700">
              {filteredAndSortedOrders.length > 0 ? filteredAndSortedOrders.map(order => (
                <React.Fragment key={order.id}>
                  <tr onClick={() => onSelect(order.id)} className={`hover:bg-emerald-50/10 transition-all cursor-pointer group ${order.isSTN ? 'bg-indigo-50/5' : ''}`}>
                    <td className="px-6 py-6">
                      <button 
                        onClick={(e) => toggleExpand(e, order.id)}
                        className={`p-2 rounded-lg transition-all ${expandedOrders.has(order.id) ? 'bg-indigo-600 text-white shadow-lg' : 'bg-slate-50 text-slate-300 hover:bg-slate-100 hover:text-indigo-600'}`}
                      >
                        {expandedOrders.has(order.id) ? <ChevronUp size={16}/> : <ChevronDown size={16}/>}
                      </button>
                    </td>
                    <td className="px-6 py-6">
                      <div className="flex items-center gap-2">
                         {order.isSTN ? <RefreshCcw size={14} className="text-indigo-600" /> : null}
                         <span className={`font-mono font-black text-base ${order.isSTN ? 'text-indigo-600' : 'text-emerald-600'}`}>{order.id}</span>
                      </div>
                      <div className="text-[8px] text-slate-400 font-bold uppercase mt-1">
                        {new Date(order.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short' })}
                      </div>
                    </td>
                    <td className="px-6 py-6">
                      <p className="text-slate-900 leading-tight">{order.customerName}</p>
                      {/* Short Order Summary Display */}
                      <div className="mt-1.5 flex flex-col gap-1">
                        <div className="text-[10px] text-slate-500 font-medium line-clamp-1 flex items-center gap-1.5 bg-slate-50 py-1 px-2 rounded-lg border border-slate-100 max-w-[400px]">
                           <Package size={10} className="text-indigo-400 shrink-0" />
                           <span className="truncate">
                             {order.items.map(i => `${i.productName} (${i.quantity} ${i.unit})`).join(', ')}
                           </span>
                        </div>
                        {order.isSTN && <p className="text-[8px] font-black text-indigo-500 uppercase tracking-widest bg-indigo-50 px-1.5 py-0.5 rounded w-fit">Stock Transfer Mode</p>}
                      </div>
                    </td>
                    <td className="px-6 py-6 text-center">
                      <span className={`inline-block px-3 py-1 rounded-lg text-[9px] font-black uppercase tracking-wider border ${
                        order.status === OrderStatus.PART_PACKED || order.status === OrderStatus.BACKORDER ? 'bg-orange-50 text-orange-600 border-orange-100' : 'bg-slate-100 text-slate-600'
                      }`}>
                        {order.status}
                      </span>
                    </td>
                    <td className="px-6 py-6 text-right font-black text-slate-900">₹{order.items.reduce((sum, item) => sum + (item.price * (item.packedQuantity || item.quantity)), 0).toLocaleString()}</td>
                    <td className="px-8 py-6 text-center"><div className="flex justify-center">{getQuickAction(order)}</div></td>
                    <td className="px-8 py-6 text-right">
                      <div className="flex items-center justify-end gap-3">
                        <button 
                          onClick={(e) => { e.stopPropagation(); onSelect(order.id); }}
                          className="flex items-center gap-2 px-4 py-2 bg-slate-900 text-white text-[10px] font-black uppercase tracking-widest rounded-xl hover:bg-indigo-600 transition-all shadow-md active:scale-95"
                        >
                          <Eye size={14} /> Full View
                        </button>
                        <div className="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-300 group-hover:text-emerald-600 transition-all">
                          <ArrowUpRight size={20} />
                        </div>
                      </div>
                    </td>
                  </tr>
                  
                  {/* Expanded Summary Row */}
                  {expandedOrders.has(order.id) && (
                    <tr className="bg-slate-50/50">
                      <td colSpan={7} className="px-12 py-6 animate-in slide-in-from-top-2 duration-300">
                        <div className="bg-white rounded-3xl border border-slate-200 shadow-xl overflow-hidden">
                           <div className="p-5 border-b bg-slate-50/50 flex items-center justify-between">
                              <h5 className="text-[10px] font-black text-slate-400 uppercase tracking-widest flex items-center gap-2">
                                <Package size={14} className="text-indigo-600" /> Order SKU Summary
                              </h5>
                              <span className="text-[10px] font-black text-indigo-600 bg-indigo-50 px-3 py-1 rounded-full">
                                {order.items.length} Line Items
                              </span>
                           </div>
                           <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-5">
                              {order.items.map((item, idx) => (
                                <div key={idx} className="flex items-center justify-between p-4 bg-slate-50 rounded-2xl border border-slate-100">
                                   <div className="min-w-0 flex-1">
                                      <p className="text-xs font-black text-slate-900 truncate">{item.productName}</p>
                                      <p className="text-[9px] font-bold text-slate-400 uppercase mt-0.5">{item.skuCode}</p>
                                   </div>
                                   <div className="text-right ml-4">
                                      <p className="text-sm font-black text-indigo-600">{item.quantity} {item.unit}</p>
                                      <p className="text-[9px] font-bold text-slate-300 uppercase">Qty</p>
                                   </div>
                                </div>
                              ))}
                           </div>
                           {order.generalRemarks && (
                             <div className="p-5 bg-indigo-50/30 border-t border-indigo-100 flex items-start gap-3">
                                <FileText size={14} className="text-indigo-400 mt-0.5" />
                                <div>
                                   <p className="text-[9px] font-black text-indigo-400 uppercase">Booking Remarks</p>
                                   <p className="text-xs font-bold text-slate-600 mt-1 italic">{order.generalRemarks}</p>
                                </div>
                             </div>
                           )}
                        </div>
                      </td>
                    </tr>
                  )}
                </React.Fragment>
              )) : (
                <tr><td colSpan={7} className="px-8 py-32 text-center text-slate-400 font-medium italic">Mission queue empty for this stage.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default OrderListView;
