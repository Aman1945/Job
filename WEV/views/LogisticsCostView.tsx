import React, { useMemo } from 'react';
import { Order, OrderStatus } from '../types';
import { DollarSign, ArrowRight, Truck, Box, Snowflake, MapPin, Search } from 'lucide-react';

interface LogisticsCostViewProps {
  orders: Order[];
  onUpdateOrders: (orders: Order[]) => void;
  onSelectOrder: (id: string) => void;
}

const LogisticsCostView: React.FC<LogisticsCostViewProps> = ({ orders, onUpdateOrders, onSelectOrder }) => {
  const pendingOrders = useMemo(() => orders.filter(o => o.status === OrderStatus.READY_FOR_BILLING || o.status === OrderStatus.PART_PACKED), [orders]);

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div>
        <h2 className="text-3xl font-black text-slate-900 tracking-tight">4. Logistics Cost Terminal</h2>
        <p className="text-sm text-slate-500 font-medium">Define cold chain and freight surcharges before invoicing</p>
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
            <tr>
              <th className="px-8 py-6">Mission Ref</th>
              <th className="px-6 py-6">Customer</th>
              <th className="px-6 py-6 text-center">Load Size</th>
              <th className="px-6 py-6 text-center">Cost Status</th>
              <th className="px-8 py-6 text-center">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y text-sm font-bold">
            {pendingOrders.map(order => (
              <tr key={order.id} className="hover:bg-slate-50/50">
                <td className="px-8 py-6 font-mono font-black text-emerald-600">{order.id}</td>
                <td className="px-6 py-6">{order.customerName}</td>
                <td className="px-6 py-6 text-center"><span className="px-3 py-1 bg-slate-100 rounded-lg text-xs">{order.packedBoxes || 0} Boxes</span></td>
                <td className="px-6 py-6 text-center">
                   <span className={`inline-block px-3 py-1 rounded-lg text-[9px] font-black uppercase ${order.logistics?.whToCustAmount ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-700'}`}>
                      {order.logistics?.whToCustAmount ? 'Estimated' : 'Not Calculated'}
                   </span>
                </td>
                <td className="px-8 py-6 text-center">
                   <button onClick={() => onSelectOrder(order.id)} className="bg-emerald-600 text-white px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-emerald-700 transition-all flex items-center gap-2 mx-auto">
                      <DollarSign size={14}/> Define Costs <ArrowRight size={14}/>
                   </button>
                </td>
              </tr>
            ))}
            {pendingOrders.length === 0 && (
              <tr><td colSpan={5} className="px-8 py-32 text-center text-slate-400 italic">No missions ready for cost calculation.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default LogisticsCostView;