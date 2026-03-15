
import React, { useState, useEffect, useMemo } from 'react';
import { Order, Customer, Product, ProcurementItem, OrderStatus, User, UserRole } from '../types';
import { 
  TrendingUp, 
  ShieldAlert, 
  Activity, 
  BarChart3, 
  PieChart as PieIcon, 
  Zap, 
  Crown, 
  Target, 
  DollarSign, 
  Package, 
  Truck, 
  CheckCircle2,
  AlertTriangle,
  ArrowUpRight,
  TrendingDown,
  Sparkles,
  Info,
  Calendar,
  Layers,
  Cpu,
  RotateCcw,
  Wallet
} from 'lucide-react';
import { 
  ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid, 
  Tooltip, PieChart, Pie, Cell, BarChart, Bar, Legend, ComposedChart, Line
} from 'recharts';
import { getExecutiveBriefing } from '../services/geminiService';

interface CEODashboardViewProps {
  orders: Order[];
  customers: Customer[];
  products: Product[];
  procurement: ProcurementItem[];
  users: User[];
}

const CEODashboardView: React.FC<CEODashboardViewProps> = ({ orders, customers, products, procurement, users }) => {
  const [aiBrief, setAiBrief] = useState<string>("Synthesizing enterprise data...");
  const [activeTab, setActiveTab] = useState<'Strategic' | 'Operational' | 'Financial'>('Strategic');

  useEffect(() => {
    getExecutiveBriefing({ orders, customers, products, procurement }).then(setAiBrief);
  }, [orders.length, customers.length, products.length]);

  const metrics = useMemo(() => {
    const totalBooked = orders.reduce((s, o) => s + o.items.reduce((is, i) => is + (i.price * i.quantity), 0), 0);
    const totalDelivered = orders.filter(o => o.status === OrderStatus.DELIVERED).reduce((s, o) => s + o.items.reduce((is, i) => is + (i.price * (i.deliveredQuantity || i.quantity)), 0), 0);
    const totalOverdue = customers.reduce((s, c) => s + c.overdue, 0);
    const totalTarget = users.filter(u => u.role === UserRole.SALES).reduce((s, u) => s + (u.monthlyTarget || 0), 0);
    
    // Efficiency: Delivered Orders vs Total Orders
    const fulfillmentRate = orders.length > 0 ? (orders.filter(o => o.status === OrderStatus.DELIVERED).length / orders.length) * 100 : 0;
    
    // Fill Rate: Delivered Qty vs Ordered Qty
    const totalOrderedQty = orders.reduce((s, o) => s + o.items.reduce((is, i) => is + i.quantity, 0), 0);
    const totalDeliveredQty = orders.reduce((s, o) => s + o.items.reduce((is, i) => is + (i.deliveredQuantity || 0), 0), 0);
    const fillRate = totalOrderedQty > 0 ? (totalDeliveredQty / totalOrderedQty) * 100 : 0;

    // Forecast Accuracy (Mocked based on MOCK_FORECASTS)
    const forecastAccuracy = 90.5; // Average of mock forecasts

    // Inventory Turnover (Simulated)
    const inventoryTurnover = 12.4; // Annualized

    // Working Capital Blocked (From MOCK_WORKING_CAPITAL)
    const workingCapitalBlocked = 4500000; // Total inventory value

    // Logistics Cost Trend (Simulated)
    const logisticsCostTrend = "+4.2%";

    // Risk: Value of near expiry stock
    const today = new Date();
    const ninetyDays = new Date();
    ninetyDays.setDate(today.getDate() + 90);
    
    const nearExpiryValue = products.reduce((s, p) => {
      const expQty = (p.availableBatches || []).filter(b => new Date(b.expDate) <= ninetyDays).reduce((bs, b) => bs + b.quantity, 0);
      return s + (expQty * p.baseRate);
    }, 0);

    return { totalBooked, totalDelivered, totalOverdue, totalTarget, fulfillmentRate, nearExpiryValue, fillRate, forecastAccuracy, inventoryTurnover, workingCapitalBlocked, logisticsCostTrend };
  }, [orders, customers, products, users]);

  const COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

  return (
    <div className="max-w-[1600px] mx-auto space-y-10 pb-24 animate-in fade-in duration-1000">
      
      {/* CEO Identity Header */}
      <div className="bg-slate-900 rounded-[50px] p-12 text-white shadow-2xl relative overflow-hidden group border border-slate-800">
         <Crown className="absolute -right-12 -top-12 w-96 h-96 opacity-[0.03] text-emerald-400 group-hover:scale-110 transition-transform duration-1000" />
         <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-10">
            <div className="flex items-center gap-8">
               <div className="w-24 h-24 bg-gradient-to-br from-indigo-600 to-indigo-400 rounded-[32px] flex items-center justify-center text-white shadow-2xl shadow-indigo-500/20">
                  <BarChart3 size={48} />
               </div>
               <div>
                  <h2 className="text-5xl font-black tracking-tighter">Enterprise Command Center</h2>
                  <div className="flex items-center gap-3 mt-3">
                     <span className="text-emerald-400 font-black uppercase tracking-[0.3em] text-xs">Strategic Oversight</span>
                     <div className="w-1.5 h-1.5 rounded-full bg-slate-600" />
                     <span className="text-slate-400 font-bold uppercase tracking-widest text-xs flex items-center gap-2">
                        <Calendar size={12}/> Q1 FY24-25
                     </span>
                  </div>
               </div>
            </div>
            
            <div className="flex bg-white/5 p-1.5 rounded-[24px] border border-white/10 backdrop-blur-md">
               {(['Strategic', 'Operational', 'Financial'] as const).map(tab => (
                 <button 
                   key={tab} 
                   onClick={() => setActiveTab(tab)}
                   className={`px-8 py-3 rounded-2xl text-[11px] font-black uppercase tracking-widest transition-all ${activeTab === tab ? 'bg-white text-slate-900 shadow-xl' : 'text-slate-400 hover:text-white'}`}
                 >
                   {tab}
                 </button>
               ))}
            </div>
         </div>
      </div>

      {/* AI Briefing Bar */}
      <div className="bg-indigo-600 p-8 rounded-[40px] text-white shadow-2xl relative group overflow-hidden border border-indigo-500 flex flex-col md:flex-row items-center gap-8 shadow-indigo-600/20">
         <Sparkles className="absolute -right-12 -bottom-12 w-64 h-64 opacity-10 group-hover:scale-110 transition-transform duration-700" />
         <div className="w-16 h-16 bg-white/20 rounded-3xl flex items-center justify-center shrink-0 border border-white/20">
            <Zap className="text-white animate-pulse" size={32} />
         </div>
         <div className="flex-1">
            <p className="text-[10px] font-black uppercase tracking-[0.3em] text-indigo-200 mb-2 flex items-center gap-2">
               <Info size={14}/> Chief of Staff AI Briefing
            </p>
            <p className="text-lg font-medium leading-relaxed tracking-tight italic">
               "{aiBrief}"
            </p>
         </div>
         <div className="shrink-0 flex gap-4">
            <button className="px-6 py-3 bg-white/10 hover:bg-white/20 rounded-2xl text-[10px] font-black uppercase tracking-widest border border-white/10 transition-all">Review Strategy</button>
         </div>
      </div>

      {/* Key Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
         <CEOStatCard 
            label="Booked Revenue (MTD)" 
            value={`₹${(metrics.totalBooked / 100000).toFixed(1)}L`} 
            trend="+12.4%" 
            sub={`Goal: ₹${(metrics.totalTarget / 100000).toFixed(1)}L`} 
            icon={<DollarSign />} 
            color="emerald" 
         />
         <CEOStatCard 
            label="Forecast Accuracy" 
            value={`${metrics.forecastAccuracy}%`} 
            trend="AI Optimized" 
            sub="Demand Sensing Active" 
            icon={<TrendingUp />} 
            color="indigo" 
         />
         <CEOStatCard 
            label="Inventory Turnover" 
            value={`${metrics.inventoryTurnover}x`} 
            trend="+0.8x" 
            sub="Annualized Velocity" 
            icon={<RotateCcw />} 
            color="amber" 
         />
         <CEOStatCard 
            label="Working Capital" 
            value={`₹${(metrics.workingCapitalBlocked / 100000).toFixed(1)}L`} 
            trend="+4.2%" 
            sub="Blocked in Inventory" 
            icon={<Wallet />} 
            color="rose" 
            bad 
         />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
         <CEOStatCard 
            label="Service Level (SLA)" 
            value={`${metrics.fulfillmentRate.toFixed(1)}%`} 
            trend="-2.1%" 
            sub="Order Fill Accuracy" 
            icon={<Truck />} 
            color="indigo" 
         />
         <CEOStatCard 
            label="Fill Rate" 
            value={`${metrics.fillRate.toFixed(1)}%`} 
            trend="+1.4%" 
            sub="Qty Fulfillment" 
            icon={<CheckCircle2 />} 
            color="emerald" 
         />
         <CEOStatCard 
            label="Logistics Cost" 
            value={metrics.logisticsCostTrend} 
            trend="Rising" 
            sub="Freight & Packing" 
            icon={<Truck />} 
            color="rose" 
            bad 
         />
         <CEOStatCard 
            label="Inventory Liability" 
            value={`₹${(metrics.nearExpiryValue / 100000).toFixed(1)}L`} 
            trend="90D Expiry" 
            sub="Critical Liquidation Value" 
            icon={<Package />} 
            color="amber" 
            bad 
         />
      </div>

      {/* Main Analysis Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
         
         {activeTab === 'Financial' ? (
           <div className="lg:col-span-3 bg-white rounded-[50px] p-10 border border-slate-200 shadow-sm space-y-8 animate-in slide-in-from-bottom-4 duration-500">
              <div className="flex items-center justify-between">
                 <div>
                    <h3 className="text-2xl font-black text-slate-900 uppercase tracking-widest flex items-center gap-3">
                       <DollarSign className="text-emerald-500" /> Projected Profit & Loss
                    </h3>
                    <p className="text-sm text-slate-400 font-medium">Feb'26 Projection - Multi-Channel Performance</p>
                 </div>
                 <div className="px-6 py-2 bg-emerald-50 text-emerald-700 rounded-full text-[10px] font-black uppercase tracking-widest border border-emerald-100">
                    Fiscal Forecast Active
                 </div>
              </div>

              <div className="overflow-x-auto">
                 <table className="w-full text-left border-separate border-spacing-y-2">
                    <thead>
                       <tr className="text-slate-400 text-[10px] font-black uppercase tracking-[0.2em]">
                          <th className="pb-4 pl-4">Particular</th>
                          <th className="pb-4 text-right">Horeca/Wholesales</th>
                          <th className="pb-4 text-right">Retail Online</th>
                          <th className="pb-4 text-right">Retail Offline</th>
                          <th className="pb-4 text-right">Home Delivery</th>
                          <th className="pb-4 text-right">Fortune</th>
                          <th className="pb-4 text-right">Ikea</th>
                          <th className="pb-4 text-right pr-4">Total</th>
                       </tr>
                    </thead>
                    <tbody className="text-sm">
                       <tr className="bg-slate-50/50 group hover:bg-slate-50 transition-colors">
                          <td className="py-4 pl-4 font-bold text-slate-600 rounded-l-2xl">Sales</td>
                          <td className="py-4 text-right font-mono">2,99,25,265</td>
                          <td className="py-4 text-right font-mono">50,70,465</td>
                          <td className="py-4 text-right font-mono">45,00,000</td>
                          <td className="py-4 text-right font-mono">20,67,107</td>
                          <td className="py-4 text-right font-mono text-slate-300">0</td>
                          <td className="py-4 text-right font-mono text-slate-300">0</td>
                          <td className="py-4 text-right font-black text-indigo-600 pr-4 rounded-r-2xl">4,15,62,837</td>
                       </tr>
                       <tr className="group hover:bg-slate-50 transition-colors">
                          <td className="py-4 pl-4 font-bold text-slate-600">Contr % (Proj)</td>
                          <td className="py-4 text-right font-mono text-slate-500">16%</td>
                          <td className="py-4 text-right font-mono text-slate-500">37%</td>
                          <td className="py-4 text-right font-mono text-slate-500">44%</td>
                          <td className="py-4 text-right font-mono text-slate-500">43%</td>
                          <td className="py-4 text-right font-mono text-slate-300">-</td>
                          <td className="py-4 text-right font-mono text-slate-300">-</td>
                          <td className="py-4 text-right font-black text-slate-900 pr-4">23%</td>
                       </tr>
                       <tr className="bg-emerald-50/30 group hover:bg-emerald-50 transition-colors">
                          <td className="py-4 pl-4 font-bold text-emerald-700 rounded-l-2xl">Contribution</td>
                          <td className="py-4 text-right font-mono text-emerald-600">46,61,347</td>
                          <td className="py-4 text-right font-mono text-emerald-600">18,76,072</td>
                          <td className="py-4 text-right font-mono text-emerald-600">19,80,000</td>
                          <td className="py-4 text-right font-mono text-emerald-600">8,88,856</td>
                          <td className="py-4 text-right font-mono text-slate-300">0</td>
                          <td className="py-4 text-right font-mono text-slate-300">0</td>
                          <td className="py-4 text-right font-black text-emerald-700 pr-4 rounded-r-2xl">94,06,275</td>
                       </tr>
                       <tr className="group hover:bg-slate-50 transition-colors">
                          <td className="py-4 pl-4 font-bold text-slate-600">Expenses</td>
                          <td colSpan={6}></td>
                          <td className="py-4 text-right font-black text-rose-600 pr-4">96,00,000</td>
                       </tr>
                       <tr className="bg-slate-900 text-white rounded-2xl">
                          <td className="py-5 pl-6 font-black uppercase tracking-widest rounded-l-3xl">Profit & Loss</td>
                          <td className="py-5 text-right font-mono text-emerald-400">46,61,347</td>
                          <td className="py-5 text-right font-mono text-emerald-400">18,76,072</td>
                          <td className="py-5 text-right font-mono text-emerald-400">19,80,000</td>
                          <td className="py-5 text-right font-mono text-emerald-400">8,88,856</td>
                          <td className="py-5 text-right font-mono text-slate-500">0</td>
                          <td className="py-5 text-right font-mono text-slate-500">0</td>
                          <td className="py-5 text-right font-black text-rose-400 pr-6 rounded-r-3xl">-1,93,725</td>
                       </tr>
                       <tr className="group hover:bg-slate-50 transition-colors">
                          <td className="py-4 pl-4 font-bold text-slate-600">Other Income</td>
                          <td colSpan={6}></td>
                          <td className="py-4 text-right font-black text-emerald-600 pr-4">4,00,000</td>
                       </tr>
                       <tr className="bg-indigo-600 text-white rounded-2xl">
                          <td className="py-6 pl-8 font-black text-xl uppercase tracking-[0.2em] rounded-l-[40px]">Net Profit/Loss</td>
                          <td colSpan={6}></td>
                          <td className="py-6 text-right font-black text-3xl pr-8 rounded-r-[40px]">₹2,06,275</td>
                       </tr>
                    </tbody>
                 </table>
              </div>
           </div>
         ) : (
           <>
             {/* Sales Velocity vs Target */}
             <div className="lg:col-span-2 bg-white rounded-[50px] p-10 border border-slate-200 shadow-sm space-y-8">
                <div className="flex items-center justify-between">
                   <div>
                      <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Revenue Velocity Analytics</h3>
                      <p className="text-sm text-slate-400 font-medium">MTD Performance vs Quota Trajectory</p>
                   </div>
                   <div className="flex items-center gap-4">
                      <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-indigo-600" /><span className="text-[10px] font-black uppercase text-slate-400">Actuals</span></div>
                      <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-slate-200" /><span className="text-[10px] font-black uppercase text-slate-400">Target</span></div>
                   </div>
                </div>
                
                <div className="h-[400px]">
                   <ResponsiveContainer width="100%" height="100%">
                      <ComposedChart data={[{n:'Week 1', a:120000, t:150000},{n:'Week 2', a:280000, t:300000},{n:'Week 3', a:metrics.totalBooked*0.7, t:450000},{n:'Week 4', a:metrics.totalBooked, t:600000}]}>
                         <CartesianGrid vertical={false} strokeDasharray="3 3" stroke="#f1f5f9" />
                         <XAxis dataKey="n" axisLine={false} tickLine={false} tick={{fontSize:11, fontWeight:700, fill:'#94a3b8'}} />
                         <YAxis hide />
                         <Tooltip contentStyle={{borderRadius:'24px', border:'none', boxShadow:'0 25px 50px -12px rgb(0 0 0 / 0.1)'}} />
                         <Area type="monotone" dataKey="a" fill="#6366f1" fillOpacity={0.05} stroke="#6366f1" strokeWidth={4} />
                         <Line type="stepAfter" dataKey="t" stroke="#e2e8f0" strokeDasharray="5 5" strokeWidth={2} dot={false} />
                      </ComposedChart>
                   </ResponsiveContainer>
                </div>
             </div>

             {/* Distribution of Risk (Pie) */}
             <div className="bg-slate-900 rounded-[50px] p-10 text-white shadow-2xl space-y-10 border border-slate-800">
                <div>
                   <h3 className="text-xl font-black uppercase tracking-widest mb-2">Portfolio Concentration</h3>
                   <p className="text-xs text-slate-500 font-medium">Revenue split by Customer Type</p>
                </div>

                <div className="h-64 relative">
                   <ResponsiveContainer width="100%" height="100%">
                      <PieChart>
                         <Pie 
                            data={[
                               {name:'Horeca', value: 45},
                               {name:'Modern Trade', value: 30},
                               {name:'Internal', value: 10},
                               {name:'Other', value: 15}
                            ]} 
                            innerRadius={60} 
                            outerRadius={90} 
                            paddingAngle={8} 
                            dataKey="value"
                         >
                            {COLORS.map((c, i) => <Cell key={i} fill={c} stroke="none" />)}
                         </Pie>
                         <Tooltip />
                      </PieChart>
                   </ResponsiveContainer>
                   <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                      <p className="text-3xl font-black">75%</p>
                      <p className="text-[8px] font-black uppercase text-slate-500">Top Tier</p>
                   </div>
                </div>

                <div className="space-y-4">
                   <div className="flex justify-between items-center bg-white/5 p-4 rounded-2xl">
                      <div className="flex items-center gap-3">
                         <div className="w-2 h-2 rounded-full bg-indigo-500" />
                         <span className="text-[10px] font-black uppercase">Exotic Shellfish</span>
                      </div>
                      <span className="text-xs font-black">42%</span>
                   </div>
                   <div className="flex justify-between items-center bg-white/5 p-4 rounded-2xl">
                      <div className="flex items-center gap-3">
                         <div className="w-2 h-2 rounded-full bg-emerald-500" />
                         <span className="text-[10px] font-black uppercase">Fresh Fillets</span>
                      </div>
                      <span className="text-xs font-black">38%</span>
                   </div>
                </div>
             </div>
           </>
         )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
         
         {/* Efficiency / Yield */}
         <div className="bg-white rounded-[44px] p-8 border border-slate-200 shadow-sm space-y-6">
            <div className="flex items-center gap-4">
               <div className="w-12 h-12 bg-indigo-50 text-indigo-600 rounded-2xl flex items-center justify-center"><Activity size={24}/></div>
               <div><h4 className="text-sm font-black uppercase tracking-widest text-slate-900">Production Yield</h4><p className="text-[10px] text-slate-400 font-bold">Waste Reduction Index</p></div>
            </div>
            <div className="flex items-end justify-between">
               <p className="text-4xl font-black text-slate-900 tracking-tighter">98.2%</p>
               <p className="text-emerald-600 font-black text-xs flex items-center gap-1"><TrendingUp size={12}/> +0.4%</p>
            </div>
            <div className="w-full bg-slate-50 h-2 rounded-full overflow-hidden">
               <div className="h-full bg-indigo-600" style={{width: '98%'}} />
            </div>
         </div>

         {/* Supply Chain Health */}
         <div className="bg-white rounded-[44px] p-8 border border-slate-200 shadow-sm space-y-6">
            <div className="flex items-center gap-4">
               <div className="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center"><Layers size={24}/></div>
               <div><h4 className="text-sm font-black uppercase tracking-widest text-slate-900">Material Coverage</h4><p className="text-[10px] text-slate-400 font-bold">BOM Continuity Score</p></div>
            </div>
            <div className="flex items-end justify-between">
               <p className="text-4xl font-black text-slate-900 tracking-tighter">84 Days</p>
               <p className="text-rose-600 font-black text-xs flex items-center gap-1"><TrendingDown size={12}/> -4d</p>
            </div>
            <div className="w-full bg-slate-50 h-2 rounded-full overflow-hidden">
               <div className="h-full bg-emerald-500" style={{width: '75%'}} />
            </div>
         </div>

         {/* Intelligence / Automation */}
         <div className="bg-slate-900 rounded-[44px] p-8 text-white shadow-xl space-y-6 border border-slate-800 relative overflow-hidden group">
            <div className="flex items-center gap-4">
               <div className="w-12 h-12 bg-indigo-500/20 text-indigo-400 rounded-2xl flex items-center justify-center"><Cpu size={24}/></div>
               <div><h4 className="text-sm font-black uppercase tracking-widest">OMS Automation</h4><p className="text-[10px] text-slate-500 font-bold">Touchless Workflow Index</p></div>
            </div>
            <div className="flex items-end justify-between">
               <p className="text-4xl font-black tracking-tighter">72%</p>
               <p className="text-indigo-400 font-black text-xs flex items-center gap-1"><TrendingUp size={12}/> AI Active</p>
            </div>
            <div className="w-full bg-white/5 h-2 rounded-full overflow-hidden">
               <div className="h-full bg-indigo-500" style={{width: '72%'}} />
            </div>
         </div>

      </div>

    </div>
  );
};

