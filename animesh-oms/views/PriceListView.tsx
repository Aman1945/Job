
import React, { useState, useMemo } from 'react';
import { Product } from '../types';
import { Search, Tag, Snowflake, Package, FileText, Download, Filter, Image as ImageIcon } from 'lucide-react';

interface PriceListViewProps {
  products: Product[];
  type: 'Horeca' | 'Retail';
}

const PriceListView: React.FC<PriceListViewProps> = ({ products, type }) => {
  const [searchTerm, setSearchTerm] = useState('');

  const filteredProducts = useMemo(() => {
    return products.filter(p => {
      const matchesSearch = p.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                            p.skuCode.toLowerCase().includes(searchTerm.toLowerCase());
      // Filter by distribution channel if available, otherwise show all as a fallback
      const matchesChannel = !p.distributionChannel || 
                             p.distributionChannel.toLowerCase().includes(type.toLowerCase());
      return matchesSearch && matchesChannel;
    });
  }, [products, searchTerm, type]);

  const handleDownload = () => {
    const headers = "SKU Code,Product Name,Weight,MRP,GST %\n";
    const rows = filteredProducts.map(p => 
      `${p.skuCode},"${p.name}",${p.productWeight || 'N/A'},${p.mrp || p.price},${p.gst || 0}%`
    ).join("\n");
    
    const blob = new Blob([headers + rows], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `NexusOMS_${type}_Catalogue.csv`;
    a.click();
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-20">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">
            {type} SKU Catalogue
          </h2>
          <p className="text-sm text-slate-500 font-medium">Enterprise material visual database and tax matrix</p>
        </div>
        <button 
          onClick={handleDownload}
          className="bg-emerald-600 text-white px-8 py-4 rounded-2xl font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-emerald-700 transition-all flex items-center gap-3 active:scale-95"
        >
          <Download size={18} /> Export CSV
        </button>
      </div>

      <div className="relative max-w-md group">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
        <input 
          type="text" 
          placeholder="Filter catalogue SKUs..." 
          className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] border-b">
              <tr>
                <th className="px-8 py-6">Image</th>
                <th className="px-6 py-6">SKU Identity</th>
                <th className="px-6 py-6">Material Description</th>
                <th className="px-6 py-6 text-center">Unit Weight</th>
                <th className="px-6 py-6 text-right">MRP / Base</th>
                <th className="px-6 py-6 text-center">GST %</th>
                <th className="px-8 py-6 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y text-sm font-bold text-slate-700">
              {filteredProducts.map(product => (
                <tr key={product.id} className="hover:bg-slate-50 transition-colors group">
                  <td className="px-8 py-6">
                    <div className="w-16 h-16 rounded-2xl bg-slate-50 border border-slate-100 overflow-hidden flex items-center justify-center shadow-sm group-hover:scale-105 transition-transform">
                       {product.imageUrl ? (
                         <img src={product.imageUrl} alt={product.name} className="w-full h-full object-cover" />
                       ) : (
                         <ImageIcon size={20} className="text-slate-200" />
                       )}
                    </div>
                  </td>
                  <td className="px-6 py-6">
                    <span className="font-mono font-black text-indigo-600 bg-indigo-50 px-3 py-1 rounded-lg border border-indigo-100 uppercase">
                      {product.skuCode}
                    </span>
                  </td>
                  <td className="px-6 py-6">
                    <p className="text-slate-900 font-black">{product.name}</p>
                    <p className="text-[10px] text-slate-400 uppercase mt-1 italic">{product.category}</p>
                  </td>
                  <td className="px-6 py-6 text-center">
                    <div className="flex items-center justify-center gap-2">
                       <Package size={14} className="text-slate-300" />
                       <span className="text-slate-500">{product.productWeight || '0.00'} {product.unit}</span>
                    </div>
                  </td>
                  <td className="px-6 py-6 text-right font-black text-slate-900">
                    ₹{(product.mrp || product.price).toLocaleString()}
                  </td>
                  <td className="px-6 py-6 text-center">
                    <span className="bg-emerald-50 text-emerald-700 px-3 py-1 rounded-lg text-xs font-black border border-emerald-100">
                      {product.gst || 0}%
                    </span>
                  </td>
                  <td className="px-8 py-6 text-right">
                    <span className="text-[9px] font-black text-slate-300 uppercase tracking-widest">In Stock</span>
                  </td>
                </tr>
              ))}
              {filteredProducts.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-8 py-32 text-center text-slate-300 font-black uppercase text-[10px] italic">
                    No matching SKUs in {type} catalogue.
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

export default PriceListView;
