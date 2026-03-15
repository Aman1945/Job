
import React, { useState, useEffect, useMemo, useRef } from 'react';
import { Order, OrderStatus, User, UserRole, Customer, LogisticsDetails, OrderItem, BatchInfo, AgingBuckets, Product } from '../types';
import { 
  ArrowLeft, CheckCircle2, Package, Truck, 
  FileCheck, Info, Sparkles, ShieldCheck,
  Box, Split, Trash2, CheckCircle, UserCircle, Activity, Zap, Snowflake, Plus, AlertTriangle, AlertCircle,
  Receipt, Printer, Share2, ArrowRight, Route, DollarSign, ShieldAlert, XCircle, CreditCard, RotateCcw, TrendingUp, PauseCircle, Send, Warehouse, FileText, Download,
  RefreshCw,
  FileUp,
  Scan,
  Gamepad2,
  MousePointer2,
  Pencil,
  Save,
  Ban,
  X,
  History as HistoryIcon
} from 'lucide-react';
import { getApprovalInsight } from '../services/geminiService';
import StatusHistoryModal from '../components/StatusHistoryModal';

interface OrderDetailsViewProps {
  order: Order;
  customer: Customer;
  user: User;
  products?: Product[];
  onBack: () => void;
  onUpdate: (order: Order) => void;
}

