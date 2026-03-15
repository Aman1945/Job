
import React, { useState, useMemo } from 'react';
import { 
  Order, Customer, Product, ProcurementItem, User, 
  SupplyChainAlert, POStatus, DemandForecast, ForecastOverride, WorkingCapitalMetrics, InventoryHealth 
} from '../types';
import { 
  Brain, 
  AlertTriangle, 
  TrendingUp, 
  ShieldCheck, 
  Zap, 
  Box, 
  Truck, 
  DollarSign, 
  BarChart3, 
  Activity, 
  Search,
  ArrowUpRight,
  ArrowDownRight,
  TrendingDown,
  Clock,
  Filter,
  Layers,
  Cpu,
  History,
  CheckCircle2,
  XCircle,
  AlertCircle
} from 'lucide-react';
import { 
  ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid, 
  Tooltip, PieChart, Pie, Cell, BarChart, Bar, Legend, ComposedChart, Line
} from 'recharts';

interface ControlTowerViewProps {
  orders: Order[];
  customers: Customer[];
  products: Product[];
  procurement: ProcurementItem[];
  users: User[];
  alerts: SupplyChainAlert[];
  poStatus: POStatus[];
  forecasts: DemandForecast[];
  overrides: ForecastOverride[];
  workingCapital: WorkingCapitalMetrics;
}

