
import React, { useState, useMemo } from 'react';
import { Product, Customer, User, Order, OrderStatus, OrderItem, BatchInfo } from '../types';
import { 
  AlertTriangle, 
  Search, 
  ShoppingBag, 
  Calendar, 
  TrendingDown, 
  UserCheck, 
  ArrowRight, 
  CheckCircle2,
  Box,
  Tag,
  ShieldAlert,
  Clock
} from 'lucide-react';

interface SelectionState {
  productId: string;
  skuCode: string;
  productName: string;
  batchNo: string;
  expDate: string;
  stockQty: number;
  orderQty: number;
  proposedRate: number;
  unit: 'PCS' | 'KG' | 'PKT';
  weight: string;
}

// Added missing NearExpiryViewProps interface to fix "Cannot find name 'NearExpiryViewProps'" error
interface NearExpiryViewProps {
  products: Product[];
  customers: Customer[];
  currentUser: User;
  onSubmitOrder: (order: Order) => void;
}

const NearExpiryView: React.FC<NearExpiryViewProps> = ({ products, customers, currentUser, onSubmitOrder }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCustomerId, setSelectedCustomerId] = useState('');
  const [orderSelections, setOrderSelections] = useState<Record<string, SelectionState>>({});

  // Identify expiring batches from all products
  const expiringStock = useMemo(() => {
    const list: SelectionState[] = [];
    const today = new Date();
    const ninetyDaysFromNow = new Date();
    ninetyDaysFromNow.setDate(today.getDate() + 90);

    products.forEach(p => {
      (p.availableBatches || []).forEach(b => {
        const exp = new Date(b.expDate);
        if (exp <= ninetyDaysFromNow) {
          list.push({
            productId: p.id,
            skuCode: p.skuCode,
            productName: p.name,
            batchNo: b.batch,
            expDate: b.expDate,
            stockQty: b.quantity,
            orderQty: 0,
            proposedRate: p.baseRate,
            unit: p.unit,
            weight: p.productWeight || '0.00'
          });
        }
      });
    });

    return list.filter(item => 
      item.productName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.skuCode.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.batchNo.toLowerCase().includes(searchTerm.toLowerCase())
    ).sort((a, b) => new Date(a.expDate).getTime() - new Date(b.expDate).getTime());
  }, [products, searchTerm]);

  // Added explicit types to state setter and cast the current state access to avoid 'unknown' type errors.
  const updateSelection = (id: string, field: keyof SelectionState, value: any) => {
    const item = expiringStock.find(s => `${s.productId}-${s.batchNo}` === id);
    if (!item) return;

    setOrderSelections((prev: Record<string, SelectionState>) => {
      const current = prev[id] || { ...item, orderQty: 0, proposedRate: item.proposedRate };
      const updated = { ...current, [field]: value };
      
      // If qty and rates are reset to 0/default, we could remove it, but keeping for UI consistency
      return { ...prev, [id]: updated };
    });
  };

  // Fixed 'Property orderQty does not exist on type unknown' error by casting Object.values to SelectionState[].
  const selectedItems = useMemo(() => 
    (Object.values(orderSelections) as SelectionState[]).filter(s => s.orderQty > 0), 
  [orderSelections]);

  const totalOrderValue = useMemo(() => 
    selectedItems.reduce((sum, item) => sum + (item.orderQty * item.proposedRate), 0),
  [selectedItems]);

  const handleSubmit = () => {
    if (!selectedCustomerId) {
      alert("Please select a target Customer for this clearance order.");
      return;
    }
    if (selectedItems.length === 0) {
      alert("Please specify quantities for at least one SKU.");
      return;
    }

    const customer = customers.find(c => c.id === selectedCustomerId);
    const timestamp = new Date().toISOString();

    const newOrder: Order = {
      id: 'CLR-' + Math.floor(Math.random() * 90000 + 10000),
      customerId: selectedCustomerId,
      customerName: customer?.name || 'Unknown',
      status: OrderStatus.PENDING_CREDIT_APPROVAL,
      statusHistory: [{ status: OrderStatus.PENDING_CREDIT_APPROVAL, timestamp }],
      createdAt: timestamp,
      salespersonId: currentUser.id,
      generalRemarks: 'CLEARANCE ORDER - NEAR EXPIRY STOCK',
      items: selectedItems.map(s => ({
        productId: s.productId,
        productName: s.productName,
        skuCode: s.skuCode,
        quantity: s.orderQty,
        unit: s.unit,
        price: s.proposedRate,
        baseRate: products.find(p => p.id === s.productId)?.baseRate || s.proposedRate,
        remarks: `Clearance: Batch ${s.batchNo} (Exp: ${s.expDate})`,
        batch: s.batchNo,
        expDate: s.expDate
      }))
    };

    onSubmitOrder(newOrder);
    setOrderSelections({});
    setSelectedCustomerId('');
    alert("Clearance mission initialized. Moved to Credit Control.");
  };

  const getExpiryStatus = (dateStr: string) => {
    const days = Math.ceil((new Date(dateStr).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24));
    if (days < 30) return { label: `${days} Days`, color: 'bg-rose-100 text-rose-700 border-rose-200 animate-pulse' };
    if (days < 60) return { label: `${days} Days`, color: 'bg-amber-100 text-amber-700 border-amber-200' };
    return { label: `${days} Days`, color: 'bg-emerald-100 text-emerald-700 border-emerald-200' };
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-24">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Clearance Terminal</h2>
          <p className="text-sm text-slate-500 font-medium">Liquidate near-expiry inventory with custom proposed rates</p>
        </div>
        <div className="bg-rose-50 border border-rose-100 px-6 py-3 rounded-2xl flex items-center gap-3">
           <AlertTriangle className="text-rose-500" size={20} />
           <span className="text-[10px] font-black text-rose-700 uppercase tracking-widest">{expiringStock.length} Batches Requiring Action</span>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div className="lg:col-span-3 space-y-6">
           <div className="relative group max-w-md">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-rose-500 transition-colors" size={18} />
              <input 
                type="text" 
                placeholder="Filter by SKU or Batch..." 
                className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-rose-500/10 outline-none transition-all"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
           </div>

           <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
              <div className="overflow-x-auto">
                 <table className="w-full text-left">
                    <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                       <tr>
                          <th className="px-8 py-6">SKU / Batch Detail</th>
                          <th className="px-6 py-6 text-center">Unit Weight</th>
                          <th className="px-6 py-6 text-center">In Stock</th>
                          <th className="px-6 py-6 text-center">Expiry Gap</th>
                          <th className="px-6 py-6 text-center w-32">Order Qty</th>
                          <th className="px-6 py-6 text-center w-40">Proposed Rate (₹)</th>
                          <th className="px-8 py-6 text-right">Clearance Value</th>
                       </tr>
                    </thead>
                    <tbody className="divide-y text-sm font-bold text-slate-700">
                       {expiringStock.map(item => {
                         const id = `${item.productId}-${item.batchNo}`;
                         const state = orderSelections[id] || { ...item, orderQty: 0 };
                         const expInfo = getExpiryStatus(item.expDate);
                         const lineValue = state.orderQty * state.proposedRate;

                         return (
                           <tr key={id} className={`hover:bg-slate-50 transition-colors ${state.orderQty > 0 ? 'bg-rose-50/20' : ''}`}>
                              <td className="px-8 py-6">
                                 <p className="text-slate-900 font-black">{item.productName}</p>
                                 <div className="flex items-center gap-2 mt-1">
                                    <span className="text-[9px] font-black text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded border border-indigo-100 uppercase">{item.skuCode}</span>
                                    <span className="text-[9px] font-black text-slate-400 uppercase bg-slate-100 px-2 py-0.5 rounded border border-slate-200">BATCH: {item.batchNo}</span>
                                 </div>
                              </td>
                              <td className="px-6 py-6 text-center text-slate-500 font-medium">{item.weight} {item.unit}</td>
                              <td className="px-6 py-6 text-center font-black">{item.stockQty} {item.unit}</td>
                              <td className="px-6 py-6 text-center">
                                 <span className={`px-3 py-1 rounded-lg text-[10px] font-black border ${expInfo.color}`}>
                                    {expInfo.label}
                                 </span>
                              </td>
                              <td className="px-6 py-6">
                                 <input 
                                   type="number" 
                                   min="0" 
                                   max={item.stockQty}
                                   className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-3 py-2 text-center font-black focus:border-rose-500 outline-none"
                                   value={state.orderQty || ''}
                                   onChange={e => updateSelection(id, 'orderQty', Math.min(item.stockQty, parseFloat(e.target.value) || 0))}
                                   placeholder="0"
                                 />
                              </td>
                              <td className="px-6 py-6">
                                 <div className="relative">
                                    <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs font-black">₹</span>
                                    <input 
                                      type="number" 
                                      className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl pl-7 pr-3 py-2 text-center font-black focus:border-emerald-500 outline-none"
                                      value={state.proposedRate}
                                      onChange={e => updateSelection(id, 'proposedRate', parseFloat(e.target.value) || 0)}
                                    />
                                 </div>
                              </td>
                              <td className="px-8 py-6 text-right font-black text-slate-900">
                                 ₹{lineValue.toLocaleString()}
                              </td>
                           </tr>
                         );
                       })}
                       {expiringStock.length === 0 && (
                         <tr>
                           <td colSpan={7} className="px-8 py-32 text-center text-slate-300 font-black uppercase tracking-widest italic">
                              No near-expiry stock detected in master inventory.
                           </td>
                         </tr>
                       )}
                    </tbody>
                 </table>
              </div>
           </div>
        </div>

        <div className="space-y-6">
           <div className="bg-slate-900 rounded-[40px] p-8 text-white shadow-2xl relative overflow-hidden group border border-slate-800">
              <ShoppingBag className="absolute -right-6 -bottom-6 w-32 h-32 opacity-10 group-hover:scale-110 transition-transform duration-700" />
              <h4 className="text-xl font-black mb-8 flex items-center gap-3">
                 <ShieldAlert className="text-rose-400" size={24} /> Dispatch Hub
              </h4>
              
              <div className="space-y-6">
                 <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Target Client</label>
                    <select 
                      className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-rose-500/50 outline-none appearance-none transition-all"
                      value={selectedCustomerId}
                      onChange={e => setSelectedCustomerId(e.target.value)}
                    >
                       <option value="" className="bg-slate-900 text-slate-500">Select Organization...</option>
                       {customers.map(c => <option key={c.id} value={c.id} className="bg-slate-900">{c.name}</option>)}
                    </select>
                 </div>

                 <div className="p-6 bg-white/5 rounded-3xl border border-white/5 space-y-4">
                    <div className="flex justify-between items-center">
                       <span className="text-[10px] font-black text-slate-500 uppercase">Clearance Items</span>
                       <span className="text-sm font-black text-rose-400">{selectedItems.length} SKUs</span>
                    </div>
                    <div className="flex justify-between items-center pt-4 border-t border-white/5">
                       <span className="text-[10px] font-black text-slate-500 uppercase">Total Offer Value</span>
                       <span className="text-2xl font-black text-white">₹{totalOrderValue.toLocaleString()}</span>
                    </div>
                 </div>

                 <button 
                   onClick={handleSubmit}
                   disabled={selectedItems.length === 0 || !selectedCustomerId}
                   className="w-full bg-rose-600 text-white py-5 rounded-[24px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-rose-500 transition-all flex items-center justify-center gap-3 active:scale-95 disabled:opacity-30"
                 >
                    Execute Clearance Order <ArrowRight size={18} />
                 </button>
              </div>
           </div>

           <div className="bg-white p-8 rounded-[40px] border border-slate-200 shadow-sm space-y-4">
              <div className="flex items-center gap-3 mb-2">
                 <Clock size={20} className="text-indigo-600" />
                 <h5 className="text-xs font-black text-slate-900 uppercase tracking-widest">Protocol Insight</h5>
              </div>
              <p className="text-[11px] font-medium text-slate-500 leading-relaxed italic">
                Clearance orders move directly to Credit Control. Please ensure the proposed rate covers at least the Variable Cost to prevent margin erosion alerts.
              </p>
           </div>
        </div>
      </div>
    </div>
  );
};

export default NearExpiryView;
