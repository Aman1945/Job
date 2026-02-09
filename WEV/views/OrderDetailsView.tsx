
import React, { useState, useEffect, useMemo } from 'react';
import { Order, OrderStatus, User, UserRole, Customer, LogisticsDetails, OrderItem, BatchInfo, AgingBuckets } from '../types';
import { 
  ArrowLeft, CheckCircle2, Package, Truck, 
  FileCheck, Info, Sparkles, ShieldCheck,
  Box, Split, Trash2, CheckCircle, UserCircle, Activity, Zap, Snowflake, Plus, AlertTriangle, AlertCircle,
  Receipt, Printer, Share2, ArrowRight, Route, DollarSign, ShieldAlert, XCircle, CreditCard, RotateCcw, TrendingUp, PauseCircle, Send, Warehouse, FileText, Download,
  RefreshCw,
  FileUp
} from 'lucide-react';
import { getApprovalInsight } from '../services/geminiService';

interface OrderDetailsViewProps {
  order: Order;
  customer: Customer;
  user: User;
  onBack: () => void;
  onUpdate: (order: Order) => void;
}

const OrderDetailsView: React.FC<OrderDetailsViewProps> = ({ order, customer, user, onBack, onUpdate }) => {
  const [aiInsight, setAiInsight] = useState<string>('Analyzing...');
  const [isUpdating, setIsUpdating] = useState(false);
  const [rejectionReason, setRejectionReason] = useState(order.rejectionReason || '');
  const [salesRemarks, setSalesRemarks] = useState('');
  
  const [packingItems, setPackingItems] = useState<OrderItem[]>(() => 
    (order.items || []).map(item => ({
      ...item,
      packedQuantity: Number(item.packedQuantity) || 0,
      batches: (item.batches && item.batches.length > 0) ? item.batches : [{ 
        batch: '', mfgDate: '', expDate: '', quantity: 0, weight: '' 
      }]
    }))
  );

  const outwardSummary = useMemo(() => {
    const packedValue = packingItems.reduce((sum, item) => {
      const totalPacked = (item.batches || []).reduce((bSum, b) => bSum + Number(b.quantity || 0), 0);
      return sum + (totalPacked * item.price);
    }, 0);
    
    const originalOrderValue = order.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    
    return { packedValue, originalOrderValue };
  }, [packingItems, order.items]);
  
  const [logisticsData, setLogisticsData] = useState<LogisticsDetails>(() => ({
    thermacolBoxCount: order.logistics?.thermacolBoxCount || 0,
    thermacolBoxRate: order.logistics?.thermacolBoxRate || 300, 
    thermacolBoxAmount: order.logistics?.thermacolBoxAmount || 0,
    dryIceKg: order.logistics?.dryIceKg || 0,
    dryIceRate: order.logistics?.dryIceRate || 18, 
    dryIceAmount: order.logistics?.dryIceAmount || 0,
    whToStationAmount: order.logistics?.whToStationAmount || 0,
    stationToLocAmount: order.logistics?.stationToLocAmount || 0,
    whToCustAmount: order.logistics?.whToCustAmount || 0,
    mode: order.logistics?.mode || 'Road',
    transporterId: order.logistics?.transporterId || '',
    vehicleNo: order.logistics?.vehicleNo || ''
  }));

  useEffect(() => {
    const boxAmt = (logisticsData.thermacolBoxCount || 0) * (logisticsData.thermacolBoxRate || 300);
    const iceAmt = (logisticsData.dryIceKg || 0) * (logisticsData.dryIceRate || 18);
    
    if (boxAmt !== logisticsData.thermacolBoxAmount || iceAmt !== logisticsData.dryIceAmount) {
      setLogisticsData(prev => ({
        ...prev,
        thermacolBoxAmount: boxAmt,
        dryIceAmount: iceAmt
      }));
    }
  }, [logisticsData.thermacolBoxCount, logisticsData.thermacolBoxRate, logisticsData.dryIceKg, logisticsData.dryIceRate]);

  const totalLogisticsCost = useMemo(() => {
    return (
      (Number(logisticsData.thermacolBoxAmount) || 0) + 
      (Number(logisticsData.dryIceAmount) || 0) + 
      (Number(logisticsData.whToStationAmount) || 0) + 
      (Number(logisticsData.stationToLocAmount) || 0) + 
      (Number(logisticsData.whToCustAmount) || 0)
    );
  }, [logisticsData]);

  const logisticsRatio = useMemo(() => {
    if (outwardSummary.packedValue === 0) return 0;
    return (totalLogisticsCost / outwardSummary.packedValue) * 100;
  }, [totalLogisticsCost, outwardSummary.packedValue]);

  const [packedBoxes, setPackedBoxes] = useState<number>(order.packedBoxes || 0);

  useEffect(() => {
    getApprovalInsight(order, customer).then(setAiInsight);
  }, [order, customer]);

  const updateBatchEntry = (itemIdx: number, batchIdx: number, field: keyof BatchInfo, value: any) => {
    const newItems = [...packingItems];
    const item = newItems[itemIdx];
    if (item.batches) {
      if (field === 'quantity') {
        const otherBatchesTotal = item.batches.filter((_, idx) => idx !== batchIdx).reduce((sum, b) => sum + Number(b.quantity || 0), 0);
        const maxAllowed = Math.max(0, item.quantity - otherBatchesTotal);
        item.batches[batchIdx].quantity = Math.min(Number(value || 0), maxAllowed);
      } else {
        (item.batches[batchIdx] as any)[field] = value;
      }
      item.packedQuantity = item.batches.reduce((sum, b) => sum + Number(b.quantity || 0), 0);
      setPackingItems(newItems);
    }
  };

  const addBatchLine = (itemIdx: number) => {
    const newItems = [...packingItems];
    if (!newItems[itemIdx].batches) newItems[itemIdx].batches = [];
    newItems[itemIdx].batches?.push({ batch: '', mfgDate: '', expDate: '', quantity: 0 });
    setPackingItems(newItems);
  };

  const removeBatchLine = (itemIdx: number, batchIdx: number) => {
    const newItems = [...packingItems];
    newItems[itemIdx].batches = newItems[itemIdx].batches?.filter((_, i) => i !== batchIdx);
    if (newItems[itemIdx].batches?.length === 0) {
      newItems[itemIdx].batches = [{ batch: '', mfgDate: '', expDate: '', quantity: 0 }];
    }
    newItems[itemIdx].packedQuantity = newItems[itemIdx].batches?.reduce((sum, b) => sum + Number(b.quantity || 0), 0) || 0;
    setPackingItems(newItems);
  };

  const handleAction = async (nextStatus: OrderStatus, extraData: Partial<Order> = {}) => {
    setIsUpdating(true);
    const timestamp = new Date().toISOString();
    
    let finalStatus = nextStatus;
    if (order.status === OrderStatus.PENDING_PACKING && nextStatus === OrderStatus.READY_FOR_BILLING) {
      const isPartiallyFulfilled = packingItems.some(item => {
        const totalPacked = (item.batches || []).reduce((sum, b) => sum + Number(b.quantity || 0), 0);
        return totalPacked < item.quantity;
      });
      if (isPartiallyFulfilled) finalStatus = OrderStatus.PART_PACKED;
    }

    const updatedHistory = [...(order.statusHistory || []), { status: finalStatus, timestamp }];
    const finalItems = packingItems.map(item => ({
      ...item,
      packedQuantity: (item.batches || []).reduce((sum, b) => sum + Number(b.quantity || 0), 0)
    }));

    onUpdate({ 
      ...order, 
      status: finalStatus, 
      statusHistory: updatedHistory, 
      items: finalItems,
      packedBoxes,
      logistics: logisticsData,
      ...extraData 
    });
    setIsUpdating(false);
  };

  const downloadFile = (dataUri: string, fileName: string) => {
    const link = document.createElement('a');
    link.href = dataUri;
    link.download = fileName;
    link.click();
  };

  const renderMetricsGrid = () => {
    let ratioColorClass = "text-emerald-600 bg-emerald-50 border-emerald-100";
    if (logisticsRatio > 15) {
      ratioColorClass = "text-rose-600 bg-rose-50 border-rose-100";
    } else if (logisticsRatio >= 10) {
      ratioColorClass = "text-amber-600 bg-amber-50 border-amber-100";
    }

    return (
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-[32px] border border-slate-200 shadow-sm flex flex-col justify-center min-h-[120px]">
          <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Original Order Value</p>
          <p className="text-3xl font-black text-slate-900 tracking-tighter">₹{outwardSummary.originalOrderValue.toLocaleString()}</p>
        </div>
        <div className="bg-white p-6 rounded-[32px] border border-emerald-100 shadow-sm flex flex-col justify-center min-h-[120px]">
          <p className="text-[10px] font-black text-emerald-600 uppercase tracking-widest mb-1">Sending Value (Stock)</p>
          <p className="text-3xl font-black text-slate-900 tracking-tighter">₹{outwardSummary.packedValue.toLocaleString()}</p>
        </div>
        <div className="bg-white p-6 rounded-[32px] border border-slate-200 shadow-sm flex flex-col justify-center min-h-[120px]">
          <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Total Logistics Cost</p>
          <p className="text-3xl font-black text-indigo-600 tracking-tighter">₹{totalLogisticsCost.toLocaleString()}</p>
        </div>
        <div className={`p-6 rounded-[32px] border shadow-sm flex flex-col justify-center min-h-[120px] ${ratioColorClass}`}>
          <p className="text-[10px] font-black uppercase tracking-widest mb-1 opacity-70">Logistics % of Stock</p>
          <p className="text-3xl font-black tracking-tighter">
            {logisticsRatio.toFixed(1)}%
          </p>
        </div>
      </div>
    );
  };

  const renderOutwardTerminal = () => (
    <div className="space-y-6 animate-in slide-in-from-bottom-4">
      <div className="bg-emerald-900 rounded-[40px] p-8 text-white shadow-2xl flex flex-col md:flex-row md:items-center justify-between gap-6 border border-emerald-800">
        <div>
          <h4 className="text-xl font-black flex items-center gap-3"><Package className="text-emerald-400" size={24} /> 3. Batch Picking Terminal</h4>
          <p className="text-[10px] text-emerald-300/60 font-black uppercase mt-1 tracking-widest italic">Sourcing from: {order.warehouseSource || 'Standard Stock'}</p>
        </div>
        <div className="flex gap-4">
          <div className="bg-white/5 p-4 rounded-[24px] border border-white/10 flex items-center gap-3 px-6 shadow-inner">
             <Box size={14} className="text-emerald-400" />
             <input type="number" value={packedBoxes} onChange={(e) => setPackedBoxes(Number(e.target.value))} className="w-16 bg-transparent border-b border-emerald-500/30 text-lg font-black outline-none text-center text-white" />
             <span className="text-xs font-bold text-emerald-300/60">Load Units</span>
          </div>
        </div>
      </div>

      <div className="bg-white p-8 rounded-[40px] border border-slate-200 shadow-sm grid grid-cols-1 md:grid-cols-2 gap-8">
         <div className="space-y-4">
            <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Thermacol Boxes Used</label>
            <div className="flex items-center gap-3 bg-slate-50 p-4 rounded-2xl border-2 border-slate-100 shadow-inner">
               <Box className="text-indigo-500" size={18} />
               <input 
                 type="number" 
                 value={logisticsData.thermacolBoxCount} 
                 onChange={e => setLogisticsData({...logisticsData, thermacolBoxCount: Number(e.target.value)})}
                 className="bg-transparent text-xl font-black outline-none w-full"
                 placeholder="0"
               />
            </div>
         </div>
         <div className="space-y-4">
            <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Dry Ice Used (KG)</label>
            <div className="flex items-center gap-3 bg-slate-50 p-4 rounded-2xl border-2 border-slate-100 shadow-inner">
               <Snowflake className="text-blue-500" size={18} />
               <input 
                 type="number" 
                 value={logisticsData.dryIceKg} 
                 onChange={e => setLogisticsData({...logisticsData, dryIceKg: Number(e.target.value)})}
                 className="bg-transparent text-xl font-black outline-none w-full"
                 placeholder="0.0"
               />
            </div>
         </div>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left min-w-[1000px]">
            <thead>
              <tr className="bg-slate-50 text-[10px] font-black uppercase tracking-widest border-b">
                <th className="px-8 py-4">Item Identity</th>
                <th className="px-6 py-4 text-center">Ordered Qty</th>
                <th className="px-6 py-4 text-center text-emerald-600">Allocated Qty</th>
                <th className="px-8 py-4">Batch Details</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {packingItems.map((item, itemIdx) => {
                const totalPacked = (item.batches || []).reduce((sum, b) => sum + Number(b.quantity || 0), 0);
                const hasShortfall = totalPacked < item.quantity;
                return (
                  <tr key={itemIdx} className={`hover:bg-slate-50 transition-colors ${hasShortfall ? 'bg-amber-50/20' : ''}`}>
                    <td className="px-8 py-8 align-top">
                      <p className="font-black text-slate-900 text-sm leading-tight">{item.productName}</p>
                      <p className="text-[10px] text-slate-400 font-bold uppercase mt-1">{item.skuCode}</p>
                    </td>
                    <td className="px-6 py-8 text-center align-top font-black text-slate-400">{item.quantity} {item.unit}</td>
                    <td className="px-6 py-8 text-center align-top font-black text-emerald-600">{totalPacked} {item.unit}</td>
                    <td className="px-8 py-8 space-y-4">
                      {(item.batches || []).map((batch, bIdx) => (
                        <div key={bIdx} className="flex gap-2 p-2 bg-slate-100/50 border border-slate-200 rounded-2xl shadow-inner group/batch">
                          <input className="bg-white px-4 py-2.5 text-[10px] font-black rounded-xl w-32 border border-slate-200 outline-none uppercase shadow-sm focus:border-emerald-500" placeholder="BATCH #" value={batch.batch} onChange={e => updateBatchEntry(itemIdx, bIdx, 'batch', e.target.value)} />
                          <input type="number" className="bg-white px-4 py-2.5 text-[10px] font-black rounded-xl w-24 border border-slate-200 outline-none text-center shadow-sm focus:border-emerald-500" placeholder="QTY" value={batch.quantity || ''} onChange={e => updateBatchEntry(itemIdx, bIdx, 'quantity', Number(e.target.value))} />
                          <button onClick={() => removeBatchLine(itemIdx, bIdx)} className="p-2 text-slate-300 hover:text-rose-500 transition-all opacity-0 group-hover/batch:opacity-100"><Trash2 size={14}/></button>
                        </div>
                      ))}
                      <button 
                        onClick={() => addBatchLine(itemIdx)}
                        disabled={totalPacked >= item.quantity}
                        className="flex items-center gap-2 text-[9px] font-black text-emerald-600 uppercase tracking-widest px-4 py-2 rounded-xl hover:bg-emerald-50 transition-all disabled:opacity-30 border border-dashed border-emerald-200 w-full justify-center"
                      >
                         <Plus size={12}/> Allocate Multi-Batch
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        <div className="p-10 bg-emerald-950 flex items-center justify-between border-t border-emerald-900">
           <div className="text-left"><p className="text-[10px] font-black text-emerald-500 uppercase tracking-widest">Aggregate Picking Value</p><p className="text-4xl font-black text-white tracking-tighter">₹{outwardSummary.packedValue.toLocaleString()}</p></div>
           <button onClick={() => handleAction(OrderStatus.READY_FOR_BILLING)} className="px-20 py-7 bg-emerald-500 text-white rounded-[32px] font-black text-xs uppercase tracking-[0.25em] shadow-2xl hover:bg-emerald-400 shadow-emerald-500/20 transition-all active:scale-95 flex items-center gap-4">Finalize Loading <ArrowRight size={18} /></button>
        </div>
      </div>
    </div>
  );

  const renderLogisticsTerminal = () => (
    <div className="space-y-6 animate-in slide-in-from-bottom-4">
      <div className="bg-indigo-900 rounded-[40px] p-8 text-white shadow-2xl border border-indigo-800">
        <h4 className="text-xl font-black flex items-center gap-3"><Truck className="text-indigo-400" size={24} /> 4. Logistics Surcharge Matrix</h4>
      </div>

      {renderMetricsGrid()}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className="bg-white rounded-[40px] border border-slate-200 p-8 shadow-sm space-y-10">
           <div className="grid grid-cols-1 gap-6">
              <div className="flex items-center gap-4 bg-slate-50 p-4 rounded-3xl border border-slate-200">
                 <div className="flex-1">
                    <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Thermacol Boxes (WH)</label>
                    <p className="text-lg font-black">{logisticsData.thermacolBoxCount} Units</p>
                 </div>
                 <div className="flex-1">
                    <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Rate (₹)</label>
                    <input type="number" value={logisticsData.thermacolBoxRate} onChange={v => setLogisticsData({...logisticsData, thermacolBoxRate: Number(v.target.value)})} className="w-full bg-white border border-slate-200 rounded-xl px-4 py-2 text-sm font-black" />
                 </div>
                 <div className="flex-1 text-right">
                    <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Amount</label>
                    <p className="text-lg font-black text-indigo-600">₹{logisticsData.thermacolBoxAmount}</p>
                 </div>
              </div>

              <div className="flex items-center gap-4 bg-slate-50 p-4 rounded-3xl border border-slate-200">
                 <div className="flex-1">
                    <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Dry Ice KG (WH)</label>
                    <p className="text-lg font-black">{logisticsData.dryIceKg} KG</p>
                 </div>
                 <div className="flex-1">
                    <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Rate (₹)</label>
                    <input type="number" value={logisticsData.dryIceRate} onChange={v => setLogisticsData({...logisticsData, dryIceRate: Number(v.target.value)})} className="w-full bg-white border border-slate-200 rounded-xl px-4 py-2 text-sm font-black" />
                 </div>
                 <div className="flex-1 text-right">
                    <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Amount</label>
                    <p className="text-lg font-black text-indigo-600">₹{logisticsData.dryIceAmount}</p>
                 </div>
              </div>

              <div className="grid grid-cols-3 gap-4">
                 <LogisticsInput label="WH-Station (₹)" value={logisticsData.whToStationAmount} onChange={v => setLogisticsData({...logisticsData, whToStationAmount: Number(v)})} />
                 <LogisticsInput label="Stat-Hub (₹)" value={logisticsData.stationToLocAmount} onChange={v => setLogisticsData({...logisticsData, stationToLocAmount: Number(v)})} />
                 <LogisticsInput label="Hub-Door (₹)" value={logisticsData.whToCustAmount} onChange={v => setLogisticsData({...logisticsData, whToCustAmount: Number(v)})} />
              </div>
           </div>
        </div>
        <div className="bg-white rounded-[40px] border border-slate-200 p-8 shadow-sm flex flex-col justify-between">
           <div className="bg-indigo-950 p-8 rounded-[32px] shadow-xl space-y-6">
              <div>
                <p className="text-[10px] font-black text-indigo-400 uppercase mb-2">Total Freight Burden</p>
                <p className="text-4xl font-black text-white tracking-tighter">₹{totalLogisticsCost.toLocaleString()}</p>
              </div>
              <div className="p-4 bg-white/5 rounded-2xl border border-white/10 flex items-center justify-between">
                <span className="text-[10px] font-black text-slate-400 uppercase">Ratio Health</span>
                <span className={`text-xs font-black uppercase ${logisticsRatio > 15 ? 'text-rose-400' : logisticsRatio >= 10 ? 'text-amber-400' : 'text-emerald-400'}`}>
                  {logisticsRatio > 15 ? 'Critical Burden' : logisticsRatio >= 10 ? 'High Burden' : 'Nominal'}
                </span>
              </div>
           </div>
           
           <div className="space-y-4 pt-8">
              <div className="space-y-2">
                 <label className="text-[10px] font-black text-slate-400 uppercase px-1">Remarks (Required for rejection)</label>
                 <input 
                    type="text" 
                    value={rejectionReason} 
                    onChange={e => setRejectionReason(e.target.value)}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold focus:border-indigo-600 outline-none transition-all"
                    placeholder="Add operational notes..."
                 />
              </div>
              <div className="flex gap-4">
                <button onClick={() => handleAction(OrderStatus.PENDING_LOGISTICS)} className="flex-1 bg-indigo-600 text-white py-6 rounded-[28px] font-black text-[11px] uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-500 transition-all flex items-center justify-center gap-3 active:scale-95">
                  <CheckCircle size={18} /> Push to Invoicing
                </button>
                <button onClick={() => handleAction(OrderStatus.PENDING_PACKING, { rejectionReason })} disabled={!rejectionReason} className="flex-1 bg-white border-2 border-rose-100 text-rose-600 py-6 rounded-[28px] font-black text-[11px] uppercase tracking-[0.2em] hover:bg-rose-50 transition-all flex items-center justify-center gap-3 disabled:opacity-30">
                  <XCircle size={18} /> Send back to WH
                </button>
              </div>
           </div>
        </div>
      </div>
    </div>
  );

  const renderInvoicingTerminal = () => (
    <div className="space-y-8 animate-in slide-in-from-bottom-4">
      <div className="bg-emerald-600 rounded-[40px] p-10 text-white shadow-2xl flex items-center justify-between border border-emerald-500 shadow-emerald-500/20">
         <div className="flex items-center gap-6">
            <div className="w-20 h-20 bg-white/10 rounded-[32px] flex items-center justify-center border border-white/20"><Receipt size={40} /></div>
            <div><h4 className="text-3xl font-black tracking-tighter">5. Invoicing Command Review</h4><p className="text-sm text-emerald-100 font-medium">Full detail audit: Ordered vs Packed, Batches, and Surcharges</p></div>
         </div>
         <button className="bg-white/10 border border-white/20 px-6 py-3 rounded-2xl flex items-center gap-2 hover:bg-white/20 transition-all text-[11px] font-black uppercase tracking-widest"><RefreshCw size={14} /> Sync from Tally</button>
      </div>

      {renderMetricsGrid()}
      
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
         <div className="lg:col-span-2 space-y-8">
            <div className="bg-white rounded-[44px] p-8 border border-slate-200 shadow-sm overflow-hidden">
               <h5 className="text-xs font-black text-slate-400 uppercase tracking-widest mb-6 border-b pb-4">Warehouse Fulfillment Log (SKU, Qty & Batches)</h5>
               <table className="w-full text-left">
                 <thead>
                    <tr className="text-[9px] font-black uppercase text-slate-400">
                       <th className="pb-3 px-2">Product Name</th>
                       <th className="pb-3 text-center">Ordered</th>
                       <th className="pb-3 text-center">Packed</th>
                       <th className="pb-3">Batches Allocated</th>
                       <th className="pb-3 text-right">Valuation</th>
                    </tr>
                 </thead>
                 <tbody className="divide-y text-xs">
                    {packingItems.map((item, idx) => (
                      <tr key={idx} className="hover:bg-slate-50 transition-colors">
                         <td className="py-4 px-2 font-black">{item.productName}</td>
                         <td className="py-4 text-center font-bold text-slate-400">{item.quantity}</td>
                         <td className="py-4 text-center font-black text-emerald-600">{item.packedQuantity}</td>
                         <td className="py-4">
                            <div className="flex gap-1 flex-wrap">
                               {item.batches?.filter(b => b.quantity > 0).map((b, bidx) => (
                                 <span key={bidx} className="bg-indigo-50 text-indigo-600 px-2 py-0.5 rounded border border-indigo-100 uppercase text-[8px] font-black">{b.batch}</span>
                               ))}
                            </div>
                         </td>
                         <td className="py-4 text-right font-black">₹{(item.price * (item.packedQuantity || 0)).toLocaleString()}</td>
                      </tr>
                    ))}
                 </tbody>
               </table>
            </div>

            <div className="bg-white rounded-[44px] p-8 border border-slate-200 shadow-sm">
               <h5 className="text-xs font-black text-slate-400 uppercase tracking-widest mb-6 border-b pb-4">Logistics Cost Breakup</h5>
               <div className="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-4">
                  <div className="flex justify-between items-center py-2 border-b border-slate-50">
                    <span className="text-[10px] font-bold text-slate-500 uppercase">Thermacol Boxes ({logisticsData.thermacolBoxCount} @ ₹{logisticsData.thermacolBoxRate})</span>
                    <span className="font-black">₹{logisticsData.thermacolBoxAmount}</span>
                  </div>
                  <div className="flex justify-between items-center py-2 border-b border-slate-50">
                    <span className="text-[10px] font-bold text-slate-500 uppercase">Dry Ice ({logisticsData.dryIceKg} KG @ ₹{logisticsData.dryIceRate})</span>
                    <span className="font-black">₹{logisticsData.dryIceAmount}</span>
                  </div>
                  <div className="flex justify-between items-center py-2 border-b border-slate-50"><span className="text-[10px] font-bold text-slate-500 uppercase">WH to Station</span><span className="font-black">₹{logisticsData.whToStationAmount}</span></div>
                  <div className="flex justify-between items-center py-2 border-b border-slate-50"><span className="text-[10px] font-bold text-slate-500 uppercase">Station to Hub</span><span className="font-black">₹{logisticsData.stationToLocAmount}</span></div>
                  <div className="flex justify-between items-center py-2 border-b border-slate-50 col-span-2"><span className="text-[10px] font-bold text-slate-500 uppercase">Hub to Customer</span><span className="font-black text-indigo-600 font-black">₹{logisticsData.whToCustAmount}</span></div>
               </div>
            </div>
         </div>

         <div className="space-y-8">
            <div className="bg-slate-900 p-10 rounded-[44px] text-white shadow-xl space-y-8 border border-slate-800">
               <h5 className="text-xl font-black border-b border-white/10 pb-4">Invoice Command</h5>
               <div className="space-y-4">
                  <div className="flex justify-between text-sm"><span className="text-slate-400 font-bold uppercase tracking-widest">Stock Total</span><span className="font-black">₹{outwardSummary.packedValue.toLocaleString()}</span></div>
                  <div className="flex justify-between text-sm"><span className="text-slate-400 font-bold uppercase tracking-widest">Surcharges</span><span className="font-black text-indigo-400">₹{totalLogisticsCost.toLocaleString()}</span></div>
                  <div className="pt-6 border-t border-white/10 flex justify-between items-center"><span className="text-sm font-black text-emerald-400 uppercase">Grand Payable</span><span className="text-4xl font-black text-white tracking-tighter">₹{(outwardSummary.packedValue + totalLogisticsCost).toLocaleString()}</span></div>
               </div>
               
               <div className="space-y-4 pt-4">
                  <div className="space-y-2">
                     <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Review Remarks</label>
                     <textarea 
                        value={rejectionReason} 
                        onChange={e => setRejectionReason(e.target.value)}
                        className="w-full bg-slate-800 border border-slate-700 rounded-2xl p-4 text-xs font-bold focus:border-emerald-500 outline-none transition-all resize-none"
                        rows={2}
                        placeholder="Required for correction cycles..."
                     />
                  </div>
                  
                  <div className="grid grid-cols-1 gap-3">
                     <button onClick={() => handleAction(OrderStatus.READY_FOR_DISPATCH, { invoiceNo: `SYS-${Math.floor(Math.random() * 90000) + 10000}` })} className="w-full bg-emerald-500 text-white py-5 rounded-[28px] font-black text-xs uppercase tracking-widest shadow-2xl hover:bg-emerald-400 active:scale-95 flex items-center justify-center gap-3">
                        <CheckCircle size={20}/> Approve & Finalize Mission
                     </button>
                     <button onClick={() => handleAction(OrderStatus.READY_FOR_BILLING, { rejectionReason })} disabled={!rejectionReason} className="w-full bg-white/5 border border-rose-500/30 text-rose-500 py-5 rounded-[28px] font-black text-xs uppercase tracking-widest hover:bg-rose-500/10 active:scale-95 flex items-center justify-center gap-3 disabled:opacity-30">
                        <XCircle size={20}/> Reject To Logistics Costing
                     </button>
                  </div>
               </div>
            </div>

            <div className="bg-white rounded-[44px] p-8 border border-slate-200 shadow-sm flex flex-col items-center justify-center text-center gap-4">
               <div className="w-16 h-16 bg-slate-50 rounded-3xl flex items-center justify-center text-slate-400">
                  <FileUp size={32} />
               </div>
               <div>
                  <p className="text-xs font-black uppercase text-slate-900 tracking-widest">Manual Invoice Upload</p>
                  <p className="text-[10px] text-slate-400 mt-1">Directly attach Tally/Physical copy</p>
               </div>
               <button className="mt-2 w-full py-4 bg-slate-100 text-slate-600 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-slate-200 transition-all">Select File</button>
            </div>
         </div>
      </div>
    </div>
  );

  const overdueBuckets: (keyof AgingBuckets)[] = [
    '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90', '90 to 120', '120 to 150', '150 to 180', '>180'
  ];

  const renderCreditControlTerminal = () => {
    const criticalOverdue = overdueBuckets.slice(2).some(bucket => (customer.agingBuckets?.[bucket] || 0) > 0);

    return (
      <div className="space-y-8 animate-in slide-in-from-bottom-4">
        <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl relative overflow-hidden border border-slate-800">
          <div className="absolute top-0 right-0 p-10 opacity-10 pointer-events-none text-indigo-400">
            <ShieldCheck size={200} />
          </div>
          <div className="relative z-10">
            <h4 className="text-3xl font-black flex items-center gap-3 tracking-tighter">
              <Zap className="text-amber-400" size={32} /> 2. Credit Exposure Matrix
            </h4>
            <p className="text-sm text-slate-400 font-bold uppercase mt-2 tracking-widest">Financial Health Review for {customer.name}</p>
          </div>
        </div>

        <div className="bg-white rounded-[40px] border border-slate-200 p-8 shadow-sm space-y-8">
          <div className="flex items-center gap-4">
            <div className={`p-4 rounded-2xl flex items-center gap-4 border-2 flex-1 transition-all ${criticalOverdue ? 'bg-rose-600 border-rose-700 text-white shadow-xl shadow-rose-200 animate-pulse' : (customer.overdue > 0 ? 'bg-rose-50 border-rose-100 text-rose-700' : 'bg-emerald-50 border-emerald-100 text-emerald-700')}`}>
              {criticalOverdue ? <AlertCircle size={32} /> : (customer.overdue > 0 ? <ShieldAlert size={24} /> : <ShieldCheck size={24} />)}
              <div>
                <p className={`text-[10px] font-black uppercase tracking-widest ${criticalOverdue ? 'opacity-80' : ''}`}>Current Standing</p>
                <p className="text-lg font-black uppercase">
                  {criticalOverdue ? 'CRITICAL EXPOSURE (15+ DAYS)' : (customer.overdue > 0 ? 'Overdue Debt Detected' : 'Clean Financial Record')}
                </p>
              </div>
            </div>
            <div className="bg-indigo-50 border-2 border-indigo-100 p-4 rounded-2xl flex-1 text-indigo-700">
              <p className="text-[10px] font-black uppercase tracking-widest">Available Credit</p>
              <p className="text-lg font-black uppercase">₹{(customer.creditLimit - customer.outstanding).toLocaleString()}</p>
            </div>
          </div>

          <div className="overflow-x-auto rounded-[32px] border border-slate-200 shadow-xl shadow-slate-200/50">
            <table className="w-full border-collapse text-[11px]">
              <thead>
                <tr className="bg-slate-900 text-white font-bold">
                  <th className="px-4 py-4 text-left border-r border-slate-700 first:rounded-tl-[30px]">Days</th>
                  <th className="px-4 py-4 text-left border-r border-slate-700">Limit</th>
                  <th className="px-4 py-4 text-left border-r border-slate-700">Sec Chq</th>
                  <th className="px-4 py-4 text-left border-r border-slate-700">O/s Balance</th>
                  <th className="px-4 py-4 text-left border-r border-slate-700 text-rose-300">Overdue</th>
                  {overdueBuckets.map((bucket, idx) => (
                    <th key={bucket} className={`px-4 py-4 text-center border-r border-slate-700 font-normal ${idx >= 2 ? 'text-rose-500 font-black bg-rose-50/5' : 'text-rose-300'} last:rounded-tr-[30px]`}>
                      {bucket}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="bg-white font-bold text-slate-700">
                <tr>
                  <td className="px-4 py-6 border-r border-slate-100 bg-slate-50">{customer.creditDays || '0 days'}</td>
                  <td className="px-4 py-6 border-r border-slate-100">₹{(customer.creditLimit || 0).toLocaleString()}</td>
                  <td className="px-4 py-6 border-r border-slate-100 text-center">{customer.securityChqStatus || 'N/A'}</td>
                  <td className="px-4 py-6 border-r border-slate-100">₹{(customer.outstanding || 0).toLocaleString()}</td>
                  <td className="px-4 py-6 border-r border-slate-100 text-rose-600 bg-rose-50/20">
                    ₹{(customer.overdue || 0).toLocaleString()}
                  </td>
                  {overdueBuckets.map((bucket, idx) => (
                    <td key={bucket} className={`px-4 py-6 border-r border-slate-100 text-center ${idx >= 2 && (customer.agingBuckets?.[bucket] || 0) > 0 ? 'text-rose-600 bg-rose-100/30 font-black' : (customer.agingBuckets?.[bucket] > 0 ? 'text-rose-400' : 'text-slate-300')}`}>
                      {customer.agingBuckets?.[bucket] > 0 ? `₹${(customer.agingBuckets[bucket]).toLocaleString()}` : '-'}
                    </td>
                  ))}
                </tr>
              </tbody>
            </table>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-6 border-t border-slate-100">
            <div className="space-y-4">
               <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Internal Note / Rejection Reason</label>
               <textarea 
                 value={rejectionReason}
                 onChange={(e) => setRejectionReason(e.target.value)}
                 className="w-full bg-slate-50 border-2 border-slate-100 rounded-3xl p-6 text-sm font-bold focus:border-indigo-600 outline-none transition-all h-32"
                 placeholder="Add internal verification notes..."
               />
            </div>
            <div className="flex flex-col justify-end gap-3">
               <button onClick={() => handleAction(OrderStatus.PENDING_WH_SELECTION)} className="w-full bg-emerald-600 text-white py-5 rounded-[24px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-emerald-500 transition-all flex items-center justify-center gap-3"><CheckCircle size={20} /> Approve Order</button>
               <button onClick={() => handleAction(OrderStatus.ON_HOLD, { rejectionReason })} className="w-full bg-amber-500 text-white py-5 rounded-[24px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-amber-400 transition-all flex items-center justify-center gap-3"><PauseCircle size={20} /> Place on Hold</button>
               <button onClick={() => handleAction(OrderStatus.REJECTED, { rejectionReason })} className="w-full bg-white border-2 border-rose-100 text-rose-600 py-5 rounded-[24px] font-black text-xs uppercase tracking-[0.2em] hover:bg-rose-50 transition-all flex items-center justify-center gap-3"><XCircle size={20} /> Reject Order</button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="max-w-7xl mx-auto space-y-10 pb-20 animate-in fade-in duration-500">
       <button onClick={onBack} className="flex items-center gap-3 text-slate-400 hover:text-emerald-600 font-black text-[11px] uppercase tracking-[0.2em] group transition-all"><ArrowLeft size={16} className="group-hover:-translate-x-1" /> Return to Queue</button>
       <div className="bg-white p-12 rounded-[50px] border border-slate-200 shadow-sm flex flex-col md:flex-row justify-between items-center gap-8 relative overflow-hidden">
          <div className="absolute top-0 right-0 p-12 opacity-[0.04] pointer-events-none -mr-16 -mt-16 text-emerald-600"><ShieldCheck size={300} /></div>
          <div className="text-center md:text-left">
             <div className="flex flex-wrap justify-center md:justify-start items-center gap-3 mb-6">
                <span className={`px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest border ${
                  order.status === OrderStatus.DELIVERED ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 
                  order.status === OrderStatus.REJECTED ? 'bg-rose-50 text-rose-600 border-rose-100' :
                  order.status === OrderStatus.ON_HOLD ? 'bg-amber-50 text-amber-600 border-amber-100' :
                  (order.status === OrderStatus.PART_ACCEPTED || order.status === OrderStatus.PART_PACKED || order.status === OrderStatus.BACKORDER) ? 'bg-orange-50 text-orange-600 border-orange-100' :
                  'bg-indigo-50 text-indigo-600'
                }`}>{order.status}</span>
                {order.invoiceNo && <span className="px-4 py-1.5 bg-slate-100 text-slate-600 rounded-full text-[10px] font-black uppercase tracking-widest border border-slate-200">#{order.invoiceNo}</span>}
             </div>
             <h3 className="text-5xl font-black text-slate-900 tracking-tighter">{order.id}</h3>
             <p className="text-slate-500 text-lg mt-2 font-medium">{customer?.name} • <span className="font-black text-slate-900">{customer?.type}</span></p>
          </div>
          <div className="text-center md:text-right">
             <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Order Booking Value</p>
             <p className="text-6xl font-black text-slate-900 tracking-tighter">₹{outwardSummary.originalOrderValue.toLocaleString()}</p>
          </div>
       </div>

       <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
          <div className="lg:col-span-2 space-y-10">
             {/* PO Attachment Display if present */}
             {order.poAttachment && (
                <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden p-8 animate-in slide-in-from-top-4">
                   <div className="flex items-center justify-between mb-6">
                      <div className="flex items-center gap-3">
                         <FileText className="text-emerald-500" size={20}/>
                         <h4 className="text-xs font-black text-slate-900 uppercase tracking-widest">Linked Document (PO / PDC)</h4>
                      </div>
                      <button 
                        onClick={() => downloadFile(order.poAttachment!, order.poFileName || 'PO_PDC_Attachment.png')}
                        className="p-2.5 bg-emerald-50 text-emerald-600 rounded-xl hover:bg-emerald-600 hover:text-white transition-all shadow-sm flex items-center gap-2 text-[10px] font-black uppercase px-4"
                      >
                         <Download size={14}/> Download Copy
                      </button>
                   </div>
                   <div className="aspect-video md:aspect-[4/1] bg-slate-50 rounded-[32px] border border-slate-100 overflow-hidden relative group">
                      <img src={order.poAttachment} className="w-full h-full object-contain" alt="PO Preview" />
                      <div className="absolute inset-0 bg-slate-900/10 opacity-0 group-hover:opacity-100 transition-opacity" />
                   </div>
                </div>
             )}

             {order.status === OrderStatus.PENDING_CREDIT_APPROVAL || order.status === OrderStatus.ON_HOLD ? (
                renderCreditControlTerminal()
             ) : (order.status === OrderStatus.REJECTED && user.role === UserRole.SALES) ? (
                <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden p-10 space-y-8 animate-in slide-in-from-bottom-4">
                   <div className="bg-rose-50 p-8 rounded-3xl border border-rose-100 text-rose-700">
                      <h4 className="text-lg font-black flex items-center gap-3 uppercase"><AlertCircle /> Rejection Review</h4>
                      <p className="text-sm font-medium mt-2 leading-relaxed opacity-80">Reasons: {order.rejectionReason || 'No specific reason provided.'}</p>
                   </div>
                   <div className="space-y-4">
                      <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Resubmission Remarks / Proof Attachment Note</label>
                      <textarea 
                        value={salesRemarks}
                        onChange={(e) => setSalesRemarks(e.target.value)}
                        className="w-full bg-slate-50 border-2 border-slate-100 rounded-3xl p-6 text-sm font-bold focus:border-indigo-600 outline-none transition-all h-32"
                        placeholder="Explain why this order should be approved (e.g., payment received, credit extension discussed)..."
                      />
                   </div>
                   <button 
                     onClick={() => handleAction(OrderStatus.PENDING_CREDIT_APPROVAL, { generalRemarks: `RESUBMITTED: ${salesRemarks}` })}
                     className="w-full bg-indigo-600 text-white py-6 rounded-[28px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-500 transition-all flex items-center justify-center gap-3"
                   >
                     <Send size={20} /> Resubmit for Approval
                   </button>
                </div>
             ) : order.status === OrderStatus.PENDING_PACKING || order.status === OrderStatus.BACKORDER ? (
                renderOutwardTerminal()
             ) : (order.status === OrderStatus.READY_FOR_BILLING || order.status === OrderStatus.PART_PACKED) ? (
                renderLogisticsTerminal()
             ) : order.status === OrderStatus.PENDING_LOGISTICS ? (
                renderInvoicingTerminal()
             ) : (
              <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm overflow-hidden p-10 space-y-8">
                <div className="flex items-center justify-between">
                   <h4 className="text-sm font-black text-slate-900 uppercase tracking-widest">Fulfillment History</h4>
                   {order.status === OrderStatus.PART_ACCEPTED && (
                      <button onClick={() => handleAction(OrderStatus.BACKORDER)} className="flex items-center gap-2 px-8 py-4 bg-indigo-600 text-white rounded-3xl text-[10px] font-black uppercase tracking-widest shadow-xl shadow-indigo-600/20 hover:bg-indigo-500 transition-all active:scale-95">
                         <RotateCcw size={16}/> Reattempt Open Stock
                      </button>
                   )}
                </div>
                <div className="space-y-4">
                  {(order.items || []).map((item, i) => (
                    <div key={i} className="flex justify-between py-6 border-b last:border-0 group transition-all">
                      <div>
                        <p className="font-black text-base group-hover:text-indigo-600 transition-colors">{item.productName}</p>
                        <p className="text-[10px] text-slate-400 font-bold uppercase mt-1">Status: {item.packedQuantity || 0} / {item.quantity} {item.unit} Delivered</p>
                      </div>
                      <div className="text-right">
                        <p className="font-black text-slate-900 text-lg">₹{((item.price) * (item.packedQuantity || item.quantity)).toLocaleString()}</p>
                        {item.quantity > (item.packedQuantity || 0) && <p className="text-[10px] font-black text-rose-500 uppercase">Short: {item.quantity - (item.packedQuantity || 0)} Units</p>}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
             )}
          </div>
          <div className="space-y-8">
             <div className="bg-emerald-600 p-10 rounded-[44px] text-white shadow-2xl relative group overflow-hidden border border-emerald-500">
                <Sparkles className="absolute -top-12 -right-12 w-64 h-64 opacity-10 group-hover:scale-110 transition-transform duration-700" />
                <p className="text-[10px] font-black uppercase tracking-widest opacity-60 mb-4 flex items-center gap-2"><Info size={14} /> Intelligence Insight</p>
                <p className="text-base font-medium italic leading-relaxed tracking-tight">"{aiInsight}"</p>
             </div>
             <div className="bg-white p-10 rounded-[44px] border border-slate-200 shadow-sm">
                <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-10 border-b pb-4">Mission Workflow Trace</h4>
                <div className="space-y-12 pl-2">
                  {[OrderStatus.PENDING_CREDIT_APPROVAL, OrderStatus.ON_HOLD, OrderStatus.PENDING_WH_SELECTION, OrderStatus.PENDING_PACKING, OrderStatus.PENDING_LOGISTICS, OrderStatus.DELIVERED].map((s, i) => (
                    <div key={i} className={`flex items-center gap-6 ${(order.statusHistory || []).some(h => h.status === s) ? 'text-emerald-600' : 'text-slate-300'}`}>
                      <div className={`w-10 h-10 rounded-2xl flex items-center justify-center border-2 transition-all ${(order.statusHistory || []).some(h => h.status === s) ? 'bg-emerald-50 border-emerald-100' : 'bg-slate-50 border-slate-100'}`}>
                        {(order.statusHistory || []).some(h => h.status === s) ? <CheckCircle size={18} /> : <div className="w-2 h-2 rounded-full bg-slate-200" />}
                      </div>
                      <span className="text-[10px] font-black uppercase tracking-[0.15em]">{s}</span>
                    </div>
                  ))}
                </div>
             </div>
          </div>
       </div>
    </div>
  );
};

const LogisticsInput = ({ label, value, onChange }: { label: string, value: any, onChange: (v: string) => void }) => (
  <div className="space-y-2.5">
     <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">{label}</label>
     <input className="w-full bg-slate-50 border-2 border-slate-100 p-4 rounded-2xl font-black text-xs outline-none focus:border-indigo-600 transition-all shadow-inner" value={value === 0 ? '0' : value || ''} onChange={e => onChange(e.target.value)} />
  </div>
);

export default OrderDetailsView;
