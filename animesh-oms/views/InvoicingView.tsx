
import React, { useMemo, useRef } from 'react';
import { Order, OrderStatus } from '../types';
import { Receipt, FileUp, Download, CheckCircle2, Search, ArrowRight, Printer, FileText } from 'lucide-react';

interface InvoicingViewProps {
  orders: Order[];
  onUpdateOrders: (orders: Order[]) => void;
  onSelectOrder: (id: string) => void;
}

const InvoicingView: React.FC<InvoicingViewProps> = ({ orders, onUpdateOrders, onSelectOrder }) => {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const activeOrderRef = useRef<string | null>(null);

  const pendingInvoicing = useMemo(() => 
    orders.filter(o => o.status === OrderStatus.PENDING_LOGISTICS), 
  [orders]);

  const invoicedOrders = useMemo(() => 
    orders.filter(o => o.invoiceNo && (o.status !== OrderStatus.PENDING_LOGISTICS)), 
  [orders]);

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file && activeOrderRef.current) {
      const reader = new FileReader();
      reader.onloadend = () => {
        const timestamp = new Date().toISOString();
        const updated = orders.map(o => {
          if (o.id === activeOrderRef.current) {
            const nextStatus = OrderStatus.READY_FOR_DISPATCH; // Move to logistics hub
            return {
              ...o,
              status: nextStatus,
              invoiceFile: reader.result as string,
              invoiceNo: `EXT-${Math.floor(Math.random()*9000)+1000}`,
              statusHistory: [...o.statusHistory, { status: nextStatus, timestamp }]
            };
          }
          return o;
        });
        onUpdateOrders(updated);
      };
      reader.readAsDataURL(file);
    }
  };

  const downloadFile = (dataUri: string, fileName: string) => {
    const link = document.createElement('a');
    link.href = dataUri;
    link.download = fileName;
    link.click();
  };

  return (
    <div className="space-y-10 animate-in fade-in duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">5. Invoicing Terminal</h2>
          <p className="text-sm text-slate-500 font-medium">Issue system invoices or upload physical accounting copies</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-10">
         <div className="space-y-6">
            <div className="flex items-center justify-between px-2">
               <h3 className="text-xs font-black text-slate-400 uppercase tracking-widest">Awaiting Billing Approval</h3>
               <span className="bg-indigo-600 text-white text-[10px] font-black px-3 py-1 rounded-full">{pendingInvoicing.length} Pending</span>
            </div>
            <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
               {pendingInvoicing.map(order => (
                 <div key={order.id} className="p-8 border-b flex items-center justify-between hover:bg-slate-50 transition-all group">
                    <div className="flex items-center gap-4">
                       <div className="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center">
                          <Receipt size={24}/>
                       </div>
                       <div>
                          <p className="font-mono font-black text-indigo-600">{order.id}</p>
                          <p className="text-sm font-black text-slate-900">{order.customerName}</p>
                          <p className="text-[9px] text-slate-400 font-bold uppercase mt-1">Value: ₹{order.items.reduce((s,i)=>s+(i.price*(i.packedQuantity||i.quantity)),0).toLocaleString()}</p>
                       </div>
                    </div>
                    <div className="flex gap-2">
                       <button onClick={() => onSelectOrder(order.id)} className="px-6 py-3 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition-all text-[10px] font-black uppercase flex items-center gap-2">
                          Audit & Invoice <ArrowRight size={14}/>
                       </button>
                    </div>
                 </div>
               ))}
               {pendingInvoicing.length === 0 && (
                  <div className="p-20 text-center space-y-4">
                     <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto text-slate-200">
                        <Printer size={32}/>
                     </div>
                     <p className="text-[10px] font-black text-slate-300 uppercase tracking-widest italic">Invoicing queue empty</p>
                  </div>
               )}
            </div>
         </div>

         <div className="space-y-6">
            <h3 className="text-xs font-black text-slate-400 uppercase tracking-widest px-2">Billed Records</h3>
            <div className="bg-slate-900 rounded-[40px] p-8 text-white shadow-2xl space-y-4 max-h-[600px] overflow-y-auto no-scrollbar border border-slate-800">
               {invoicedOrders.map(order => (
                 <div key={order.id} className="bg-white/5 border border-white/10 p-5 rounded-3xl flex items-center justify-between group hover:bg-white/10 transition-all">
                    <div className="flex items-center gap-4">
                       <div className="w-10 h-10 bg-emerald-500/20 text-emerald-400 rounded-xl flex items-center justify-center">
                          <FileText size={20}/>
                       </div>
                       <div>
                          <p className="text-[10px] font-black text-emerald-400 uppercase">INV: {order.invoiceNo}</p>
                          <p className="text-sm font-bold truncate max-w-[150px]">{order.customerName}</p>
                       </div>
                    </div>
                    <div className="flex gap-2">
                       {order.invoiceFile && (
                         <button onClick={() => downloadFile(order.invoiceFile!, `INV_${order.id}.png`)} className="p-2.5 bg-white/10 text-white rounded-xl hover:bg-emerald-500 transition-all">
                            <Download size={16}/>
                         </button>
                       )}
                       <button onClick={() => onSelectOrder(order.id)} className="p-2.5 bg-white/10 text-white rounded-xl hover:bg-indigo-500 transition-all">
                          <ArrowRight size={16}/>
                       </button>
                    </div>
                 </div>
               ))}
               {invoicedOrders.length === 0 && <div className="p-12 text-center text-slate-700 font-black uppercase text-[10px]">No History</div>}
            </div>
         </div>
      </div>

      <input type="file" ref={fileInputRef} className="hidden" onChange={handleFileUpload} accept="image/*,.pdf" />
    </div>
  );
};

export default InvoicingView;
