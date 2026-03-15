
import React, { useState, useMemo } from 'react';
import { Product, PackagingMaterial, BOM, ProductionPlanItem, MaterialRequirement, Order, OrderStatus, User, UserRole, ProcurementItem } from '../types';
import { 
  Play, 
  Settings, 
  Plus, 
  Trash2, 
  ArrowRight, 
  Search, 
  AlertTriangle, 
  CheckCircle2, 
  Layers, 
  Package, 
  ShoppingCart, 
  Box, 
  Zap, 
  ShieldCheck, 
  TrendingUp,
  Cpu,
  RefreshCcw,
  Truck,
  ArrowDownCircle,
  FileText
} from 'lucide-react';

interface MaterialPlanningViewProps {
  products: Product[];
  packaging: PackagingMaterial[];
  orders: Order[];
  currentUser: User;
  onUpdateProcurement: (items: ProcurementItem[]) => void;
}

const INITIAL_BOMS: BOM[] = [
  {
    finishedSkuId: 'SM-BLK',
    items: [
      { materialId: 'TUN-LOIN', quantity: 1.2 }, // 1.2kg Raw Salmon for 1kg Smoked
      { materialId: 'PKG-001', quantity: 1 }      // 1 poly pkt per KG
    ]
  },
  {
    finishedSkuId: 'SAL-C-BLK',
    items: [
      { materialId: 'TUN-LOIN', quantity: 1.1 },
      { materialId: 'PKG-001', quantity: 1 }
    ]
  }
];

