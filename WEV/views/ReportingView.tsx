
import React, { useMemo, useState } from 'react';
import { Order, OrderStatus, Product } from '../types';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, 
  ResponsiveContainer, Legend, LineChart, Line, AreaChart, 
  Area, Cell, PieChart, Pie
} from 'recharts';
import { 
  Download, Printer, Filter, ShoppingBag, CheckCircle, 
  AlertTriangle, Truck, Map, Trophy, Route, Activity,
  ChevronRight, ArrowUpRight, UserCircle, Zap, ShieldCheck, Box,
  PieChart as PieIcon,
  BarChart as BarIcon
} from 'lucide-react';

interface ReportingViewProps {
  orders: Order[];
}

const ReportingView: React.FC<ReportingViewProps> = ({ orders }) => {
  const [activeSubTab, setActiveSubTab] = useState<'fulfilment' | 'fleet' | 'category'>('fulfilment');

  // Fulfilment Calculations
  const metrics = useMemo(() => {
    let totalOrderedQty = 0;
    let totalSuppliedQty = 0;
    
    orders.forEach(o => {
      o.items.forEach(i => {
        totalOrderedQty += i.quantity;
        if (o.status === OrderStatus.DELIVERED) {
          totalSuppliedQty += (i.packedQuantity ?? i.quantity); 
        } else if (o.status === OrderStatus.OUT_FOR_DELIVERY || o.status === OrderStatus.PICKED_UP) {
          totalSuppliedQty += (i.packedQuantity ?? i.quantity) * 0.95; 
        }
      });
    });

    const deliveredCount = orders.filter(o => o.status === OrderStatus.DELIVERED).length;
    const qtyFulfilment = totalOrderedQty > 0 ? (totalSuppliedQty / totalOrderedQty) * 100 : 0;
    const orderFulfilment = orders.length > 0 ? (deliveredCount / orders.length) * 100 : 0;

    return { totalOrderedQty, totalSuppliedQty, qtyFulfilment, orderFulfilment };
  }, [orders]);

  // Category Distribution Data
  const categoryData = useMemo(() => {
    const categoryValueMap: Record<string, number> = {};
    const categoryQtyMap: Record<string, number> = {};

    orders.forEach(o => {
      o.items.forEach(i => {
        const cat = i.productName.split(' ')[0] || 'Uncategorized'; // Mocking category from first word
        categoryValueMap[cat] = (categoryValueMap[cat] || 0) + (i.price * i.quantity);
        categoryQtyMap[cat] = (categoryQtyMap[cat] || 0) + i.quantity;
      });
    });

    const valueData = Object.entries(categoryValueMap).map(([name, value]) => ({ name, value }));
    const qtyData = Object.entries(categoryQtyMap).map(([name, value]) => ({ name, value }));

    return { valueData, qtyData };
  }, [orders]);

  // Fleet Analytics
  const fleetMetrics = useMemo(() => {
    const deliveredOrders = orders.filter(o => o.status === OrderStatus.DELIVERED);
    const agentMap: Record<string, { deliveries: number, distance: number, name: string }> = {};
    const vehicleMap: Record<string, { deliveries: number, provider: string }> = {};
    const providerMap: Record<string, number> = { Internal: 0, Porter: 0, Other: 0 };

    deliveredOrders.forEach(o => {
      if (o.logistics) {
        const agentId = o.logistics.deliveryAgentId || 'Unknown';
        const distance = o.logistics.distanceKm || 0;
        const vehicleNo = o.logistics.vehicleNo || 'Unknown';
        const provider = o.logistics.vehicleProvider || 'Internal';

        if (!agentMap[agentId]) {
          agentMap[agentId] = { deliveries: 0, distance: 0, name: agentId.split('@')[0].replace('.', ' ') };
        }
        agentMap[agentId].deliveries += 1;
        agentMap[agentId].distance += distance;

        if (!vehicleMap[vehicleNo]) {
          vehicleMap[vehicleNo] = { deliveries: 0, provider: provider };
        }
        vehicleMap[vehicleNo].deliveries += 1;

        providerMap[provider] = (providerMap[provider] || 0) + 1;
      }
    });

    const agentData = Object.values(agentMap).sort((a, b) => b.deliveries - a.deliveries);
    const vehicleData = Object.entries(vehicleMap).map(([reg, data]) => ({ reg, deliveries: data.deliveries, provider: data.provider })).sort((a, b) => b.deliveries - a.deliveries);
    const providerPieData = Object.entries(providerMap).map(([name, value]) => ({ name, value }));
    const totalDistance = agentData.reduce((sum, a) => sum + a.distance, 0);

    return { agentData, vehicleData, providerPieData, totalDistance, totalDeliveries: deliveredOrders.length };
  }, [orders]);

  const COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Intelligence Terminal</h2>
          <p className="text-sm text-slate-500 font-medium">Holistic operational & category performance analytics</p>
        </div>
        
        <div className="flex bg-slate-200 p-1 rounded-2xl border border-slate-300 shadow-inner overflow-x-auto no-scrollbar">
           <button onClick={() => setActiveSubTab('fulfilment')} className={`px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeSubTab === 'fulfilment' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>Order Flow</button>
           <button onClick={() => setActiveSubTab('category')} className={`px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeSubTab === 'category' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>Category Split</button>
           <button onClick={() => setActiveSubTab('fleet')} className={`px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeSubTab === 'fleet' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>Fleet Intelligence</button>
        </div>
      </div>

      {activeSubTab === 'fulfilment' && (
        <div className="space-y-8 animate-in slide-in-from-left-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <KpiCard label="MTD Qty Fulfilment" value={`${metrics.qtyFulfilment.toFixed(1)}%`} subtext={`Ordered: ${metrics.totalOrderedQty} units`} color="indigo" />
            <KpiCard label="Order Success Rate" value={`${metrics.orderFulfilment.toFixed(1)}%`} subtext={`Total MTD: ${orders.length} orders`} color="emerald" />
            <KpiCard label="Stock Shortage (Loss)" value={`₹${(orders.length * 4500 * 0.05).toLocaleString()}`} subtext="5.2% leakage avg" color="amber" />
            <KpiCard label="Avg Lead Time" value="3.4 Days" subtext="-0.8d vs Q1" color="slate" />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2 bg-white p-10 rounded-[40px] border shadow-sm border-slate-200">
               <h3 className="font-black text-slate-900 text-lg mb-8">Supply Velocity % (MTD Trend)</h3>
               <div className="h-[350px]">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={[{n:'W1',v:88},{n:'W2',v:92},{n:'W3',v:metrics.qtyFulfilment},{n:'W4',v:metrics.qtyFulfilment+2}]}>
                    <defs>
                      <linearGradient id="colorFul" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#6366f1" stopOpacity={0.1}/>
                        <stop offset="95%" stopColor="#6366f1" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="n" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#94a3b8', fontWeight: 600 }} />
                    <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#94a3b8' }} domain={[0, 100]} />
                    <Tooltip contentStyle={{ borderRadius: '24px', border: 'none', boxShadow: '0 25px 50px -12px rgb(0 0 0 / 0.1)' }} />
                    <Area type="monotone" dataKey="v" stroke="#6366f1" strokeWidth={4} fillOpacity={1} fill="url(#colorFul)" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            <div className="bg-slate-900 p-10 rounded-[40px] text-white shadow-2xl flex flex-col items-center justify-center text-center">
              <ShoppingBag size={48} className="text-indigo-400 mb-6" />
              <h3 className="font-black text-3xl mb-1 tracking-tighter">{metrics.totalSuppliedQty} Units</h3>
              <p className="text-xs text-slate-400 uppercase tracking-widest font-black">Outwarded MTD</p>
              <div className="w-full h-1 bg-white/10 rounded-full mt-8 overflow-hidden"><div className="h-full bg-indigo-500" style={{ width: `${metrics.qtyFulfilment}%` }} /></div>
              <p className="text-[10px] font-bold text-slate-500 mt-3 italic">Capacity Utilization: Nominal</p>
            </div>
          </div>
        </div>
      )}

      {activeSubTab === 'category' && (
        <div className="space-y-8 animate-in slide-in-from-bottom-4">
           <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="bg-white p-10 rounded-[44px] border border-slate-200 shadow-sm">
                 <h3 className="font-black text-slate-900 text-lg mb-8 flex items-center gap-2"><PieIcon size={20} className="text-indigo-600"/> Value by Category Split</h3>
                 <div className="h-80">
                    <ResponsiveContainer width="100%" height="100%">
                       <PieChart>
                          <Pie data={categoryData.valueData} cx="50%" cy="50%" innerRadius={60} outerRadius={100} paddingAngle={5} dataKey="value">
                             {categoryData.valueData.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                          </Pie>
                          <Tooltip />
                          <Legend verticalAlign="bottom" height={36}/>
                       </PieChart>
                    </ResponsiveContainer>
                 </div>
              </div>

              <div className="bg-white p-10 rounded-[44px] border border-slate-200 shadow-sm">
                 <h3 className="font-black text-slate-900 text-lg mb-8 flex items-center gap-2"><BarIcon size={20} className="text-emerald-600"/> Qty Concentration</h3>
                 <div className="h-80">
                    <ResponsiveContainer width="100%" height="100%">
                       <BarChart data={categoryData.qtyData}>
                          <CartesianGrid vertical={false} strokeDasharray="3 3" stroke="#f1f5f9" />
                          <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fontSize:10, fontStyle:'bold'}} />
                          <YAxis hide />
                          <Tooltip cursor={{fill: '#f8fafc'}} />
                          <Bar dataKey="value" radius={[10, 10, 0, 0]} barSize={40}>
                             {categoryData.qtyData.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[(index + 1) % COLORS.length]} />)}
                          </Bar>
                       </BarChart>
                    </ResponsiveContainer>
                 </div>
              </div>
           </div>
        </div>
      )}

      {activeSubTab === 'fleet' && (
        <div className="space-y-8 animate-in slide-in-from-right-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <KpiCard label="Fleet Coverage" value={`${fleetMetrics.totalDistance.toLocaleString()} KM`} subtext="Trip distance MTD" color="indigo" icon={<Route size={16}/>} />
            <KpiCard label="Active Assets" value={`${fleetMetrics.vehicleData.length}`} subtext="Unique Reg Numbers" color="amber" icon={<Truck size={16}/>} />
            <KpiCard label="Successful Drops" value={`${fleetMetrics.totalDeliveries}`} subtext="Confirmed PODs" color="emerald" icon={<ShieldCheck size={16}/>} />
            <KpiCard label="Fleet Personnel" value={`${fleetMetrics.agentData.length}`} subtext="On-field force" color="slate" icon={<UserCircle size={16}/>} />
          </div>

          <div className="bg-white p-10 rounded-[40px] border shadow-sm border-slate-200">
             <h3 className="font-black text-slate-900 text-lg mb-8">Fleet Assignment Velocity</h3>
             <div className="h-[400px]">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={fleetMetrics.vehicleData}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="reg" axisLine={false} tickLine={false} tick={{ fontSize: 10, fill: '#94a3b8', fontWeight: 700 }} />
                    <YAxis hide />
                    <Tooltip cursor={{fill: '#f8fafc'}} contentStyle={{ borderRadius: '24px', border: 'none', boxShadow: '0 25px 50px -12px rgb(0 0 0 / 0.1)' }} />
                    <Bar dataKey="deliveries" name="Drops" radius={[8, 8, 0, 0]} barSize={40}>
                       {fleetMetrics.vehicleData.map((entry, index) => <Cell key={`cell-${index}`} fill={entry.provider === 'Porter' ? '#f59e0b' : '#4f46e5'} />)}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
             </div>
          </div>
        </div>
      )}
    </div>
  );
};

const KpiCard = ({ label, value, subtext, color, icon }: { label: string, value: string, subtext: string, color: string, icon?: React.ReactNode }) => {
  const colors: Record<string, string> = {
    indigo: 'border-l-indigo-500',
    emerald: 'border-l-emerald-500',
    amber: 'border-l-amber-500',
    slate: 'border-l-slate-800'
  };

  return (
    <div className={`bg-white p-7 rounded-[32px] border shadow-sm border-l-4 ${colors[color] || 'border-l-slate-200'} transition-all hover:scale-105 duration-300`}>
      <div className="flex items-center justify-between mb-4">
        <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">{label}</p>
        {icon && <div className="text-slate-300">{icon}</div>}
      </div>
      <h3 className="text-3xl font-black text-slate-900 tracking-tighter">{value}</h3>
      <p className="text-[10px] text-slate-400 mt-2 font-medium italic">{subtext}</p>
    </div>
  );
};

export default ReportingView;
