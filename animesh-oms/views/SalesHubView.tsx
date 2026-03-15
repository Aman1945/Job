
import React, { useMemo } from 'react';
import { Order, OrderStatus, Product, User } from '../types';
import { 
  TrendingUp, 
  Target, 
  Package, 
  DollarSign, 
  BarChart3, 
  ChevronRight,
  Zap,
  ShoppingBag,
  Award,
  AlertCircle,
  TrendingDown,
  Activity,
  UserCheck,
  Calendar
} from 'lucide-react';
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Cell, LineChart, Line, AreaChart, Area } from 'recharts';

interface SalesHubViewProps {
  orders: Order[];
  products: Product[];
  currentUser: User;
}

const SalesHubView: React.FC<SalesHubViewProps> = ({ orders, products, currentUser }) => {
  const mtdStats = useMemo(() => {
    const now = new Date();
    const currentMonthOrders = orders.filter(o => {
      const oDate = new Date(o.createdAt);
      return o.salespersonId === currentUser.id && 
             oDate.getMonth() === now.getMonth() && 
             oDate.getFullYear() === now.getFullYear() &&
             o.status !== OrderStatus.REJECTED;
    });

    let actualValue = 0;
    let actualQty = 0;
    const skuSales: Record<string, { qty: number, value: number, name: string }> = {};
    const clientSales: Record<string, { value: number, name: string }> = {};
    const dailyData: Record<string, number> = {};

    currentMonthOrders.forEach(o => {
      const day = new Date(o.createdAt).getDate();
      const val = o.items.reduce((s, i) => s + (i.price * i.quantity), 0);
      dailyData[day] = (dailyData[day] || 0) + val;

      if (!clientSales[o.customerId]) {
        clientSales[o.customerId] = { value: 0, name: o.customerName };
      }
      o.items.forEach(i => {
        const itemVal = i.price * i.quantity;
        const qty = i.quantity;
        actualValue += itemVal;
        actualQty += qty;
        clientSales[o.customerId].value += itemVal;

        if (!skuSales[i.productId]) {
          skuSales[i.productId] = { qty: 0, value: 0, name: i.productName };
        }
        skuSales[i.productId].qty += qty;
        skuSales[i.productId].value += itemVal;
      });
    });

    const valChartData = Object.entries(skuSales).map(([id, data]) => ({
      name: data.name.substring(0, 8) + '...',
      fullName: data.name,
      value: data.value
    })).sort((a, b) => b.value - a.value).slice(0, 5);

    const trendData = Object.entries(dailyData)
      .map(([day, val]) => ({ day: `D${day}`, val }))
      .sort((a, b) => parseInt(a.day.slice(1)) - parseInt(b.day.slice(1)));

    return { 
      actualValue, 
      actualQty, 
      valChartData, 
      trendData,
      skuSales: Object.values(skuSales).sort((a, b) => b.value - a.value),
      clientSales: Object.values(clientSales).sort((a, b) => b.value - a.value)
    };
  }, [orders, currentUser]);

  const targetValue = currentUser.monthlyTarget || 1200000;
  const targetQty = currentUser.monthlyQtyTarget || 5000;
  
  const valAchievement = (mtdStats.actualValue / targetValue) * 100;
  const qtyAchievement = (mtdStats.actualQty / targetQty) * 100;
  
  const valShortfall = Math.max(0, targetValue - mtdStats.actualValue);
  const qtyShortfall = Math.max(0, targetQty - mtdStats.actualQty);

  return (
    <div className="space-y-10 animate-in fade-in duration-700 pb-20">
      
      {/* Sales Manager Identity Header */}
      <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl relative overflow-hidden group border border-slate-800">
        <Award className="absolute -right-6 -bottom-6 w-64 h-64 opacity-10 text-indigo-400" />
        <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
           <div>
              <div className="flex items-center gap-3 mb-2">
                 <Zap className="text-amber-400 animate-pulse" size={24}/>
                 <h2 className="text-4xl font-black tracking-tighter">Manager Dashboard: {currentUser.name}</h2>
              </div>
              <p className="text-sm text-slate-400 font-black uppercase tracking-widest flex items-center gap-2">
                <Calendar size={14} className="text-indigo-400"/> Period: Current Month Operations
              </p>
           </div>
           <div className="flex gap-4">
              <div className="px-6 py-4 bg-emerald-500/10 border border-emerald-500/20 rounded-3xl">
                 <p className="text-[10px] font-black text-emerald-400 uppercase tracking-tighter">MTD Progress</p>
                 <p className="text-xl font-black text-white">{valAchievement.toFixed(1)}% Done</p>
              </div>
           </div>
        </div>
      </div>

      {/* Targets vs Actual Matrix */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        
        {/* Value Target Card */}
        <div className="bg-white p-10 rounded-[44px] border border-slate-200 shadow-sm space-y-8">
           <div className="flex items-center justify-between">
              <div>
                 <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Target Achievement (Value)</p>
                 <h3 className="text-5xl font-black text-slate-900 tracking-tighter">₹{mtdStats.actualValue.toLocaleString()}</h3>
              </div>
              <div className={`text-right ${valAchievement < 100 ? 'text-rose-500' : 'text-emerald-500'}`}>
                 <p className="text-3xl font-black">{valAchievement.toFixed(1)}%</p>
                 <p className="text-[9px] font-black uppercase tracking-tighter">Value Progress</p>
              </div>
           </div>

           <div className="space-y-3">
              <div className="flex justify-between text-[10px] font-black uppercase tracking-widest text-slate-400">
                 <span>Actual: ₹{mtdStats.actualValue.toLocaleString()}</span>
                 <span>Target: ₹{targetValue.toLocaleString()}</span>
              </div>
              <div className="w-full bg-slate-100 h-6 rounded-full overflow-hidden p-1 shadow-inner">
                 <div 
                   className={`h-full rounded-full shadow-lg transition-all duration-1000 ${valAchievement < 100 ? 'bg-rose-500' : 'bg-emerald-500'}`} 
                   style={{ width: `${Math.min(100, valAchievement)}%` }} 
                 />
              </div>
           </div>

           <div className="pt-6 border-t border-slate-100 flex items-center justify-between">
              <div>
                 <p className="text-[10px] font-black text-slate-400 uppercase">Target Shortfall</p>
                 <p className={`text-xl font-black ${valShortfall > 0 ? 'text-rose-600' : 'text-emerald-600'}`}>₹{valShortfall.toLocaleString()}</p>
              </div>
              <div className={`p-3 rounded-2xl ${valAchievement < 100 ? 'bg-rose-50 text-rose-500' : 'bg-emerald-50 text-emerald-500'}`}>
                 {valAchievement < 100 ? <TrendingDown size={24}/> : <TrendingUp size={24}/>}
              </div>
           </div>
        </div>

        {/* Quantity Target Card */}
        <div className="bg-white p-10 rounded-[44px] border border-slate-200 shadow-sm space-y-8">
           <div className="flex items-center justify-between">
              <div>
                 <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Target Achievement (Qty)</p>
                 <h3 className="text-5xl font-black text-slate-900 tracking-tighter">{mtdStats.actualQty.toLocaleString()} Units</h3>
              </div>
              <div className={`text-right ${qtyAchievement < 100 ? 'text-rose-500' : 'text-emerald-500'}`}>
                 <p className="text-3xl font-black">{qtyAchievement.toFixed(1)}%</p>
                 <p className="text-[9px] font-black uppercase tracking-tighter">Qty Progress</p>
              </div>
           </div>

           <div className="space-y-3">
              <div className="flex justify-between text-[10px] font-black uppercase tracking-widest text-slate-400">
                 <span>Actual: {mtdStats.actualQty} Units</span>
                 <span>Target: {targetQty} Units</span>
              </div>
              <div className="w-full bg-slate-100 h-6 rounded-full overflow-hidden p-1 shadow-inner">
                 <div 
                   className={`h-full rounded-full shadow-lg transition-all duration-1000 ${qtyAchievement < 100 ? 'bg-rose-500' : 'bg-emerald-500'}`} 
                   style={{ width: `${Math.min(100, qtyAchievement)}%` }} 
                 />
              </div>
           </div>

           <div className="pt-6 border-t border-slate-100 flex items-center justify-between">
              <div>
                 <p className="text-[10px] font-black text-slate-400 uppercase">Qty Shortfall</p>
                 <p className={`text-xl font-black ${qtyShortfall > 0 ? 'text-rose-600' : 'text-emerald-600'}`}>{qtyShortfall.toLocaleString()} Units</p>
              </div>
              <div className={`p-3 rounded-2xl ${qtyAchievement < 100 ? 'bg-rose-50 text-rose-500' : 'bg-emerald-50 text-emerald-500'}`}>
                 <Package size={24}/>
              </div>
           </div>
        </div>
      </div>

      {/* Analytics Feed */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
         <div className="lg:col-span-2 bg-white rounded-[44px] border border-slate-200 p-10 shadow-sm">
            <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-8">Daily Sales Velocity (MTD)</h4>
            <div className="h-80">
               <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={mtdStats.trendData}>
                     <defs>
                        <linearGradient id="vGrad" x1="0" y1="0" x2="0" y2="1">
                           <stop offset="5%" stopColor="#6366f1" stopOpacity={0.1}/>
                           <stop offset="95%" stopColor="#6366f1" stopOpacity={0}/>
                        </linearGradient>
                     </defs>
                     <CartesianGrid vertical={false} strokeDasharray="3 3" stroke="#f1f5f9" />
                     <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{fontSize:10, fill:'#94a3b8', fontWeight:700}} />
                     <YAxis hide />
                     <Tooltip contentStyle={{ borderRadius: '20px', border: 'none', boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1)' }} />
                     <Area type="monotone" dataKey="val" stroke="#4f46e5" strokeWidth={4} fill="url(#vGrad)" />
                  </AreaChart>
               </ResponsiveContainer>
            </div>
         </div>

         <div className="bg-slate-900 p-10 rounded-[44px] text-white shadow-2xl flex flex-col justify-between group overflow-hidden relative">
            <Activity className="absolute -top-10 -right-10 w-48 h-48 opacity-10 group-hover:scale-110 transition-transform duration-700 text-indigo-400" />
            <div className="relative z-10">
               <h5 className="text-[10px] font-black text-indigo-400 uppercase tracking-widest mb-6">Market Insight</h5>
               <p className="text-2xl font-black leading-tight mb-4 tracking-tight">Booking frequency is up 12.5% compared to previous cycle.</p>
               <p className="text-sm text-slate-400">Current velocity suggests 100% target coverage by day 26 of operations.</p>
            </div>
            <button className="relative z-10 w-full bg-white/10 hover:bg-white/20 py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all">Explore Lead Data</button>
         </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
         <div className="bg-white rounded-[44px] border border-slate-200 p-10 shadow-sm">
            <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-8">Top 5 SKU Value Contribution</h4>
            <div className="h-64">
               <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={mtdStats.valChartData}>
                     <CartesianGrid vertical={false} strokeDasharray="3 3" stroke="#f1f5f9" />
                     <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fontSize:10, fontWeight:700}} />
                     <YAxis hide />
                     <Tooltip cursor={{fill: '#f8fafc'}} />
                     <Bar dataKey="value" radius={[10, 10, 0, 0]} barSize={40}>
                        {mtdStats.valChartData.map((e, i) => <Cell key={i} fill={i === 0 ? '#4f46e5' : '#818cf8'} />)}
                     </Bar>
                  </BarChart>
               </ResponsiveContainer>
            </div>
         </div>
         <div className="bg-white rounded-[44px] border border-slate-200 p-10 shadow-sm flex flex-col">
            <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-8">Top Contributing Clients</h4>
            <div className="space-y-6 flex-1 overflow-y-auto no-scrollbar">
               {mtdStats.clientSales.slice(0, 6).map((c, i) => (
                 <div key={i} className="flex items-center justify-between group">
                    <p className="text-xs font-black text-slate-900 group-hover:text-indigo-600 transition-colors truncate pr-4">{c.name}</p>
                    <p className="text-sm font-black text-slate-900 shrink-0">₹{c.value.toLocaleString()}</p>
                 </div>
               ))}
            </div>
         </div>
      </div>
    </div>
  );
};

export default SalesHubView;
