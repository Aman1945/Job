
import React, { useState, useMemo } from 'react';
import { Product, ProductionLog, InventoryTransaction, User, PackagingMaterial, LaborSession, Order, OrderStatus, BatchInfo } from '../types';
import { 
  Warehouse, RefreshCcw, ArrowUpRight, Activity, Plus, Search, 
  Calendar, Layers, Tag, Clock, CheckCircle2, AlertTriangle, History, TrendingUp, 
  Box, Scale, ArrowRight, ShieldCheck, Scan, RotateCw, MapPin, Circle, Users,
  Calculator, Timer, DollarSign, Split, Truck, AlertCircle, PackageCheck, Archive, Thermometer,
  ChevronDown, ChevronUp, BarChart
} from 'lucide-react';

interface InventoryHubViewProps {
  products: Product[];
  orders: Order[];
  packaging: PackagingMaterial[];
  transactions: InventoryTransaction[];
  productionLogs: ProductionLog[];
  laborSessions: LaborSession[];
  onUpdateProducts: (p: Product[]) => void;
  onUpdateTransactions: (t: InventoryTransaction[]) => void;
  onUpdateProductionLogs: (l: ProductionLog[]) => void;
  onUpdateLaborSessions: (s: LaborSession[]) => void;
  currentUser: User;
}

