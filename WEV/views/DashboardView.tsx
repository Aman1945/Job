import React from 'react';
import { Order, OrderStatus, UserRole } from '../types';
import { ResponsiveContainer, PieChart, Pie, Cell, Tooltip, AreaChart, Area, XAxis, YAxis, CartesianGrid } from 'recharts';
import { TrendingUp, Clock, AlertCircle, Zap, Box, ShoppingCart, Truck, CheckCircle2 } from 'lucide-react';

interface DashboardViewProps {
  orders: Order[];
  onViewOrder: (id: string) => void;
}

const DashboardView: React.FC<DashboardViewProps> = ({ orders, onViewOrder }) => {
  const departmentHealth = [
    { label: 'Sales', status: 'Inbound Orders', count: orders.filter(o => o.status === OrderStatus.PENDING_CREDIT_APPROVAL).length, icon: <ShoppingCart size={14}/>, color: 'text-emerald-600', bg: 'bg-emerald-50' },
    { label: 'Credit Control', status: 'Awaiting Review', count: orders.filter(o => o.status === OrderStatus.PENDING_CREDIT_APPROVAL).length, icon: <Zap size={14}/>, color: 'text-indigo-600', bg: 'bg-indigo-50' },
    { label: 'Warehouse', status: 'Outward Queue', count: orders.filter(o => o.status === OrderStatus.PENDING_PACKING).length, icon: <Box size={14}/>, color: 'text-emerald-600', bg: 'bg-emerald-50' },
    { label: 'Logistics', status: 'Transit Hub', count: orders.filter(o => o.status === OrderStatus.OUT_FOR_DELIVERY || o.status === OrderStatus.PICKED_UP).length, icon: <Truck size={14}/>, color: 'text-indigo-600', bg: 'bg-indigo-50' },
  ];

  const pieData = [
    { name: 'Pending', value: orders.filter(o => o.status.includes('Pending')).length, color: '#f59e0b' },
    { name: 'In Transit', value: orders.filter(o => o.status === OrderStatus.OUT_FOR_DELIVERY || o.status === OrderStatus.PICKED_UP).length, color: '#6366f1' },
    { name: 'Success', value: orders.filter(o => o.status === OrderStatus.DELIVERED).length, color: '#10b981' },
  ];

  return (
    <div className="space-y-8 animate-in fade-in duration-700">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-black text-slate-800 tracking-tight">Enterprise Pulse</h2>
          <p className="text-sm text-slate-500 font-medium">Real-time supply chain monitoring</p>
        </div>
        <div className="bg-emerald-50 px-4 py-2 rounded-full flex items-center gap-2 border border-emerald-100 shadow-sm">
           <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
           <span className="text-[10px] font-black text-emerald-700 uppercase">Operational Status: Nominal</span>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {departmentHealth.map((dept, i) => (
          <div key={i} className="bg-white p-5 rounded-3xl border border-slate-100 shadow-sm hover:shadow-md hover:border-emerald-100 transition-all group cursor-default">
            <div className={`w-10 h-10 ${dept.bg} ${dept.color} rounded-2xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform shadow-sm`}>
              {dept.icon}
            </div>
            <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">{dept.label}</p>
            <h4 className="text-2xl font-black text-slate-800 my-1">{dept.count}</h4>
            <p className="text-[10px] font-bold text-slate-500 italic">{dept.status}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-white rounded-[40px] border border-slate-100 p-8 shadow-sm">
          <div className="flex items-center justify-between mb-8">
            <h3 className="font-black text-slate-800 uppercase text-xs tracking-widest">Throughput Efficiency</h3>
            <div className="flex gap-4">
               <div className="flex items-center gap-1.5"><div className="w-2 h-2 rounded-full bg-emerald-500" /><span className="text-[10px] font-bold text-slate-500 uppercase">Deliveries</span></div>
            </div>
          </div>
          <div className="h-[300px] min-h-[300px]">
            <ResponsiveContainer width="100%" height="100%" minWidth={0}>
              <AreaChart data={[{n:'Mon',v:10},{n:'Tue',v:25},{n:'Wed',v:15},{n:'Thu',v:32},{n:'Fri',v:28},{n:'Sat',v:12},{n:'Sun',v:8}]}>
                <defs>
                  <linearGradient id="pgrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.2}/>
                    <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid vertical={false} strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="n" axisLine={false} tickLine={false} tick={{fontSize:10, fontWeight:700, fill:'#94a3b8'}} />
                <YAxis hide />
                <Tooltip contentStyle={{borderRadius:'20px', border:'none', boxShadow:'0 10px 15px -3px rgb(0 0 0 / 0.1)'}} />
                <Area type="monotone" dataKey="v" stroke="#10b981" strokeWidth={4} fill="url(#pgrad)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-emerald-950 rounded-[40px] p-8 shadow-2xl text-white flex flex-col items-center justify-center text-center overflow-hidden relative min-h-[400px] border border-emerald-900">
          <div className="absolute -top-10 -right-10 opacity-10 text-emerald-500 pointer-events-none">
            <CheckCircle2 size={240} />
          </div>
          <div className="relative z-10 w-full h-[200px] min-h-[200px]">
             <ResponsiveContainer width="100%" height="100%" minWidth={0}>
                <PieChart>
                  <Pie data={pieData} cx="50%" cy="50%" innerRadius={65} outerRadius={85} paddingAngle={8} dataKey="value">
                    {pieData.map((e,i) => <Cell key={i} fill={e.color} stroke="none" />)}
                  </Pie>
                  <Tooltip contentStyle={{background:'#064e3b', borderRadius:'15px', border:'none', color:'#fff'}} />
                </PieChart>
             </ResponsiveContainer>
          </div>
          <div className="mt-4 relative z-10">
            <h3 className="text-2xl font-black mb-1 text-emerald-400">94.2% Reliability</h3>
            <p className="text-xs text-emerald-300/60 font-medium">Fleet performance index (Current Qtr)</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardView;