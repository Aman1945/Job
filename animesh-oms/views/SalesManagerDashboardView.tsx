
import React, { useMemo } from 'react';
import { Order, OrderStatus, User, UserRole } from '../types';
import { 
  Trophy, 
  Target, 
  TrendingUp, 
  TrendingDown, 
  Users, 
  DollarSign, 
  Package, 
  AlertCircle,
  ArrowUpRight,
  ChevronRight,
  Zap,
  Activity
} from 'lucide-react';
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, Cell, ComposedChart, Line } from 'recharts';

interface SalesManagerDashboardViewProps {
  orders: Order[];
  users: User[];
}

const SalesManagerDashboardView: React.FC<SalesManagerDashboardViewProps> = ({ orders, users }) => {
  const salesUsers = useMemo(() => users.filter(u => u.role === UserRole.SALES), [users]);

  const teamMetrics = useMemo(() => {
    return salesUsers.map(user => {
      const userOrders = orders.filter(o => o.salespersonId === user.id && o.status !== OrderStatus.REJECTED);
      
      const actualValue = userOrders.reduce((sum, o) => {
        return sum + o.items.reduce((iSum, i) => iSum + (i.price * (i.packedQuantity || i.quantity)), 0);
      }, 0);

      const actualQty = userOrders.reduce((sum, o) => {
        return sum + o.items.reduce((iSum, i) => iSum + (i.packedQuantity || i.quantity), 0);
      }, 0);

      const targetValue = user.monthlyTarget || 0;
      const targetQty = user.monthlyQtyTarget || 0;

      const valAchievement = targetValue > 0 ? (actualValue / targetValue) * 100 : 0;
      const qtyAchievement = targetQty > 0 ? (actualQty / targetQty) * 100 : 0;

      const valShortfall = Math.max(0, targetValue - actualValue);
      const qtyShortfall = Math.max(0, targetQty - actualQty);

      return {
        id: user.id,
        name: user.name,
        targetValue,
        actualValue,
        valAchievement,
        valShortfall,
        targetQty,
        actualQty,
        qtyAchievement,
        qtyShortfall
      };
    });
  }, [salesUsers, orders]);

  const aggregateTotals = useMemo(() => {
    return teamMetrics.reduce((acc, m) => ({
      targetValue: acc.targetValue + m.targetValue,
      actualValue: acc.actualValue + m.actualValue,
      targetQty: acc.targetQty + m.targetQty,
      actualQty: acc.actualQty + m.actualQty,
    }), { targetValue: 0, actualValue: 0, targetQty: 0, actualQty: 0 });
  }, [teamMetrics]);

  const totalValAchievement = (aggregateTotals.actualValue / aggregateTotals.targetValue) * 100;

  return (
    <div className="space-y-10 animate-in fade-in duration-700 pb-20">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-4xl font-black text-slate-900 tracking-tighter flex items-center gap-4">
            <Trophy className="text-amber-500" size={40} /> Sales Leadership Hub
          </h2>
          <p className="text-slate-500 font-medium mt-1">Consolidated team performance vs. monthly quotas</p>
        </div>
        <div className="bg-emerald-50 px-6 py-3 rounded-2xl border border-emerald-100 flex items-center gap-4 shadow-sm">
          <div className="w-3 h-3 rounded-full bg-emerald-500 animate-pulse" />
          <span className="text-[10px] font-black text-emerald-700 uppercase tracking-widest">Team Success: {totalValAchievement.toFixed(1)}% Achieved</span>
        </div>
      </div>

      {/* Aggregate KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <MetricCard title="Total Team Target" value={`₹${(aggregateTotals.targetValue / 100000).toFixed(1)}L`} icon={<Target className="text-indigo-600" />} color="bg-indigo-50" />
        <MetricCard title="Actual Booking" value={`₹${(aggregateTotals.actualValue / 100000).toFixed(1)}L`} icon={<DollarSign className="text-emerald-600" />} color="bg-emerald-50" />
        <MetricCard title="Total Qty Booked" value={`${aggregateTotals.actualQty.toLocaleString()}`} icon={<Package className="text-amber-600" />} color="bg-amber-50" />
        <MetricCard title="Global Shortfall" value={`₹${((aggregateTotals.targetValue - aggregateTotals.actualValue) / 100000).toFixed(1)}L`} icon={<TrendingDown className="text-rose-600" />} color="bg-rose-50" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
        {/* Performance Chart */}
        <div className="lg:col-span-2 bg-white p-10 rounded-[44px] border border-slate-200 shadow-sm">
          <div className="flex items-center justify-between mb-10">
            <h3 className="font-black text-slate-900 text-lg uppercase tracking-widest flex items-center gap-3">
              <Activity size={20} className="text-indigo-600" /> Individual Achievement Comparison
            </h3>
          </div>
          <div className="h-[400px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={teamMetrics} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 11, fontWeight: 700, fill: '#64748b' }} />
                <YAxis hide />
                <Tooltip 
                  cursor={{ fill: '#f8fafc' }}
                  contentStyle={{ borderRadius: '24px', border: 'none', boxShadow: '0 25px 50px -12px rgb(0 0 0 / 0.1)' }}
                />
                <Legend iconType="circle" />
                <Bar name="Target (₹)" dataKey="targetValue" fill="#e2e8f0" radius={[10, 10, 0, 0]} />
                <Bar name="Actual (₹)" dataKey="actualValue" radius={[10, 10, 0, 0]}>
                  {teamMetrics.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.valAchievement >= 100 ? '#10b981' : '#6366f1'} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Shortfall Summary Sidebar */}
        <div className="bg-slate-900 rounded-[44px] p-10 text-white shadow-2xl space-y-8 flex flex-col justify-between border border-slate-800">
          <div>
            <h4 className="text-xl font-black mb-6 border-b border-white/10 pb-4">Shortfall Insights</h4>
            <div className="space-y-6">
              {teamMetrics.filter(m => m.valAchievement < 100).map(m => (
                <div key={m.id} className="flex justify-between items-center group">
                  <div>
                    <p className="text-xs font-black uppercase text-slate-400 group-hover:text-rose-400 transition-colors">{m.name}</p>
                    <p className="text-lg font-black text-rose-500">₹{m.valShortfall.toLocaleString()}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Achievement</p>
                    <p className="text-lg font-black text-white">{m.valAchievement.toFixed(1)}%</p>
                  </div>
                </div>
              ))}
              {teamMetrics.filter(m => m.valAchievement < 100).length === 0 && (
                <div className="py-10 text-center">
                  <Zap className="mx-auto text-emerald-400 mb-4" size={48} />
                  <p className="text-sm font-bold text-slate-400 uppercase tracking-widest">100% Efficiency Target Met Across Team</p>
                </div>
              )}
            </div>
          </div>
          <div className="bg-white/5 p-6 rounded-3xl border border-white/10 text-center">
            <p className="text-[10px] font-black uppercase tracking-[0.2em] text-indigo-400 mb-2">Team Strategy</p>
            <p className="text-xs text-slate-400 leading-relaxed italic">Focus on high-margin Exotic Shellfish SKUs to close gaps in the final week of operations.</p>
          </div>
        </div>
      </div>

      {/* Detailed Team Table */}
      <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-8 border-b bg-slate-50/30 flex items-center justify-between">
          <h3 className="font-black text-slate-900 text-lg uppercase tracking-widest">Full Performance Ledger</h3>
          <button className="px-6 py-2 bg-slate-100 text-slate-500 rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-slate-200 transition-all">Export Audit Report</button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left min-w-[1000px]">
            <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] border-b">
              <tr>
                <th className="px-10 py-6">Sales Executive</th>
                <th className="px-6 py-6 text-right">Value Target</th>
                <th className="px-6 py-6 text-right">Value Actual</th>
                <th className="px-6 py-6 text-center">Val. Achievement %</th>
                <th className="px-6 py-6 text-right">Qty Target</th>
                <th className="px-6 py-6 text-right">Qty Actual</th>
                <th className="px-10 py-6 text-right">Shortfall (Value)</th>
              </tr>
            </thead>
            <tbody className="divide-y text-sm font-bold text-slate-700">
              {teamMetrics.map(m => (
                <tr key={m.id} className="hover:bg-slate-50/50 transition-colors group">
                  <td className="px-10 py-6">
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-10 bg-slate-100 rounded-xl flex items-center justify-center font-black text-xs text-slate-400 group-hover:bg-indigo-600 group-hover:text-white transition-all">
                        {m.name.charAt(0)}
                      </div>
                      <div>
                        <p className="text-slate-900 font-black">{m.name}</p>
                        <p className="text-[9px] text-slate-400 font-bold uppercase mt-0.5">{m.id}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-6 text-right font-mono">₹{m.targetValue.toLocaleString()}</td>
                  <td className="px-6 py-6 text-right font-mono text-slate-900">₹{m.actualValue.toLocaleString()}</td>
                  <td className="px-6 py-6 text-center">
                    <span className={`px-4 py-1.5 rounded-full text-xs font-black ${m.valAchievement < 100 ? 'bg-rose-50 text-rose-600 border border-rose-100' : 'bg-emerald-50 text-emerald-600 border border-emerald-100'}`}>
                      {m.valAchievement.toFixed(1)}%
                    </span>
                  </td>
                  <td className="px-6 py-6 text-right font-mono italic text-slate-400">{m.targetQty.toLocaleString()}</td>
                  <td className="px-6 py-6 text-right font-mono text-slate-900">{m.actualQty.toLocaleString()}</td>
                  <td className="px-10 py-6 text-right">
                    {m.valAchievement < 100 ? (
                      <span className="text-rose-600 font-black flex items-center justify-end gap-2 animate-in slide-in-from-right-2">
                        <TrendingDown size={14}/> ₹{m.valShortfall.toLocaleString()}
                      </span>
                    ) : (
                      <span className="text-emerald-600 font-black flex items-center justify-end gap-2">
                        <TrendingUp size={14}/> Surplus
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

const MetricCard = ({ title, value, icon, color }: { title: string, value: string, icon: React.ReactNode, color: string }) => (
  <div className={`bg-white p-8 rounded-[36px] border border-slate-200 shadow-sm transition-all hover:scale-[1.03] group`}>
    <div className={`w-12 h-12 ${color} rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform`}>
      {icon}
    </div>
    <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">{title}</p>
    <h4 className="text-3xl font-black text-slate-900 tracking-tighter">{value}</h4>
  </div>
);

export default SalesManagerDashboardView;