const InventoryHubView: React.FC<InventoryHubViewProps> = ({ 
  products, orders, packaging, transactions, productionLogs, laborSessions, 
  onUpdateProducts, onUpdateTransactions, onUpdateProductionLogs, onUpdateLaborSessions, currentUser 
}) => {
  const [activeTab, setActiveTab] = useState<'Health' | 'Production' | 'Transactions' | 'Warehouse' | 'Labor'>('Health');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedWH, setSelectedWH] = useState<string | null>(null);
  const [expandedSkus, setExpandedSkus] = useState<Set<string>>(new Set());

  const WAREHOUSES = ['IOPL Kurla', 'IOPL DP WORLD', 'IOPL Arihant Delhi', 'IOPL Jolly Bng'];

  const toggleSkuExpansion = (sku: string) => {
    const newSet = new Set(expandedSkus);
    if (newSet.has(sku)) newSet.delete(sku);
    else newSet.add(sku);
    setExpandedSkus(newSet);
  };

  // Labor Form State
  const [laborForm, setLaborForm] = useState({
    headcount: 5,
    rate: 1000,
    start: '08:00',
    dispatch: '12:00',
    end: '18:00',
    date: new Date().toISOString().split('T')[0]
  });

  // Production Form State
  const [prodForm, setProdForm] = useState({
    rawSkuId: '',
    rawQtyUsed: 0,
    finishedSkuId: '',
    finishedQtyProduced: 0,
    batchNo: `PRD-${Date.now().toString().slice(-6)}`,
    packagingId: '',
    laborSessionId: laborSessions[0]?.id || ''
  });

  const filteredProducts = useMemo(() => {
    return products.filter(p => p.name.toLowerCase().includes(searchTerm.toLowerCase()) || p.skuCode.toLowerCase().includes(searchTerm.toLowerCase()));
  }, [products, searchTerm]);

  // --- Cold Room Analytics Logic ---
  const whAnalytics = useMemo(() => {
    if (!selectedWH) return null;

    const today = new Date();
    const ninetyDaysFromNow = new Date();
    ninetyDaysFromNow.setDate(today.getDate() + 90);

    const whProducts = products.filter(p => (p.warehouseStock?.[selectedWH] || 0) > 0);
    
    let totalStock = 0;
    let overageStockCount = 0;
    let nearExpiryCount = 0;
    let expiredCount = 0;
    let slowMovingCount = 0;

    const enrichedProducts = whProducts.map(p => {
      const qty = p.warehouseStock?.[selectedWH] || 0;
      totalStock += qty;

      const ads = p.avgDailySales || 0;
      const isOverage = ads > 0 && qty > (ads * 90);
      const isSlow = ads < 2 && qty > 50;
      
      const hasExpired = p.availableBatches?.some(b => new Date(b.expDate) < today);
      const hasNearExpiry = p.availableBatches?.some(b => {
        const d = new Date(b.expDate);
        return d >= today && d <= ninetyDaysFromNow;
      });

      if (isOverage) overageStockCount++;
      if (isSlow) slowMovingCount++;
      if (hasExpired) expiredCount++;
      if (hasNearExpiry) nearExpiryCount++;

      return {
        ...p,
        currentQty: qty,
        isOverage,
        isSlow,
        hasNearExpiry,
        hasExpired,
        batches: p.availableBatches || []
      };
    });

    return { 
      totalStock, 
      overageStockCount, 
      nearExpiryCount, 
      expiredCount, 
      slowMovingCount, 
      enrichedProducts 
    };
  }, [products, selectedWH]);

  // --- Labor Efficiency Calculation ---
  const dailyEfficiency = useMemo(() => {
    const selectedDateStr = laborForm.date;
    const dailyOrders = (orders || []).filter(o => 
      o.createdAt.split('T')[0] === selectedDateStr && 
      (o.status === OrderStatus.PICKED_UP || o.status === OrderStatus.OUT_FOR_DELIVERY || o.status === OrderStatus.DELIVERED || o.status === OrderStatus.READY_FOR_DISPATCH)
    );
    const totalDispatchedKg = dailyOrders.reduce((sum, o) => {
      const orderKg = o.items.reduce((iSum, i) => iSum + (i.packedQuantity || i.quantity), 0);
      return sum + orderKg;
    }, 0);
    const dailyProduction = (productionLogs || []).filter(log => log.timestamp.split('T')[0] === selectedDateStr);
    const totalPacketsPacked = dailyProduction.reduce((sum, log) => sum + log.finishedQtyProduced, 0);
    return { dispatchCount: dailyOrders.length, totalDispatchedKg, totalPacketsPacked, productionRunCount: dailyProduction.length };
  }, [orders, productionLogs, laborForm.date]);

  const laborCalc = useMemo(() => {
    const startH = parseInt(laborForm.start.split(':')[0]);
    const startM = parseInt(laborForm.start.split(':')[1]);
    const dispH = parseInt(laborForm.dispatch.split(':')[0]);
    const dispM = parseInt(laborForm.dispatch.split(':')[1]);
    const endH = parseInt(laborForm.end.split(':')[0]);
    const endM = parseInt(laborForm.end.split(':')[1]);
    const startTotal = startH * 60 + startM;
    const dispTotal = dispH * 60 + dispM;
    const endTotal = endH * 60 + endM;
    const totalMinutes = endTotal - startTotal;
    const loadingMinutes = dispTotal - startTotal;
    const totalDailyCost = laborForm.headcount * laborForm.rate;
    const costPerMin = totalMinutes > 0 ? totalDailyCost / totalMinutes : 0;
    const loadingCost = loadingMinutes * costPerMin;
    const repackagingCost = totalDailyCost - loadingCost;
    const costPerKg = dailyEfficiency.totalDispatchedKg > 0 ? loadingCost / dailyEfficiency.totalDispatchedKg : 0;
    const costPerPkt = dailyEfficiency.totalPacketsPacked > 0 ? repackagingCost / dailyEfficiency.totalPacketsPacked : 0;
    return { totalDailyCost, loadingCost, repackagingCost, loadingHrs: (loadingMinutes / 60).toFixed(1), costPerKg, costPerPkt };
  }, [laborForm, dailyEfficiency]);

  const handleLaborSubmit = () => {
    const newSession: LaborSession = {
      id: 'LS-' + Math.floor(Math.random() * 9000 + 1000),
      date: laborForm.date,
      headcount: laborForm.headcount,
      ratePerLabour: laborForm.rate,
      shiftStart: laborForm.start,
      dispatchTime: laborForm.dispatch,
      shiftEnd: laborForm.end,
      totalCost: laborCalc.totalDailyCost,
      loadingCost: laborCalc.loadingCost,
      repackagingCost: laborCalc.repackagingCost
    };
    onUpdateLaborSessions([newSession, ...laborSessions]);
    alert("Labor shift log committed.");
  };

  const handleProductionSubmit = () => {
    if (!prodForm.rawSkuId || !prodForm.finishedSkuId || !prodForm.rawQtyUsed || !prodForm.finishedQtyProduced) {
      alert("Please fill all mandatory production fields.");
      return;
    }
    const session = laborSessions.find(s => s.id === prodForm.laborSessionId);
    const unitLaborCost = session ? session.repackagingCost / prodForm.finishedQtyProduced : 0;
    const timestamp = new Date().toISOString();
    const newLog: ProductionLog = {
      id: `LOG-${Math.floor(Math.random() * 90000 + 10000)}`,
      timestamp,
      rawSkuId: prodForm.rawSkuId,
      rawQtyUsed: prodForm.rawQtyUsed,
      finishedSkuId: prodForm.finishedSkuId,
      finishedQtyProduced: prodForm.finishedQtyProduced,
      yieldPercent: 100, // simplified
      batchNo: prodForm.batchNo,
      operatorId: currentUser.name,
      laborSessionId: prodForm.laborSessionId,
      unitLaborCost: unitLaborCost,
      packagingConsumed: prodForm.packagingId ? [{ materialId: prodForm.packagingId, qty: prodForm.finishedQtyProduced }] : []
    };
    const updatedProducts = products.map(p => {
      if (p.id === prodForm.rawSkuId) return { ...p, stock: p.stock - prodForm.rawQtyUsed };
      if (p.id === prodForm.finishedSkuId) return { ...p, stock: p.stock + prodForm.finishedQtyProduced };
      return p;
    });
    onUpdateProductionLogs([newLog, ...productionLogs]);
    onUpdateProducts(updatedProducts);
    alert("Production committed.");
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-24">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Supply Chain Command</h2>
          <p className="text-sm text-slate-500 font-medium">Logistics, labor costing and multi-facility inventory</p>
        </div>
        <div className="flex bg-slate-200 p-1 rounded-2xl border border-slate-300 shadow-inner overflow-x-auto no-scrollbar">
           <button onClick={() => setActiveTab('Health')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeTab === 'Health' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Stock Health</button>
           <button onClick={() => setActiveTab('Warehouse')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeTab === 'Warehouse' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Facility Registry</button>
           <button onClick={() => setActiveTab('Labor')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeTab === 'Labor' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>Labor Matrix</button>
           <button onClick={() => setActiveTab('Production')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeTab === 'Production' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Repackaging</button>
           <button onClick={() => setActiveTab('Transactions')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap ${activeTab === 'Transactions' ? 'bg-white shadow-md text-emerald-600' : 'text-slate-500'}`}>Audit Ledger</button>
        </div>
      </div>

      {activeTab === 'Warehouse' && (
        <div className="space-y-8 animate-in slide-in-from-right-4">
           {/* Warehouse Selector Dashboard */}
           <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {WAREHOUSES.map(wh => (
                <button 
                  key={wh}
                  onClick={() => {setSelectedWH(wh); setExpandedSkus(new Set());}}
                  className={`p-8 rounded-[40px] border-2 transition-all flex flex-col items-center gap-4 text-center group ${selectedWH === wh ? 'bg-slate-900 border-slate-900 text-white shadow-2xl scale-[1.03]' : 'bg-white border-slate-100 text-slate-400 hover:border-emerald-200'}`}
                >
                   <div className={`w-16 h-16 rounded-3xl flex items-center justify-center transition-all ${selectedWH === wh ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-500/20' : 'bg-slate-50 text-slate-300 group-hover:bg-emerald-50 group-hover:text-emerald-500'}`}>
                      <Warehouse size={32} />
                   </div>
                   <div>
                      <h4 className="font-black uppercase tracking-widest text-xs">{wh}</h4>
                      <p className={`text-[10px] font-bold mt-1 ${selectedWH === wh ? 'text-emerald-400' : 'text-slate-400'}`}>Open Facility Ledger</p>
                   </div>
                </button>
              ))}
           </div>

           {selectedWH && whAnalytics && (
             <div className="space-y-8 animate-in zoom-in-95">
                {/* Facility KPI Matrix */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                   <div className="bg-white p-6 rounded-[32px] border border-slate-100 shadow-sm">
                      <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Total Facility Stock</p>
                      <p className="text-3xl font-black text-slate-900 tracking-tighter">{whAnalytics.totalStock.toLocaleString()} Units</p>
                   </div>
                   <div className={`p-6 rounded-[32px] border shadow-sm ${whAnalytics.nearExpiryCount > 0 ? 'bg-rose-50 border-rose-100 text-rose-700' : 'bg-white border-slate-100'}`}>
                      <p className="text-[10px] font-black uppercase tracking-widest mb-1 opacity-70">Near Expiry (90d)</p>
                      <p className="text-3xl font-black tracking-tighter">{whAnalytics.nearExpiryCount} SKUs</p>
                   </div>
                   <div className={`p-6 rounded-[32px] border shadow-sm ${whAnalytics.overageStockCount > 0 ? 'bg-indigo-50 border-indigo-100 text-indigo-700' : 'bg-white border-slate-100'}`}>
                      <p className="text-[10px] font-black uppercase tracking-widest mb-1 opacity-70">Overage Stock (90d ADS)</p>
                      <p className="text-3xl font-black tracking-tighter">{whAnalytics.overageStockCount} SKUs</p>
                   </div>
                   <div className="bg-white p-6 rounded-[32px] border border-slate-100 shadow-sm">
                      <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Slow Moving SKUs</p>
                      <p className="text-3xl font-black text-orange-600 tracking-tighter">{whAnalytics.slowMovingCount} SKUs</p>
                   </div>
                </div>

                {/* SKU Audit Table with Batch Expansion */}
                <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm overflow-hidden">
                   <div className="p-8 border-b flex items-center justify-between bg-slate-50/30">
                      <div className="flex items-center gap-4">
                         <Box className="text-emerald-500" />
                         <h4 className="text-xl font-black text-slate-900 tracking-tight">Active Inventory Ledger: {selectedWH}</h4>
                      </div>
                      <div className="relative group max-w-xs w-full">
                         <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={16} />
                         <input 
                           type="text" 
                           placeholder="Filter items..." 
                           className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-3 text-sm font-bold shadow-inner focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all"
                           value={searchTerm}
                           onChange={(e) => setSearchTerm(e.target.value)}
                         />
                      </div>
                   </div>
                   <div className="overflow-x-auto">
                      <table className="w-full text-left">
                         <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                            <tr>
                               <th className="px-8 py-6">Product / SKU Identity</th>
                               <th className="px-6 py-6 text-center">Total Stock</th>
                               <th className="px-6 py-6 text-center">Daily Vel.</th>
                               <th className="px-6 py-6 text-center">Audit Class</th>
                               <th className="px-8 py-6 text-right">Operations</th>
                            </tr>
                         </thead>
                         <tbody className="divide-y text-sm font-bold text-slate-700">
                            {whAnalytics.enrichedProducts.filter(p => p.name.toLowerCase().includes(searchTerm.toLowerCase())).map(p => (
                              <React.Fragment key={p.id}>
                                <tr className={`hover:bg-slate-50 transition-colors group ${expandedSkus.has(p.id) ? 'bg-emerald-50/30' : ''}`}>
                                  <td className="px-8 py-6">
                                     <p className="text-slate-900 font-black">{p.name}</p>
                                     <p className="text-[9px] text-slate-400 font-black uppercase mt-1">ID: {p.skuCode}</p>
                                  </td>
                                  <td className="px-6 py-6 text-center">
                                     <span className="text-xl font-black text-slate-900">{p.currentQty.toLocaleString()}</span>
                                     <span className="text-[10px] text-slate-400 ml-1 uppercase">{p.unit}</span>
                                  </td>
                                  <td className="px-6 py-6 text-center text-slate-400 font-medium">
                                     {p.avgDailySales || 0} / Day
                                  </td>
                                  <td className="px-6 py-6">
                                     <div className="flex flex-wrap justify-center gap-1.5">
                                        {p.hasExpired && <span className="px-2 py-1 bg-rose-600 text-white rounded-lg text-[8px] font-black uppercase shadow-sm">Expired</span>}
                                        {p.hasNearExpiry && <span className="px-2 py-1 bg-rose-50 text-rose-600 rounded-lg text-[8px] font-black uppercase border border-rose-100">Near Expiry (90d)</span>}
                                        {p.isOverage && <span className="px-2 py-1 bg-indigo-50 text-indigo-600 rounded-lg text-[8px] font-black uppercase border border-indigo-100">Overage (90d+)</span>}
                                        {p.isSlow && <span className="px-2 py-1 bg-orange-50 text-orange-600 rounded-lg text-[8px] font-black uppercase border border-orange-100">Slow Moving</span>}
                                        {!p.hasExpired && !p.hasNearExpiry && !p.isOverage && !p.isSlow && <span className="px-2 py-1 bg-emerald-50 text-emerald-600 rounded-lg text-[8px] font-black uppercase border border-emerald-100">Optimized</span>}
                                     </div>
                                  </td>
                                  <td className="px-8 py-6 text-right">
                                     <button 
                                       onClick={() => toggleSkuExpansion(p.id)}
                                       className={`px-4 py-2 rounded-xl text-[9px] font-black uppercase tracking-widest transition-all flex items-center gap-2 ml-auto ${expandedSkus.has(p.id) ? 'bg-slate-900 text-white shadow-xl' : 'bg-slate-100 text-slate-500 hover:bg-emerald-600 hover:text-white'}`}
                                     >
                                        <Layers size={14}/> {expandedSkus.has(p.id) ? 'Collapse Batches' : 'Audit Batches'}
                                        {expandedSkus.has(p.id) ? <ChevronUp size={14}/> : <ChevronDown size={14}/>}
                                     </button>
                                  </td>
                                </tr>
                                {expandedSkus.has(p.id) && (
                                  <tr className="bg-slate-50/50">
                                    <td colSpan={5} className="px-12 py-8 animate-in slide-in-from-top-4 duration-300">
                                       <div className="bg-white rounded-[32px] border border-slate-200 shadow-xl overflow-hidden">
                                          <div className="p-6 border-b bg-slate-50/50 flex items-center justify-between">
                                             <h5 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] flex items-center gap-2">
                                                <History size={14} className="text-indigo-600" /> Batch-Wise Stock Breakdown
                                             </h5>
                                             <span className="text-[10px] font-black text-indigo-600 bg-indigo-50 px-3 py-1 rounded-full">{p.batches.length} Batches Detected</span>
                                          </div>
                                          <div className="overflow-x-auto">
                                             <table className="w-full text-left text-xs">
                                                <thead className="bg-slate-50 text-[9px] font-black text-slate-400 uppercase border-b">
                                                   <tr>
                                                      <th className="px-6 py-4">Batch Number</th>
                                                      <th className="px-6 py-4">Mfg Date</th>
                                                      <th className="px-6 py-4">Expiry Date</th>
                                                      <th className="px-6 py-4 text-center">Batch Stock</th>
                                                      <th className="px-6 py-4 text-center">Days to Expiry</th>
                                                      <th className="px-6 py-4 text-right">Status</th>
                                                   </tr>
                                                </thead>
                                                <tbody className="divide-y font-bold text-slate-600">
                                                   {p.batches.map((batch, bi) => {
                                                     const expDate = new Date(batch.expDate);
                                                     const today = new Date();
                                                     const diffDays = Math.ceil((expDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
                                                     const isNear = diffDays > 0 && diffDays <= 90;
                                                     const isExpired = diffDays <= 0;

                                                     return (
                                                       <tr key={bi} className={`hover:bg-slate-50 transition-colors ${isExpired ? 'bg-rose-50/30' : isNear ? 'bg-amber-50/30' : ''}`}>
                                                          <td className="px-6 py-4 font-mono font-black text-slate-900">{batch.batch}</td>
                                                          <td className="px-6 py-4 text-slate-400">{batch.mfgDate}</td>
                                                          <td className={`px-6 py-4 ${isExpired ? 'text-rose-600' : isNear ? 'text-amber-600' : 'text-slate-900'}`}>{batch.expDate}</td>
                                                          <td className="px-6 py-4 text-center font-black">{batch.quantity}</td>
                                                          <td className="px-6 py-4 text-center">
                                                             <span className={`px-2 py-1 rounded text-[10px] font-black ${isExpired ? 'text-rose-600' : diffDays < 30 ? 'text-rose-500' : 'text-slate-400'}`}>
                                                                {isExpired ? 'Expired' : `${diffDays}d`}
                                                             </span>
                                                          </td>
                                                          <td className="px-6 py-4 text-right">
                                                             {isExpired ? (
                                                               <span className="text-[8px] font-black uppercase text-rose-600 flex items-center justify-end gap-1"><AlertTriangle size={10}/> Quarantined</span>
                                                             ) : isNear ? (
                                                               <span className="text-[8px] font-black uppercase text-amber-600 flex items-center justify-end gap-1"><Clock size={10}/> Liquidation Candidate</span>
                                                             ) : (
                                                               <span className="text-[8px] font-black uppercase text-emerald-600 flex items-center justify-end gap-1"><CheckCircle2 size={10}/> Standard</span>
                                                             )}
                                                          </td>
                                                       </tr>
                                                     );
                                                   })}
                                                </tbody>
                                             </table>
                                          </div>
                                       </div>
                                    </td>
                                  </tr>
                                )}
                              </React.Fragment>
                            ))}
                         </tbody>
                      </table>
                   </div>
                </div>
             </div>
           )}
           
           {!selectedWH && (
             <div className="py-32 text-center bg-white rounded-[40px] border-2 border-dashed border-slate-200">
                <div className="w-24 h-24 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6 text-slate-200">
                   <Warehouse size={48} />
                </div>
                <h3 className="text-2xl font-black text-slate-900 uppercase tracking-widest">Facility Intelligence</h3>
                <p className="text-slate-400 font-medium mt-2 max-w-sm mx-auto">Select a warehouse terminal above to visualize stock classifications and batch-wise breakdowns.</p>
             </div>
           )}
        </div>
      )}

      {activeTab === 'Health' && (
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
           <div className="lg:col-span-3">
              <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
                <div className="overflow-x-auto">
                   <table className="w-full text-left whitespace-nowrap">
                      <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                         <tr>
                            <th className="px-8 py-6">Material / Barcode</th>
                            <th className="px-6 py-6 text-center">Opening</th>
                            <th className="px-6 py-6 text-center">Current Stock</th>
                            <th className="px-6 py-6 text-center">ADS (30d)</th>
                            <th className="px-6 py-6 text-center">Days Cover</th>
                            <th className="px-8 py-6 text-right">Health Status</th>
                         </tr>
                      </thead>
                      <tbody className="divide-y text-sm font-bold text-slate-700">
                         {filteredProducts.map(p => {
                           const health = getHealthStatus(p);
                           return (
                             <tr key={p.id} className="hover:bg-slate-50/50 transition-colors group">
                                <td className="px-8 py-6 flex items-center gap-6">
                                   <div className="w-12 h-12 rounded-xl bg-slate-100 flex items-center justify-center border border-slate-200 shadow-sm">
                                      <Scan size={20} className="text-slate-400" />
                                   </div>
                                   <div>
                                      <p className="text-slate-900 font-black">{p.name}</p>
                                      <p className="text-[9px] text-slate-400 font-black uppercase mt-1">CODE: {p.skuCode} • {p.type}</p>
                                   </div>
                                </td>
                                <td className="px-6 py-6 text-center text-slate-400 font-medium italic">{p.openingStock || 0} {p.unit}</td>
                                <td className="px-6 py-6 text-center">
                                   <span className="text-lg font-black text-slate-900">{p.stock} {p.unit}</span>
                                </td>
                                <td className="px-6 py-6 text-center text-slate-500 font-medium">{p.avgDailySales || 0} / day</td>
                                <td className="px-6 py-6 text-center">
                                   <span className={`px-4 py-1.5 rounded-xl font-black text-xs ${health.color.includes('rose') ? 'bg-rose-600 text-white shadow-lg shadow-rose-200' : 'bg-slate-100 text-slate-600'}`}>
                                      {health.cover === Infinity ? 'N/A' : `${health.cover.toFixed(0)} Days`}
                                   </span>
                                </td>
                                <td className="px-8 py-6 text-right">
                                   <div className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-lg border text-[9px] font-black uppercase ${health.color}`}>
                                      {health.label}
                                   </div>
                                </td>
                             </tr>
                           );
                         })}
                      </tbody>
                   </table>
                </div>
              </div>
           </div>
           <div className="space-y-6">
              <div className="bg-slate-900 rounded-[40px] p-8 text-white shadow-2xl relative overflow-hidden border border-slate-800 group">
                 <Activity className="absolute -right-6 -bottom-6 w-32 h-32 opacity-10 group-hover:scale-110 transition-transform duration-700" />
                 <h4 className="text-xl font-black mb-6 flex items-center gap-3"><TrendingUp className="text-emerald-400" /> Supply Insight</h4>
                 <div className="space-y-6">
                    <div className="p-4 bg-white/5 rounded-2xl border border-white/5 flex justify-between items-center">
                       <span className="text-[10px] font-black uppercase text-slate-400">Critical Stockouts</span>
                       <span className="text-xl font-black text-rose-400">{products.filter(p => (p.stock / (p.avgDailySales || 1)) < 7).length}</span>
                    </div>
                    <div className="p-4 bg-white/5 rounded-2xl border border-white/5 flex justify-between items-center">
                       <span className="text-[10px] font-black uppercase text-slate-400">Repackaging Needed</span>
                       <span className="text-xl font-black text-orange-400">{products.filter(p => p.type === 'Finished' && p.stock < 100).length}</span>
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}

      {activeTab === 'Labor' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-10 animate-in slide-in-from-right-4">
           <div className="lg:col-span-2 space-y-8">
              <div className="bg-white rounded-[44px] border border-slate-200 p-10 shadow-sm space-y-10">
                 <div className="flex items-center justify-between border-b pb-8">
                    <h3 className="text-2xl font-black tracking-tight flex items-center gap-3">
                       <Users className="text-indigo-600" /> Daily Headcount & Shift Setup
                    </h3>
                    <div className="text-right">
                       <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Active Date</p>
                       <input type="date" value={laborForm.date} className="font-black text-slate-900 border-b border-indigo-200 outline-none" onChange={e => setLaborForm({...laborForm, date: e.target.value})} />
                    </div>
                 </div>

                 <div className="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-10">
                    <div className="space-y-6">
                       <h4 className="text-xs font-black uppercase tracking-widest text-slate-400">Section 1: Force Size</h4>
                       <div className="space-y-4">
                          <div className="bg-slate-50 p-6 rounded-3xl border border-slate-100 flex items-center justify-between shadow-inner">
                             <div>
                                <p className="text-[10px] font-black text-slate-400 uppercase mb-1">Total Workers</p>
                                <input type="number" className="bg-transparent text-3xl font-black outline-none w-24" value={laborForm.headcount} onChange={e => setLaborForm({...laborForm, headcount: parseInt(e.target.value) || 0})} />
                             </div>
                             <Users size={32} className="text-indigo-200" />
                          </div>
                          <div className="bg-slate-50 p-6 rounded-3xl border border-slate-100 flex items-center justify-between shadow-inner">
                             <div>
                                <p className="text-[10px] font-black text-slate-400 uppercase mb-1">Rate / Labour (₹)</p>
                                <input type="number" className="bg-transparent text-3xl font-black outline-none w-24" value={laborForm.rate} onChange={e => setLaborForm({...laborForm, rate: parseInt(e.target.value) || 0})} />
                             </div>
                             <DollarSign size={32} className="text-indigo-200" />
                          </div>
                       </div>
                    </div>

                    <div className="space-y-6">
                       <h4 className="text-xs font-black uppercase tracking-widest text-slate-400">Section 2: Shift Timeline</h4>
                       <div className="space-y-4">
                          <div className="grid grid-cols-2 gap-4">
                             <div className="space-y-2">
                                <label className="text-[9px] font-black text-slate-400 uppercase px-1">Shift Start</label>
                                <input type="time" className="w-full bg-slate-50 p-4 rounded-2xl border border-slate-100 font-black" value={laborForm.start} onChange={e => setLaborForm({...laborForm, start: e.target.value})} />
                             </div>
                             <div className="space-y-2">
                                <label className="text-[9px] font-black text-slate-400 uppercase px-1 text-emerald-600">Dispatch Time</label>
                                <input type="time" className="w-full bg-emerald-50 p-4 rounded-2xl border border-emerald-100 font-black text-emerald-700" value={laborForm.dispatch} onChange={e => setLaborForm({...laborForm, dispatch: e.target.value})} />
                             </div>
                          </div>
                          <div className="space-y-2">
                             <label className="text-[9px] font-black text-slate-400 uppercase px-1">Shift End</label>
                             <input type="time" className="w-full bg-slate-50 p-4 rounded-2xl border border-slate-100 font-black" value={laborForm.end} onChange={e => setLaborForm({...laborForm, end: e.target.value})} />
                          </div>
                       </div>
                    </div>
                 </div>

                 <div className="pt-10 border-t border-slate-100">
                    <button onClick={handleLaborSubmit} className="w-full bg-indigo-600 text-white py-6 rounded-[28px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-500 transition-all flex items-center justify-center gap-3">
                       Commit Shift Parameters <Calculator size={18} />
                    </button>
                 </div>
              </div>

              {/* Efficiency & Output Table */}
              <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
                 <h4 className="p-8 text-xs font-black text-slate-400 uppercase tracking-widest bg-slate-50/50 border-b">Operational Throughput (Active Date)</h4>
                 <div className="grid grid-cols-1 md:grid-cols-2 divide-x">
                    <div className="p-8 space-y-6">
                       <div className="flex items-center gap-3">
                          <Truck className="text-indigo-600" size={20}/>
                          <h5 className="text-sm font-black text-slate-900 uppercase">Dispatch Summary</h5>
                       </div>
                       <div className="space-y-4">
                          <div className="flex justify-between items-center bg-slate-50 p-4 rounded-2xl">
                             <span className="text-[10px] font-black text-slate-400 uppercase">Successful Missions</span>
                             <span className="text-xl font-black">{dailyEfficiency.dispatchCount} Orders</span>
                          </div>
                          <div className="flex justify-between items-center bg-slate-50 p-4 rounded-2xl">
                             <span className="text-[10px] font-black text-slate-400 uppercase">Gross Weight</span>
                             <span className="text-xl font-black text-indigo-600">{dailyEfficiency.totalDispatchedKg.toFixed(1)} KG</span>
                          </div>
                          <div className="pt-4 border-t border-slate-100 flex justify-between items-center">
                             <span className="text-[10px] font-black text-emerald-600 uppercase">Loading Cost / KG</span>
                             <span className="text-2xl font-black text-emerald-600">₹{laborCalc.costPerKg.toFixed(2)}</span>
                          </div>
                       </div>
                    </div>
                    <div className="p-8 space-y-6">
                       <div className="flex items-center gap-3">
                          <RotateCw className="text-emerald-600" size={20}/>
                          <h5 className="text-sm font-black text-slate-900 uppercase">Repackaging Output</h5>
                       </div>
                       <div className="space-y-4">
                          <div className="flex justify-between items-center bg-slate-50 p-4 rounded-2xl">
                             <span className="text-[10px] font-black text-slate-400 uppercase">Production Runs</span>
                             <span className="text-xl font-black">{dailyEfficiency.productionRunCount} Batches</span>
                          </div>
                          <div className="flex justify-between items-center bg-slate-50 p-4 rounded-2xl">
                             <span className="text-[10px] font-black text-slate-400 uppercase">Total Packets</span>
                             <span className="text-xl font-black text-emerald-600">{dailyEfficiency.totalPacketsPacked} PKTS</span>
                          </div>
                          <div className="pt-4 border-t border-slate-100 flex justify-between items-center">
                             <span className="text-[10px] font-black text-indigo-600 uppercase">Repack Cost / Packet</span>
                             <span className="text-2xl font-black text-indigo-600">₹{laborCalc.costPerPkt.toFixed(2)}</span>
                          </div>
                       </div>
                    </div>
                 </div>
              </div>

              <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
                 <h4 className="p-8 text-xs font-black text-slate-400 uppercase tracking-widest bg-slate-50/50 border-b">Recent Labor Logs</h4>
                 <div className="overflow-x-auto">
                    <table className="w-full text-left">
                       <thead className="bg-slate-50 text-[9px] font-black text-slate-400 uppercase border-b">
                          <tr>
                             <th className="px-8 py-5">Date</th>
                             <th className="px-6 py-5">Headcount</th>
                             <th className="px-6 py-5">Shift Split</th>
                             <th className="px-6 py-5 text-right">Loading Burn</th>
                             <th className="px-8 py-5 text-right">Repack Burn</th>
                          </tr>
                       </thead>
                       <tbody className="divide-y text-xs font-bold text-slate-700">
                          {laborSessions.map(s => (
                            <tr key={s.id} className="hover:bg-slate-50">
                               <td className="px-8 py-5">{s.date}</td>
                               <td className="px-6 py-5">
                                  <span className="bg-indigo-50 text-indigo-600 px-2 py-1 rounded-lg">{s.headcount} Workers</span>
                               </td>
                               <td className="px-6 py-5">
                                  <p className="text-[10px]">{s.shiftStart} → {s.dispatchTime} (Load)</p>
                                  <p className="text-[10px] text-emerald-600">{s.dispatchTime} → {s.shiftEnd} (Repack)</p>
                               </td>
                               <td className="px-6 py-5 text-right text-rose-500">₹{s.loadingCost.toFixed(0)}</td>
                               <td className="px-8 py-5 text-right text-emerald-600 font-black">₹{s.repackagingCost.toFixed(0)}</td>
                            </tr>
                          ))}
                       </tbody>
                    </table>
                 </div>
              </div>
           </div>

           <div className="space-y-6">
              <div className="bg-indigo-950 rounded-[44px] p-10 text-white shadow-2xl border border-indigo-900 sticky top-8">
                 <h4 className="text-2xl font-black mb-10 flex items-center gap-3"><Split className="text-emerald-400" /> Cost Distribution</h4>
                 <div className="space-y-10">
                    <div className="text-center bg-white/5 p-8 rounded-3xl border border-white/10 shadow-inner">
                       <p className="text-[10px] font-black text-emerald-400 uppercase tracking-widest mb-2">Total Daily Cost Pool</p>
                       <p className="text-5xl font-black">₹{laborCalc.totalDailyCost.toLocaleString()}</p>
                    </div>
                    <div className="space-y-6">
                       <div className="flex justify-between items-center group">
                          <div>
                             <p className="text-[10px] font-black text-slate-400 uppercase">Loading / Dispatch</p>
                             <p className="text-2xl font-black text-white">₹{laborCalc.loadingCost.toFixed(0)}</p>
                          </div>
                          <div className="text-right">
                             <p className="text-[10px] font-black text-slate-500 uppercase">Efficiency</p>
                             <p className="text-lg font-black text-rose-400">₹{laborCalc.costPerKg.toFixed(2)} / KG</p>
                          </div>
                       </div>
                       <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden">
                          <div className="h-full bg-rose-500" style={{ width: `${(laborCalc.loadingCost / laborCalc.totalDailyCost) * 100}%` }} />
                       </div>
                       <div className="flex justify-between items-center pt-4">
                          <div>
                             <p className="text-[10px] font-black text-slate-400 uppercase">Repackaging Pool</p>
                             <p className="text-2xl font-black text-white">₹{laborCalc.repackagingCost.toFixed(0)}</p>
                          </div>
                          <div className="text-right">
                             <p className="text-[10px] font-black text-slate-500 uppercase">Efficiency</p>
                             <p className="text-lg font-black text-emerald-400">₹{laborCalc.costPerPkt.toFixed(2)} / PKT</p>
                          </div>
                       </div>
                       <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden">
                          <div className="h-full bg-emerald-500" style={{ width: `${(laborCalc.repackagingCost / laborCalc.totalDailyCost) * 100}%` }} />
                       </div>
                    </div>
                    <div className="p-6 bg-white/5 rounded-2xl border border-white/5 flex items-center gap-4">
                       <Timer size={24} className="text-indigo-400" />
                       <p className="text-[11px] text-slate-400 leading-relaxed italic">The Repackaging Pool is dynamically divided by total finished units produced today.</p>
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}

      {activeTab === 'Production' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-10 animate-in slide-in-from-bottom-6">
           <div className="lg:col-span-2 space-y-8">
              <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm p-10 space-y-10">
                 <div className="flex items-center justify-between border-b pb-8">
                    <h3 className="text-2xl font-black tracking-tight flex items-center gap-3">
                       <RefreshCcw className="text-indigo-600" /> Repackaging Terminal
                    </h3>
                    <div className="bg-indigo-50 border border-indigo-100 px-6 py-3 rounded-2xl">
                       <p className="text-[10px] font-black text-indigo-600 uppercase tracking-widest">Active Batch: {prodForm.batchNo}</p>
                    </div>
                 </div>
                 <div className="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-10">
                    <div className="space-y-6">
                       <h4 className="text-xs font-black uppercase tracking-widest text-slate-400">Step 1: Input & Labor Link</h4>
                       <div className="space-y-4">
                          <div className="space-y-2">
                             <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Source Bulk SKU</label>
                             <select className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-indigo-600 transition-all outline-none appearance-none" value={prodForm.rawSkuId} onChange={e => setProdForm({...prodForm, rawSkuId: e.target.value})}>
                                <option value="">Select Raw Item...</option>
                                {products.filter(p => p.type === 'Raw').map(p => <option key={p.id} value={p.id}>{p.name} (In Stock: {p.stock} KG)</option>)}
                             </select>
                          </div>
                          <div className="space-y-2">
                             <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Link to Labor Shift</label>
                             <select className="w-full bg-indigo-50 border-2 border-indigo-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-indigo-600 transition-all outline-none appearance-none" value={prodForm.laborSessionId} onChange={e => setProdForm({...prodForm, laborSessionId: e.target.value})}>
                                <option value="">Select Today's Labor Shift...</option>
                                {laborSessions.map(ls => <option key={ls.id} value={ls.id}>{ls.date} (Pool: ₹{ls.repackagingCost.toFixed(0)})</option>)}
                             </select>
                          </div>
                          <div className="space-y-2">
                             <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Raw Qty Used (KG)</label>
                             <div className="flex items-center gap-4 bg-slate-50 border-2 border-slate-100 rounded-2xl p-4 shadow-inner">
                                <Scale size={18} className="text-slate-400" />
                                <input type="number" className="bg-transparent text-xl font-black outline-none w-full" placeholder="0.00" value={prodForm.rawQtyUsed || ''} onChange={e => setProdForm({...prodForm, rawQtyUsed: parseFloat(e.target.value) || 0})} />
                             </div>
                          </div>
                       </div>
                    </div>
                    <div className="space-y-6">
                       <h4 className="text-xs font-black uppercase tracking-widest text-slate-400">Step 2: Output</h4>
                       <div className="space-y-4">
                          <div className="space-y-2">
                             <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Target Finished SKU</label>
                             <select className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-sm font-bold focus:border-indigo-600 transition-all outline-none appearance-none" value={prodForm.finishedSkuId} onChange={e => setProdForm({...prodForm, finishedSkuId: e.target.value})}>
                                <option value="">Select Finished SKU...</option>
                                {products.filter(p => p.type === 'Finished').map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
                             </select>
                          </div>
                          <div className="space-y-2">
                             <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Finished Qty (PCS)</label>
                             <div className="flex items-center gap-4 bg-slate-50 border-2 border-slate-100 rounded-2xl p-4 shadow-inner">
                                <Box size={18} className="text-slate-400" />
                                <input type="number" className="bg-transparent text-xl font-black outline-none w-full" placeholder="0" value={prodForm.finishedQtyProduced || ''} onChange={e => setProdForm({...prodForm, finishedQtyProduced: parseInt(e.target.value) || 0})} />
                             </div>
                          </div>
                       </div>
                    </div>
                 </div>
                 <div className="pt-10 border-t border-slate-100">
                    <button onClick={handleProductionSubmit} className="w-full bg-indigo-500 text-white py-6 rounded-[28px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-400 active:scale-95 transition-all flex items-center justify-center gap-3">
                       Execute Batch Repack <RotateCw size={18} />
                    </button>
                 </div>
              </div>
           </div>
           <div className="space-y-6">
              <div className="bg-indigo-950 rounded-[44px] p-10 text-white shadow-2xl sticky top-8 border border-indigo-900 flex flex-col justify-between min-h-[500px]">
                 <div className="space-y-12">
                    <div className="flex items-center gap-4">
                       <div className="w-12 h-12 bg-white/10 rounded-2xl flex items-center justify-center border border-white/10">
                          <Scale size={24} className="text-indigo-400" />
                       </div>
                       <h4 className="text-2xl font-black tracking-tight">Yield Matrix</h4>
                    </div>
                    <div className="space-y-2 text-center py-10 bg-white/5 rounded-[32px] border border-white/5">
                       <p className="text-[10px] font-black text-indigo-400 uppercase tracking-[0.2em]">Efficiency Score</p>
                       <h5 className="text-6xl font-black tracking-tighter">100.0<span className="text-xl text-indigo-400">%</span></h5>
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}

      {activeTab === 'Transactions' && (
        <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden animate-in fade-in zoom-in-95">
           <div className="p-10 border-b bg-slate-50/50 flex items-center justify-between">
              <h3 className="text-xl font-black text-slate-900 uppercase tracking-tight flex items-center gap-3"><History className="text-indigo-600" /> Audit Ledger</h3>
           </div>
           <div className="overflow-x-auto">
              <table className="w-full text-left">
                 <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase border-b">
                    <tr>
                       <th className="px-8 py-5">Date / Time</th>
                       <th className="px-6 py-5">Product Identity</th>
                       <th className="px-6 py-5">Event Type</th>
                       <th className="px-6 py-5 text-center">Qty</th>
                       <th className="px-8 py-5 text-right">Reference</th>
                    </tr>
                 </thead>
                 <tbody className="divide-y text-xs font-bold text-slate-700">
                    {transactions.map(tx => {
                      const p = products.find(prod => prod.id === tx.productId);
                      return (
                        <tr key={tx.id} className="hover:bg-slate-50/50 transition-colors">
                           <td className="px-8 py-5 text-slate-400">{new Date(tx.timestamp).toLocaleString()}</td>
                           <td className="px-6 py-5">
                              <p className="text-slate-900 font-black">{p?.name}</p>
                              <p className="text-[9px] text-slate-400 font-black">{p?.skuCode}</p>
                           </td>
                           <td className="px-6 py-5">
                              <span className={`px-2 py-0.5 rounded text-[9px] uppercase border ${tx.type.includes('IN') ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 'bg-rose-50 text-rose-600 border-rose-100'}`}>{tx.type}</span>
                           </td>
                           <td className={`px-6 py-5 text-center font-black ${tx.type.includes('IN') ? 'text-emerald-600' : 'text-rose-600'}`}>
                              {tx.type.includes('IN') ? '+' : '-'}{tx.qty}
                           </td>
                           <td className="px-8 py-5 text-right text-slate-400 font-mono">{tx.referenceId}</td>
                        </tr>
                      );
                    })}
                 </tbody>
              </table>
           </div>
        </div>
      )}
    </div>
  );
};

const SummaryBox = ({ label, value, icon, color }: { label: string, value: number, icon: React.ReactNode, color: string }) => {
  const colors: Record<string, string> = {
    emerald: 'bg-emerald-50 text-emerald-600 border-emerald-100',
    indigo: 'bg-indigo-50 text-indigo-600 border-indigo-100',
    amber: 'bg-amber-50 text-amber-600 border-amber-100',
    rose: 'bg-rose-50 text-rose-600 border-rose-100',
    slate: 'bg-slate-50 text-slate-600 border-slate-200',
    orange: 'bg-orange-50 text-orange-600 border-orange-100'
  };

  return (
    <div className={`p-6 rounded-[32px] border shadow-sm transition-all hover:scale-105 ${colors[color] || colors.slate}`}>
       <div className="flex items-center gap-3 mb-4 opacity-70">
          {icon}
          <p className="text-[9px] font-black uppercase tracking-widest">{label}</p>
       </div>
       <p className="text-2xl font-black tracking-tighter">{value.toLocaleString()}</p>
    </div>
  );
};

const getHealthStatus = (p: Product) => {
  if (!p.avgDailySales || p.avgDailySales === 0) return { label: 'STAGNANT', color: 'bg-slate-50 text-slate-400', cover: Infinity };
  const cover = p.stock / p.avgDailySales;
  if (cover < 7) return { label: 'CRITICAL', color: 'bg-rose-50 text-rose-600 border-rose-100 animate-pulse', cover };
  if (cover < 14) return { label: 'WARNING', color: 'bg-orange-50 text-orange-600 border-orange-100', cover };
  return { label: 'OPTIMAL', color: 'bg-emerald-50 text-emerald-600 border-emerald-100', cover };
};

export default InventoryHubView;
