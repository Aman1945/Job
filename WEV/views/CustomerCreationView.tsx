
import React, { useState, useRef } from 'react';
import { Customer, User, UserRole } from '../types';
import { 
  UserPlus, 
  Save, 
  ArrowRight, 
  Building2, 
  MapPin, 
  FileText, 
  CreditCard, 
  ShieldCheck,
  FileUp,
  X,
  UserCheck,
  CheckCircle2
} from 'lucide-react';

interface CustomerCreationViewProps {
  users: User[];
  onSubmit: (customer: Customer) => void;
}

const STATES = [
  "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat", 
  "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh", 
  "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab", 
  "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", 
  "Uttarakhand", "West Bengal"
];

const CustomerCreationView: React.FC<CustomerCreationViewProps> = ({ users, onSubmit }) => {
  const [formData, setFormData] = useState<Partial<Customer>>({
    name: '',
    address: '',
    constitution: 'Proprietorship',
    partnerDirectorNames: '',
    telephoneMobile: '',
    email: '',
    gstNo: '',
    fssaiLicenseNo: '',
    panCard: '',
    regionState: '',
    salesManager: '',
    employeeResponsible: '',
    saleOffice: '2611',
    saleOrganization: '5200',
    distributionChannel: '19',
    division: '70',
    creditDays: '',
    creditLimit: 0,
    type: ''
  });

  const [attachments, setAttachments] = useState<{
    gst: { file: string | null; name: string | null };
    pan: { file: string | null; name: string | null };
    cheque: { file: string | null; name: string | null };
  }>({
    gst: { file: null, name: null },
    pan: { file: null, name: null },
    cheque: { file: null, name: null }
  });

  const fileRefs = {
    gst: useRef<HTMLInputElement>(null),
    pan: useRef<HTMLInputElement>(null),
    cheque: useRef<HTMLInputElement>(null)
  };

  const handleFileUpload = (type: keyof typeof attachments, e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setAttachments(prev => ({
          ...prev,
          [type]: { file: reader.result as string, name: file.name }
        }));
      };
      reader.readAsDataURL(file);
    }
  };

  const salesUsers = users.filter(u => u.role === UserRole.SALES || u.role === UserRole.ADMIN);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Basic validations requested: email and digits for phone
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (formData.email && !emailRegex.test(formData.email)) {
      alert("Invalid Email format");
      return;
    }
    
    const phoneDigitsOnly = formData.telephoneMobile?.replace(/\D/g, '');
    if (!phoneDigitsOnly || phoneDigitsOnly.length < 10) {
      alert("Telephone/Mobile should be digits only (min 10)");
      return;
    }

    const newCustomer: Customer = {
      ...formData as Customer,
      id: 'CUST-' + Math.floor(Math.random() * 9000 + 1000),
      outstanding: 0,
      overdue: 0,
      ageingDays: 0,
      status: 'Active',
      securityChqStatus: attachments.cheque.file ? 'Yes' : 'No',
      agingBuckets: { '0 to 7': 0, '7 to 15': 0, '15 to 30': 0, '30 to 45': 0, '45 to 90': 0, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 },
      gstCertificateFile: attachments.gst.file || undefined,
      panCardFile: attachments.pan.file || undefined,
      securityChequeFile: attachments.cheque.file || undefined
    };

    onSubmit(newCustomer);
  };

  return (
    <div className="max-w-6xl mx-auto pb-20 animate-in fade-in duration-500">
      <div className="bg-white rounded-[50px] border border-slate-200 shadow-sm overflow-hidden mb-10">
        <div className="p-12 border-b bg-slate-50/50 flex items-center justify-between">
          <div>
            <h2 className="text-4xl font-black text-slate-900 tracking-tighter">New Customer Onboarding</h2>
            <p className="text-slate-500 font-medium mt-2">Enterprise Client Registry Setup (End-to-End Workflow)</p>
          </div>
          <div className="w-16 h-16 bg-emerald-600 rounded-3xl flex items-center justify-center text-white shadow-2xl shadow-emerald-500/30">
            <UserPlus size={32} />
          </div>
        </div>

        <form onSubmit={handleSubmit} className="p-12 space-y-12">
          {/* STEP 1: Particulars */}
          <section className="space-y-10">
             <div className="flex items-center gap-3">
                <div className="w-1.5 h-8 bg-emerald-600 rounded-full" />
                <h3 className="text-xl font-black text-slate-900 tracking-tight uppercase">Step 1: General Particulars</h3>
             </div>

             <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                <Field label="1. Name of Customer" value={formData.name} onChange={v => setFormData({...formData, name: v})} required />
                <div className="lg:col-span-2">
                   <Field label="2. Address of Customer" value={formData.address} onChange={v => setFormData({...formData, address: v})} required />
                </div>
                
                <div className="space-y-2">
                   <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">3. Constitution</label>
                   <select 
                     className="w-full border-2 border-slate-100 rounded-2xl px-5 py-4 font-bold text-sm bg-white focus:border-emerald-600 outline-none transition-all appearance-none"
                     value={formData.constitution}
                     onChange={e => setFormData({...formData, constitution: e.target.value as any})}
                   >
                      <option value="Proprietorship">Proprietorship</option>
                      <option value="Partnership">Partnership</option>
                      <option value="Company">Company</option>
                   </select>
                </div>

                <Field label="4. Partners/Directors Names" value={formData.partnerDirectorNames} onChange={v => setFormData({...formData, partnerDirectorNames: v})} />
                <Field label="5. Telephone & Mobile" placeholder="Digits only" value={formData.telephoneMobile} onChange={v => setFormData({...formData, telephoneMobile: v})} required />
                <Field label="6. Email ID" placeholder="format@domain.com" type="email" value={formData.email} onChange={v => setFormData({...formData, email: v})} required />
                
                <Field label="7. GST No" value={formData.gstNo} onChange={v => setFormData({...formData, gstNo: v})} required />
                <Field label="8. FSSAI License No" value={formData.fssaiLicenseNo} onChange={v => setFormData({...formData, fssaiLicenseNo: v})} />
                <Field label="9. Pan Card" value={formData.panCard} onChange={v => setFormData({...formData, panCard: v})} required />
                
                <div className="space-y-2">
                   <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">10. Region (State)</label>
                   <select 
                     className="w-full border-2 border-slate-100 rounded-2xl px-5 py-4 font-bold text-sm bg-white focus:border-emerald-600 outline-none transition-all appearance-none"
                     value={formData.regionState}
                     onChange={e => setFormData({...formData, regionState: e.target.value})}
                     required
                   >
                      <option value="">Select State...</option>
                      {STATES.map(s => <option key={s} value={s}>{s}</option>)}
                   </select>
                </div>

                <div className="space-y-2">
                   <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">12. Sales Manager</label>
                   <select 
                     className="w-full border-2 border-slate-100 rounded-2xl px-5 py-4 font-bold text-sm bg-white focus:border-emerald-600 outline-none transition-all appearance-none"
                     value={formData.salesManager}
                     onChange={e => setFormData({...formData, salesManager: e.target.value})}
                     required
                   >
                      <option value="">Assign Manager...</option>
                      {salesUsers.map(u => <option key={u.id} value={u.name}>{u.name}</option>)}
                   </select>
                </div>

                <div className="space-y-2">
                   <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">13. Employee Responsible</label>
                   <select 
                     className="w-full border-2 border-slate-100 rounded-2xl px-5 py-4 font-bold text-sm bg-white focus:border-emerald-600 outline-none transition-all appearance-none"
                     value={formData.employeeResponsible}
                     onChange={e => setFormData({...formData, employeeResponsible: e.target.value})}
                     required
                   >
                      <option value="">Select Employee...</option>
                      {salesUsers.map(u => <option key={u.id} value={u.name}>{u.name}</option>)}
                   </select>
                </div>

                <Field label="14. Sale Office" value={formData.saleOffice} onChange={v => setFormData({...formData, saleOffice: v})} disabled />
                <Field label="15. Sale Organization" value={formData.saleOrganization} onChange={v => setFormData({...formData, saleOrganization: v})} disabled />
                <Field label="16. Distribution Channel" value={formData.distributionChannel} onChange={v => setFormData({...formData, distributionChannel: v})} disabled />
                <Field label="17. Division" value={formData.division} onChange={v => setFormData({...formData, division: v})} disabled />
             </div>
          </section>

          {/* STEP 2: Financials */}
          <section className="space-y-10 pt-10 border-t border-slate-100">
             <div className="flex items-center gap-3">
                <div className="w-1.5 h-8 bg-indigo-600 rounded-full" />
                <h3 className="text-xl font-black text-slate-900 tracking-tight uppercase">Step 2: Credit Parameters</h3>
             </div>

             <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                <Field label="1. Credit Days (Nos)" type="number" value={formData.creditDays} onChange={v => setFormData({...formData, creditDays: v})} required />
                <Field label="2. Credit Limit (Amount)" type="number" value={formData.creditLimit} onChange={v => setFormData({...formData, creditLimit: parseFloat(v)||0})} required />
                <Field label="Customer Type" value={formData.type} onChange={v => setFormData({...formData, type: v})} placeholder="e.g. Modern Trade / Retail" required />
             </div>
          </section>

          {/* ATTACHMENTS */}
          <section className="space-y-10 pt-10 border-t border-slate-100">
             <div className="flex items-center gap-3">
                <div className="w-1.5 h-8 bg-amber-500 rounded-full" />
                <h3 className="text-xl font-black text-slate-900 tracking-tight uppercase">Step 3: Document Repository</h3>
             </div>

             <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                <UploadCard 
                   label="GST Certificate" 
                   attachment={attachments.gst} 
                   onUpload={(e) => handleFileUpload('gst', e)} 
                   onClear={() => setAttachments({...attachments, gst: {file: null, name: null}})} 
                   fileRef={fileRefs.gst}
                />
                <UploadCard 
                   label="PAN Card Copy" 
                   attachment={attachments.pan} 
                   onUpload={(e) => handleFileUpload('pan', e)} 
                   onClear={() => setAttachments({...attachments, pan: {file: null, name: null}})} 
                   fileRef={fileRefs.pan}
                />
                <UploadCard 
                   label="Security Cheque" 
                   attachment={attachments.cheque} 
                   onUpload={(e) => handleFileUpload('cheque', e)} 
                   onClear={() => setAttachments({...attachments, cheque: {file: null, name: null}})} 
                   fileRef={fileRefs.cheque}
                />
             </div>
          </section>

          <div className="pt-10 border-t border-slate-100 flex flex-col md:flex-row justify-between items-center gap-8">
             <div className="bg-emerald-50 px-8 py-4 rounded-3xl border border-emerald-100 flex items-center gap-4">
                <ShieldCheck size={28} className="text-emerald-600" />
                <div>
                   <p className="text-[10px] font-black uppercase text-emerald-700 tracking-widest">Compliance Ready</p>
                   <p className="text-sm font-bold text-slate-600">Verification protocol active</p>
                </div>
             </div>
             <button 
               type="submit" 
               className="w-full md:w-auto px-20 py-7 bg-slate-900 text-white rounded-[32px] font-black text-sm uppercase tracking-[0.25em] shadow-2xl hover:bg-emerald-600 transition-all active:scale-95 flex items-center justify-center gap-4"
             >
                Commit Master Record <Save size={20} />
             </button>
          </div>
        </form>
      </div>
    </div>
  );
};

