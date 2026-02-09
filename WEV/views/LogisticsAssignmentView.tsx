
import React, { useState, useMemo } from 'react';
import { Order, OrderStatus, User, UserRole } from '../types';
import { 
  Truck, 
  CheckCircle2, 
  UserCircle, 
  Navigation, 
  Box, 
  Calendar, 
  Clock, 
  ArrowRight, 
  Search, 
  Filter, 
  Activity, 
  MapPin,
  ChevronRight,
  ShieldCheck,
  PackageCheck,
  Download,
  FileText,
  ImageIcon,
  AlertCircle,
  History,
  Route,
  Zap
} from 'lucide-react';

interface LogisticsAssignmentViewProps {
  orders: Order[];
  users: User[];
  onBulkUpdate: (orders: Order[]) => void;
}

const LogisticsAssignmentView: React.FC<LogisticsAssignmentViewProps> = ({ orders, users, onBulkUpdate }) => {
  const [activeTab, setActiveTab] = useState<'pending' | 'active'>('pending');
  const [selectedOrderIds, setSelectedOrderIds] = useState<string[]>([]);
  const [assignedAgentId, setAssignedAgentId] = useState('');
  const [vehicleNo, setVehicleNo] = useState('');
  const [vehicleProvider, setVehicleProvider] = useState<'Internal' | 'Porter' | 'Other'>('Internal');
  const [distanceKm, setDistanceKm] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  const pendingOrders = useMemo(() => {
    // FIX: Orders move here AFTER Invoicing is finalized (status becomes READY_FOR_DISPATCH)
    // We only show those that haven't been assigned an agent yet.
    return orders.filter(o => 
      o.status === OrderStatus.READY_FOR_DISPATCH && 
      !o.logistics?.deliveryAgentId &&
      (o.id.toLowerCase().includes(searchTerm.toLowerCase()) || o.customerName.toLowerCase().includes(searchTerm.toLowerCase()))
    );
  }, [orders, searchTerm]);

  const activeShipments = useMemo(() => {
    // Show shipments that have been assigned a driver and are in transit or ready
    const trackableStatuses = [
      OrderStatus.READY_FOR_DISPATCH,
      OrderStatus.PICKED_UP,
      OrderStatus.OUT_FOR_DELIVERY,
      OrderStatus.DELIVERED,
      OrderStatus.PART_ACCEPTED,
      OrderStatus.RETURNED_TO_WH
    ];
    return orders.filter(o => 
      o.logistics?.deliveryAgentId &&
      trackableStatuses.includes(o.status) &&
      (o.id.toLowerCase().includes(searchTerm.toLowerCase()) || o.customerName.toLowerCase().includes(searchTerm.toLowerCase()))
    ).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [orders, searchTerm]);

  const deliveryAgents = useMemo(() => {
    return users.filter(u => u.role === UserRole.DELIVERY);
  }, [users]);

  const toggleSelection = (id: string) => {
    setSelectedOrderIds(prev => 
      prev.includes(id) ? prev.filter(oid => oid !== id) : [...prev, id]
    );
  };

  const handleBulkAssign = async () => {
    if (!assignedAgentId || !vehicleNo || selectedOrderIds.length === 0) return;
    
    setIsProcessing(true);
    await new Promise(r => setTimeout(r, 1200));

    const updatedOrders = orders.map(order => {
      if (selectedOrderIds.includes(order.id)) {
        // Status remains READY_FOR_DISPATCH but now has fleet metadata
        // It will now disappear from the 'pending' list and move to 'active'
        return {
          ...order,
          logistics: {
            ...(order.logistics || {
              thermacolBoxCount: 0,
              thermacolBoxAmount: 0,
              dryIceKg: 0,
              dryIceAmount: 0,
              whToStationAmount: 0,
              stationToLocAmount: 0,
              whToCustAmount: 0,
              mode: 'Road',
              transporterId: 'Internal'
            }),
            deliveryAgentId: assignedAgentId,
            vehicleNo: vehicleNo,
            vehicleProvider: vehicleProvider,
            distanceKm: parseFloat(distanceKm) || 0
          }
        };
      }
      return order;
    });

    onBulkUpdate(updatedOrders);
    setSelectedOrderIds([]);
    setAssignedAgentId('');
    setVehicleNo('');
    setDistanceKm('');
    setVehicleProvider('Internal');
    setIsProcessing(false);
    setActiveTab('active'); 
  };

  const getStatusConfig = (status: OrderStatus) => {
    switch(status) {
      case OrderStatus.READY_FOR_DISPATCH: return { label: 'Awaiting Driver Receipt', color: 'bg-emerald-100 text-emerald-700' };
      case OrderStatus.PICKED_UP: return { label: 'Loaded/At Hub', color: 'bg-indigo-100 text-indigo-700' };
      case OrderStatus.OUT_FOR_DELIVERY: return { label: 'On Route', color: 'bg-emerald-600 text-white shadow-lg' };
      case OrderStatus.DELIVERED: return { label: 'Mission Success', color: 'bg-emerald-100 text-emerald-700' };
      case OrderStatus.PART_ACCEPTED: return { label: 'Partially Fulfilled', color: 'bg-amber-100 text-amber-700' };
      default: return { label: status, color: 'bg-slate-100 text-slate-600' };
    }
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8 pb-24 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Logistics Hub (Fleet Loading)</h2>
          <p className="text-sm text-slate-500 font-medium">Assign delivery agents and vehicles to invoiced missions</p>
        </div>
        
        <div className="flex bg-slate-200 p-1 rounded-2xl border border-slate-300 shadow-inner">
           <button onClick={() => setActiveTab('pending')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeTab === 'pending' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Unassigned ({pendingOrders.length})</button>
           <button onClick={() => setActiveTab('active')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeTab === 'active' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Track Trips ({activeShipments.length})</button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div className="lg:col-span-3 space-y-4">
          <div className="relative group">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
            <input type="text" placeholder={`Trace by ID or Client...`} className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium focus:ring-4 focus:ring-emerald-500/10 focus:border-emerald-600 outline-none transition-all shadow-sm" value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} />
          </div>

          {activeTab === 'pending' ? (
            <div className="bg-white rounded-[32px] border border-slate-200 shadow-sm overflow-hidden animate-in slide-in-from-left-4">
              <table className="w-full text-left">
                <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b border-slate-100">
                  <tr>
                    <th className="px-8 py-5 w-12"><input type="checkbox" className="rounded border-slate-300 text-emerald-600 focus:ring-emerald-500" checked={selectedOrderIds.length === pendingOrders.length && pendingOrders.length > 0} onChange={(e) => { if (e.target.checked) setSelectedOrderIds(pendingOrders.map(o => o.id)); else setSelectedOrderIds([]); }} /></th>
                    <th className="px-6 py-5">Mission ID</th>
                    <th className="px-6 py-5">Customer Entity</th>
                    <th className="px-6 py-5 text-center">Boxes</th>
                    <th className="px-6 py-5 text-center">Invoice Number</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-50 text-sm">
                  {pendingOrders.map(order => (
                    <tr key={order.id} className={`hover:bg-emerald-50/10 transition-colors cursor-pointer ${selectedOrderIds.includes(order.id) ? 'bg-emerald-50/30' : ''}`} onClick={() => toggleSelection(order.id)}>
                      <td className="px-8 py-5"><input type="checkbox" className="rounded border-slate-300 text-emerald-600 focus:ring-emerald-500" checked={selectedOrderIds.includes(order.id)} onChange={(e) => { e.stopPropagation(); toggleSelection(order.id); }} /></td>
                      <td className="px-6 py-5"><p className="font-mono font-black text-emerald-600 uppercase">{order.id}</p><p className="text-[9px] text-slate-300 font-bold uppercase">Ready For Loading</p></td>
                      <td className="px-6 py-5 font-bold text-slate-800">{order.customerName}</td>
                      <td className="px-6 py-5 text-center"><span className="inline-flex items-center gap-1.5 px-3 py-1 bg-emerald-50 text-emerald-600 rounded-full text-xs font-black border border-emerald-100"><Box size={12} /> {order.packedBoxes || 0}</span></td>
                      <td className="px-6 py-5 text-center"><span className="text-[10px] font-black uppercase text-indigo-600 bg-indigo-50 px-2 py-1 rounded-lg border border-indigo-100">{order.invoiceNo || 'INV-PNDG'}</span></td>
                    </tr>
                  ))}
                  {pendingOrders.length === 0 && (<tr><td colSpan={5} className="px-8 py-24 text-center text-slate-300 font-bold uppercase tracking-widest italic">All invoiced loads assigned to fleet.</td></tr>)}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="space-y-4 animate-in slide-in-from-right-4">
              {activeShipments.map(order => {
                const agent = users.find(u => u.id === order.logistics?.deliveryAgentId);
                const statusInfo = getStatusConfig(order.status);
                return (
                  <div key={order.id} className="bg-white rounded-[32px] border border-slate-200 overflow-hidden shadow-sm group hover:border-emerald-200 transition-all">
                     <div className="p-6 flex flex-col md:flex-row items-center gap-6">
                        <div className={`w-16 h-16 rounded-2xl flex items-center justify-center shrink-0 transition-all ${order.status === OrderStatus.DELIVERED ? 'bg-emerald-50 text-emerald-600' : 'bg-slate-50 text-slate-400 group-hover:bg-emerald-50 group-hover:text-emerald-600'}`}>
                           {order.status === OrderStatus.DELIVERED ? <CheckCircle2 size={28} /> : <Truck size={28} />}
                        </div>
                        <div className="flex-1 min-w-0">
                           <div className="flex items-center gap-3 mb-1">
                              <span className="text-xs font-black text-emerald-600 font-mono">{order.id}</span>
                              <span className={`text-[9px] font-black px-2 py-0.5 rounded-lg uppercase ${statusInfo.color}`}>{statusInfo.label}</span>
                              <span className="text-[8px] font-black px-2 py-0.5 rounded-lg uppercase bg-slate-100 text-slate-500">Fleet: {order.logistics?.vehicleProvider || 'Internal'}</span>
                           </div>
                           <h4 className="font-black text-slate-900 truncate">{order.customerName}</h4>
                           <div className="flex flex-wrap items-center gap-y-2 gap-x-4 mt-2">
                              <div className="flex items-center gap-1.5"><UserCircle size={14} className="text-slate-400" /><span className="text-[10px] font-bold text-slate-500 uppercase">{agent?.name || 'Unassigned'}</span></div>
                              <div className="flex items-center gap-1.5"><Activity size={14} className="text-slate-400" /><span className="text-[10px] font-bold text-slate-500 uppercase">{order.logistics?.vehicleNo || 'N/A'}</span></div>
                              <div className="flex items-center gap-1.5"><Route size={14} className="text-slate-400" /><span className="text-[10px] font-bold text-slate-500 uppercase">{order.logistics?.distanceKm || 0} KM</span></div>
                           </div>
                        </div>
                        <div className="text-right shrink-0">
                           <p className="text-xl font-black text-slate-900">₹{order.items.reduce((s,i)=>s+(i.price*(i.packedQuantity || i.quantity)),0).toLocaleString()}</p>
                           <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">Invoiced Value</p>
                        </div>
                     </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        <div className="space-y-6">
          <div className="bg-emerald-950 rounded-[40px] p-8 text-white shadow-2xl border border-emerald-900 relative overflow-hidden group">
            <h4 className="text-xl font-black mb-8 flex items-center gap-3"><Navigation className="text-emerald-400" size={24} /> Assignment Panel</h4>
            <div className="space-y-6">
              <div className="space-y-2">
                <label className="text-[10px] font-black text-emerald-400/60 uppercase tracking-widest px-1">Fleet Provider</label>
                <div className="grid grid-cols-3 gap-2">
                   {['Internal', 'Porter', 'Other'].map((p) => (
                     <button key={p} onClick={() => setVehicleProvider(p as any)} className={`py-3 rounded-xl text-[9px] font-black uppercase tracking-widest transition-all border ${vehicleProvider === p ? 'bg-emerald-500 text-white border-emerald-400 shadow-lg' : 'bg-white/5 text-emerald-500/40 border-white/5 hover:bg-white/10'}`}>{p}</button>
                   ))}
                </div>
              </div>
              <div className="space-y-2">
                <label className="text-[10px] font-black text-emerald-400/60 uppercase tracking-widest px-1">Delivery Executive</label>
                <select className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-emerald-500/50 outline-none appearance-none transition-all" value={assignedAgentId} onChange={(e) => setAssignedAgentId(e.target.value)}>
                    <option value="" className="bg-emerald-950">Select Agent...</option>
                    {deliveryAgents.map(agent => (<option key={agent.id} value={agent.id} className="bg-emerald-950">{agent.name}</option>))}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-[10px] font-black text-emerald-400/60 uppercase tracking-widest px-1">Vehicle Reg No.</label>
                <input type="text" placeholder="e.g. MH-12-Nexus-1234" className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-emerald-500/50 outline-none transition-all uppercase placeholder:text-emerald-900/40" value={vehicleNo} onChange={(e) => setVehicleNo(e.target.value)} />
              </div>
              <div className="space-y-2">
                <label className="text-[10px] font-black text-emerald-400/60 uppercase tracking-widest px-1">Journey Est. (KM)</label>
                <input type="number" placeholder="0" className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-emerald-500/50 outline-none transition-all placeholder:text-emerald-900/40" value={distanceKm} onChange={(e) => setDistanceKm(e.target.value)} />
              </div>
              <button onClick={handleBulkAssign} disabled={!assignedAgentId || !vehicleNo || selectedOrderIds.length === 0 || isProcessing} className="w-full bg-emerald-500 text-white py-5 rounded-[24px] font-black text-sm uppercase tracking-[0.15em] hover:bg-emerald-400 shadow-xl shadow-emerald-500/20 active:scale-95 transition-all disabled:opacity-30 flex items-center justify-center gap-3">
                  {isProcessing ? (<div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />) : (<>Confirm Loading <ArrowRight size={18} /></>)}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LogisticsAssignmentView;
