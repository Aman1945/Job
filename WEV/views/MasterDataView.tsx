
import React, { useState, useRef, useMemo } from 'react';
import * as XLSX from 'xlsx';
import { Customer, Product, User, UserRole, ODMaster, AgingBuckets } from '../types';
import { 
  Users, FileSpreadsheet, Plus, X, Upload, Trash2, Pencil,
  ClipboardList, Package, Truck, TrendingDown, History,
  Search, FileUp, AlertCircle, FileCheck, Layers
} from 'lucide-react';

interface MasterDataViewProps {
  customers: Customer[];
  products: Product[];
  users: User[];
  odMaster: ODMaster[];
  currentUser: User;
  onUpdateCustomers: (customers: Customer[]) => void;
  onUpdateProducts: (products: Product[]) => void;
  onUpdateUsers: (users: User[]) => void;
  onUpdateOdMaster: (od: ODMaster[]) => void;
}

type NexusTab = 'User Master' | 'Customer Master' | 'Material Master' | 'Delivery Person' | 'OD Master';

const MasterDataView: React.FC<MasterDataViewProps> = ({ 
  customers, products, users, odMaster, currentUser,
  onUpdateCustomers, onUpdateProducts, onUpdateUsers, onUpdateOdMaster 
}) => {
  const [activeTab, setActiveTab] = useState<NexusTab>('User Master');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingRecord, setEditingRecord] = useState<any>(null);
  const [importStatus, setImportStatus] = useState<{ type: 'success' | 'error' | null; message: string }>({ type: null, message: '' });
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [formData, setFormData] = useState<any>({});

  const templates: Record<NexusTab, string> = {
    'User Master': 'name,email,role,isApprover',
    'Customer Master': 'id,name,Sales Manager,Employee responsible,status,distributionChannel,class,limit,location,email,postalCode,address',
    'Material Master': 'ProductCode,Product Name,ProductShortName,DistributionChannel,Specie,product Weight,Product Packing,MRP,GST%,HSNCODE,COUNTRY OF ORIGIN',
    'Delivery Person': 'name,email',
    'OD Master': 'Customer ID,Channel,Sales Manager,Class,Employee responsible,Customer Names,Credit Days,Credit Limit,Security Chq,Dist Channel,O/s Amt,OD Amt,Diffn btw ydy & tday,0 to 7,7 to 15,15 to 30,30 to 45,45 to 90,90 to 120,120 to 150,150 to 180,>180'
  };

  const handleDownloadTemplate = () => {
    const headerString = templates[activeTab];
    const blob = new Blob([headerString], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `${activeTab.replace(/\s+/g, '_')}_Template.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const bstr = evt.target?.result;
        const wb = XLSX.read(bstr, { type: 'binary' });
        const wsname = wb.SheetNames[0];
        const ws = wb.Sheets[wsname];
        const data = XLSX.utils.sheet_to_json(ws);
        processSmartMerge(activeTab, data);
      } catch (err: any) {
        setImportStatus({ type: 'error', message: `Upload error: ${err.message}` });
      }
    };
    reader.readAsBinaryString(file);
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  const processSmartMerge = (tab: NexusTab, rows: any[]) => {
    let added = 0;
    let updatedCount = 0;

    if (tab === 'User Master' || tab === 'Delivery Person') {
      const currentMap = new Map((users || []).map(u => [u.id.toLowerCase(), u]));
      rows.forEach((row: any) => {
        const id = String(row.email || row.Email || row.id || '').trim().toLowerCase();
        if (!id) return;
        
        let role = row.role || row.Role || (tab === 'Delivery Person' ? UserRole.DELIVERY : UserRole.SALES);
        if (role === 'Credit Control') role = UserRole.FINANCE;
        if (role === 'Billing Team') role = UserRole.BILLING;
        if (role === 'Logistic Team') role = UserRole.LOGISTICS;
        if (role === 'Warehouse/Packing') role = UserRole.WAREHOUSE;

        const userData: User = {
          id: id,
          name: String(row.name || row.Name || 'New User').trim(),
          role: role,
          status: 'Active',
          isApprover: String(row.isApprover || row.isapprover || '').toLowerCase() === 'true' || String(row.isApprover || '').toLowerCase() === 'yes' || role === UserRole.ADMIN
        };
        if (currentMap.has(id)) updatedCount++; else added++;
        currentMap.set(id, userData);
      });
      onUpdateUsers(Array.from(currentMap.values()));
    } 
    else if (tab === 'Material Master') {
      const currentMap = new Map((products || []).map(p => [p.skuCode.toLowerCase(), p]));
      rows.forEach((row: any) => {
        const sku = String(row.ProductCode || row.skucode || row.id || '').trim();
        if (!sku) return;
        const mrp = Number(String(row.MRP || row.mrp || row.price || 0).replace(/[₹,]/g, ''));
        const gstVal = parseFloat(String(row['GST%'] || row.gst || 0).replace('%', ''));
        
        const productData: Product = {
          id: sku,
          skuCode: sku,
          name: String(row['Product Name'] || row.name || 'Unnamed SKU').trim(),
          productShortName: String(row.ProductShortName || '').trim(),
          distributionChannel: String(row.DistributionChannel || '').trim(),
          specie: String(row.Specie || '').trim(),
          productWeight: String(row['product Weight'] || row.productWeight || '').trim(),
          productPacking: String(row['Product Packing'] || row.productPacking || '').trim(),
          mrp: mrp,
          price: mrp,
          gst: gstVal,
          hsnCode: String(row.HSNCODE || row.hsnCode || '').trim(),
          countryOfOrigin: String(row['COUNTRY OF ORIGIN'] || row.countryOfOrigin || '').trim(),
          category: String(row.Specie || 'General'),
          // Fix: Changed 'Packs' to 'PCS' to match 'PCS' | 'KG' type
          unit: 'PCS',
          baseRate: mrp,
          stock: 0
        };
        if (currentMap.has(sku.toLowerCase())) updatedCount++; else added++;
        currentMap.set(sku.toLowerCase(), productData);
      });
      onUpdateProducts(Array.from(currentMap.values()));
    }
    else if (tab === 'Customer Master') {
      const currentMap = new Map((customers || []).map(c => [c.id.toLowerCase(), c]));
      rows.forEach((row: any) => {
        const id = String(row.id || row.code || '').trim().toLowerCase();
        if (!id) return;
        const customerData: Customer = {
          id: id,
          name: String(row.name || 'New Entity').trim(),
          salesManager: String(row['Sales Manager'] || row.salesManager || '').trim(),
          employeeResponsible: String(row['Employee responsible'] || row.employeeResponsible || '').trim(),
          status: String(row.status || 'Active').trim(),
          distributionChannel: String(row.distributionChannel || '').trim(),
          customerClass: String(row.class || row.customerClass || '').trim(),
          creditLimit: parseFloat(String(row.limit || row.creditLimit || 0).replace(/[₹,]/g, '')) || 0,
          location: String(row.location || '').trim(),
          email: String(row.email || '').trim(),
          postalCode: String(row.postalCode || '').trim(),
          address: String(row.address || '').trim(),
          type: 'Retail',
          outstanding: 0,
          overdue: 0,
          ageingDays: 0,
          creditDays: '0 days',
          securityChqStatus: 'N/A',
          agingBuckets: { '0 to 7': 0, '7 to 15': 0, '15 to 30': 0, '30 to 45': 0, '45 to 90': 0, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 }
        };
        if (currentMap.has(id)) updatedCount++; else added++;
        currentMap.set(id, customerData);
      });
      onUpdateCustomers(Array.from(currentMap.values()));
    }
    else if (tab === 'OD Master') {
      const currentMap = new Map((odMaster || []).map(o => [o.customerId.toLowerCase(), o]));
      rows.forEach((row: any) => {
        const id = String(row['Customer ID'] || row.customerId || '').trim().toLowerCase();
        if (!id) return;
        const odEntry: ODMaster = {
          customerId: id,
          channel: String(row['Channel'] || row.channel || '').trim(),
          salesManager: String(row['Sales Manager'] || row.salesManager || '').trim(),
          customerClass: String(row['Class'] || row.customerClass || '').trim(),
          employeeResponsible: String(row['Employee responsible'] || row.employeeResponsible || '').trim(),
          customerName: String(row['Customer Names'] || row.customerName || '').trim(),
          creditDays: String(row['Credit Days'] || row.creditDays || '').trim(),
          creditLimit: parseFloat(String(row['Credit Limit'] || row.creditLimit || 0).replace(/[₹,]/g, '')) || 0,
          securityChq: String(row['Security Chq'] || row.securityChq || 'N/A').trim(),
          distChannel: String(row['Dist Channel'] || row.distChannel || '').trim(),
          outstandingAmt: parseFloat(String(row['O/s Amt'] || row.outstandingAmt || 0).replace(/[₹,]/g, '')) || 0,
          overdueAmt: parseFloat(String(row['OD Amt'] || row.overdueAmt || 0).replace(/[₹,]/g, '')) || 0,
          diffYesterdayToday: parseFloat(String(row['Diffn btw ydy & tday'] || row.diffYesterdayToday || 0).replace(/[₹,]/g, '')) || 0,
          aging: {
            '0 to 7': parseFloat(String(row['0 to 7'] || 0).replace(/[₹,]/g, '')) || 0,
            '7 to 15': parseFloat(String(row['7 to 15'] || 0).replace(/[₹,]/g, '')) || 0,
            '15 to 30': parseFloat(String(row['15 to 30'] || 0).replace(/[₹,]/g, '')) || 0,
            '30 to 45': parseFloat(String(row['30 to 45'] || 0).replace(/[₹,]/g, '')) || 0,
            '45 to 90': parseFloat(String(row['45 to 90'] || 0).replace(/[₹,]/g, '')) || 0,
            '90 to 120': parseFloat(String(row['90 to 120'] || 0).replace(/[₹,]/g, '')) || 0,
            '120 to 150': parseFloat(String(row['120 to 150'] || 0).replace(/[₹,]/g, '')) || 0,
            '150 to 180': parseFloat(String(row['150 to 180'] || 0).replace(/[₹,]/g, '')) || 0,
            '>180': parseFloat(String(row['>180'] || 0).replace(/[₹,]/g, '')) || 0,
          }
        };
        if (currentMap.has(id)) updatedCount++; else added++;
        currentMap.set(id, odEntry);
      });
      onUpdateOdMaster(Array.from(currentMap.values()));
    }

    setImportStatus({ 
      type: 'success', 
      message: `Smart-Merge Complete: Added ${added} and updated ${updatedCount} records.` 
    });
  };

  const activeList = useMemo(() => {
    switch (activeTab) {
      case 'User Master': return users.filter(u => u.role !== UserRole.DELIVERY);
      case 'Delivery Person': return users.filter(u => u.role === UserRole.DELIVERY);
      case 'Customer Master': return customers;
      case 'Material Master': return products;
      case 'OD Master': return odMaster;
      default: return [];
    }
  }, [activeTab, users, customers, products, odMaster]);

  const handleSaveModal = () => {
    const isEditing = !!editingRecord;
    switch (activeTab) {
      case 'User Master':
      case 'Delivery Person':
        onUpdateUsers(isEditing ? users.map(u => u.id === editingRecord.id ? formData : u) : [...users, formData]);
        break;
      case 'Customer Master':
        onUpdateCustomers(isEditing ? customers.map(c => c.id === editingRecord.id ? formData : c) : [...customers, formData]);
        break;
      case 'OD Master':
        onUpdateOdMaster(isEditing ? odMaster.map(o => o.customerId === editingRecord.customerId ? formData : o) : [...odMaster, formData]);
        break;
      case 'Material Master':
        onUpdateProducts(isEditing ? products.map(m => m.skuCode === editingRecord.skuCode ? formData : m) : [...products, formData]);
        break;
    }
    setIsModalOpen(false);
    setEditingRecord(null);
    setFormData({});
  };

  const handleDelete = (id: string) => {
    if (!window.confirm("Delete record from local state?")) return;
    if (activeTab === 'User Master' || activeTab === 'Delivery Person') onUpdateUsers(users.filter(u => u.id !== id));
    else if (activeTab === 'Customer Master') onUpdateCustomers(customers.filter(c => c.id !== id));
    else if (activeTab === 'OD Master') onUpdateOdMaster(odMaster.filter(o => o.customerId !== id));
    else onUpdateProducts(products.filter(p => p.skuCode !== id));
  };

  return (
    <div className="space-y-8 max-w-[1600px] mx-auto pb-20 animate-in fade-in duration-500">
      <div className="flex flex-wrap items-center justify-between gap-4 bg-slate-200/50 p-1.5 rounded-2xl border border-slate-200 shadow-inner overflow-x-auto no-scrollbar">
        <div className="flex items-center gap-1">
          {(Object.keys(templates) as NexusTab[]).map((tab) => (
            <button 
              key={tab}
              onClick={() => { setActiveTab(tab); setImportStatus({ type: null, message: '' }); }}
              className={`px-5 py-2.5 rounded-xl text-[11px] font-black uppercase tracking-wider transition-all flex items-center gap-2 whitespace-nowrap ${activeTab === tab ? 'bg-indigo-600 text-white shadow-lg' : 'text-slate-500 hover:text-slate-800'}`}
            >
              {tab === 'User Master' && <Users size={14}/>}
              {tab === 'Customer Master' && <ClipboardList size={14}/>}
              {tab === 'Material Master' && <Package size={14}/>}
              {tab === 'Delivery Person' && <Truck size={14}/>}
              {tab === 'OD Master' && <TrendingDown size={14}/>}
              {tab}
            </button>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-4 gap-8">
        <div className="xl:col-span-3 space-y-6">
          <div className="bg-white rounded-[40px] border border-slate-200 p-8 shadow-sm relative overflow-hidden">
             <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6 mb-8">
                <div>
                   <h3 className="text-3xl font-black text-slate-900 tracking-tight">{activeTab}</h3>
                   <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mt-1">Enterprise Master Terminal</p>
                </div>
                <div className="flex gap-2">
                   <button onClick={handleDownloadTemplate} className="p-3 bg-slate-100 rounded-2xl text-slate-600 hover:bg-indigo-50 hover:text-indigo-600 transition-all flex items-center gap-2 text-[10px] font-black uppercase">
                      <FileSpreadsheet size={20} /> Template
                   </button>
                   <button onClick={() => { setEditingRecord(null); setFormData({}); setIsModalOpen(true); }} className="p-3 bg-slate-900 text-white rounded-2xl hover:bg-indigo-600 transition-all flex items-center gap-2 text-[10px] font-black uppercase px-6">
                      <Plus size={20} /> Add New
                   </button>
                </div>
             </div>

             {importStatus.type && (
               <div className={`mb-6 p-4 rounded-2xl flex items-center gap-3 animate-in slide-in-from-top-2 border ${importStatus.type === 'success' ? 'bg-emerald-50 text-emerald-700 border-emerald-100' : 'bg-rose-50 text-rose-700 border-rose-100'}`}>
                  {importStatus.type === 'success' ? <FileCheck size={18}/> : <AlertCircle size={18}/>}
                  <span className="text-xs font-bold">{importStatus.message}</span>
               </div>
             )}

             <div className="rounded-3xl border border-slate-100 overflow-hidden shadow-inner bg-slate-50/30 max-h-[700px] overflow-x-auto overflow-y-auto no-scrollbar">
                <table className="w-full text-left whitespace-nowrap">
                   <thead className="bg-white text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] border-b sticky top-0 z-20">
                      <tr>
                        {activeTab === 'User Master' && <> <th className="px-6 py-5">Name</th> <th className="px-6 py-5">Email</th> <th className="px-6 py-5">Role</th> <th className="px-6 py-5 text-center">Approver</th> </>}
                        {activeTab === 'Delivery Person' && <> <th className="px-6 py-5">Name</th> <th className="px-6 py-5">Email</th> </>}
                        {activeTab === 'Customer Master' && <> <th className="px-6 py-5">ID</th> <th className="px-6 py-5">Name</th> <th className="px-6 py-5">Manager</th> <th className="px-6 py-5">Status</th> <th className="px-6 py-5 text-right">Credit Limit</th> </>}
                        {activeTab === 'OD Master' && <> <th className="px-6 py-5">Cust ID</th> <th className="px-6 py-5">Names</th> <th className="px-6 py-5 text-right">O/s Amt</th> <th className="px-6 py-5 text-right text-rose-500">OD Amt</th> </>}
                        {activeTab === 'Material Master' && <> <th className="px-6 py-5">Code</th> <th className="px-6 py-5">Product Name</th> <th className="px-6 py-5 text-right">MRP</th> <th className="px-6 py-5 text-right">GST%</th> <th className="px-6 py-5">Country</th> </>}
                        <th className="px-6 py-5 w-24">Actions</th>
                      </tr>
                   </thead>
                   <tbody className="divide-y text-xs font-bold text-slate-700">
                      {(activeList || []).map((item: any) => (
                        <tr key={item.id || item.productCode || item.customerId || item.skuCode || Math.random()} className="hover:bg-white group transition-colors">
                          {activeTab === 'User Master' && <> <td className="px-6 py-4">{item.name}</td> <td className="px-6 py-4">{item.id}</td> <td className="px-6 py-4 text-indigo-600">{item.role}</td> <td className="px-6 py-4 text-center">{item.isApprover ? '✅' : '-'}</td> </>}
                          {activeTab === 'Delivery Person' && <> <td className="px-6 py-4">{item.name}</td> <td className="px-6 py-4">{item.id}</td> </>}
                          {activeTab === 'Customer Master' && <> <td className="px-6 py-4">{item.id}</td> <td className="px-6 py-4 font-black">{item.name}</td> <td className="px-6 py-4">{item.salesManager}</td> <td className="px-6 py-4"><span className={`px-2 py-0.5 rounded text-[9px] uppercase ${item.status === 'Active' ? 'bg-emerald-50 text-emerald-600' : 'bg-rose-50 text-rose-600'}`}>{item.status}</span></td> <td className="px-6 py-4 text-right">₹{item.creditLimit?.toLocaleString() || 0}</td> </>}
                          {activeTab === 'OD Master' && <> <td className="px-6 py-4">{item.customerId}</td> <td className="px-6 py-4">{item.customerName}</td> <td className="px-6 py-4 text-right font-black">₹{item.outstandingAmt?.toLocaleString() || 0}</td> <td className="px-6 py-4 text-right font-black text-rose-600">₹{item.overdueAmt?.toLocaleString() || 0}</td> </>}
                          {activeTab === 'Material Master' && <> <td className="px-6 py-4 font-mono text-indigo-600">{item.skuCode}</td> <td className="px-6 py-4">{item.name}</td> <td className="px-6 py-4 text-right font-black">₹{item.price?.toLocaleString() || 0}</td> <td className="px-6 py-4 text-right">{item.gst || 0}%</td> <td className="px-6 py-4 text-slate-400">{item.countryOfOrigin || 'N/A'}</td> </>}
                          <td className="px-6 py-4 text-right flex justify-end gap-2">
                             <button onClick={() => { setEditingRecord(item); setFormData({...item}); setIsModalOpen(true); }} className="p-2 text-slate-300 hover:text-indigo-600 transition-all opacity-0 group-hover:opacity-100"><Pencil size={14}/></button>
                             <button onClick={() => handleDelete(item.id || item.productCode || item.customerId || item.skuCode)} className="p-2 text-slate-300 hover:text-rose-500 transition-all opacity-0 group-hover:opacity-100"><Trash2 size={14} /></button>
                          </td>
                        </tr>
                      ))}
                      {(activeList || []).length === 0 && (
                        <tr>
                          <td colSpan={10} className="px-6 py-24 text-center text-slate-400 italic font-medium">
                             <div className="flex flex-col items-center gap-4">
                                <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-slate-200 shadow-sm border border-slate-100">
                                   <Layers size={32} />
                                </div>
                                <div>
                                   <p className="font-black text-slate-900 uppercase">Database Empty</p>
                                   <p className="text-xs">Use Template or Add New</p>
                                </div>
                             </div>
                          </td>
                        </tr>
                      )}
                   </tbody>
                </table>
             </div>
          </div>
        </div>

        <div className="space-y-6">
           <div className="bg-slate-900 rounded-[40px] p-8 text-white shadow-2xl relative overflow-hidden group">
              <FileUp className="absolute -right-6 -bottom-6 w-32 h-32 opacity-10 group-hover:scale-110 transition-transform duration-700" />
              <h4 className="text-xl font-black flex items-center gap-3 mb-6">
                 <Upload size={24} /> Bulk Append
              </h4>
              <p className="text-xs font-medium text-slate-400 mb-8 leading-relaxed">
                Smart-Merge automatically updates existing keys and appends new entities.
              </p>
              
              <button 
                onClick={() => fileInputRef.current?.click()}
                className="w-full bg-indigo-600 text-white py-5 rounded-2xl font-black text-xs uppercase tracking-[0.2em] shadow-xl hover:bg-indigo-500 transition-all flex items-center justify-center gap-3 active:scale-95"
              >
                <FileSpreadsheet size={16} /> Bulk Import
              </button>
              
              <input 
                type="file" 
                ref={fileInputRef} 
                onChange={handleFileUpload} 
                accept=".csv, .xlsx, .xls" 
                className="hidden" 
              />
           </div>
        </div>
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-slate-900/80 backdrop-blur-sm overflow-y-auto">
           <div className="bg-white w-full max-w-5xl rounded-[40px] p-8 shadow-2xl relative my-8 animate-in zoom-in-95">
              <div className="flex items-center justify-between mb-8">
                 <h4 className="text-2xl font-black text-slate-900 tracking-tight">{editingRecord ? 'Edit' : 'Create'} {activeTab}</h4>
                 <button onClick={() => setIsModalOpen(false)} className="p-2 hover:bg-slate-100 rounded-xl transition-all"><X size={24}/></button>
              </div>

              <div className="space-y-6 max-h-[70vh] overflow-y-auto px-1 pr-4 no-scrollbar">
                 {activeTab === 'Customer Master' && (
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                       <ManualInput label="id" value={formData.id} onChange={v => setFormData({...formData, id: v})} />
                       <ManualInput label="name" value={formData.name} onChange={v => setFormData({...formData, name: v})} />
                       <ManualInput label="Sales Manager" value={formData.salesManager} onChange={v => setFormData({...formData, salesManager: v})} />
                       <ManualInput label="Employee responsible" value={formData.employeeResponsible} onChange={v => setFormData({...formData, employeeResponsible: v})} />
                       <ManualInput label="status" value={formData.status} onChange={v => setFormData({...formData, status: v})} />
                       <ManualInput label="distributionChannel" value={formData.distributionChannel} onChange={v => setFormData({...formData, distributionChannel: v})} />
                       <ManualInput label="class" value={formData.customerClass} onChange={v => setFormData({...formData, customerClass: v})} />
                       <ManualInput label="creditLimit" type="number" value={formData.creditLimit} onChange={v => setFormData({...formData, creditLimit: parseFloat(v)||0})} />
                       <ManualInput label="location" value={formData.location} onChange={v => setFormData({...formData, location: v})} />
                       <ManualInput label="email" value={formData.email} onChange={v => setFormData({...formData, email: v})} />
                    </div>
                 )}

                 {activeTab === 'OD Master' && (
                    <div className="space-y-8">
                       <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                          <ManualInput label="Customer ID" value={formData.customerId} onChange={v => setFormData({...formData, customerId: v})} />
                          <ManualInput label="Customer Names" value={formData.customerName} onChange={v => setFormData({...formData, customerName: v})} />
                          <ManualInput label="Credit Limit" type="number" value={formData.creditLimit} onChange={v => setFormData({...formData, creditLimit: parseFloat(v)||0})} />
                          <ManualInput label="O/s Amt" type="number" value={formData.outstandingAmt} onChange={v => setFormData({...formData, outstandingAmt: parseFloat(v)||0})} />
                          <ManualInput label="OD Amt" type="number" value={formData.overdueAmt} onChange={v => setFormData({...formData, overdueAmt: parseFloat(v)||0})} />
                       </div>
                       <div className="bg-slate-50 p-6 rounded-3xl border border-slate-100">
                          <h5 className="text-[11px] font-black uppercase text-indigo-600 mb-6 flex items-center gap-2"><History size={14}/> Ageing Buckets Analysis</h5>
                          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
                             {['0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90', '90 to 120', '120 to 150', '150 to 180', '>180'].map(bucket => (
                               <ManualInput key={bucket} label={`${bucket} Days`} type="number" value={formData.aging?.[bucket]} onChange={v => setFormData({ ...formData, aging: { ...(formData.aging || {}), [bucket]: parseFloat(v) || 0 } })} />
                             ))}
                          </div>
                       </div>
                    </div>
                 )}

                 {activeTab === 'Material Master' && (
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                       <ManualInput label="ProductCode" value={formData.skuCode} onChange={v => setFormData({...formData, skuCode: v, id: v})} />
                       <ManualInput label="Product Name" value={formData.name} onChange={v => setFormData({...formData, name: v, productName: v})} />
                       <ManualInput label="MRP / Price" type="number" value={formData.price} onChange={v => setFormData({...formData, price: parseFloat(v)||0, mrp: parseFloat(v)||0, baseRate: parseFloat(v)||0})} />
                       <ManualInput label="GST%" type="number" value={formData.gst} onChange={v => setFormData({...formData, gst: parseFloat(v)||0})} />
                       <ManualInput label="HSNCODE" value={formData.hsnCode} onChange={v => setFormData({...formData, hsnCode: v})} />
                       <ManualInput label="Specie" value={formData.specie} onChange={v => setFormData({...formData, specie: v})} />
                       <ManualInput label="Weight" value={formData.productWeight} onChange={v => setFormData({...formData, productWeight: v})} />
                       <ManualInput label="Country" value={formData.countryOfOrigin} onChange={v => setFormData({...formData, countryOfOrigin: v})} />
                    </div>
                 )}

                 {(activeTab === 'User Master' || activeTab === 'Delivery Person') && (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                       <ManualInput label="name" value={formData.name} onChange={v => setFormData({...formData, name: v})} />
                       <ManualInput label="email" value={formData.id} onChange={v => setFormData({...formData, id: v})} />
                       {activeTab === 'User Master' && (
                         <>
                          <ManualInput label="role" value={formData.role} onChange={v => setFormData({...formData, role: v})} />
                          <div className="flex items-center gap-3 p-4 bg-slate-50 rounded-2xl border-2 border-slate-100 mt-4">
                            <input type="checkbox" checked={formData.isApprover} onChange={e => setFormData({...formData, isApprover: e.target.checked})} />
                            <label className="text-xs font-black uppercase text-slate-700">Can Approve Orders</label>
                          </div>
                         </>
                       )}
                    </div>
                 )}
              </div>

              <div className="mt-10 pt-8 border-t flex gap-4">
                 <button onClick={() => setIsModalOpen(false)} className="flex-1 py-4 text-xs font-black uppercase text-slate-400">Abort</button>
                 <button onClick={handleSaveModal} className="flex-[2] bg-slate-900 text-white py-4 rounded-2xl font-black text-xs uppercase tracking-widest shadow-xl transition-all active:scale-95">Commit To Master</button>
              </div>
           </div>
        </div>
      )}
    </div>
  );
};

// Fixed unintentional comparison between string and number by removing default string value in destructuring and updating the zero check.
const ManualInput: React.FC<{ label: string, type?: string, value?: any, onChange: (v: string) => void }> = ({ label, type = 'text', value, onChange }) => (
  <div className="space-y-2">
     <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">{label}</label>
     <input type={type} value={value === 0 || value === '0' ? '0' : (value || '')} className="w-full border-2 border-slate-100 rounded-xl px-4 py-3 text-sm font-bold focus:border-indigo-600 outline-none transition-all" onChange={(e) => onChange(e.target.value)} />
  </div>
);

export default MasterDataView;
