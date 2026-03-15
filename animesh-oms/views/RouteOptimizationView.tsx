
import React, { useState, useMemo } from 'react';
import { Order, OrderStatus, RTVReturn, Vehicle, User, RouteStop, DeliveryRoute } from '../types';
import { optimizeRoute, WAREHOUSE_COORDS } from '../services/routeService';
import { 
  Navigation, 
  Truck, 
  Map as MapIcon, 
  Zap, 
  Box, 
  Package, 
  ArrowRight, 
  RotateCcw, 
  Warehouse, 
  Plus, 
  CheckCircle2, 
  Clock, 
  AlertTriangle,
  History,
  Activity,
  Maximize2,
  Trash2,
  ArrowUpRight,
  // Added missing icons
  Layers,
  RotateCw,
  ShieldCheck
} from 'lucide-react';

interface RouteOptimizationViewProps {
  orders: Order[];
  rtvs: RTVReturn[];
  vehicles: Vehicle[];
  deliveryAgents: User[];
  onRouteCreated: (route: DeliveryRoute) => void;
}

const RouteOptimizationView: React.FC<RouteOptimizationViewProps> = ({ 
  orders, rtvs, vehicles, deliveryAgents, onRouteCreated 
}) => {
  const [selectedWarehouse, setSelectedWarehouse] = useState<string>('IOPL Kurla');
  const [selectedVehicleId, setSelectedVehicleId] = useState<string>('');
  const [selectedAgentId, setSelectedAgentId] = useState<string>('');
  const [isOptimizing, setIsOptimizing] = useState(false);
  const [plannedRoute, setPlannedRoute] = useState<RouteStop[]>([]);

  // Consolidate pending tasks for the current warehouse
  const pendingTasks = useMemo(() => {
    const list: RouteStop[] = [];
    
    // 1. Deliveries from this warehouse
    orders.filter(o => o.status === OrderStatus.READY_FOR_DISPATCH && o.warehouseSource === selectedWarehouse)
      .forEach(o => list.push({
        id: `STOP-${o.id}`,
        referenceId: o.id,
        type: o.isSTN ? 'STOCK_TRANSFER' : 'DELIVERY',
        name: o.customerName,
        address: 'Customer Address Hub', // In real app, from Customer object
        coords: { lat: 19.0 + Math.random()*0.5, lng: 72.8 + Math.random()*0.5 }, // Simulated
        status: 'PENDING',
        sequence: 0,
        weightKg: o.weightKg || 50,
        volumeCft: 10
      }));

    // 2. RTV Pickups that should return to this warehouse
    rtvs.filter(r => r.status === 'QC_Pending')
      .forEach(r => list.push({
        id: `STOP-${r.id}`,
        referenceId: r.id,
        type: 'RETURN_PICKUP',
        name: r.customerName,
        address: 'Return Pickup Location',
        coords: { lat: 19.0 + Math.random()*0.5, lng: 72.8 + Math.random()*0.5 },
        status: 'PENDING',
        sequence: 0,
        weightKg: r.weightKg || 20,
        volumeCft: 5
      }));

    return list;
  }, [orders, rtvs, selectedWarehouse]);

  const handleOptimize = async () => {
    const vehicle = vehicles.find(v => v.id === selectedVehicleId);
    if (!vehicle) return;

    setIsOptimizing(true);
    try {
      const optimized = await optimizeRoute(
        pendingTasks, 
        WAREHOUSE_COORDS[selectedWarehouse], 
        vehicle
      );
      setPlannedRoute(optimized);
    } catch (e) {
      console.error(e);
    } finally {
      setIsOptimizing(false);
    }
  };

  const handleDispatch = () => {
    if (!selectedVehicleId || !selectedAgentId || plannedRoute.length === 0) return;
    
    const newRoute: DeliveryRoute = {
      id: `ROUTE-${Date.now().toString().slice(-6)}`,
      vehicleId: selectedVehicleId,
      driverId: selectedAgentId,
      depotId: selectedWarehouse,
      stops: plannedRoute,
      totalDistance: plannedRoute.reduce((s, st) => s + (st.distanceFromPrev || 0), 0),
      estimatedTimeMin: plannedRoute.length * 20, // rough est
      status: 'ACTIVE',
      startTime: new Date().toISOString()
    };

    onRouteCreated(newRoute);
    setPlannedRoute([]);
    setSelectedVehicleId('');
    setSelectedAgentId('');
    alert("Mission Dispatched to Driver Terminal.");
  };

  return (
    <div className="max-w-[1600px] mx-auto space-y-8 animate-in fade-in duration-500 pb-24">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-4xl font-black text-slate-900 tracking-tighter flex items-center gap-3">
             <Navigation className="text-emerald-500" /> Logistics Intelligence Hub
          </h2>
          <p className="text-sm text-slate-500 font-medium mt-1 uppercase tracking-widest">Multi-Depot VRP Route Optimization Terminal</p>
        </div>
        <div className="flex bg-slate-200 p-1 rounded-[24px] border border-slate-300 shadow-inner">
           {Object.keys(WAREHOUSE_COORDS).map(wh => (
             <button 
               key={wh} 
               onClick={() => {setSelectedWarehouse(wh); setPlannedRoute([]);}}
               className={`px-6 py-2.5 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all ${selectedWarehouse === wh ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}
             >
               {wh}
             </button>
           ))}
        </div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-4 gap-10">
        
        {/* Left: Pending Task Pool */}
        <div className="xl:col-span-1 space-y-6">
           <div className="bg-white rounded-[40px] border border-slate-200 p-8 shadow-sm h-fit">
              <h3 className="text-xs font-black text-slate-400 uppercase tracking-[0.2em] mb-8 flex items-center gap-2">
                 <Package size={16} className="text-indigo-600" /> Dispatch Pool ({pendingTasks.length})
              </h3>
              <div className="space-y-4 max-h-[600px] overflow-y-auto no-scrollbar">
                 {pendingTasks.map(task => (
                   <div key={task.id} className="p-5 rounded-[28px] bg-slate-50 border border-slate-100 flex items-start gap-4 group hover:border-emerald-500 transition-all">
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${task.type === 'DELIVERY' ? 'bg-emerald-50 text-emerald-600' : task.type === 'RETURN_PICKUP' ? 'bg-rose-50 text-rose-600' : 'bg-indigo-50 text-indigo-600'}`}>
                         {task.type === 'DELIVERY' ? <Truck size={20}/> : task.type === 'RETURN_PICKUP' ? <RotateCcw size={20}/> : <Warehouse size={20}/>}
                      </div>
                      <div className="min-w-0">
                         <p className="text-xs font-black text-slate-900 truncate">{task.name}</p>
                         <div className="flex items-center gap-2 mt-1">
                            <span className="text-[8px] font-black uppercase text-slate-400">Ref: {task.referenceId}</span>
                            <span className="text-[8px] font-black uppercase text-indigo-500">{task.weightKg} KG</span>
                         </div>
                      </div>
                   </div>
                 ))}
                 {pendingTasks.length === 0 && (
                   <div className="py-20 text-center space-y-4 opacity-30">
                      <CheckCircle2 className="mx-auto" size={48}/>
                      <p className="text-[10px] font-black uppercase tracking-widest">Queue Clear</p>
                   </div>
                 )}
              </div>
           </div>

           <div className="bg-slate-900 rounded-[40px] p-8 text-white shadow-2xl space-y-8">
              <h4 className="text-xl font-black flex items-center gap-3 text-emerald-400"><Activity /> Fleet Capacity</h4>
              <div className="space-y-6">
                 {vehicles.map(v => (
                   <div key={v.id} className="p-4 bg-white/5 border border-white/10 rounded-3xl group hover:bg-white/10 transition-all">
                      <div className="flex justify-between items-center mb-3">
                         <p className="text-xs font-black uppercase">{v.regNo}</p>
                         <span className="text-[8px] font-black uppercase text-emerald-400">{v.status}</span>
                      </div>
                      <div className="w-full h-1.5 bg-white/5 rounded-full overflow-hidden">
                         <div className="h-full bg-emerald-500" style={{width: '15%'}} />
                      </div>
                      <div className="flex justify-between mt-2 text-[8px] font-black text-slate-500 uppercase">
                         <span>Used: 15%</span>
                         <span>Cap: {v.capacityKg}kg</span>
                      </div>
                   </div>
                 ))}
              </div>
           </div>
        </div>

        {/* Center: Live Map & Optimization Preview */}
        <div className="xl:col-span-2 space-y-8">
           {/* Visual Map Placeholder */}
           <div className="bg-slate-100 rounded-[60px] aspect-[16/9] relative overflow-hidden border border-slate-200 group shadow-inner">
              <div className="absolute inset-0 bg-[url('https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/72.88,19.07,11/1200x800?access_token=unused')] bg-cover opacity-60 mix-blend-multiply grayscale" />
              
              {/* Warehouse Marker */}
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
                 <div className="w-12 h-12 bg-slate-900 rounded-2xl flex items-center justify-center text-white shadow-2xl border-2 border-emerald-500 animate-pulse">
                    <Warehouse size={24}/>
                 </div>
              </div>

              {/* Planned Stops visualization */}
              {plannedRoute.map((stop, i) => (
                <div 
                  key={stop.id}
                  className="absolute transition-all duration-1000 animate-in zoom-in"
                  style={{ top: `${20 + (i * 12)}%`, left: `${10 + (i * 20)}%` }}
                >
                   <div className="flex flex-col items-center">
                      <div className={`w-8 h-8 rounded-full flex items-center justify-center text-[10px] font-black text-white shadow-xl ${stop.type === 'RETURN_PICKUP' ? 'bg-rose-500' : 'bg-emerald-500'}`}>
                         {stop.sequence}
                      </div>
                      <div className="mt-2 bg-white px-3 py-1 rounded-full border border-slate-200 shadow-sm">
                         <p className="text-[8px] font-black uppercase text-slate-900 truncate max-w-[80px]">{stop.name}</p>
                      </div>
                   </div>
                </div>
              ))}

              <div className="absolute bottom-10 right-10 bg-white/90 backdrop-blur-md p-6 rounded-[32px] border border-slate-200 shadow-2xl max-w-xs animate-in slide-in-from-right-10">
                 <h5 className="text-[10px] font-black uppercase text-slate-400 tracking-widest mb-4">Traffic Conditions</h5>
                 <div className="flex items-center gap-4">
                    <div className="w-2 h-12 bg-emerald-500 rounded-full" />
                    <div>
                       <p className="text-sm font-black text-slate-900">Optimal (Green)</p>
                       <p className="text-[10px] text-slate-500">Real-time sync: 2 min ago</p>
                    </div>
                 </div>
              </div>
           </div>

           {/* Planning Ledger */}
           <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
              <div className="p-8 border-b flex items-center justify-between">
                 <h4 className="text-sm font-black text-slate-900 uppercase tracking-widest flex items-center gap-2"><Layers size={16} className="text-indigo-600"/> Optimized Route Sequence</h4>
                 <div className="flex gap-4">
                    <div className="text-right">
                       <p className="text-[10px] font-black text-slate-400 uppercase">Est. Distance</p>
                       <p className="text-lg font-black">{plannedRoute.reduce((s, st) => s + (st.distanceFromPrev || 0), 0)} KM</p>
                    </div>
                    <div className="text-right">
                       <p className="text-[10px] font-black text-slate-400 uppercase">Trip Cycle</p>
                       <p className="text-lg font-black">{plannedRoute.length * 20} MIN</p>
                    </div>
                 </div>
              </div>
              <div className="overflow-x-auto">
                 <table className="w-full text-left">
                    <thead className="bg-slate-50 text-[9px] font-black text-slate-400 uppercase border-b">
                       <tr>
                          <th className="px-8 py-4">SEQ</th>
                          <th className="px-6 py-4">Point Identity</th>
                          <th className="px-6 py-4">Mission Class</th>
                          <th className="px-6 py-4 text-center">Load</th>
                          <th className="px-8 py-4 text-right">Leg Dist.</th>
                       </tr>
                    </thead>
                    <tbody className="divide-y text-xs font-bold text-slate-700">
                       {plannedRoute.map(stop => (
                         <tr key={stop.id} className="hover:bg-slate-50">
                            <td className="px-8 py-5">
                               <span className="w-6 h-6 rounded-lg bg-slate-900 text-white flex items-center justify-center text-[10px]">{stop.sequence}</span>
                            </td>
                            <td className="px-6 py-5">
                               <p className="text-slate-900 font-black">{stop.name}</p>
                               <p className="text-[8px] text-slate-400 uppercase">{stop.referenceId}</p>
                            </td>
                            <td className="px-6 py-5">
                               <span className={`px-2 py-0.5 rounded text-[8px] font-black uppercase border ${
                                 stop.type === 'DELIVERY' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' :
                                 stop.type === 'RETURN_PICKUP' ? 'bg-rose-50 text-rose-600 border-rose-100' :
                                 'bg-indigo-50 text-indigo-100 border-indigo-100'
                               }`}>
                                 {stop.type.replace('_', ' ')}
                               </span>
                            </td>
                            <td className="px-6 py-5 text-center text-slate-400">{stop.weightKg}kg</td>
                            <td className="px-8 py-5 text-right font-mono text-indigo-600">+{stop.distanceFromPrev}km</td>
                         </tr>
                       ))}
                       {plannedRoute.length === 0 && (
                         <tr><td colSpan={5} className="py-24 text-center text-slate-300 font-black uppercase text-[10px] italic">Generate optimized route to visualize sequence.</td></tr>
                       )}
                    </tbody>
                 </table>
              </div>
           </div>
        </div>

        {/* Right: Controller Sidebar */}
        <div className="xl:col-span-1 space-y-6">
           <div className="bg-white rounded-[44px] border border-slate-200 p-8 shadow-sm space-y-8 sticky top-8">
              <h4 className="text-xl font-black text-slate-900 tracking-tight flex items-center gap-3"><Zap className="text-amber-500"/> Dispatch Control</h4>
              
              <div className="space-y-6">
                 <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Selected Vehicle</label>
                    <select 
                      className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-emerald-600 outline-none appearance-none transition-all"
                      value={selectedVehicleId}
                      onChange={e => setSelectedVehicleId(e.target.value)}
                    >
                       <option value="">Select Carrier...</option>
                       {vehicles.map(v => <option key={v.id} value={v.id}>{v.regNo} ({v.type})</option>)}
                    </select>
                 </div>

                 <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Mission Agent</label>
                    <select 
                      className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-emerald-600 outline-none appearance-none transition-all"
                      value={selectedAgentId}
                      onChange={e => setSelectedAgentId(e.target.value)}
                    >
                       <option value="">Select Agent...</option>
                       {deliveryAgents.map(a => <option key={a.id} value={a.id}>{a.name}</option>)}
                    </select>
                 </div>

                 <div className="pt-6 border-t border-slate-100 space-y-4">
                    <button 
                      onClick={handleOptimize}
                      disabled={isOptimizing || pendingTasks.length === 0 || !selectedVehicleId}
                      className="w-full bg-slate-900 text-white py-5 rounded-[24px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-600 active:scale-95 transition-all disabled:opacity-20 flex items-center justify-center gap-3"
                    >
                       {isOptimizing ? <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" /> : <><RotateCw size={18}/> Run MRP Route Logic</>}
                    </button>

                    <button 
                      onClick={handleDispatch}
                      disabled={plannedRoute.length === 0 || !selectedAgentId}
                      className="w-full bg-emerald-600 text-white py-6 rounded-[28px] font-black text-xs uppercase tracking-[0.25em] shadow-xl shadow-emerald-500/20 hover:bg-emerald-500 active:scale-95 transition-all disabled:opacity-20 flex items-center justify-center gap-3"
                    >
                       Dispatch Mission <ArrowRight size={20}/>
                    </button>
                 </div>

                 <div className="p-6 bg-slate-50 rounded-3xl border border-slate-100 space-y-4">
                    <div className="flex items-center gap-3 text-emerald-600">
                       <ShieldCheck size={18}/>
                       <p className="text-[9px] font-black uppercase tracking-widest">Protocol Sync Active</p>
                    </div>
                    <p className="text-[11px] text-slate-400 leading-relaxed font-medium italic">VRP solver accounts for real-time traffic density (Google Maps Engine) and vehicle volumetric capacity.</p>
                 </div>
              </div>
           </div>
        </div>

      </div>
    </div>
  );
};

export default RouteOptimizationView;
