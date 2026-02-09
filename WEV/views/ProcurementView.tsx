
import React, { useState, useMemo, useRef } from 'react';
import { ProcurementItem, Product, User, UserRole } from '../types';
import { 
  CheckSquare, 
  Square, 
  Trash2, 
  Plus, 
  Search, 
  CheckCircle2, 
  Clock, 
  FileText, 
  Tag, 
  User as UserIcon, 
  ArrowRight,
  Filter,
  CheckCircle,
  FileUp,
  Download,
  ShieldCheck,
  Send,
  X
} from 'lucide-react';

interface ProcurementViewProps {
  procurement: ProcurementItem[];
  products: Product[];
  currentUser: User;
  onUpdate: (items: ProcurementItem[]) => void;
}

const ProcurementView: React.FC<ProcurementViewProps> = ({ procurement, products, currentUser, onUpdate }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [isAdding, setIsAdding] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [activeUploadId, setActiveUploadId] = useState<string | null>(null);

  const [newEntry, setNewEntry] = useState<Partial<ProcurementItem>>({
    supplierName: '',
    skuCode: '',
    sipChecked: false,
    labelsChecked: false,
    docsChecked: false
  });

  const isProcurementHead = currentUser.role === UserRole.PROCUREMENT_HEAD || currentUser.role === UserRole.ADMIN;
  const isProcurementStaff = currentUser.role === UserRole.PROCUREMENT || currentUser.role === UserRole.ADMIN;

  const filteredItems = useMemo(() => {
    return procurement.filter(item => 
      item.supplierName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.skuName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.skuCode.toLowerCase().includes(searchTerm.toLowerCase())
    ).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [procurement, searchTerm]);

  const toggleCheck = (itemId: string, field: keyof ProcurementItem) => {
    if (isProcurementHead && !isProcurementStaff) return; // Head only approves
    const updated = procurement.map(item => {
      if (item.id === itemId && item.status === 'Pending') {
        const newItem = { ...item, [field]: !item[field] };
        return newItem as ProcurementItem;
      }
      return item;
    });
    onUpdate(updated);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file && activeUploadId) {
      const reader = new FileReader();
      reader.onloadend = () => {
        const updated = procurement.map(item => {
          if (item.id === activeUploadId) {
            return {
              ...item,
              attachment: reader.result as string,
              attachmentName: file.name
            } as ProcurementItem;
          }
          return item;
        });
        onUpdate(updated);
        setActiveUploadId(null);
      };
      reader.readAsDataURL(file);
    }
  };

  const submitToHead = (itemId: string) => {
    const updated = procurement.map(item => {
      if (item.id === itemId) {
        if (!item.sipChecked || !item.labelsChecked || !item.docsChecked || !item.attachment) {
          alert("All checks must be completed and documents uploaded before submitting to head.");
          return item;
        }
        return { ...item, status: 'Awaiting Head Approval', clearedBy: currentUser.name } as ProcurementItem;
      }
      return item;
    });
    onUpdate(updated);
  };

  const headApprove = (itemId: string) => {
    const updated = procurement.map(item => {
      if (item.id === itemId) {
        return { ...item, status: 'Approved', approvedBy: currentUser.name } as ProcurementItem;
      }
      return item;
    });
    onUpdate(updated);
  };

  const deleteItem = (itemId: string) => {
    if (window.confirm('Delete this procurement checklist?')) {
      onUpdate(procurement.filter(i => i.id !== itemId));
    }
  };

  const downloadFile = (dataUri: string, fileName: string) => {
    const link = document.createElement('a');
    link.href = dataUri;
    link.download = fileName;
    link.click();
  };

  const handleAdd = () => {
    if (!newEntry.supplierName || !newEntry.skuCode) return;
    
    const product = products.find(p => p.skuCode === newEntry.skuCode);
    const item: ProcurementItem = {
      id: 'PRC-' + Math.floor(Math.random() * 9000 + 1000),
      supplierName: newEntry.supplierName!,
      skuCode: newEntry.skuCode!,
      skuName: product ? product.name : 'Unknown SKU',
      sipChecked: !!newEntry.sipChecked,
      labelsChecked: !!newEntry.labelsChecked,
      docsChecked: !!newEntry.docsChecked,
      status: 'Pending',
      createdAt: new Date().toISOString()
    };

    onUpdate([item, ...procurement]);
    setIsAdding(false);
    setNewEntry({ supplierName: '', skuCode: '', sipChecked: false, labelsChecked: false, docsChecked: false });
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-20">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-3xl font-black text-slate-900 tracking-tight">Procurement Gate Terminal</h2>
          <p className="text-sm text-slate-500 font-medium">Verify supplier inbound requirements & multi-stage approval</p>
        </div>
        {isProcurementStaff && (
          <button 
            onClick={() => setIsAdding(true)}
            className="bg-indigo-600 text-white px-8 py-4 rounded-2xl font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-700 transition-all flex items-center gap-3 active:scale-95"
          >
            <Plus size={18} /> Log New Inbound
          </button>
        )}
      </div>

      <div className="flex flex-col md:flex-row gap-6">
        <div className="relative flex-1 group">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-indigo-600 transition-colors" size={18} />
          <input 
            type="text" 
            placeholder="Search Supplier, SKU Name or Code..." 
            className="w-full bg-white border border-slate-200 rounded-2xl pl-12 pr-4 py-4 text-sm font-medium shadow-sm focus:ring-4 focus:ring-indigo-500/10 outline-none transition-all"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className="flex items-center gap-4 px-6 bg-white border border-slate-200 rounded-2xl shadow-sm">
           <Filter size={16} className="text-slate-400" />
           <span className="text-[10px] font-black uppercase text-slate-400">Filter Active</span>
        </div>
      </div>

      {isAdding && (
        <div className="bg-slate-900 rounded-[40px] p-10 text-white shadow-2xl animate-in zoom-in-95 duration-300">
           <div className="flex items-center justify-between mb-10">
              <h3 className="text-2xl font-black tracking-tight">Supply Inbound Form</h3>
              <button onClick={() => setIsAdding(false)} className="text-slate-500 hover:text-white transition-colors"><X size={24}/></button>
           </div>
           <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="space-y-2">
                 <label className="text-[10px] font-black text-indigo-400 uppercase tracking-widest px-1">Supplier Name</label>
                 <input 
                    type="text" 
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-indigo-500/50 outline-none transition-all"
                    value={newEntry.supplierName}
                    onChange={e => setNewEntry({...newEntry, supplierName: e.target.value})}
                    placeholder="Enter vendor identity..."
                 />
              </div>
              <div className="space-y-2">
                 <label className="text-[10px] font-black text-indigo-400 uppercase tracking-widest px-1">Target SKU</label>
                 <select 
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-indigo-500/50 outline-none appearance-none transition-all"
                    value={newEntry.skuCode}
                    onChange={e => setNewEntry({...newEntry, skuCode: e.target.value})}
                 >
                    <option value="" className="bg-slate-900 text-slate-400">Select Material SKU...</option>
                    {products.map(p => (
                      <option key={p.skuCode} value={p.skuCode} className="bg-slate-900">{p.skuCode} - {p.name}</option>
                    ))}
                 </select>
              </div>
           </div>
           <button 
              onClick={handleAdd}
              className="mt-10 bg-indigo-500 hover:bg-indigo-400 text-white px-12 py-5 rounded-2xl font-black text-xs uppercase tracking-widest shadow-xl transition-all active:scale-95"
           >
              Register Inbound Entry
           </button>
        </div>
      )}

      <div className="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left min-w-[1200px]">
            <thead className="bg-slate-50 text-[10px] font-black text-slate-400 uppercase tracking-widest border-b">
              <tr>
                <th className="px-8 py-6">Mission Ref</th>
                <th className="px-6 py-6">Vendor / Supplier</th>
                <th className="px-6 py-6">Material SKU</th>
                <th className="px-6 py-6">Checks (SIP/LBL/DOC)</th>
                <th className="px-6 py-6 text-center">Docs / Files</th>
                <th className="px-6 py-6 text-center">Stage</th>
                <th className="px-8 py-6 text-right">Workflow</th>
              </tr>
            </thead>
            <tbody className="divide-y text-sm font-bold text-slate-700">
              {filteredItems.map(item => (
                <tr key={item.id} className="hover:bg-slate-50/50 transition-colors group">
                  <td className="px-8 py-6">
                    <div className="flex flex-col">
                       <span className="font-mono font-black text-indigo-600 text-base">{item.id}</span>
                       <span className="text-[9px] text-slate-400 font-bold uppercase">{new Date(item.createdAt).toLocaleDateString()}</span>
                    </div>
                  </td>
                  <td className="px-6 py-6 font-black text-slate-900">{item.supplierName}</td>
                  <td className="px-6 py-6">
                    <p className="text-slate-700">{item.skuName}</p>
                    <p className="text-[10px] font-black text-indigo-500 uppercase mt-1">CODE: {item.skuCode}</p>
                  </td>
                  <td className="px-6 py-6">
                    <div className="flex gap-2">
                      <button 
                         onClick={() => toggleCheck(item.id, 'sipChecked')}
                         className={`p-2 rounded-xl transition-all ${item.sipChecked ? 'bg-indigo-600 text-white shadow-lg' : 'bg-slate-100 text-slate-300'}`}
                         title="SIP Checklist"
                      >
                         <CheckSquare size={18} />
                      </button>
                      <button 
                         onClick={() => toggleCheck(item.id, 'labelsChecked')}
                         className={`p-2 rounded-xl transition-all ${item.labelsChecked ? 'bg-indigo-600 text-white shadow-lg' : 'bg-slate-100 text-slate-300'}`}
                         title="Labels Verified"
                      >
                         <Tag size={18} />
                      </button>
                      <button 
                         onClick={() => toggleCheck(item.id, 'docsChecked')}
                         className={`p-2 rounded-xl transition-all ${item.docsChecked ? 'bg-indigo-600 text-white shadow-lg' : 'bg-slate-100 text-slate-300'}`}
                         title="Documents Checklist"
                      >
                         <FileText size={18} />
                      </button>
                    </div>
                  </td>
                  <td className="px-6 py-6 text-center">
                    <div className="flex justify-center items-center gap-2">
                      {item.attachment ? (
                        <button 
                          onClick={() => downloadFile(item.attachment!, item.attachmentName || 'procurement_doc.png')}
                          className="p-3 bg-emerald-50 text-emerald-600 rounded-xl hover:bg-emerald-600 hover:text-white transition-all shadow-sm"
                        >
                          <Download size={16}/>
                        </button>
                      ) : (
                        item.status === 'Pending' && isProcurementStaff && (
                          <button 
                            onClick={() => { setActiveUploadId(item.id); fileInputRef.current?.click(); }}
                            className="p-3 bg-slate-50 text-slate-400 rounded-xl border border-dashed border-slate-200 hover:bg-indigo-50 hover:text-indigo-600 hover:border-indigo-200 transition-all"
                          >
                            <FileUp size={16}/>
                          </button>
                        )
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-6 text-center">
                    <span className={`inline-block px-3 py-1 rounded-lg text-[9px] font-black uppercase tracking-widest border ${
                      item.status === 'Approved' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 
                      item.status === 'Awaiting Head Approval' ? 'bg-indigo-50 text-indigo-600 border-indigo-100' :
                      'bg-amber-50 text-amber-600 border-amber-100'
                    }`}>
                      {item.status}
                    </span>
                  </td>
                  <td className="px-8 py-6 text-right">
                    <div className="flex justify-end gap-2">
                       {item.status === 'Pending' && isProcurementStaff && (
                         <button 
                           onClick={() => submitToHead(item.id)}
                           className="px-4 py-2 bg-indigo-600 text-white rounded-xl text-[9px] font-black uppercase flex items-center gap-2 hover:bg-indigo-700 transition-all shadow-lg"
                         >
                            <Send size={12}/> Submit To Head
                         </button>
                       )}
                       {item.status === 'Awaiting Head Approval' && isProcurementHead && (
                         <button 
                           onClick={() => headApprove(item.id)}
                           className="px-4 py-2 bg-emerald-600 text-white rounded-xl text-[9px] font-black uppercase flex items-center gap-2 hover:bg-emerald-700 transition-all shadow-lg"
                         >
                            <ShieldCheck size={12}/> Final Approval
                         </button>
                       )}
                       {isProcurementStaff && (
                         <button onClick={() => deleteItem(item.id)} className="p-2 text-slate-200 hover:text-rose-500 transition-colors">
                           <Trash2 size={16}/>
                         </button>
                       )}
                    </div>
                  </td>
                </tr>
              ))}
              {filteredItems.length === 0 && (
                <tr>
                  <td colSpan={8} className="px-8 py-32 text-center text-slate-300 font-bold uppercase tracking-widest italic">
                    <div className="flex flex-col items-center gap-4">
                       <CheckCircle size={48} className="opacity-20" />
                       <p>No procurement missions detected.</p>
                    </div>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
      
      <input 
        type="file" 
        ref={fileInputRef} 
        onChange={handleFileUpload} 
        className="hidden" 
        accept="image/*,.pdf" 
      />
    </div>
  );
};

export default ProcurementView;