const OrderDetailsView: React.FC<OrderDetailsViewProps> = ({ order, customer, user, products = [], onBack, onUpdate }) => {
  const [aiInsight, setAiInsight] = useState<string>('Analyzing...');
  const [isUpdating, setIsUpdating] = useState(false);
  const [rejectionReason, setRejectionReason] = useState(order.rejectionReason || '');
  const [salesRemarks, setSalesRemarks] = useState('');
  const [scanMode, setScanMode] = useState<'AUTO' | 'MANUAL'>('MANUAL');
  const [scanningIdx, setScanningIdx] = useState<number | null>(null);
  
  // Edit Mode State
  const [isEditingOrder, setIsEditingOrder] = useState(false);
  const [editedItems, setEditedItems] = useState<OrderItem[]>([]);
  const [showHistoryModal, setShowHistoryModal] = useState(false);
  
  const [packingItems, setPackingItems] = useState<OrderItem[]>([]);

  const invoiceFileRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (order && order.items) {
      const initializedItems = order.items.map(item => ({
        ...item,
        packedQuantity: Number(item.packedQuantity) || 0,
        barcode: item.barcode || '',
        batches: (item.batches && item.batches.length > 0) 
          ? item.batches 
          : [{ batch: '', mfgDate: '', expDate: '', quantity: 0, weight: '' }]
      }));
      setPackingItems(initializedItems);
      setEditedItems(JSON.parse(JSON.stringify(order.items))); // Deep clone for editing
    }
  }, [order.id, order.items]);

  const outwardSummary = useMemo(() => {
    const packedValue = (packingItems || []).reduce((sum, item) => {
      const totalPacked = (item.batches || []).reduce((bSum, b) => bSum + Number(b.quantity || 0), 0);
      return sum + (totalPacked * item.price);
    }, 0);
    
    const originalOrderValue = (order.items || []).reduce((sum, item) => sum + (item.price * item.quantity), 0);
    
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

  // NEW ACCESS CONTROL LOGIC
  const isAdmin = user.role === UserRole.ADMIN;
  const isSalesManager = user.role === UserRole.SALES;

  // Sales Manager can edit before order is packed (status not in QC or beyond)
  // Admin can cancel until delivered.
  const canEdit = isAdmin ? (order.status !== OrderStatus.DELIVERED) : 
                  isSalesManager ? [
                    OrderStatus.PENDING_CREDIT_APPROVAL, 
                    OrderStatus.ON_HOLD, 
                    OrderStatus.REJECTED, 
                    OrderStatus.PENDING_WH_SELECTION, 
                    OrderStatus.PENDING_PACKING,
                    OrderStatus.BACKORDER,
                    OrderStatus.PART_PACKED
                  ].includes(order.status) : false;

  const canCancel = isAdmin ? (order.status !== OrderStatus.DELIVERED) :
                    isSalesManager ? [
                      OrderStatus.PENDING_CREDIT_APPROVAL, 
                      OrderStatus.ON_HOLD, 
                      OrderStatus.REJECTED, 
                      OrderStatus.PENDING_WH_SELECTION, 
                      OrderStatus.PENDING_PACKING,
                      OrderStatus.BACKORDER
                    ].includes(order.status) : false;

  const handleCancelOrder = async () => {
    if (!window.confirm("Are you sure you want to cancel this mission? This will mark the order as REJECTED.")) return;
    
    const timestamp = new Date().toISOString();
    const nextStatus = OrderStatus.REJECTED;
    
    onUpdate({
      ...order,
      status: nextStatus,
      rejectionReason: 'Mission cancelled by authorized personnel.',
      statusHistory: [...(order.statusHistory || []), { status: nextStatus, timestamp, userName: user.name }]
    });
    onBack();
  };

  const handleSaveEdits = async () => {
    setIsUpdating(true);
    await new Promise(r => setTimeout(r, 800));
    
    const timestamp = new Date().toISOString();
    const nextStatus = OrderStatus.PENDING_CREDIT_APPROVAL; 
    
    onUpdate({
      ...order,
      items: editedItems,
      status: nextStatus,
      statusHistory: [...(order.statusHistory || []), { status: nextStatus, timestamp, userName: user.name }]
    });
    
    setIsEditingOrder(false);
    setIsUpdating(false);
  };

  const addEditItem = () => {
    if (products.length === 0) return;
    const p = products[0];
    setEditedItems([...editedItems, {
      productId: p.id,
      productName: p.name,
      skuCode: p.skuCode,
      quantity: 1,
      unit: p.unit,
      price: p.price,
      baseRate: p.baseRate
    }]);
  };

  const updateEditItem = (idx: number, field: keyof OrderItem, value: any) => {
    const next = [...editedItems];
    if (field === 'productId') {
      const p = products.find(prod => prod.id === value);
      if (p) {
        next[idx] = {
          ...next[idx],
          productId: p.id,
          productName: p.name,
          skuCode: p.skuCode,
          unit: p.unit,
          price: p.price,
          baseRate: p.baseRate
        };
      }
    } else {
      (next[idx] as any)[field] = value;
    }
    setEditedItems(next);
  };

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

  const simulateScan = async (idx: number) => {
    setScanningIdx(idx);
    await new Promise(r => setTimeout(r, 800));
    const newItems = [...packingItems];
    newItems[idx].barcode = order.items[idx].barcode || '8901234567890';
    setPackingItems(newItems);
    setScanningIdx(null);
  };

  const updateItemBarcode = (itemIdx: number, barcode: string) => {
    const newItems = [...packingItems];
    newItems[itemIdx].barcode = barcode;
    setPackingItems(newItems);
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

  const validatePicking = (): boolean => {
    if (!packingItems || packingItems.length === 0) {
      alert("Error: No items found for picking. Please contact support.");
      return false;
    }
    
    let anyAllocated = false;
    for (const item of packingItems) {
      const totalAllocated = (item.batches || []).reduce((s, b) => s + (Number(b.quantity) || 0), 0);
      
      if (totalAllocated > 0) {
        anyAllocated = true;
        if (!item.barcode || item.barcode.trim() === '') {
          alert(`CRITICAL: Barcode is mandatory for allocated item: ${item.productName}`);
          return false;
        }
        if (item.batches) {
          // Fix: Corrected invalid loop syntax for destructuring and iteration using .entries()
          for (const [bIdx, batch] of item.batches.entries()) {
            if (batch.quantity > 0) {
              if (!batch.batch || batch.batch.trim() === '') {
                alert(`CRITICAL: Batch number missing for ${item.productName} (Line ${bIdx + 1})`);
                return false;
              }
              if (!batch.mfgDate) {
                alert(`CRITICAL: Mfg Date missing for batch ${batch.batch} (${item.productName})`);
                return false;
              }
              if (!batch.expDate) {
                alert(`CRITICAL: Expiry Date missing for batch ${batch.batch} (${item.productName})`);
                return false;
              }
            }
          }
        }
      }
    }

    if (!anyAllocated) {
      return window.confirm("NOTICE: You have allocated ZERO quantity for all items. Do you want to push this as a Shortage / Backorder mission?");
    }

    return true;
  };

  const handleAction = async (nextStatus: OrderStatus, extraData: Partial<Order> = {}) => {
    const isOutwardStage = order.status === OrderStatus.PENDING_PACKING || order.status === OrderStatus.BACKORDER || order.status === OrderStatus.PART_PACKED;
    
    // Intercept "Push to QC" transition
    if (isOutwardStage && (nextStatus === OrderStatus.PENDING_QC || nextStatus === OrderStatus.READY_FOR_BILLING)) {
      if (!validatePicking()) return;
      // Force status update to QC path
      nextStatus = OrderStatus.PENDING_QC; 
    }

    setIsUpdating(true);
    const timestamp = new Date().toISOString();
    
    let finalStatus = nextStatus;
    // Determine if it's a full or partial pack
    if (isOutwardStage && nextStatus === OrderStatus.PENDING_QC) {
      const isPartiallyFulfilled = packingItems.some(item => {
        const totalPacked = (item.batches || []).reduce((sum, b) => sum + Number(b.quantity || 0), 0);
        return totalPacked < item.quantity;
      });
      if (isPartiallyFulfilled) finalStatus = OrderStatus.PART_PACKED;
    }

    const updatedHistory = [...(order.statusHistory || []), { status: finalStatus, timestamp, userName: user.name }];
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
    onBack();
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

  const renderLogisticsTerminal = () => (
    <div className="space-y-8 animate-in slide-in-from-bottom-4">
      <div className="bg-amber-500 rounded-[40px] p-10 text-white shadow-2xl relative overflow-hidden border border-amber-600">
        <h4 className="text-3xl font-black flex items-center gap-3 tracking-tighter">
          <DollarSign size={32} /> 4. Logistics Surcharges
        </h4>
        <p className="text-sm text-amber-100 font-bold uppercase mt-2 tracking-widest italic">Calculate Cold-Chain & Freight Burden</p>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 p-8 shadow-sm space-y-8">
        {renderMetricsGrid()}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <LogisticsInput label="Thermacol Boxes (Qty)" value={logisticsData.thermacolBoxCount} onChange={v => setLogisticsData({...logisticsData, thermacolBoxCount: parseInt(v)||0})} />
          <LogisticsInput label="Dry Ice (KG)" value={logisticsData.dryIceKg} onChange={v => setLogisticsData({...logisticsData, dryIceKg: parseFloat(v)||0})} />
          <LogisticsInput label="WH to Station (₹)" value={logisticsData.whToStationAmount} onChange={v => setLogisticsData({...logisticsData, whToStationAmount: parseFloat(v)||0})} />
          <LogisticsInput label="Station to Loc (₹)" value={logisticsData.stationToLocAmount} onChange={v => setLogisticsData({...logisticsData, stationToLocAmount: parseFloat(v)||0})} />
          <LogisticsInput label="WH to Customer (₹)" value={logisticsData.whToCustAmount} onChange={v => setLogisticsData({...logisticsData, whToCustAmount: parseFloat(v)||0})} />
          <div className="space-y-2.5">
             <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Transit Mode</label>
             <select className="w-full bg-slate-50 border-2 border-slate-100 p-4 rounded-2xl font-black text-xs outline-none focus:border-indigo-600 transition-all" value={logisticsData.mode} onChange={e => setLogisticsData({...logisticsData, mode: e.target.value})}>
                <option value="Road">Road</option>
                <option value="Air">Air</option>
                <option value="Train">Train</option>
             </select>
          </div>
        </div>
        <button onClick={() => handleAction(OrderStatus.PENDING_LOGISTICS)} className="w-full bg-slate-900 text-white py-6 rounded-[28px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-600 transition-all flex items-center justify-center gap-3">
          Lock Costs & Send to Billing <ArrowRight size={20} />
        </button>
      </div>
    </div>
  );

  const renderInvoicingTerminal = () => (
    <div className="space-y-8 animate-in slide-in-from-bottom-4">
      <div className="bg-emerald-600 rounded-[40px] p-10 text-white shadow-2xl relative overflow-hidden border border-emerald-500">
        <h4 className="text-3xl font-black flex items-center gap-3 tracking-tighter">
          <Receipt size={32} /> 5. Billing & Invoicing
        </h4>
        <p className="text-sm text-emerald-100 font-bold uppercase mt-2 tracking-widest italic">Attach Tax Invoice and Close Mission</p>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 p-10 shadow-sm space-y-8 text-center">
         <div 
           onClick={() => invoiceFileRef.current?.click()}
           className={`aspect-video rounded-[40px] border-4 border-dashed transition-all flex flex-col items-center justify-center gap-6 cursor-pointer ${order.invoiceFile ? 'border-emerald-500 bg-emerald-50' : 'border-slate-100 bg-slate-50 hover:bg-indigo-50 hover:border-indigo-300'}`}
         >
            {order.invoiceFile ? (
               <>
                 <CheckCircle2 size={64} className="text-emerald-500" />
                 <div>
                    <p className="text-xl font-black text-slate-900 uppercase">Invoice Captured</p>
                    <p className="text-xs text-slate-500 font-bold uppercase mt-1">Ref: {order.invoiceNo}</p>
                 </div>
               </>
            ) : (
               <>
                 <FileUp size={64} className="text-slate-200" />
                 <div>
                    <p className="text-xl font-black text-slate-900 uppercase">Upload System Invoice</p>
                    <p className="text-xs text-slate-500 font-bold uppercase mt-1">Supports PDF, JPG, PNG</p>
                 </div>
               </>
            )}
            <input 
              type="file" 
              ref={invoiceFileRef} 
              className="hidden" 
              accept="image/*,.pdf" 
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) {
                  const reader = new FileReader();
                  reader.onloadend = () => {
                    handleAction(OrderStatus.READY_FOR_DISPATCH, {
                      invoiceFile: reader.result as string,
                      invoiceNo: `INV-${Math.floor(Math.random() * 90000 + 10000)}`
                    });
                  };
                  reader.readAsDataURL(file);
                }
              }} 
            />
         </div>
         <p className="text-[11px] font-bold text-slate-400 max-w-md mx-auto leading-relaxed italic">
            Once the invoice is attached, the mission will automatically be routed to the Logistics Hub for fleet loading.
         </p>
      </div>
    </div>
  );

  const renderOutwardTerminal = () => (
    <div className="space-y-6 animate-in slide-in-from-bottom-4">
      <div className="bg-emerald-900 rounded-[40px] p-8 text-white shadow-2xl flex flex-col md:flex-row md:items-center justify-between gap-6 border border-emerald-800">
        <div>
          <h4 className="text-xl font-black flex items-center gap-3"><Package className="text-emerald-400" size={24} /> 3. Batch Picking Terminal</h4>
          <p className="text-[10px] text-emerald-300/60 font-black uppercase mt-1 tracking-widest italic">Sourcing from: {order.warehouseSource || 'Standard Stock'}</p>
        </div>
        <div className="flex gap-4">
          <div className="bg-white/5 p-1 rounded-2xl flex items-center border border-white/10">
             <button onClick={() => setScanMode('AUTO')} className={`px-4 py-2 rounded-xl text-[9px] font-black uppercase tracking-widest transition-all flex items-center gap-2 ${scanMode === 'AUTO' ? 'bg-emerald-50 text-white shadow-lg' : 'text-emerald-300/40 hover:text-white'}`}>
                <Scan size={14}/> Auto-Scan
             </button>
             <button onClick={() => setScanMode('MANUAL')} className={`px-4 py-2 rounded-xl text-[9px] font-black uppercase tracking-widest transition-all flex items-center gap-2 ${scanMode === 'MANUAL' ? 'bg-emerald-50 text-white shadow-lg' : 'text-emerald-300/40 hover:text-white'}`}>
                <MousePointer2 size={14}/> Manual
             </button>
          </div>
          <div className="bg-white/5 p-4 rounded-[24px] border border-white/10 flex items-center gap-3 px-6 shadow-inner">
             <Box size={14} className="text-emerald-400" />
             <input type="number" value={packedBoxes} onChange={(e) => setPackedBoxes(Number(e.target.value))} className="w-16 bg-transparent border-b border-emerald-500/30 text-lg font-black outline-none text-center text-white" />
             <span className="text-xs font-bold text-emerald-300/60">Load Units</span>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left min-w-[1200px]">
            <thead>
              <tr className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                <th className="px-8 py-4">Item Identity / Barcode</th>
                <th className="px-6 py-4 text-center">Ordered Qty</th>
                <th className="px-6 py-4 text-center text-emerald-600">Allocated Qty</th>
                <th className="px-8 py-4">Batch Details</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {packingItems.map((item, itemIdx) => {
                const totalPacked = (item.batches || []).reduce((sum, b) => sum + Number(b.quantity || 0), 0);
                const isScanning = scanningIdx === itemIdx;

                return (
                  <tr key={itemIdx} className="hover:bg-slate-50 transition-colors">
                    <td className="px-8 py-8 align-top">
                      <p className="font-black text-slate-900 text-sm leading-tight">{item.productName}</p>
                      <p className="text-[10px] text-slate-400 font-bold uppercase mt-1 mb-3">{item.skuCode}</p>
                      {scanMode === 'AUTO' ? (
                        <button onClick={() => simulateScan(itemIdx)} disabled={!!item.barcode} className={`w-full p-4 rounded-2xl border-2 border-dashed flex items-center justify-center gap-3 transition-all ${item.barcode ? 'bg-emerald-50 border-emerald-200 text-emerald-600' : 'bg-slate-50 border-slate-200 text-slate-400 hover:border-emerald-500 hover:bg-white hover:text-emerald-600'}`}>
                          {isScanning ? <div className="w-5 h-5 border-2 border-emerald-600 border-t-transparent rounded-full animate-spin" /> : item.barcode ? <><CheckCircle size={16} /> {item.barcode}</> : <><Scan size={16} /> Tap to Scan SKU</>}
                        </button>
                      ) : (
                        <div className="flex items-center gap-2 bg-slate-100 p-3 rounded-xl border border-slate-200 shadow-inner">
                           <Scan size={14} className="text-indigo-600" />
                           <input className="bg-transparent text-[11px] font-black outline-none w-full placeholder:text-slate-300" placeholder="TYPE BARCODE" value={item.barcode || ''} onChange={(e) => updateItemBarcode(itemIdx, e.target.value)} />
                        </div>
                      )}
                    </td>
                    <td className="px-6 py-8 text-center align-top font-black text-slate-400">{item.quantity} {item.unit}</td>
                    <td className="px-6 py-8 text-center align-top font-black text-emerald-600">{totalPacked} {item.unit}</td>
                    <td className="px-8 py-8 space-y-4">
                      {(item.batches || []).map((batch, bIdx) => (
                        <div key={bIdx} className="grid grid-cols-5 gap-2 p-2 bg-slate-100/50 border border-slate-200 rounded-2xl shadow-inner group/batch">
                          <input className="bg-white px-3 py-2 text-[10px] font-black rounded-xl w-full border border-slate-200 outline-none uppercase" placeholder="BATCH" value={batch.batch} onChange={e => updateBatchEntry(itemIdx, bIdx, 'batch', e.target.value)} />
                          <input type="date" className="bg-white px-3 py-2 text-[10px] font-black rounded-xl w-full border border-slate-200 outline-none" value={batch.mfgDate} onChange={e => updateBatchEntry(itemIdx, bIdx, 'mfgDate', e.target.value)} />
                          <input type="date" className="bg-white px-3 py-2 text-[10px] font-black rounded-xl w-full border border-slate-200 outline-none" value={batch.expDate} onChange={e => updateBatchEntry(itemIdx, bIdx, 'expDate', e.target.value)} />
                          <input type="number" className="bg-white px-3 py-2 text-[10px] font-black rounded-xl w-full border border-slate-200 outline-none text-center" placeholder="QTY" value={batch.quantity || ''} onChange={e => updateBatchEntry(itemIdx, bIdx, 'quantity', Number(e.target.value))} />
                          <button onClick={() => removeBatchLine(itemIdx, bIdx)} className="p-2 text-slate-300 hover:text-rose-500 transition-all opacity-0 group-hover/batch:opacity-100"><Trash2 size={14}/></button>
                        </div>
                      ))}
                      <button onClick={() => addBatchLine(itemIdx)} disabled={totalPacked >= item.quantity} className="flex items-center gap-2 text-[9px] font-black text-emerald-600 uppercase tracking-widest px-4 py-2 rounded-xl hover:bg-emerald-50 transition-all border border-dashed border-emerald-200 w-full justify-center">
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
           <div className="text-left">
              <p className="text-[10px] font-black text-emerald-500 uppercase tracking-widest">Aggregate Picking Value</p>
              <p className="text-4xl font-black text-white tracking-tighter">₹{outwardSummary.packedValue.toLocaleString()}</p>
           </div>
           <button onClick={() => handleAction(OrderStatus.PENDING_QC)} className="px-20 py-7 bg-emerald-500 text-white rounded-[32px] font-black text-xs uppercase tracking-[0.25em] shadow-2xl hover:bg-emerald-400 active:scale-95 flex items-center gap-4">
              Push to Quality Control <ArrowRight size={18} />
           </button>
        </div>
      </div>
    </div>
  );

  const renderEditTerminal = () => (
    <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm p-10 space-y-8 animate-in slide-in-from-bottom-4">
      <div className="flex items-center justify-between border-b pb-6">
        <h4 className="text-xl font-black text-slate-900 uppercase tracking-tight flex items-center gap-3"><Pencil size={20} className="text-indigo-600"/> Edit Supply Mission</h4>
        <button onClick={() => setIsEditingOrder(false)} className="text-slate-400 hover:text-rose-500 transition-colors"><X size={24}/></button>
      </div>

      <div className="space-y-6">
        <div className="overflow-x-auto rounded-[32px] border border-slate-100 shadow-inner bg-slate-50/30">
          <table className="w-full text-left">
            <thead className="bg-white text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
              <tr>
                <th className="px-6 py-4 w-[40%]">Product / SKU</th>
                <th className="px-6 py-4 text-center">Qty</th>
                <th className="px-6 py-4 text-center">Unit</th>
                <th className="px-6 py-4 text-right">Applied Rate</th>
                <th className="px-6 py-4 text-right">Total</th>
                <th className="px-6 py-4"></th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {editedItems.map((item, idx) => (
                <tr key={idx} className="hover:bg-white transition-colors">
                  <td className="px-6 py-4">
                    <select 
                      className="w-full bg-transparent border-b-2 border-slate-200 focus:border-indigo-600 outline-none font-bold text-sm"
                      value={item.productId}
                      onChange={e => updateEditItem(idx, 'productId', e.target.value)}
                    >
                      {products.map(p => <option key={p.id} value={p.id}>{p.skuCode} - {p.name}</option>)}
                    </select>
                  </td>
                  <td className="px-6 py-4 text-center">
                    <input type="number" className="w-20 bg-transparent border-b-2 border-slate-200 focus:border-indigo-600 outline-none font-black text-center" value={item.quantity} onChange={e => updateEditItem(idx, 'quantity', parseFloat(e.target.value) || 0)} />
                  </td>
                  <td className="px-6 py-4 text-center uppercase text-slate-400 text-xs font-black">{item.unit}</td>
                  <td className="px-6 py-4 text-right">
                    <input type="number" className="w-24 bg-transparent border-b-2 border-slate-200 focus:border-indigo-600 outline-none font-black text-right" value={item.price} onChange={e => updateEditItem(idx, 'price', parseFloat(e.target.value) || 0)} />
                  </td>
                  <td className="px-6 py-4 text-right font-black">₹{(item.quantity * item.price).toLocaleString()}</td>
                  <td className="px-6 py-4 text-right">
                    <button onClick={() => setEditedItems(editedItems.filter((_, i) => i !== idx))} className="text-slate-300 hover:text-rose-500"><Trash2 size={16}/></button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <button onClick={addEditItem} className="w-full py-4 border-2 border-dashed border-slate-200 rounded-2xl text-[10px] font-black uppercase text-slate-400 hover:border-indigo-500 hover:text-indigo-600 transition-all flex items-center justify-center gap-2">
           <Plus size={14}/> Add New Item Line
        </button>
      </div>

      <div className="pt-8 border-t flex justify-between items-center">
        <div>
           <p className="text-[10px] font-black text-slate-400 uppercase">Revised Valuation</p>
           <p className="text-4xl font-black text-slate-900 tracking-tighter">₹{editedItems.reduce((s,i) => s + (i.quantity * i.price), 0).toLocaleString()}</p>
        </div>
        <div className="flex gap-4">
           <button onClick={() => setIsEditingOrder(false)} className="px-8 py-5 text-[10px] font-black uppercase text-slate-400">Discard Changes</button>
           <button onClick={handleSaveEdits} className="px-12 py-5 bg-indigo-600 text-white rounded-3xl font-black text-xs uppercase tracking-widest shadow-xl hover:bg-indigo-500 active:scale-95 transition-all flex items-center gap-3">
              <Save size={18}/> Commit & Resubmit for Approval
           </button>
        </div>
      </div>
    </div>
  );

  const renderCreditControlTerminal = () => {
    const criticalOverdue = overdueBuckets.slice(2).some(bucket => (customer.agingBuckets?.[bucket] || 0) > 0);

    return (
      <div className="space-y-8 animate-in slide-in-from-bottom-4">
        <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl relative overflow-hidden border border-slate-800">
          <div className="absolute top-0 right-0 p-10 opacity-10 pointer-events-none text-indigo-400">
            <ShieldCheck size={200} />
          </div>
          <div className="relative z-10 flex justify-between items-center">
            <div>
              <h4 className="text-3xl font-black flex items-center gap-3 tracking-tighter">
                <Zap className="text-amber-400" size={32} /> 2. Credit Exposure Matrix
              </h4>
              <p className="text-sm text-slate-400 font-bold uppercase mt-2 tracking-widest">Financial Health Review for {customer.name}</p>
            </div>
            {canEdit && !isEditingOrder && (
               <div className="flex gap-3">
                  <button onClick={() => setIsEditingOrder(true)} className="px-6 py-3 bg-white/10 hover:bg-white/20 border border-white/10 rounded-2xl text-[10px] font-black uppercase tracking-widest flex items-center gap-2 transition-all">
                     <Pencil size={14} className="text-indigo-400"/> Edit Order
                  </button>
                  {canCancel && (
                    <button onClick={handleCancelOrder} className="px-6 py-3 bg-rose-500/10 hover:bg-rose-500/20 border border-rose-500/20 rounded-2xl text-[10px] font-black uppercase tracking-widest flex items-center gap-2 text-rose-400 transition-all">
                       <Ban size={14}/> Cancel Order
                    </button>
                  )}
               </div>
            )}
          </div>
        </div>

        {isEditingOrder ? renderEditTerminal() : (
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

            <div className="overflow-x-auto rounded-3xl border border-slate-200 shadow-xl shadow-slate-200/50">
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
                 {(user.role === UserRole.APPROVER || user.role === UserRole.FINANCE || user.role === UserRole.ADMIN) && (
                   <>
                    <button onClick={() => handleAction(OrderStatus.PENDING_WH_SELECTION)} className="w-full bg-emerald-600 text-white py-5 rounded-[24px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-emerald-500 transition-all flex items-center justify-center gap-3"><CheckCircle size={20} /> Approve Order</button>
                    <button onClick={() => handleAction(OrderStatus.ON_HOLD, { rejectionReason })} className="w-full bg-amber-500 text-white py-5 rounded-[24px] font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-amber-400 transition-all flex items-center justify-center gap-3"><PauseCircle size={20} /> Place on Hold</button>
                    <button onClick={() => handleAction(OrderStatus.REJECTED, { rejectionReason })} className="w-full bg-white border-2 border-rose-100 text-rose-600 py-5 rounded-[24px] font-black text-xs uppercase tracking-[0.2em] hover:bg-rose-50 transition-all flex items-center justify-center gap-3"><XCircle size={20} /> Reject Order</button>
                   </>
                 )}
              </div>
            </div>
          </div>
        )}
      </div>
    );
  };

  const overdueBuckets: (keyof AgingBuckets)[] = [
    '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90', '90 to 120', '120 to 150', '150 to 180', '>180'
  ];

  return (
    <div className="max-w-7xl mx-auto space-y-10 pb-20 animate-in fade-in duration-500">
       <div className="flex items-center justify-between">
          <button onClick={onBack} className="flex items-center gap-3 text-slate-400 hover:text-emerald-600 font-black text-[11px] uppercase tracking-[0.2em] group transition-all"><ArrowLeft size={16} className="group-hover:-translate-x-1" /> Return to Queue</button>
          {!isEditingOrder && (
             <div className="flex gap-2">
                {canEdit && (
                  <button onClick={() => setIsEditingOrder(true)} className="px-6 py-3 bg-white border border-slate-200 rounded-2xl text-[10px] font-black uppercase tracking-widest flex items-center gap-2 hover:bg-slate-50 transition-all shadow-sm">
                     <Pencil size={14}/> Edit
                  </button>
                )}
                {canCancel && (
                  <button onClick={handleCancelOrder} className="px-6 py-3 bg-white border border-rose-200 rounded-2xl text-[10px] font-black uppercase tracking-widest flex items-center gap-2 text-rose-500 hover:bg-rose-50 transition-all shadow-sm">
                     <Ban size={14}/> Cancel
                  </button>
                )}
             </div>
          )}
       </div>

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
             {order.poAttachment && (
                <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden p-8 animate-in slide-in-from-top-4">
                   <div className="flex items-center justify-between mb-6">
                      <div className="flex items-center gap-3">
                         <FileText className="text-emerald-50" size={20}/>
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
             ) : (order.status === OrderStatus.REJECTED && (isSalesManager || isAdmin)) ? (
                <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden p-10 space-y-8 animate-in slide-in-from-bottom-4">
                   <div className="bg-rose-50 p-8 rounded-3xl border border-rose-100 text-rose-700 flex justify-between items-center">
                      <div>
                         <h4 className="text-lg font-black flex items-center gap-3 uppercase"><AlertCircle /> Mission Alert</h4>
                         <p className="text-sm font-medium mt-2 leading-relaxed opacity-80">Reason: {order.rejectionReason || 'No specific reason provided.'}</p>
                      </div>
                      <div className="flex gap-2">
                         {canEdit && (
                           <button onClick={() => setIsEditingOrder(true)} className="px-6 py-3 bg-white/20 hover:bg-white/40 rounded-2xl text-[10px] font-black uppercase flex items-center gap-2 border border-rose-200 transition-all shadow-sm">
                              <Pencil size={14}/> Edit Order
                           </button>
                         )}
                      </div>
                   </div>

                   {isEditingOrder ? renderEditTerminal() : (
                     <div className="space-y-8">
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
                   )}
                </div>
             ) : order.status === OrderStatus.PENDING_PACKING || order.status === OrderStatus.BACKORDER || order.status === OrderStatus.PART_PACKED ? (
                <div className="space-y-10">
                   {isEditingOrder && renderEditTerminal()}
                   {!isEditingOrder && renderOutwardTerminal()}
                </div>
             ) : (order.status === OrderStatus.READY_FOR_BILLING) ? (
                <div className="space-y-10">
                   {isEditingOrder && renderEditTerminal()}
                   {!isEditingOrder && renderLogisticsTerminal()}
                </div>
             ) : order.status === OrderStatus.PENDING_LOGISTICS ? (
                <div className="space-y-10">
                   {isEditingOrder && renderEditTerminal()}
                   {!isEditingOrder && renderInvoicingTerminal()}
                </div>
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
                {isEditingOrder && renderEditTerminal()}
                {!isEditingOrder && (
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
                )}
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
                <div className="flex items-center justify-between mb-10 border-b pb-4">
                   <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Mission Workflow Trace</h4>
                   <button 
                     onClick={() => setShowHistoryModal(true)}
                     className="text-[10px] font-black text-indigo-600 uppercase tracking-widest flex items-center gap-2 hover:text-indigo-700 transition-colors"
                   >
                     <HistoryIcon size={14} /> View Full Log
                   </button>
                </div>
                <div className="space-y-12 pl-2">
                  {[
                    OrderStatus.PENDING_CREDIT_APPROVAL, 
                    OrderStatus.ON_HOLD, 
                    OrderStatus.PENDING_WH_SELECTION, 
                    OrderStatus.PENDING_PACKING, 
                    OrderStatus.PART_PACKED,
                    OrderStatus.PENDING_QC, 
                    OrderStatus.READY_FOR_BILLING, 
                    OrderStatus.PENDING_LOGISTICS, 
                    OrderStatus.READY_FOR_DISPATCH,
                    OrderStatus.DISPATCHED,
                    OrderStatus.DELIVERED,
                    ...(order.status === OrderStatus.REJECTED ? [OrderStatus.REJECTED] : []),
                    ...(order.status === OrderStatus.CANCELLED ? [OrderStatus.CANCELLED] : [])
                  ].map((s, i) => {
                    const isCompleted = (order.statusHistory || []).some(h => h.status === s);
                    const isCurrent = order.status === s;
                    const isNegative = s === OrderStatus.REJECTED || s === OrderStatus.CANCELLED;
                    
                    return (
                      <div key={i} className={`flex items-center gap-6 ${isCompleted ? (isNegative ? 'text-rose-600' : 'text-emerald-600') : isCurrent ? 'text-indigo-600' : 'text-slate-300'}`}>
                        <div className={`w-10 h-10 rounded-2xl flex items-center justify-center border-2 transition-all ${
                          isCompleted ? (isNegative ? 'bg-rose-50 border-rose-100 shadow-sm' : 'bg-emerald-50 border-emerald-100 shadow-sm') : 
                          isCurrent ? 'bg-indigo-50 border-indigo-100 shadow-md scale-110' : 
                          'bg-slate-50 border-slate-100'
                        }`}>
                          {isCompleted ? (isNegative ? <XCircle size={18} /> : <CheckCircle size={18} />) : isCurrent ? <Zap size={18} className="animate-pulse" /> : <div className="w-2 h-2 rounded-full bg-slate-200" />}
                        </div>
                        <div className="flex flex-col">
                          <span className={`text-[10px] font-black uppercase tracking-[0.15em] ${isCurrent ? 'text-slate-900' : ''}`}>{s}</span>
                          {isCurrent && <span className={`text-[8px] font-bold uppercase tracking-widest mt-0.5 ${isNegative ? 'text-rose-400' : 'text-indigo-400'}`}>Active Stage</span>}
                        </div>
                      </div>
                    );
                  })}
                </div>
             </div>
          </div>
       </div>

       {showHistoryModal && (
         <StatusHistoryModal 
           order={order} 
           onClose={() => setShowHistoryModal(false)} 
         />
       )}
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
