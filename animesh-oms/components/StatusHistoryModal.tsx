
import React from 'react';
import { Order, OrderStatus } from '../types';
import { X, Clock, User, CheckCircle2, AlertCircle, Zap, ShieldCheck, Box, Truck, Receipt, Navigation } from 'lucide-react';

interface StatusHistoryModalProps {
  order: Order;
  onClose: () => void;
}

const StatusHistoryModal: React.FC<StatusHistoryModalProps> = ({ order, onClose }) => {
  const getStatusIcon = (status: OrderStatus) => {
    switch (status) {
      case OrderStatus.PENDING_CREDIT_APPROVAL: return <ShieldCheck size={18} className="text-amber-500" />;
      case OrderStatus.PENDING_WH_SELECTION: return <Zap size={18} className="text-indigo-500" />;
      case OrderStatus.PENDING_PACKING: return <Box size={18} className="text-blue-500" />;
      case OrderStatus.PENDING_QC: return <CheckCircle2 size={18} className="text-emerald-500" />;
      case OrderStatus.READY_FOR_BILLING: return <Receipt size={18} className="text-emerald-600" />;
      case OrderStatus.READY_FOR_DISPATCH: return <Truck size={18} className="text-orange-500" />;
      case OrderStatus.DELIVERED: return <CheckCircle2 size={18} className="text-emerald-600" />;
      case OrderStatus.REJECTED: return <AlertCircle size={18} className="text-rose-500" />;
      case OrderStatus.ON_HOLD: return <Clock size={18} className="text-amber-600" />;
      default: return <Navigation size={18} className="text-slate-400" />;
    }
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-300">
      <div className="bg-white w-full max-w-2xl rounded-[40px] shadow-2xl overflow-hidden animate-in zoom-in-95 duration-300">
        <div className="p-8 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
          <div>
            <h3 className="text-2xl font-black text-slate-900 tracking-tight flex items-center gap-3">
              <Clock className="text-indigo-600" size={24} /> Mission Workflow Trace
            </h3>
            <p className="text-xs text-slate-500 font-bold uppercase tracking-widest mt-1">Order Ref: {order.id}</p>
          </div>
          <button 
            onClick={onClose}
            className="p-3 bg-white text-slate-400 hover:text-rose-500 rounded-2xl border border-slate-200 transition-all hover:bg-rose-50"
          >
            <X size={20} />
          </button>
        </div>

        <div className="p-10 max-h-[60vh] overflow-y-auto no-scrollbar">
          <div className="relative space-y-12">
            <div className="absolute left-[19px] top-2 bottom-2 w-0.5 bg-slate-100" />
            
            {(order.statusHistory || []).map((history, idx) => (
              <div key={idx} className="relative flex items-start gap-8 group">
                <div className={`w-10 h-10 rounded-2xl border-4 border-white shadow-lg flex items-center justify-center z-10 transition-all group-hover:scale-110 ${
                  idx === 0 ? 'bg-indigo-600 text-white' : 'bg-slate-50 text-slate-400'
                }`}>
                  {getStatusIcon(history.status)}
                </div>
                <div className="flex-1 pt-1">
                  <div className="flex flex-col md:flex-row md:items-center justify-between gap-2 mb-2">
                    <h4 className="text-sm font-black text-slate-900 uppercase tracking-widest">{history.status}</h4>
                    <span className="text-[10px] font-bold text-slate-400 bg-slate-50 px-3 py-1 rounded-full border border-slate-100">
                      {new Date(history.timestamp).toLocaleString('en-GB', { 
                        day: '2-digit', month: 'short', year: 'numeric', 
                        hour: '2-digit', minute: '2-digit', second: '2-digit' 
                      })}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-xs font-bold text-slate-500">
                    <User size={14} className="text-indigo-400" />
                    <span>Action by: <span className="text-slate-900 font-black">{history.userName || 'System / Automated'}</span></span>
                  </div>
                  {idx === 0 && (
                    <div className="mt-4 inline-block px-3 py-1 bg-emerald-50 text-emerald-600 rounded-lg text-[9px] font-black uppercase tracking-widest border border-emerald-100">
                      Current Active Stage
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="p-8 bg-slate-50 border-t border-slate-100 flex justify-end">
          <button 
            onClick={onClose}
            className="px-8 py-4 bg-slate-900 text-white rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-indigo-600 transition-all shadow-xl active:scale-95"
          >
            Close Trace
          </button>
        </div>
      </div>
    </div>
  );
};

export default StatusHistoryModal;