const Field = ({ label, value, onChange, placeholder, type = 'text', required = false, disabled = false }: any) => (
  <div className="space-y-2">
     <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">
       {label} {required && <span className="text-rose-500">*</span>}
     </label>
     <input 
        type={type}
        disabled={disabled}
        className={`w-full border-2 rounded-2xl px-6 py-4 font-bold text-sm transition-all outline-none ${disabled ? 'bg-slate-100 border-slate-200 text-slate-400' : 'border-slate-100 focus:border-emerald-600 bg-white shadow-sm'}`}
        placeholder={placeholder}
        value={value}
        onChange={e => onChange(e.target.value)}
        required={required}
     />
  </div>
);

const UploadCard = ({ label, attachment, onUpload, onClear, fileRef }: any) => (
  <div 
    onClick={() => !attachment.file && fileRef.current?.click()}
    className={`group relative aspect-[4/3] rounded-[40px] border-4 border-dashed transition-all flex flex-col items-center justify-center gap-4 cursor-pointer overflow-hidden ${attachment.file ? 'border-emerald-600 bg-white' : 'border-slate-200 bg-slate-50 hover:bg-emerald-50/50 hover:border-emerald-300'}`}
  >
     {attachment.file ? (
        <>
          <img src={attachment.file} className="absolute inset-0 w-full h-full object-contain p-6" alt="Preview" />
          <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm flex flex-col items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
             <CheckCircle2 className="text-emerald-400 mb-2" size={40} />
             <p className="text-xs font-black text-white uppercase tracking-widest">Document Secured</p>
             <p className="text-[10px] text-white/60 mt-1 truncate max-w-[80%]">{attachment.name}</p>
             <button 
                type="button" 
                onClick={(e) => { e.stopPropagation(); onClear(); }}
                className="mt-4 px-6 py-2 bg-rose-500 text-white rounded-xl text-[10px] font-black uppercase hover:bg-rose-600 transition-colors"
             >
                Remove
             </button>
          </div>
        </>
     ) : (
        <>
          <div className="w-16 h-16 bg-white rounded-3xl flex items-center justify-center text-slate-300 group-hover:text-emerald-500 group-hover:scale-110 transition-all shadow-sm">
             <FileUp size={32} />
          </div>
          <div className="text-center">
             <p className="text-xs font-black text-slate-700 uppercase tracking-widest">{label}</p>
             <p className="text-[10px] text-slate-400 font-medium italic mt-1">Snapshot Required</p>
          </div>
        </>
     )}
     <input type="file" ref={fileRef} className="hidden" accept="image/*,.pdf" onChange={onUpload} />
  </div>
);

export default CustomerCreationView;
