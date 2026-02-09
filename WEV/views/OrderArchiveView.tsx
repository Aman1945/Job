
import React, { useState, useMemo } from 'react';
import { Order, OrderStatus } from '../types';
import { 
  FileText, 
  Download, 
  Search, 
  Filter, 
  Calendar, 
  Image as ImageIcon,
  CheckCircle2,
  XCircle,
  Clock,
  ExternalLink,
  Archive,
  Receipt
} from 'lucide-react';

interface OrderArchiveViewProps {
  orders: Order[];
  onSelectOrder: (id: string) => void;
}

const OrderArchiveView: React.FC<OrderArchiveViewProps> = ({ orders, onSelectOrder }) => {
  const [searchTerm, setSearchTerm] = useState('');

  const filteredOrders = useMemo(() => {
    const term = searchTerm.toLowerCase();
    return orders.filter(o => 
      o.id.toLowerCase().includes(term) || 
      o.customerName.toLowerCase().includes(term) ||
      (o.invoiceNo && o.invoiceNo.toLowerCase().includes(term))
    ).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [orders, searchTerm]);

  const downloadFile = (dataUri: string, fileName: string) => {
    const link = document.createElement('a');
    link.href = dataUri;
    link.download = fileName;
    link.click();
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-20">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Orders Master Archive</h2>
          <p className="text-sm text-slate-500 font-medium">Trace statuses, invoices, and delivery proof snapshots</p>
        </div>
        
        <div className="relative max-w-md w-full">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
          <input 
            type="text" 
            placeholder="Search Reference, Client, or Invoice..." 
            className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all shadow-sm"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
              <tr>
                <th className="px-8 py-6">Mission Ref</th>
                <th className="px-6 py-6">Customer</th>
                <th className="px-6 py-6 text-center">Status</th>
                <th className="px-6 py-6 text-center">Invoice Copy</th>
                <th className="px-6 py-6 text-center">Ack. Copy (POD)</th>
                <th className="px-8 py-6 text-right">Value</th>
              </tr>
            </thead>
            <tbody className="divide-y text-sm font-bold text-slate-700">
              {filteredOrders.map(order => (
                <tr key={order.id} onClick={() => onSelectOrder(order.id)} className="hover:bg-slate-50/50 cursor-pointer transition-colors group">
                  <td className="px-8 py-6">
                    <div className="flex flex-col">
                      <span className="font-mono font-black text-emerald-600">{order.id}</span>
                      <span className="text-[9px] text-slate-400 font-bold uppercase">{new Date(order.createdAt).toLocaleDateString()}</span>
                    </div>
                  </td>
                  <td className="px-6 py-6">
                    <p className="text-slate-900">{order.customerName}</p>
                    {order.invoiceNo && <p className="text-[10px] text-indigo-500 font-black uppercase mt-1">INV: {order.invoiceNo}</p>}
                  </td>
                  <td className="px-6 py-6 text-center">
                    <span className={`inline-block px-3 py-1 rounded-lg text-[9px] font-black uppercase border ${
                      order.status === OrderStatus.DELIVERED ? 'bg-emerald-50 text-emerald-600 border-emerald-100' :
                      order.status === OrderStatus.REJECTED ? 'bg-rose-50 text-rose-600 border-rose-100' :
                      order.status === OrderStatus.ON_HOLD ? 'bg-amber-50 text-amber-600 border-amber-100' :
                      'bg-slate-100 text-slate-500 border-slate-200'
                    }`}>
                      {order.status}
                    </span>
                  </td>
                  <td className="px-6 py-6 text-center">
                    {order.invoiceFile ? (
                      <button 
                        onClick={(e) => { e.stopPropagation(); downloadFile(order.invoiceFile!, `Invoice_${order.id}.png`); }}
                        className="p-3 bg-indigo-50 text-indigo-600 rounded-xl hover:bg-indigo-600 hover:text-white transition-all shadow-sm"
                      >
                        <Receipt size={18}/>
                      </button>
                    ) : (
                      <span className="text-[10px] text-slate-300 font-black uppercase italic">Pending</span>
                    )}
                  </td>
                  <td className="px-6 py-6 text-center">
                    {order.deliveryProof ? (
                      <button 
                        onClick={(e) => { e.stopPropagation(); downloadFile(order.deliveryProof!, `POD_${order.id}.png`); }}
                        className="p-3 bg-emerald-50 text-emerald-600 rounded-xl hover:bg-emerald-600 hover:text-white transition-all shadow-sm"
                      >
                        <ImageIcon size={18}/>
                      </button>
                    ) : (
                      <span className="text-[10px] text-slate-300 font-black uppercase italic">No Proof</span>
                    )}
                  </td>
                  <td className="px-8 py-6 text-right font-black text-slate-900">
                    ₹{order.items.reduce((s,i) => s + (i.price * (i.packedQuantity || i.quantity)), 0).toLocaleString()}
                  </td>
                </tr>
              ))}
              {filteredOrders.length === 0 && (
                <tr>
                  <td colSpan={6} className="px-8 py-32 text-center text-slate-300 font-bold uppercase tracking-widest italic">
                    No matching missions found in history.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default OrderArchiveView;