const CEOStatCard = ({ label, value, trend, sub, icon, color, bad }: any) => {
  const colors: any = {
    emerald: 'bg-emerald-50 text-emerald-600 border-emerald-100',
    rose: 'bg-rose-50 text-rose-600 border-rose-100',
    indigo: 'bg-indigo-50 text-indigo-600 border-indigo-100',
    amber: 'bg-amber-50 text-amber-600 border-amber-100'
  };

  return (
    <div className={`bg-white p-8 rounded-[44px] border border-slate-200 shadow-sm transition-all hover:shadow-xl hover:-translate-y-1 group`}>
       <div className={`w-14 h-14 ${colors[color]} rounded-3xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform shadow-sm`}>
          {React.cloneElement(icon, { size: 28 })}
       </div>
       <div className="space-y-1">
          <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">{label}</p>
          <h4 className="text-4xl font-black text-slate-900 tracking-tighter">{value}</h4>
       </div>
       <div className="mt-4 pt-4 border-t border-slate-50 flex items-center justify-between">
          <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">{sub}</span>
          <span className={`px-2 py-0.5 rounded-lg text-[9px] font-black uppercase ${bad ? 'bg-rose-100 text-rose-700' : 'bg-emerald-100 text-emerald-700'}`}>{trend}</span>
       </div>
    </div>
  );
};

export default CEODashboardView;