const ControlTowerView: React.FC<ControlTowerViewProps> = ({ 
  orders, customers, products, procurement, users, 
  alerts, poStatus, forecasts, overrides, workingCapital 
}) => {
  const [activeModule, setActiveModule] = useState<'Demand' | 'Inventory' | 'Governance' | 'Alerts' | 'PO' | 'Capital'>('Alerts');

  const COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899'];

  const renderModule = () => {
    switch (activeModule) {
      case 'Alerts': return <AlertsModule alerts={alerts} />;
      case 'Demand': return <DemandModule forecasts={forecasts} overrides={overrides} />;
      case 'Inventory': return <InventoryModule products={products} />;
      case 'Governance': return <GovernanceModule overrides={overrides} />;
      case 'PO': return <POModule poStatus={poStatus} />;
      case 'Capital': return <CapitalModule metrics={workingCapital} />;
      default: return null;
    }
  };

  return (
    <div className="max-w-[1600px] mx-auto space-y-8 pb-24 animate-in fade-in duration-700">
      
      {/* Control Tower Header */}
      <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl relative overflow-hidden border border-slate-800">
         <Cpu className="absolute -right-12 -top-12 w-80 h-80 opacity-[0.03] text-indigo-400" />
         <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-8">
            <div className="flex items-center gap-6">
               <div className="w-20 h-20 bg-gradient-to-br from-indigo-600 to-indigo-400 rounded-3xl flex items-center justify-center text-white shadow-2xl shadow-indigo-500/20">
                  <Brain size={40} />
               </div>
               <div>
                  <h2 className="text-4xl font-black tracking-tighter">AI Operations Control Tower</h2>
                  <div className="flex items-center gap-3 mt-2">
                     <span className="text-indigo-400 font-black uppercase tracking-[0.2em] text-[10px]">Supply Chain Intelligence Layer</span>
                     <div className="w-1.5 h-1.5 rounded-full bg-slate-600" />
                     <span className="text-slate-400 font-bold uppercase tracking-widest text-[10px] flex items-center gap-2">
                        <Activity size={12}/> System Health: Optimal
                     </span>
                  </div>
               </div>
            </div>
            
            <div className="flex flex-wrap gap-2 bg-white/5 p-1.5 rounded-[24px] border border-white/10 backdrop-blur-md">
               {[
                 { id: 'Alerts', label: 'Early Warnings', icon: <AlertTriangle size={14}/> },
                 { id: 'Demand', label: 'Demand Intel', icon: <TrendingUp size={14}/> },
                 { id: 'Inventory', label: 'Inventory Risk', icon: <Box size={14}/> },
                 { id: 'PO', label: 'PO Visibility', icon: <Truck size={14}/> },
                 { id: 'Capital', label: 'Working Capital', icon: <DollarSign size={14}/> },
                 { id: 'Governance', label: 'Governance', icon: <ShieldCheck size={14}/> }
               ].map(mod => (
                 <button 
                   key={mod.id} 
                   onClick={() => setActiveModule(mod.id as any)}
                   className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all flex items-center gap-2 ${activeModule === mod.id ? 'bg-white text-slate-900 shadow-xl' : 'text-slate-400 hover:text-white'}`}
                 >
                   {mod.icon}
                   {mod.label}
                 </button>
               ))}
            </div>
         </div>
      </div>

      {/* Module Content */}
      <div className="min-h-[600px]">
        {renderModule()}
      </div>

    </div>
  );
};

const AlertsModule = ({ alerts }: { alerts: SupplyChainAlert[] }) => {
  return (
    <div className="space-y-6 animate-in slide-in-from-bottom-4 duration-500">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-rose-50 border border-rose-100 p-6 rounded-[32px] flex items-center gap-4">
          <div className="w-12 h-12 bg-rose-500 text-white rounded-2xl flex items-center justify-center shadow-lg shadow-rose-500/20"><AlertCircle size={24}/></div>
          <div>
            <p className="text-[10px] font-black uppercase tracking-widest text-rose-600">Critical Alerts</p>
            <p className="text-2xl font-black text-rose-900">{alerts.filter(a => a.severity === 'Critical').length}</p>
          </div>
        </div>
        <div className="bg-amber-50 border border-amber-100 p-6 rounded-[32px] flex items-center gap-4">
          <div className="w-12 h-12 bg-amber-500 text-white rounded-2xl flex items-center justify-center shadow-lg shadow-amber-500/20"><AlertTriangle size={24}/></div>
          <div>
            <p className="text-[10px] font-black uppercase tracking-widest text-amber-600">Medium Risk</p>
            <p className="text-2xl font-black text-amber-900">{alerts.filter(a => a.severity === 'Medium').length}</p>
          </div>
        </div>
        <div className="bg-indigo-50 border border-indigo-100 p-6 rounded-[32px] flex items-center gap-4">
          <div className="w-12 h-12 bg-indigo-500 text-white rounded-2xl flex items-center justify-center shadow-lg shadow-indigo-500/20"><Zap size={24}/></div>
          <div>
            <p className="text-[10px] font-black uppercase tracking-widest text-indigo-600">AI Predictions</p>
            <p className="text-2xl font-black text-indigo-900">Active</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-8 border-b border-slate-100 flex justify-between items-center">
          <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Anomaly Detection Feed</h3>
          <button className="text-[10px] font-black uppercase tracking-widest text-indigo-600 hover:text-indigo-700">Clear All</button>
        </div>
        <div className="divide-y divide-slate-50">
          {alerts.map(alert => (
            <div key={alert.id} className="p-8 hover:bg-slate-50 transition-colors flex gap-6">
              <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${
                alert.severity === 'Critical' ? 'bg-rose-100 text-rose-600' : 
                alert.severity === 'Medium' ? 'bg-amber-100 text-amber-600' : 'bg-indigo-100 text-indigo-600'
              }`}>
                {alert.type === 'Stockout Risk' ? <Box size={24}/> : 
                 alert.type === 'Demand Spike' ? <TrendingUp size={24}/> : <Truck size={24}/>}
              </div>
              <div className="flex-1 space-y-2">
                <div className="flex justify-between items-start">
                  <div>
                    <span className={`text-[9px] font-black uppercase px-2 py-0.5 rounded-md mb-1 inline-block ${
                      alert.severity === 'Critical' ? 'bg-rose-600 text-white' : 
                      alert.severity === 'Medium' ? 'bg-amber-500 text-white' : 'bg-indigo-500 text-white'
                    }`}>
                      {alert.severity} Severity
                    </span>
                    <h4 className="text-lg font-black text-slate-900">{alert.type}: {alert.skuName}</h4>
                  </div>
                  <span className="text-[10px] font-bold text-slate-400 flex items-center gap-1"><Clock size={12}/> {alert.timestamp}</span>
                </div>
                <p className="text-slate-600 text-sm">{alert.message}</p>
                <div className="bg-slate-100 p-4 rounded-2xl flex items-center justify-between">
                  <p className="text-xs font-bold text-slate-700 flex items-center gap-2">
                    <Zap size={14} className="text-indigo-600"/> Recommended Action: {alert.recommendedAction}
                  </p>
                  <button className="px-4 py-2 bg-white text-[10px] font-black uppercase tracking-widest rounded-xl border border-slate-200 hover:bg-slate-50 transition-all">Execute</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

const DemandModule = ({ forecasts, overrides }: { forecasts: DemandForecast[], overrides: ForecastOverride[] }) => {
  return (
    <div className="space-y-8 animate-in slide-in-from-bottom-4 duration-500">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-white rounded-[40px] p-10 border border-slate-200 shadow-sm space-y-8">
          <div className="flex justify-between items-center">
            <div>
              <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Demand Intelligence Engine</h3>
              <p className="text-sm text-slate-400 font-medium">Real-time demand sensing & mid-cycle adjustments</p>
            </div>
            <div className="flex gap-2">
              <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-indigo-600" /><span className="text-[10px] font-black uppercase text-slate-400">AI Forecast</span></div>
              <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-slate-200" /><span className="text-[10px] font-black uppercase text-slate-400">Historical</span></div>
            </div>
          </div>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={forecasts}>
                <CartesianGrid vertical={false} strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="skuName" axisLine={false} tickLine={false} tick={{fontSize:10, fontWeight:700, fill:'#94a3b8'}} />
                <YAxis hide />
                <Tooltip contentStyle={{borderRadius:'20px', border:'none', boxShadow:'0 20px 40px -10px rgb(0 0 0 / 0.1)'}} />
                <Bar dataKey="historicalAvg" fill="#e2e8f0" radius={[10, 10, 0, 0]} />
                <Bar dataKey="aiPredicted" fill="#6366f1" radius={[10, 10, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
        <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl space-y-8 border border-slate-800">
          <h3 className="text-xl font-black uppercase tracking-widest">Forecast Accuracy</h3>
          <div className="space-y-6">
            {forecasts.map(f => (
              <div key={f.skuId} className="space-y-2">
                <div className="flex justify-between items-center">
                  <span className="text-xs font-bold text-slate-400">{f.skuName}</span>
                  <span className="text-xs font-black text-emerald-400">{f.accuracyPercent}%</span>
                </div>
                <div className="w-full bg-white/5 h-2 rounded-full overflow-hidden">
                  <div className="h-full bg-emerald-500" style={{width: `${f.accuracyPercent}%`}} />
                </div>
              </div>
            ))}
          </div>
          <div className="pt-6 border-t border-white/10">
            <p className="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-4">AI Insights</p>
            <p className="text-sm italic text-slate-300 leading-relaxed">"Forecast accuracy improved by 12% following the inclusion of distributor sell-out data in the Norwegian Salmon category."</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-8 border-b border-slate-100">
          <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Substitution & Pattern Recognition</h3>
        </div>
        <div className="p-8 grid grid-cols-1 md:grid-cols-2 gap-8">
          <div className="bg-slate-50 p-6 rounded-3xl border border-slate-100 flex items-center gap-6">
            <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center shadow-sm text-indigo-600"><History size={32}/></div>
            <div>
              <h4 className="font-black text-slate-900">SKU Substitution Detected</h4>
              <p className="text-sm text-slate-500">Customers switching from 'Trim C' to 'Trim D' due to price variance.</p>
              <button className="mt-2 text-xs font-black text-indigo-600 uppercase tracking-widest">Adjust Planning Logic</button>
            </div>
          </div>
          <div className="bg-slate-50 p-6 rounded-3xl border border-slate-100 flex items-center gap-6">
            <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center shadow-sm text-emerald-600"><CheckCircle2 size={32}/></div>
            <div>
              <h4 className="font-black text-slate-900">Promotion Impact Validated</h4>
              <p className="text-sm text-slate-500">Marriott promotion resulted in 22% lift vs 15% predicted.</p>
              <button className="mt-2 text-xs font-black text-emerald-600 uppercase tracking-widest">Update ML Model</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const InventoryModule = ({ products }: { products: Product[] }) => {
  return (
    <div className="space-y-8 animate-in slide-in-from-bottom-4 duration-500">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <InventoryStatCard label="Healthy Stock" value="68%" color="emerald" />
        <InventoryStatCard label="Aging Stock" value="18%" color="amber" />
        <InventoryStatCard label="Slow Moving" value="9%" color="indigo" />
        <InventoryStatCard label="Dead/Expiry Risk" value="5%" color="rose" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-white rounded-[40px] p-10 border border-slate-200 shadow-sm space-y-8">
          <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Inventory Risk Heatmap</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {['Kurla', 'DP World', 'Arihant Delhi', 'Jolly Bng'].map(loc => (
              <div key={loc} className="bg-slate-50 p-6 rounded-3xl border border-slate-100 text-center space-y-2">
                <p className="text-[10px] font-black uppercase tracking-widest text-slate-400">{loc}</p>
                <p className="text-2xl font-black text-slate-900">₹{(Math.random() * 50).toFixed(1)}L</p>
                <div className="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden">
                  <div className="h-full bg-indigo-500" style={{width: `${Math.random() * 100}%`}} />
                </div>
              </div>
            ))}
          </div>
          <div className="bg-indigo-50 p-6 rounded-3xl border border-indigo-100 flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-indigo-500 text-white rounded-2xl flex items-center justify-center"><ArrowUpRight size={24}/></div>
              <div>
                <h4 className="font-black text-indigo-900">Transfer Suggestion</h4>
                <p className="text-sm text-indigo-700">Move 200kg of Salmon Fillet from Kurla to Delhi to avoid stockout risk.</p>
              </div>
            </div>
            <button className="px-6 py-3 bg-indigo-600 text-white text-[10px] font-black uppercase tracking-widest rounded-2xl shadow-lg shadow-indigo-600/20">Approve Transfer</button>
          </div>
        </div>
        <div className="bg-white rounded-[40px] p-10 border border-slate-200 shadow-sm space-y-8">
          <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Expiry Probability</h3>
          <div className="space-y-6">
            {products.slice(0, 4).map(p => (
              <div key={p.id} className="flex items-center justify-between p-4 bg-slate-50 rounded-2xl border border-slate-100">
                <div>
                  <p className="text-xs font-black text-slate-900">{p.name}</p>
                  <p className="text-[10px] text-slate-500">Batch: BT-{(Math.random() * 1000).toFixed(0)}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-black text-rose-600">{(Math.random() * 40).toFixed(1)}% Risk</p>
                  <p className="text-[10px] text-slate-400">of write-off</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

const InventoryStatCard = ({ label, value, color }: any) => {
  const colors: any = {
    emerald: 'bg-emerald-50 text-emerald-600 border-emerald-100',
    amber: 'bg-amber-50 text-amber-600 border-amber-100',
    indigo: 'bg-indigo-50 text-indigo-600 border-indigo-100',
    rose: 'bg-rose-50 text-rose-600 border-rose-100'
  };
  return (
    <div className={`p-6 rounded-[32px] border ${colors[color]} text-center space-y-2`}>
      <p className="text-[10px] font-black uppercase tracking-widest opacity-70">{label}</p>
      <p className="text-3xl font-black">{value}</p>
    </div>
  );
};

const GovernanceModule = ({ overrides }: { overrides: ForecastOverride[] }) => {
  return (
    <div className="space-y-8 animate-in slide-in-from-bottom-4 duration-500">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-white rounded-[40px] p-10 border border-slate-200 shadow-sm space-y-8">
          <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Override Governance System</h3>
          <div className="overflow-x-auto">
            <table className="w-full text-left border-separate border-spacing-y-2">
              <thead>
                <tr className="text-[10px] font-black uppercase tracking-widest text-slate-400">
                  <th className="pb-4 pl-4">User</th>
                  <th className="pb-4">SKU</th>
                  <th className="pb-4">Adjustment</th>
                  <th className="pb-4">Reason</th>
                  <th className="pb-4">Impact</th>
                  <th className="pb-4 pr-4">Status</th>
                </tr>
              </thead>
              <tbody className="text-sm">
                {overrides.map(ovr => (
                  <tr key={ovr.id} className="bg-slate-50 hover:bg-slate-100 transition-colors">
                    <td className="py-4 pl-4 rounded-l-2xl font-bold text-slate-900">{ovr.userName}</td>
                    <td className="py-4 font-medium text-slate-600">{ovr.skuId}</td>
                    <td className="py-4 font-mono text-indigo-600">{ovr.originalForecast} → {ovr.newForecast}</td>
                    <td className="py-4 text-xs text-slate-500">{ovr.reason}</td>
                    <td className="py-4">
                      <span className="text-emerald-600 font-black text-xs">+{ovr.impactOnServiceLevel}% Service</span>
                    </td>
                    <td className="py-4 pr-4 rounded-r-2xl">
                      <span className="px-2 py-1 bg-emerald-100 text-emerald-700 text-[9px] font-black uppercase rounded-md">Value Add</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
        <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl space-y-8 border border-slate-800">
          <h3 className="text-xl font-black uppercase tracking-widest">Override Performance</h3>
          <div className="space-y-8">
            <div className="flex items-center gap-6">
              <div className="w-16 h-16 bg-emerald-500/20 text-emerald-400 rounded-2xl flex items-center justify-center border border-emerald-500/20"><TrendingUp size={32}/></div>
              <div>
                <p className="text-2xl font-black text-emerald-400">82%</p>
                <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">Value Adding Overrides</p>
              </div>
            </div>
            <div className="flex items-center gap-6">
              <div className="w-16 h-16 bg-rose-500/20 text-rose-400 rounded-2xl flex items-center justify-center border border-rose-500/20"><TrendingDown size={32}/></div>
              <div>
                <p className="text-2xl font-black text-rose-400">18%</p>
                <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">Harmful Overrides</p>
              </div>
            </div>
          </div>
          <div className="pt-6 border-t border-white/10">
            <p className="text-sm italic text-slate-400 leading-relaxed">"System identified that manual overrides in the 'Retail' channel consistently lead to excess inventory. Recommend restricting override authority for Tier C SKUs."</p>
          </div>
        </div>
      </div>
    </div>
  );
};

const POModule = ({ poStatus }: { poStatus: POStatus[] }) => {
  return (
    <div className="space-y-8 animate-in slide-in-from-bottom-4 duration-500">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div className="bg-white rounded-[40px] p-8 border border-slate-200 shadow-sm space-y-4">
          <p className="text-[10px] font-black uppercase tracking-widest text-slate-400">On-Time Delivery (OTD)</p>
          <p className="text-4xl font-black text-slate-900">92.4%</p>
          <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
            <div className="h-full bg-emerald-500" style={{width: '92%'}} />
          </div>
        </div>
        <div className="bg-white rounded-[40px] p-8 border border-slate-200 shadow-sm space-y-4">
          <p className="text-[10px] font-black uppercase tracking-widest text-slate-400">Average PO Aging</p>
          <p className="text-4xl font-black text-slate-900">14 Days</p>
          <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
            <div className="h-full bg-indigo-500" style={{width: '60%'}} />
          </div>
        </div>
        <div className="bg-white rounded-[40px] p-8 border border-slate-200 shadow-sm space-y-4">
          <p className="text-[10px] font-black uppercase tracking-widest text-slate-400">Supplier Fill Rate</p>
          <p className="text-4xl font-black text-slate-900">88.2%</p>
          <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
            <div className="h-full bg-amber-500" style={{width: '88%'}} />
          </div>
        </div>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-8 border-b border-slate-100 flex justify-between items-center">
          <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Real-Time PO Visibility</h3>
          <div className="flex gap-2">
            <button className="px-4 py-2 bg-slate-100 text-[10px] font-black uppercase tracking-widest rounded-xl">All POs</button>
            <button className="px-4 py-2 bg-rose-50 text-rose-600 text-[10px] font-black uppercase tracking-widest rounded-xl border border-rose-100">Risk Flagged</button>
          </div>
        </div>
        <div className="divide-y divide-slate-50">
          {poStatus.map(po => (
            <div key={po.id} className="p-8 hover:bg-slate-50 transition-colors flex items-center justify-between">
              <div className="flex items-center gap-6">
                <div className={`w-14 h-14 rounded-2xl flex items-center justify-center ${
                  po.status === 'Delayed' ? 'bg-rose-100 text-rose-600' : 
                  po.status === 'At Risk' ? 'bg-amber-100 text-amber-600' : 'bg-emerald-100 text-emerald-600'
                }`}>
                  <Truck size={24}/>
                </div>
                <div>
                  <h4 className="text-lg font-black text-slate-900">{po.id}: {po.supplierName}</h4>
                  <p className="text-sm text-slate-500">{po.skuName} • {po.orderQty}kg</p>
                </div>
              </div>
              <div className="flex items-center gap-12 text-right">
                <div>
                  <p className="text-[10px] font-black uppercase text-slate-400 mb-1">Expected Date</p>
                  <p className="text-sm font-bold text-slate-700">{po.expectedDate}</p>
                </div>
                <div>
                  <p className="text-[10px] font-black uppercase text-slate-400 mb-1">Risk Score</p>
                  <p className={`text-sm font-black ${po.riskScore > 50 ? 'text-rose-600' : 'text-emerald-600'}`}>{po.riskScore}/100</p>
                </div>
                <div className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest ${
                  po.status === 'Delayed' ? 'bg-rose-100 text-rose-700' : 
                  po.status === 'At Risk' ? 'bg-amber-100 text-amber-700' : 'bg-emerald-100 text-emerald-700'
                }`}>
                  {po.status}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

const CapitalModule = ({ metrics }: { metrics: WorkingCapitalMetrics }) => {
  return (
    <div className="space-y-8 animate-in slide-in-from-bottom-4 duration-500">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl space-y-6 border border-slate-800 relative overflow-hidden">
          <DollarSign className="absolute -right-8 -top-8 w-48 h-48 opacity-[0.05] text-emerald-400" />
          <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">Total Inventory Value</p>
          <p className="text-5xl font-black tracking-tighter text-emerald-400">₹{(metrics.inventoryValue / 100000).toFixed(1)}L</p>
          <div className="pt-6 border-t border-white/10 flex justify-between items-center">
            <span className="text-[10px] font-black uppercase text-slate-500">Working Capital Blocked</span>
            <span className="text-rose-400 font-black text-xs flex items-center gap-1"><ArrowUpRight size={12}/> +4.2%</span>
          </div>
        </div>
        <div className="bg-white rounded-[40px] p-10 border border-slate-200 shadow-sm space-y-6">
          <p className="text-[10px] font-black uppercase tracking-widest text-slate-400">Cash Blocked in Excess Stock</p>
          <p className="text-5xl font-black tracking-tighter text-slate-900">₹{(metrics.cashBlockedInExcess / 100000).toFixed(1)}L</p>
          <div className="pt-6 border-t border-slate-100 flex justify-between items-center">
            <span className="text-[10px] font-black uppercase text-slate-400">Liquidation Target</span>
            <span className="text-emerald-600 font-black text-xs flex items-center gap-1"><TrendingDown size={12}/> -₹1.2L</span>
          </div>
        </div>
        <div className="bg-white rounded-[40px] p-10 border border-slate-200 shadow-sm space-y-6">
          <p className="text-[10px] font-black uppercase tracking-widest text-slate-400">Dead Stock Percentage</p>
          <p className="text-5xl font-black tracking-tighter text-rose-600">{metrics.deadStockPercent}%</p>
          <div className="pt-6 border-t border-slate-100 flex justify-between items-center">
            <span className="text-[10px] font-black uppercase text-slate-400">Write-off Risk</span>
            <span className="text-rose-600 font-black text-xs flex items-center gap-1"><AlertTriangle size={12}/> Critical</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white rounded-[40px] p-10 border border-slate-200 shadow-sm space-y-8">
          <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Capital Efficiency Breakdown</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie 
                  data={[
                    {name:'Healthy', value: metrics.inventoryValue - metrics.agingValue},
                    {name:'Aging', value: metrics.agingValue},
                    {name:'Slow Moving', value: metrics.slowMovingValue}
                  ]} 
                  innerRadius={60} 
                  outerRadius={90} 
                  paddingAngle={8} 
                  dataKey="value"
                >
                  {['#10b981', '#f59e0b', '#6366f1'].map((c, i) => <Cell key={i} fill={c} stroke="none" />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
        <div className="bg-white rounded-[40px] p-10 border border-slate-200 shadow-sm space-y-8">
          <h3 className="text-xl font-black text-slate-900 uppercase tracking-widest">Forecast Variance Impact</h3>
          <div className="space-y-6">
            <div className="p-6 bg-slate-50 rounded-3xl border border-slate-100">
              <p className="text-sm font-bold text-slate-700 mb-2">Impact of Forecast Error on Working Capital</p>
              <p className="text-3xl font-black text-rose-600">₹{(metrics.forecastVarianceImpact / 100000).toFixed(1)}L</p>
              <p className="text-[10px] text-slate-400 mt-2 uppercase font-black tracking-widest">Lost Opportunity Cost</p>
            </div>
            <div className="bg-indigo-600 p-6 rounded-3xl text-white shadow-xl shadow-indigo-600/20">
              <h4 className="font-black uppercase tracking-widest text-xs mb-2">AI Optimization Strategy</h4>
              <p className="text-sm italic opacity-90 leading-relaxed">"By reducing forecast error by 20%, we can release ₹12.5L in working capital over the next 90 days."</p>
              <button className="mt-4 w-full py-3 bg-white text-indigo-600 text-[10px] font-black uppercase tracking-widest rounded-xl">Simulate Scenario</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ControlTowerView;