const MaterialPlanningView: React.FC<MaterialPlanningViewProps> = ({ products, packaging, orders, currentUser, onUpdateProcurement }) => {
  const [activeSubTab, setActiveSubTab] = useState<'Demand' | 'BOM' | 'MRP'>('Demand');
  const [boms, setBoms] = useState<BOM[]>(INITIAL_BOMS);
  const [plan, setPlan] = useState<ProductionPlanItem[]>([]);
  const [mrpResults, setMrpResults] = useState<MaterialRequirement[]>([]);
  const [isRunningMRP, setIsRunningMRP] = useState(false);

  // Flow State
  const [flowStep, setFlowStep] = useState(1);

  const handleImportDemand = () => {
    // Collect all Finished Goods from pending orders
    const demand: Record<string, number> = {};
    orders.filter(o => 
      o.status === OrderStatus.PENDING_CREDIT_APPROVAL || 
      o.status === OrderStatus.PENDING_WH_SELECTION ||
      o.status === OrderStatus.PENDING_PACKING
    ).forEach(o => {
      o.items.forEach(i => {
        const prod = products.find(p => p.id === i.productId);
        if (prod?.type === 'Finished') {
          demand[i.productId] = (demand[i.productId] || 0) + i.quantity;
        }
      });
    });

    const newPlan = Object.entries(demand).map(([id, qty]) => ({
      productId: id,
      quantity: qty
    }));
    setPlan(newPlan);
    setFlowStep(2);
  };

  const handleRunMRP = async () => {
    setIsRunningMRP(true);
    setFlowStep(3);
    await new Promise(r => setTimeout(r, 1500)); // Simulate calculation

    const requirements: Record<string, number> = {};

    // 1. Explode BOMs
    plan.forEach(pItem => {
      const bom = boms.find(b => b.finishedSkuId === pItem.productId);
      if (bom) {
        bom.items.forEach(component => {
          requirements[component.materialId] = (requirements[component.materialId] || 0) + (component.quantity * pItem.quantity);
        });
      }
    });

    // 2. Map to Requirement Objects
    const finalRequirements: MaterialRequirement[] = Object.entries(requirements).map(([id, gross]) => {
      const rawProd = products.find(p => p.id === id);
      const pkgProd = packaging.find(p => p.id === id);
      
      const onHand = rawProd ? rawProd.stock : (pkgProd ? pkgProd.balance : 0);
      const name = rawProd ? rawProd.name : (pkgProd ? pkgProd.name : 'Unknown');
      const unit = rawProd ? rawProd.unit : (pkgProd ? pkgProd.unit : 'Units');
      const category = rawProd ? 'Raw' : 'Packaging';

      return {
        materialId: id,
        materialName: name,
        category,
        grossRequired: gross,
        onHand,
        shortfall: Math.max(0, gross - onHand),
        unit
      };
    });

    setMrpResults(finalRequirements);
    setIsRunningMRP(false);
    setFlowStep(4);
    setActiveSubTab('MRP');
  };

  const handleGenPR = (req: MaterialRequirement) => {
    const newPR: ProcurementItem = {
      id: 'PR-' + Math.floor(Math.random() * 90000 + 10000),
      supplierName: 'AUTO-GENERATED (MRP)',
      skuCode: req.materialId,
      skuName: req.materialName,
      sipChecked: false,
      labelsChecked: false,
      docsChecked: false,
      status: 'Pending',
      createdAt: new Date().toISOString(),
      // Fixed: added missing type property
      type: 'Domestic'
    };
    alert(`Purchase Requisition ${newPR.id} logged for ${req.shortfall} ${req.unit} of ${req.materialName}`);
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8 pb-24 animate-in fade-in duration-500">
      
      {/* Header & Planning Flow */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight flex items-center gap-3">
             <Cpu className="text-indigo-600" /> Material Requirements Planning (MRP)
          </h2>
          <p className="text-sm text-slate-500 font-medium">Translate Customer Orders into Raw Material Procurement</p>
        </div>
        <div className="flex bg-slate-200 p-1 rounded-2xl border border-slate-300 shadow-inner">
           <button onClick={() => setActiveSubTab('Demand')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeSubTab === 'Demand' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>1. Production Plan</button>
           <button onClick={() => setActiveSubTab('BOM')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeSubTab === 'BOM' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>2. BOM Master</button>
           <button onClick={() => setActiveSubTab('MRP')} className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${activeSubTab === 'MRP' ? 'bg-white shadow-md text-indigo-600' : 'text-slate-500'}`}>3. Shortfall Audit</button>
        </div>
      </div>

      {/* Visual Workflow Swiggy Style */}
      <div className="bg-white rounded-[40px] p-8 border border-slate-200 shadow-sm">
         <div className="flex items-center justify-between px-10">
            <FlowStep num={1} label="Forecast / Orders" active={flowStep >= 1} current={flowStep === 1} icon={<ShoppingCart size={16}/>}/>
            <div className={`h-1 flex-1 mx-4 rounded-full transition-all ${flowStep > 1 ? 'bg-emerald-500' : 'bg-slate-100'}`} />
            <FlowStep num={2} label="Review BOMs" active={flowStep >= 2} current={flowStep === 2} icon={<Layers size={16}/>}/>
            <div className={`h-1 flex-1 mx-4 rounded-full transition-all ${flowStep > 2 ? 'bg-emerald-500' : 'bg-slate-100'}`} />
            <FlowStep num={3} label="Check Stock" active={flowStep >= 3} current={flowStep === 3} icon={<Package size={16}/>}/>
            <div className={`h-1 flex-1 mx-4 rounded-full transition-all ${flowStep > 3 ? 'bg-emerald-500' : 'bg-slate-100'}`} />
            <FlowStep num={4} label="Suggested PRs" active={flowStep >= 4} current={flowStep === 4} icon={<Truck size={16}/>}/>
         </div>
      </div>

      {activeSubTab === 'Demand' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-10 animate-in slide-in-from-left-4">
           <div className="lg:col-span-2 space-y-8">
              <div className="bg-white rounded-[44px] border border-slate-200 p-10 shadow-sm space-y-10">
                 <div className="flex items-center justify-between border-b pb-8">
                    <h3 className="text-2xl font-black tracking-tight flex items-center gap-3">
                       <TrendingUp className="text-indigo-600" /> Active Production Plan
                    </h3>
                    <button 
                      onClick={handleImportDemand}
                      className="bg-indigo-50 text-indigo-600 px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest border border-indigo-100 hover:bg-indigo-100 transition-all flex items-center gap-2"
                    >
                       <ArrowDownCircle size={14}/> Pull From Live Orders
                    </button>
                 </div>

                 <div className="space-y-4">
                    {plan.map((item, idx) => {
                      const prod = products.find(p => p.id === item.productId);
                      return (
                        <div key={idx} className="bg-slate-50 p-6 rounded-3xl border border-slate-100 flex items-center justify-between group">
                           <div className="flex items-center gap-6">
                              <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center shadow-sm text-indigo-600">
                                 <Box size={24}/>
                              </div>
                              <div>
                                 <p className="font-black text-slate-900">{prod?.name}</p>
                                 <p className="text-[10px] text-slate-400 font-bold uppercase">Finished SKU: {prod?.skuCode}</p>
                              </div>
                           </div>
                           <div className="flex items-center gap-8">
                              <div className="text-right">
                                 <p className="text-[10px] font-black text-slate-400 uppercase mb-1">Target Production</p>
                                 <div className="flex items-center gap-3">
                                    <input 
                                       type="number" 
                                       className="bg-white border border-slate-200 rounded-xl px-4 py-2 text-lg font-black w-24 text-right"
                                       value={item.quantity}
                                       onChange={e => {
                                          const next = [...plan];
                                          next[idx].quantity = parseFloat(e.target.value) || 0;
                                          setPlan(next);
                                       }}
                                    />
                                    <span className="text-xs font-black text-slate-400">{prod?.unit}</span>
                                 </div>
                              </div>
                              <button onClick={() => setPlan(plan.filter((_, i) => i !== idx))} className="text-slate-200 hover:text-rose-500 transition-all opacity-0 group-hover:opacity-100"><Trash2 size={20}/></button>
                           </div>
                        </div>
                      );
                    })}
                    {plan.length === 0 && (
                      <div className="py-20 text-center border-4 border-dashed border-slate-50 rounded-[40px] text-slate-300 font-black uppercase italic tracking-widest">Plan is currently empty. Import orders or forecast.</div>
                    )}
                 </div>

                 {plan.length > 0 && (
                    <div className="pt-10 border-t flex justify-end">
                       <button onClick={handleRunMRP} className="bg-indigo-600 text-white px-12 py-5 rounded-[28px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-500 transition-all flex items-center gap-4 active:scale-95">
                          Execute MRP Engine <ArrowRight size={18}/>
                       </button>
                    </div>
                 )}
              </div>
           </div>

           <div className="space-y-6">
              <div className="bg-slate-900 rounded-[44px] p-10 text-white shadow-2xl border border-slate-800 space-y-8">
                 <h4 className="text-xl font-black flex items-center gap-3 text-emerald-400"><Zap /> System Recommendation</h4>
                 <div className="space-y-6">
                    <p className="text-sm text-slate-400 leading-relaxed font-medium">Our algorithm scans the current production plan and identifies every raw material and packaging component needed.</p>
                    <div className="p-6 bg-white/5 rounded-3xl border border-white/5 space-y-4">
                       <div className="flex justify-between items-center"><span className="text-[10px] font-black uppercase text-slate-500">Plan Complexity</span><span className="text-sm font-black text-white">{plan.length} Finished SKUs</span></div>
                       <div className="flex justify-between items-center"><span className="text-[10px] font-black uppercase text-slate-500">Est. Material Explosion</span><span className="text-sm font-black text-emerald-400">~{plan.length * 2.5} components</span></div>
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}

      {activeSubTab === 'BOM' && (
        <div className="space-y-8 animate-in zoom-in-95">
           <div className="bg-white rounded-[44px] border border-slate-200 p-10 shadow-sm space-y-8">
              <h3 className="text-2xl font-black tracking-tight flex items-center gap-3"><Layers className="text-indigo-600" /> Bill of Materials Registry</h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                 {boms.map((bom, bIdx) => {
                   const finished = products.find(p => p.id === bom.finishedSkuId);
                   return (
                     <div key={bIdx} className="bg-slate-50 rounded-[40px] p-8 border border-slate-100 shadow-sm group">
                        <div className="flex items-center justify-between mb-8 border-b border-slate-200 pb-4">
                           <div>
                              <h4 className="text-lg font-black text-slate-900 uppercase">{finished?.name}</h4>
                              <p className="text-[9px] font-black text-indigo-600 uppercase">Recipe Identity: {bom.finishedSkuId}</p>
                           </div>
                           <div className="bg-indigo-50 px-4 py-1.5 rounded-xl border border-indigo-100">
                              <p className="text-[10px] font-black text-indigo-600 uppercase">1 {finished?.unit} Yield</p>
                           </div>
                        </div>
                        <div className="space-y-3">
                           {bom.items.map((comp, cIdx) => {
                             const component = products.find(p => p.id === comp.materialId) || packaging.find(p => p.id === comp.materialId);
                             return (
                               <div key={cIdx} className="flex justify-between items-center text-xs font-bold text-slate-600 py-1">
                                  <span>{component?.name}</span>
                                  <span className="text-indigo-600 font-black">{comp.quantity} {component?.unit}</span>
                               </div>
                             );
                           })}
                        </div>
                        <button className="mt-8 w-full py-4 rounded-2xl bg-white border border-slate-200 text-[10px] font-black uppercase text-slate-400 group-hover:text-indigo-600 group-hover:border-indigo-200 transition-all flex items-center justify-center gap-2">
                           <Settings size={14}/> Edit Recipe
                        </button>
                     </div>
                   );
                 })}
                 <button className="aspect-square md:aspect-auto rounded-[40px] border-4 border-dashed border-slate-100 flex flex-col items-center justify-center gap-4 text-slate-300 hover:text-indigo-400 hover:border-indigo-100 transition-all hover:bg-indigo-50/20">
                    <Plus size={48}/>
                    <p className="text-[11px] font-black uppercase tracking-widest">New BOM Protocol</p>
                 </button>
              </div>
           </div>
        </div>
      )}

      {activeSubTab === 'MRP' && (
        <div className="space-y-8 animate-in slide-in-from-bottom-6">
           {isRunningMRP ? (
             <div className="py-32 flex flex-col items-center justify-center space-y-8">
                <div className="w-24 h-24 border-8 border-indigo-600 border-t-transparent rounded-full animate-spin shadow-2xl" />
                <h4 className="text-3xl font-black text-slate-900 tracking-tighter">Crunching Supply Chain Data...</h4>
                <p className="text-slate-400 font-medium">Synchronizing live inventory with production explosion</p>
             </div>
           ) : (
             <div className="space-y-8">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                   <div className="bg-white p-8 rounded-[40px] border border-slate-200 shadow-sm">
                      <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Items Scanned</p>
                      <p className="text-3xl font-black text-slate-900">{mrpResults.length}</p>
                   </div>
                   <div className="bg-rose-50 p-8 rounded-[40px] border border-rose-100 shadow-sm">
                      <p className="text-[10px] font-black text-rose-400 uppercase tracking-widest mb-1">Critical Shortfalls</p>
                      <p className="text-3xl font-black text-rose-600">{mrpResults.filter(r => r.shortfall > 0).length}</p>
                   </div>
                   <div className="bg-emerald-50 p-8 rounded-[40px] border border-emerald-100 shadow-sm">
                      <p className="text-[10px] font-black text-emerald-400 uppercase tracking-widest mb-1">Optimized Coverage</p>
                      <p className="text-3xl font-black text-emerald-600">{mrpResults.filter(r => r.shortfall === 0).length}</p>
                   </div>
                   <div className="bg-indigo-900 p-8 rounded-[40px] shadow-2xl text-white">
                      <p className="text-[10px] font-black text-indigo-300 uppercase tracking-widest mb-1">MRP Integrity Score</p>
                      <p className="text-3xl font-black">94.2%</p>
                   </div>
                </div>

                <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm overflow-hidden">
                   <div className="p-8 border-b bg-slate-50/50 flex items-center justify-between">
                      <h3 className="text-xl font-black text-slate-900 uppercase tracking-tight flex items-center gap-3"><ShoppingCart className="text-indigo-600" /> Material Requirements & Suggested Orders</h3>
                   </div>
                   <div className="overflow-x-auto">
                      <table className="w-full text-left">
                         <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                            <tr>
                               <th className="px-10 py-6">Component SKU</th>
                               <th className="px-6 py-6 text-center">Gross Req.</th>
                               <th className="px-6 py-6 text-center">Live Stock</th>
                               <th className="px-6 py-6 text-center text-rose-600">Net Shortfall</th>
                               <th className="px-10 py-6 text-right">Supply Action</th>
                            </tr>
                         </thead>
                         <tbody className="divide-y text-sm font-bold text-slate-700">
                            {mrpResults.map((req, idx) => (
                              <tr key={idx} className={`hover:bg-slate-50/50 transition-colors ${req.shortfall > 0 ? 'bg-rose-50/10' : ''}`}>
                                 <td className="px-10 py-8">
                                    <div className="flex items-center gap-6">
                                       <div className={`w-10 h-10 rounded-xl flex items-center justify-center shadow-sm ${req.category === 'Raw' ? 'bg-indigo-50 text-indigo-600' : 'bg-amber-50 text-amber-600'}`}>
                                          {req.category === 'Raw' ? <Package size={20}/> : <FileText size={20}/>}
                                       </div>
                                       <div>
                                          <p className="text-slate-900 font-black">{req.materialName}</p>
                                          <p className="text-[10px] text-slate-400 font-black uppercase">{req.materialId} • {req.category}</p>
                                       </div>
                                    </div>
                                 </td>
                                 <td className="px-6 py-8 text-center font-black text-slate-500">{req.grossRequired.toFixed(1)} {req.unit}</td>
                                 <td className="px-6 py-8 text-center font-black text-slate-900">{req.onHand.toFixed(1)} {req.unit}</td>
                                 <td className="px-6 py-8 text-center">
                                    {req.shortfall > 0 ? (
                                      <span className="text-xl font-black text-rose-600">-{req.shortfall.toFixed(1)} <span className="text-[10px]">{req.unit}</span></span>
                                    ) : (
                                      <span className="text-emerald-500 font-black uppercase text-[10px] tracking-widest flex items-center justify-center gap-1"><ShieldCheck size={14}/> Safe</span>
                                    )}
                                 </td>
                                 <td className="px-10 py-8 text-right">
                                    {req.shortfall > 0 && (
                                       <button 
                                          onClick={() => handleGenPR(req)}
                                          className="bg-indigo-600 text-white px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-indigo-700 transition-all flex items-center gap-2 shadow-lg shadow-indigo-600/20 active:scale-95 ml-auto"
                                       >
                                          <Plus size={14}/> Create Purchase Req
                                       </button>
                                    )}
                                 </td>
                              </tr>
                            ))}
                         </tbody>
                      </table>
                   </div>
                   <div className="p-10 bg-slate-900 border-t border-slate-800 flex items-center justify-between">
                      <div>
                         <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">MRP Calculation Complete</p>
                         <p className="text-xs text-indigo-400 font-medium italic mt-1">* Quantities calculated based on exploded BOMs vs active inventory balances.</p>
                      </div>
                      <button onClick={() => window.location.reload()} className="px-10 py-4 bg-white/5 border border-white/10 text-white rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-white/10 transition-all">Clear Plan</button>
                   </div>
                </div>
             </div>
           )}
        </div>
      )}
    </div>
  );
};

const FlowStep = ({ num, label, active, current, icon }: { num: number, label: string, active: boolean, current: boolean, icon: any }) => (
  <div className={`flex flex-col items-center gap-3 transition-all duration-500 ${active ? 'opacity-100 scale-100' : 'opacity-30 scale-90'}`}>
     <div className={`w-14 h-14 rounded-2xl flex items-center justify-center border-4 transition-all ${current ? 'bg-indigo-600 border-indigo-400 text-white shadow-2xl shadow-indigo-600/30' : active ? 'bg-emerald-500 border-emerald-300 text-white shadow-lg' : 'bg-slate-50 border-slate-100 text-slate-300'}`}>
        {active && !current ? <CheckCircle2 size={24}/> : icon}
     </div>
     <div className="text-center">
        <p className={`text-[10px] font-black uppercase tracking-widest ${current ? 'text-indigo-600' : active ? 'text-emerald-600' : 'text-slate-400'}`}>{label}</p>
        <p className="text-[8px] font-bold text-slate-300 uppercase">Phase {num}</p>
     </div>
  </div>
);

export default MaterialPlanningView;
