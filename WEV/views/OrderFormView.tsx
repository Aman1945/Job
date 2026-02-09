
import React, { useState, useEffect, useRef } from 'react';
import { Customer, Product, Order, OrderStatus, User, AgingBuckets, OrderItem } from '../types';
import { 
  Plus, 
  Trash2, 
  Save, 
  ShoppingBag, 
  AlertCircle, 
  CreditCard, 
  Clock, 
  FileText, 
  ShieldCheck, 
  ShieldAlert,
  ChevronDown,
  Info,
  Search,
  MessageSquareText,
  History,
  Tag,
  Zap,
  FileUp,
  X
} from 'lucide-react';

interface OrderFormViewProps {
  customers: Customer[];
  products: Product[];
  currentUser: User;
  allOrders: Order[]; 
  onSubmit: (order: Order) => void;
}

const OrderFormView: React.FC<OrderFormViewProps> = ({ customers, products, currentUser, allOrders, onSubmit }) => {
  const [selectedCustId, setSelectedCustId] = useState('');
  const [salespersonId, setSalespersonId] = useState(currentUser.id);
  const [items, setItems] = useState<{ 
    productId: string; 
    quantity: number; 
    appliedRate: number | string; 
    remarks: string;
    unit: 'PCS' | 'KG';
  }[]>([]);
  const [generalRemarks, setGeneralRemarks] = useState('');
  const [poAttachment, setPoAttachment] = useState<string | null>(null);
  const [poFileName, setPoFileName] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const selectedCustomer = customers.find(c => c.id === selectedCustId);

  useEffect(() => {
    if (selectedCustomer?.assignedSalespersonId) {
      setSalespersonId(selectedCustomer.assignedSalespersonId);
    } else {
      setSalespersonId(currentUser.id);
    }
  }, [selectedCustId, selectedCustomer]);

  const getPreviousRate = (prodId: string) => {
    if (!selectedCustId) return 0;
    const pastOrders = allOrders
      .filter(o => o.customerId === selectedCustId)
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
    
    for (const order of pastOrders) {
      const item = order.items.find(i => i.productId === prodId);
      if (item) return item.price;
    }
    return 0;
  };

  const addItem = () => {
    const firstProduct = products[0];
    const prevRate = getPreviousRate(firstProduct.id);
    setItems([...items, { 
      productId: firstProduct.id, 
      quantity: 1, 
      appliedRate: prevRate || firstProduct.price,
      unit: firstProduct.unit,
      remarks: '' 
    }]);
  };

  const removeItem = (index: number) => {
    setItems(items.filter((_, i) => i !== index));
  };

  const updateItem = (index: number, field: string, value: any) => {
    const newItems = [...items];
    (newItems[index] as any)[field] = value;
    
    if (field === 'productId') {
      const p = products.find(prod => prod.id === value);
      if (p) {
        newItems[index].appliedRate = getPreviousRate(p.id) || p.price;
        newItems[index].unit = p.unit;
      }
    }
    
    setItems(newItems);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPoAttachment(reader.result as string);
        setPoFileName(file.name);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCustId || items.length === 0) return;

    const timestamp = new Date().toISOString();
    const newOrder: Order = {
      id: 'ORD-' + Math.floor(Math.random() * 90000 + 10000),
      customerId: selectedCustId,
      customerName: selectedCustomer!.name,
      items: items.map(item => {
        const p = products.find(p => p.id === item.productId)!;
        return {
          productId: p.id,
          productName: p.name,
          skuCode: p.skuCode,
          quantity: item.quantity,
          unit: item.unit,
          price: parseFloat(item.appliedRate.toString()) || p.price,
          baseRate: p.baseRate,
          previousRate: getPreviousRate(p.id),
          remarks: item.remarks,
          barcode: p.barcode
        };
      }),
      status: OrderStatus.PENDING_CREDIT_APPROVAL,
      statusHistory: [{ status: OrderStatus.PENDING_CREDIT_APPROVAL, timestamp }],
      createdAt: timestamp,
      salespersonId: salespersonId,
      generalRemarks: generalRemarks,
      poAttachment: poAttachment || undefined,
      poFileName: poFileName || undefined
    };

    onSubmit(newOrder);
  };

  const overdueBuckets: (keyof AgingBuckets)[] = [
    '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90', '90 to 120', '120 to 150', '150 to 180', '>180'
  ];

  const hasHighRisk = selectedCustomer && selectedCustomer.overdue > 0;

  return (
    <div className="max-w-7xl mx-auto pb-20 animate-in fade-in duration-500 space-y-8">
      
      {/* 1. Customer Selection & Credit Exposure */}
      <div className="bg-white rounded-[40px] border shadow-sm overflow-hidden border-slate-200">
        <div className="p-10 border-b bg-slate-50/50 flex items-center justify-between">
          <div>
            <h3 className="text-3xl font-black text-slate-900 tracking-tighter">1. Supply Requisition</h3>
            <p className="text-sm text-slate-500 font-medium tracking-tight">Enter Customer Details & Check Exposure</p>
          </div>
          <div className="w-14 h-14 bg-indigo-600 rounded-3xl flex items-center justify-center text-white shadow-xl">
            <ShoppingBag size={28} />
          </div>
        </div>

        <div className="p-10 space-y-10">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-end">
            <div className="space-y-3">
              <label className="block text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Customer Selection</label>
              <div className="relative">
                <select 
                  className="w-full border-2 border-slate-100 rounded-2xl px-6 py-4 focus:border-indigo-600 bg-white transition-all outline-none text-sm font-bold appearance-none"
                  value={selectedCustId}
                  onChange={(e) => setSelectedCustId(e.target.value)}
                  required
                >
                  <option value="">Search Organization Client Base...</option>
                  {customers.map(c => (
                    <option key={c.id} value={c.id}>{c.name} ({c.type})</option>
                  ))}
                </select>
                <ChevronDown className="absolute right-6 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" size={18} />
              </div>
            </div>

            {selectedCustomer && (
              <div className={`p-4 rounded-2xl border-2 flex items-center gap-4 animate-in slide-in-from-right-4 ${hasHighRisk ? 'bg-rose-50 border-rose-100 text-rose-700' : 'bg-emerald-50 border-emerald-100 text-emerald-700'}`}>
                 {hasHighRisk ? <ShieldAlert size={24} /> : <ShieldCheck size={24} />}
                 <div>
                    <p className="text-[10px] font-black uppercase tracking-widest">Financial Health Check</p>
                    <p className="text-sm font-black uppercase">{hasHighRisk ? 'Credit Limit Alert' : 'Healthy Standing'}</p>
                 </div>
              </div>
            )}
          </div>

          {selectedCustomer && (
            <div className="animate-in fade-in slide-in-from-bottom-4 space-y-6 pt-6 border-t border-slate-100">
              <h4 className="text-xs font-black text-slate-400 uppercase tracking-widest flex items-center gap-2">
                <Zap size={14} className="text-amber-500" /> Credit Exposure Table
              </h4>
              <div className="overflow-x-auto rounded-3xl border border-slate-200">
                <table className="w-full text-left text-[11px]">
                  <thead>
                    <tr className="bg-slate-900 text-white">
                      <th className="px-4 py-4 border-r border-slate-700">Limit</th>
                      <th className="px-4 py-4 border-r border-slate-700">O/s Balance</th>
                      <th className="px-4 py-4 border-r border-slate-700 text-rose-300">Overdue</th>
                      {overdueBuckets.map(bucket => (
                        <th key={bucket} className="px-4 py-4 text-center border-r border-slate-700 font-normal">
                          {bucket}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody className="bg-white font-bold text-slate-700">
                    <tr>
                      <td className="px-4 py-4 border-r border-slate-100">₹{selectedCustomer.creditLimit.toLocaleString()}</td>
                      <td className="px-4 py-4 border-r border-slate-100">₹{selectedCustomer.outstanding.toLocaleString()}</td>
                      <td className="px-4 py-4 border-r border-slate-100 text-rose-600 bg-rose-50/20">₹{selectedCustomer.overdue.toLocaleString()}</td>
                      {overdueBuckets.map(bucket => (
                        <td key={bucket} className={`px-4 py-4 border-r border-slate-100 text-center ${selectedCustomer.agingBuckets?.[bucket] > 0 ? 'text-rose-600 bg-rose-50/10' : 'text-slate-300'}`}>
                          {selectedCustomer.agingBuckets?.[bucket] > 0 ? `₹${selectedCustomer.agingBuckets[bucket].toLocaleString()}` : '-'}
                        </td>
                      ))}
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* 2. Item Entry Terminal */}
      <div className="bg-white rounded-[40px] border shadow-sm overflow-hidden border-slate-200 p-10">
        <form onSubmit={handleSubmit} className="space-y-12">
          <section className="space-y-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-1.5 h-6 bg-indigo-600 rounded-full" />
                <h4 className="text-xs font-black text-slate-400 uppercase tracking-widest">SKU Selection & Pricing Hub</h4>
              </div>
              <button 
                type="button" 
                onClick={addItem}
                className="bg-indigo-600 text-white px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-indigo-700 transition-all flex items-center gap-2 shadow-lg shadow-indigo-600/20"
              >
                <Plus size={14} /> Add Line Item
              </button>
            </div>

            <div className="bg-white rounded-[32px] border border-slate-200 overflow-hidden shadow-sm">
              <table className="w-full text-left">
                <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b border-slate-100">
                  <tr>
                    <th className="px-6 py-5 w-[30%]">Product / SKU</th>
                    <th className="px-4 py-5 text-center">Unit</th>
                    <th className="px-4 py-5 text-center text-slate-500">Base Rate</th>
                    <th className="px-4 py-5 text-center">Prev. Rate</th>
                    <th className="px-4 py-5 text-center">Qty</th>
                    <th className="px-4 py-5 text-center w-[15%]">Final Rate</th>
                    <th className="px-6 py-5 w-12"></th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-50">
                  {items.map((item, index) => {
                    const prod = products.find(p => p.id === item.productId);
                    const prevRate = getPreviousRate(item.productId);
                    return (
                      <tr key={index} className="hover:bg-slate-50/50 transition-colors group">
                        <td className="px-6 py-5">
                          <select 
                            className="w-full border-2 border-slate-100 rounded-xl px-4 py-3 text-sm font-bold bg-white focus:border-indigo-500 outline-none"
                            value={item.productId}
                            onChange={(e) => updateItem(index, 'productId', e.target.value)}
                          >
                            {products.map(p => (
                              <option key={p.id} value={p.id}>{p.skuCode} - {p.name}</option>
                            ))}
                          </select>
                        </td>
                        <td className="px-4 py-5 text-center">
                          <select 
                             className="border-2 border-slate-100 rounded-lg px-2 py-1 text-[10px] font-black bg-slate-50 focus:border-indigo-500 outline-none uppercase"
                             value={item.unit}
                             onChange={(e) => updateItem(index, 'unit', e.target.value)}
                          >
                             <option value="PCS">PCS</option>
                             <option value="KG">KG</option>
                          </select>
                        </td>
                        <td className="px-4 py-5 text-center">
                          <span className="text-xs font-black text-slate-300 italic">₹{prod?.baseRate || 0}</span>
                        </td>
                        <td className="px-4 py-5 text-center">
                          <span className={`text-xs font-black flex items-center justify-center gap-1 ${prevRate ? 'text-indigo-600' : 'text-slate-300'}`}>
                             <History size={12}/> ₹{prevRate || 0}
                          </span>
                        </td>
                        <td className="px-4 py-5 text-center">
                           <input 
                              type="number"
                              className="w-20 border-2 border-slate-100 rounded-xl px-2 py-2.5 text-sm font-black focus:border-indigo-500 outline-none text-center"
                              value={item.quantity}
                              onChange={(e) => updateItem(index, 'quantity', parseFloat(e.target.value) || 0)}
                            />
                        </td>
                        <td className="px-4 py-5 text-center">
                          <input 
                            type="number"
                            className={`w-full border-2 rounded-xl px-3 py-2.5 text-sm font-black text-center ${parseFloat(item.appliedRate.toString()) < (prod?.baseRate || 0) ? 'border-amber-200 bg-amber-50' : 'border-slate-100'}`}
                            value={item.appliedRate}
                            onChange={(e) => updateItem(index, 'appliedRate', e.target.value)}
                          />
                        </td>
                        <td className="px-6 py-5 text-right">
                           <button type="button" onClick={() => removeItem(index)} className="p-2 text-slate-300 hover:text-rose-500 transition-all"><Trash2 size={18} /></button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
              {items.length === 0 && (
                <div className="py-24 text-center text-slate-300 uppercase font-black text-xs italic tracking-widest">Entry Database Empty. Add Items.</div>
              )}
            </div>
          </section>

          {/* PO / PDC Attachment Section */}
          <section className="space-y-6 pt-10 border-t border-slate-100">
             <div className="flex items-center gap-3">
                <div className="w-1.5 h-6 bg-emerald-500 rounded-full" />
                <h4 className="text-xs font-black text-slate-400 uppercase tracking-widest">Documentation (PO / PDC Copy)</h4>
             </div>
             <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-4">
                   <label className="block text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Upload Scanned Document</label>
                   <div 
                     onClick={() => fileInputRef.current?.click()}
                     className="group cursor-pointer aspect-video md:aspect-[3/1] bg-slate-50 rounded-[32px] border-4 border-dashed border-slate-200 flex flex-col items-center justify-center gap-4 hover:bg-emerald-50 hover:border-emerald-200 transition-all relative overflow-hidden"
                   >
                     {poAttachment ? (
                        <>
                          <img src={poAttachment} className="absolute inset-0 w-full h-full object-contain p-4" alt="PO Preview" />
                          <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm flex flex-col items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                             <FileUp className="text-white mb-2" size={32} />
                             <p className="text-[10px] font-black text-white uppercase tracking-widest">Replace Document</p>
                             <p className="text-[8px] text-white/60 truncate max-w-[200px] mt-1">{poFileName}</p>
                          </div>
                          <button 
                            type="button"
                            onClick={(e) => { e.stopPropagation(); setPoAttachment(null); setPoFileName(null); }}
                            className="absolute top-4 right-4 p-2 bg-rose-500 text-white rounded-full hover:bg-rose-600 transition-all shadow-lg"
                          >
                             <X size={16} />
                          </button>
                        </>
                     ) : (
                        <>
                          <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center text-slate-400 shadow-sm group-hover:text-emerald-600 transition-all">
                             <FileUp size={24} />
                          </div>
                          <div className="text-center">
                             <p className="text-xs font-black text-slate-600 uppercase tracking-widest">Attach PO or PDC Snapshot</p>
                             <p className="text-[10px] text-slate-400 mt-1 font-medium italic">Supports JPG, PNG, PDF</p>
                          </div>
                        </>
                     )}
                   </div>
                   <input 
                     type="file" 
                     ref={fileInputRef} 
                     className="hidden" 
                     onChange={handleFileChange} 
                     accept="image/*,.pdf" 
                   />
                </div>
                <div className="space-y-4">
                   <label className="block text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Internal Instructions / Remarks</label>
                   <textarea 
                     className="w-full h-full min-h-[140px] bg-slate-50 border-2 border-slate-100 rounded-[32px] p-6 text-sm font-bold focus:border-indigo-600 outline-none transition-all resize-none"
                     placeholder="Mention any special billing or delivery notes..."
                     value={generalRemarks}
                     onChange={(e) => setGeneralRemarks(e.target.value)}
                   />
                </div>
             </div>
          </section>

          <div className="pt-10 border-t flex flex-col md:flex-row justify-between items-center gap-8">
            <div className="text-left">
              <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Aggregate Value</p>
              <p className="text-5xl font-black text-slate-900 tracking-tighter">
                ₹{items.reduce((sum, item) => sum + ( (parseFloat(item.appliedRate.toString()) || 0) * item.quantity), 0).toLocaleString()}
              </p>
            </div>
            <button 
              type="submit"
              disabled={items.length === 0 || !selectedCustId}
              className="w-full md:w-auto bg-slate-900 text-white px-16 py-7 rounded-[32px] font-black text-sm uppercase tracking-[0.2em] hover:bg-indigo-600 transition-all shadow-2xl flex items-center justify-center gap-3 active:scale-95 disabled:opacity-30"
            >
              <Save size={20} /> Commit Supply Request
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default OrderFormView;
