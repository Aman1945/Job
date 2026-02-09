
import React, { useState } from 'react';
import { Product, Order, OrderStatus, User, OrderItem } from '../types';
import { 
  ArrowRight, 
  Plus, 
  Trash2, 
  Save, 
  RefreshCcw, 
  Warehouse,
  Package,
  AlertCircle
} from 'lucide-react';

interface STNBookingViewProps {
  products: Product[];
  currentUser: User;
  onSubmit: (stn: Order) => void;
}

const WAREHOUSES = [
  'IOPL Kurla',
  'IOPL DP WORLD',
  'IOPL Arihant Delhi',
  'IOPL Jolly Bng'
];

const STNBookingView: React.FC<STNBookingViewProps> = ({ products, currentUser, onSubmit }) => {
  const [fromWH, setFromWH] = useState('');
  const [toWH, setToWH] = useState('');
  const [items, setItems] = useState<{ 
    productId: string; 
    quantity: number; 
    unit: 'PCS' | 'KG';
  }[]>([]);
  const [remarks, setRemarks] = useState('');

  const addItem = () => {
    const firstProduct = products[0];
    setItems([...items, { 
      productId: firstProduct.id, 
      quantity: 1, 
      unit: firstProduct.unit 
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
        newItems[index].unit = p.unit;
      }
    }
    setItems(newItems);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!fromWH || !toWH || items.length === 0) return;
    if (fromWH === toWH) {
      alert("Source and Destination warehouses cannot be the same.");
      return;
    }

    const timestamp = new Date().toISOString();
    const newSTN: Order = {
      id: 'STN-' + Math.floor(Math.random() * 90000 + 10000),
      customerId: 'INTERNAL-TRANSFER',
      customerName: `STN: ${fromWH} → ${toWH}`,
      isSTN: true,
      fromWarehouse: fromWH,
      toWarehouse: toWH,
      warehouseSource: fromWH as any, // Initialize the source
      items: items.map(item => {
        const p = products.find(p => p.id === item.productId)!;
        return {
          productId: p.id,
          productName: p.name,
          skuCode: p.skuCode,
          quantity: item.quantity,
          unit: item.unit,
          price: p.baseRate, // For internal accounting reference
          baseRate: p.baseRate,
          barcode: p.barcode
        };
      }),
      status: OrderStatus.PENDING_WH_SELECTION, // Direct to warehouse, bypass credit control
      statusHistory: [{ status: OrderStatus.PENDING_WH_SELECTION, timestamp }],
      createdAt: timestamp,
      salespersonId: currentUser.id,
      generalRemarks: remarks
    };

    onSubmit(newSTN);
  };

  return (
    <div className="max-w-6xl mx-auto pb-20 animate-in fade-in duration-500 space-y-8">
      <div className="bg-white rounded-[40px] border shadow-sm overflow-hidden border-slate-200">
        <div className="p-10 border-b bg-indigo-600 text-white flex items-center justify-between">
          <div>
            <h3 className="text-3xl font-black tracking-tighter">Stock Transfer Note (STN)</h3>
            <p className="text-sm text-indigo-100 font-medium tracking-tight">Internal facility movement - No credit approval required</p>
          </div>
          <div className="w-14 h-14 bg-white/20 rounded-3xl flex items-center justify-center text-white border border-white/20">
            <RefreshCcw size={28} />
          </div>
        </div>

        <form onSubmit={handleSubmit} className="p-10 space-y-12">
          {/* Warehouse Configuration */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-10 items-start">
             <div className="space-y-4">
                <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Source Warehouse (FROM)</label>
                <div className="relative">
                   <select 
                     className="w-full border-2 border-slate-100 rounded-2xl px-6 py-5 font-black text-sm bg-slate-50 focus:border-indigo-600 transition-all outline-none appearance-none"
                     value={fromWH}
                     onChange={e => setFromWH(e.target.value)}
                     required
                   >
                      <option value="">Select Origin...</option>
                      {WAREHOUSES.map(w => <option key={w} value={w}>{w}</option>)}
                   </select>
                   <Warehouse size={20} className="absolute right-6 top-1/2 -translate-y-1/2 text-slate-400" />
                </div>
             </div>

             <div className="space-y-4">
                <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Destination Warehouse (TO)</label>
                <div className="relative">
                   <select 
                     className="w-full border-2 border-slate-100 rounded-2xl px-6 py-5 font-black text-sm bg-slate-50 focus:border-indigo-600 transition-all outline-none appearance-none"
                     value={toWH}
                     onChange={e => setToWH(e.target.value)}
                     required
                   >
                      <option value="">Select Destination...</option>
                      {WAREHOUSES.map(w => <option key={w} value={w}>{w}</option>)}
                   </select>
                   <ArrowRight size={20} className="absolute right-6 top-1/2 -translate-y-1/2 text-slate-400" />
                </div>
             </div>
          </div>

          {fromWH && toWH && fromWH === toWH && (
             <div className="bg-rose-50 border border-rose-100 p-4 rounded-2xl flex items-center gap-3 text-rose-600 text-xs font-black uppercase tracking-widest animate-in slide-in-from-top-2">
                <AlertCircle size={18} /> Error: Source and Destination cannot be identical.
             </div>
          )}

          {/* Item List */}
          <div className="space-y-6 pt-6 border-t border-slate-100">
             <div className="flex items-center justify-between">
                <h4 className="text-xs font-black text-slate-400 uppercase tracking-widest">Inventory List for Transfer</h4>
                <button 
                  type="button" 
                  onClick={addItem}
                  className="bg-slate-900 text-white px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-indigo-600 transition-all flex items-center gap-2 shadow-lg"
                >
                  <Plus size={14} /> Add Line Item
                </button>
             </div>

             <div className="bg-white rounded-3xl border border-slate-100 overflow-hidden shadow-sm">
                <table className="w-full text-left">
                   <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
                      <tr>
                        <th className="px-6 py-4 w-[50%]">Material Description / SKU</th>
                        <th className="px-6 py-4 text-center">Unit</th>
                        <th className="px-6 py-4 text-center w-[20%]">Transfer Qty</th>
                        <th className="px-6 py-4 text-right">Action</th>
                      </tr>
                   </thead>
                   <tbody className="divide-y text-sm font-bold text-slate-700">
                      {items.map((item, index) => (
                        <tr key={index} className="hover:bg-slate-50 transition-colors">
                          <td className="px-6 py-4">
                            <select 
                              className="w-full border-2 border-slate-100 rounded-xl px-4 py-3 bg-white focus:border-indigo-600 outline-none"
                              value={item.productId}
                              onChange={e => updateItem(index, 'productId', e.target.value)}
                            >
                               {products.map(p => <option key={p.id} value={p.id}>{p.skuCode} - {p.name}</option>)}
                            </select>
                          </td>
                          <td className="px-6 py-4 text-center">
                             <span className="bg-slate-100 px-3 py-1 rounded-lg text-[10px] uppercase font-black">{item.unit}</span>
                          </td>
                          <td className="px-6 py-4 text-center">
                             <input 
                               type="number"
                               className="w-24 border-2 border-slate-100 rounded-xl px-2 py-3 text-center focus:border-indigo-600 outline-none"
                               value={item.quantity}
                               onChange={e => updateItem(index, 'quantity', parseFloat(e.target.value) || 0)}
                               min="1"
                             />
                          </td>
                          <td className="px-6 py-4 text-right">
                             <button type="button" onClick={() => removeItem(index)} className="p-2 text-slate-300 hover:text-rose-500 transition-all"><Trash2 size={18}/></button>
                          </td>
                        </tr>
                      ))}
                      {items.length === 0 && (
                        <tr><td colSpan={4} className="py-20 text-center text-slate-300 font-black uppercase text-[10px] italic">No items listed in STN.</td></tr>
                      )}
                   </tbody>
                </table>
             </div>
          </div>

          <div className="space-y-4">
             <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Remarks / Reason for Transfer</label>
             <textarea 
               className="w-full bg-slate-50 border-2 border-slate-100 rounded-3xl p-6 text-sm font-bold focus:border-indigo-600 outline-none transition-all resize-none h-24"
               placeholder="e.g. Stock replenishment for North Hub, Regional balance update..."
               value={remarks}
               onChange={e => setRemarks(e.target.value)}
             />
          </div>

          <div className="pt-10 border-t flex flex-col md:flex-row justify-between items-center gap-8">
             <div className="flex items-center gap-4 bg-amber-50 px-6 py-4 rounded-2xl border border-amber-100">
                <Package className="text-amber-600" size={24}/>
                <div>
                   <p className="text-[10px] font-black uppercase text-amber-700 tracking-widest">Bypassing Credit Control</p>
                   <p className="text-xs font-bold text-amber-600/70">STN request routes directly to Warehouse Selection</p>
                </div>
             </div>
             <button 
               type="submit" 
               disabled={!fromWH || !toWH || items.length === 0 || fromWH === toWH}
               className="w-full md:w-auto px-20 py-7 bg-indigo-600 text-white rounded-[32px] font-black text-sm uppercase tracking-[0.2em] shadow-2xl hover:bg-indigo-700 transition-all active:scale-95 disabled:opacity-30 flex items-center justify-center gap-4"
             >
                Dispatch STN Request <Save size={20} />
             </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default STNBookingView;
