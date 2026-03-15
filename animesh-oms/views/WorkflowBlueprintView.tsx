
import React, { useState } from 'react';
import { 
  GitMerge, 
  UserPlus, 
  ShoppingBag, 
  Zap, 
  Warehouse, 
  Box, 
  ShieldCheck, 
  DollarSign, 
  Receipt, 
  Truck, 
  CheckCircle2,
  ArrowRight,
  ChevronRight,
  Info,
  Layers,
  Settings,
  Activity
} from 'lucide-react';

interface StageDefinition {
  id: number;
  title: string;
  role: string;
  icon: any;
  color: string;
  process: string[];
  transition: string;
  visuals: string;
}

const STAGES: StageDefinition[] = [
  {
    id: 0,
    title: "Customer Onboarding",
    role: "Sales / Admin",
    icon: <UserPlus />,
    color: "emerald",
    process: [
      "Gather KYC documents (GST, PAN, Security Cheque).",
      "Define credit parameters (Limit and Credit Days).",
      "Assign a permanent Sales Manager and Employee Responsible."
    ],
    transition: "Upon 'Commit Master Record', the customer becomes active in the database and is immediately available for Order Booking.",
    visuals: "Blue 'New Customer' view with document upload cards."
  },
  {
    id: 1,
    title: "Order Booking",
    role: "Sales Team",
    icon: <ShoppingBag />,
    color: "indigo",
    process: [
      "Select customer and audit live Credit Exposure.",
      "Add SKU line items with auto-fetched historical pricing.",
      "Attach Customer PO or PDC snapshot as primary evidence."
    ],
    transition: "On 'Save', status becomes 'PENDING_CREDIT_APPROVAL'. If it's a Stock Transfer (STN), it bypasses Stage 2 and moves directly to 'PENDING_WH_SELECTION'.",
    visuals: "Dynamic order form with real-time aging bucket table."
  },
  {
    id: 2,
    title: "Credit Control",
    role: "Finance Team",
    icon: <Zap />,
    color: "amber",
    process: [
      "Audit customer outstanding vs credit limit.",
      "Review aging buckets for critical overdue (15+ days).",
      "AI provides 'Approval Insight' based on risk factors."
    ],
    transition: "On 'Approve', status moves to 'PENDING_WH_SELECTION'. On 'Hold', it stays in the queue. On 'Reject', it returns to Sales for clarification.",
    visuals: "High-contrast risk matrix with Rose/Emerald status cards."
  },
  {
    id: 2.5,
    title: "Warehouse Assignment",
    role: "Operations Manager",
    icon: <Warehouse />,
    color: "slate",
    process: [
      "Analyze order geography and SKU availability.",
      "Select optimal cold-room facility (Kurla, DP World, etc.).",
      "For STNs, confirm the source warehouse identity."
    ],
    transition: "On 'Assign', the status updates to 'PENDING_PACKING'. The order now appears only in the dashboard of the selected warehouse team.",
    visuals: "Facility cards with active mission counters."
  },
  {
    id: 3,
    title: "Warehouse Fulfillment",
    role: "Warehouse / Packing",
    icon: <Box />,
    color: "emerald",
    process: [
      "Batch picking from cold storage.",
      "Mandatory scan/entry of Barcodes, Batch IDs, Mfg and Exp dates.",
      "Log packaging consumption (Thermacol boxes and Dry Ice KG)."
    ],
    transition: "On 'Finalize', status becomes 'PENDING_QC'. If items are missing, it flags as 'PART_PACKED', creating a shortfall record.",
    visuals: "Inventory picking terminal with barcode validation."
  },
  {
    id: 3.5,
    title: "Quality Control (QC)",
    role: "QC Agent",
    icon: <ShieldCheck />,
    color: "indigo",
    process: [
      "Verify core temperature standards (-18°C or 0-4°C).",
      "Audit physical packaging integrity and label clarity.",
      "Capture a 'Load Snapshot' as visual proof of standard compliance."
    ],
    transition: "On 'Approve', status moves to 'READY_FOR_BILLING'. On 'Reject', the mission is sent back to fulfillment for correction.",
    visuals: "Inspection checklist with photo upload terminal."
  },
  {
    id: 4,
    title: "Logistics Costing",
    role: "Logistics Team",
    icon: <DollarSign />,
    color: "amber",
    process: [
      "Input freight surcharges (WH-to-Station, Stat-to-Hub, etc.).",
      "Calculate surcharge as a % of load value (The 'Ratio Health').",
      "Define vehicle provider (Internal vs Porter)."
    ],
    transition: "On 'Define Costs', the financial burden is locked into the order metadata, and status moves to 'PENDING_LOGISTICS' (Billing).",
    visuals: "Cost breakdown matrix with ratio health indicators."
  },
  {
    id: 5,
    title: "Invoicing",
    role: "Billing Team",
    icon: <Receipt />,
    color: "emerald",
    process: [
      "Reconcile final packed items vs original order.",
      "Sync or upload the final Tax Invoice from accounting (Tally).",
      "Final audit of all surcharges and discounts."
    ],
    transition: "On 'Invoice Upload', status moves to 'READY_FOR_DISPATCH'. The mission is now ready for physical loading.",
    visuals: "Billing dashboard with document history."
  },
  {
    id: 6,
    title: "Fleet Loading (Hub)",
    role: "Logistics Hub",
    icon: <Truck />,
    color: "indigo",
    process: [
      "Group invoiced orders for regional routing.",
      "Assign a physical Delivery Agent and Vehicle Reg No.",
      "Confirm 'Loading' status once the vehicle leaves the hub."
    ],
    transition: "On 'Confirm Loading', status becomes 'DISPATCHED' or 'PICKED_UP'. The mission now appears in the Delivery Agent's mobile terminal.",
    visuals: "Fleet assignment board with unassigned queue."
  },
  {
    id: 7,
    title: "Delivery Execution",
    role: "Delivery Agent",
    icon: <CheckCircle2 />,
    color: "emerald",
    process: [
      "Follow route to customer door.",
      "Record delivery outcome (Full, Part, or Refused).",
      "Mandatory capture of signed Ack. copy / POD photo."
    ],
    transition: "On 'Vault POD', the mission is officially 'DELIVERED'. POD data is uploaded to secure cloud storage and archived in the Order History.",
    visuals: "Mobile-first execution view with camera integration."
  }
];

const WorkflowBlueprintView: React.FC = () => {
  const [activeStage, setActiveStage] = useState(0);

  const colors: Record<string, string> = {
    emerald: 'bg-emerald-50 text-emerald-600 border-emerald-100',
    indigo: 'bg-indigo-50 text-indigo-600 border-indigo-100',
    amber: 'bg-amber-50 text-amber-600 border-amber-100',
    slate: 'bg-slate-50 text-slate-600 border-slate-200',
  };

  const darkColors: Record<string, string> = {
    emerald: 'bg-emerald-600',
    indigo: 'bg-indigo-600',
    amber: 'bg-amber-500',
    slate: 'bg-slate-800',
  };

  const current = STAGES.find(s => s.id === activeStage) || STAGES[0];

  return (
    <div className="max-w-[1600px] mx-auto space-y-10 pb-24 animate-in fade-in duration-700">
      
      {/* Blueprint Header */}
      <div className="bg-slate-900 rounded-[50px] p-12 text-white shadow-2xl relative overflow-hidden group border border-slate-800">
         <GitMerge className="absolute -right-12 -bottom-12 w-96 h-96 opacity-[0.03] text-indigo-400 group-hover:scale-110 transition-transform duration-1000" />
         <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-10">
            <div className="flex items-center gap-8">
               <div className="w-24 h-24 bg-gradient-to-br from-indigo-600 to-indigo-400 rounded-[32px] flex items-center justify-center text-white shadow-2xl shadow-indigo-500/20">
                  <Layers size={48} />
               </div>
               <div>
                  <h2 className="text-5xl font-black tracking-tighter">Workflow Blueprint</h2>
                  <p className="text-indigo-400 font-black uppercase tracking-[0.3em] text-sm mt-2">End-to-End Mission Governance</p>
               </div>
            </div>
            <div className="bg-white/5 p-6 rounded-[32px] border border-white/10 backdrop-blur-md">
               <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Standard Operating Protocol</p>
               <p className="text-xl font-bold">Version 2.4 Active</p>
            </div>
         </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-10">
         
         {/* Stage Navigation */}
         <div className="lg:col-span-1 space-y-4 h-fit sticky top-8">
            <h3 className="text-xs font-black text-slate-400 uppercase tracking-widest px-4 mb-6 flex items-center gap-2">
               <Settings size={14} /> Mission Lifecycle
            </h3>
            {STAGES.map((stage) => (
               <button 
                  key={stage.id}
                  onClick={() => setActiveStage(stage.id)}
                  className={`w-full flex items-center gap-4 p-5 rounded-[28px] border-2 transition-all group ${activeStage === stage.id ? 'bg-white border-indigo-600 shadow-xl scale-[1.05]' : 'bg-transparent border-transparent text-slate-400 hover:bg-slate-100'}`}
               >
                  <div className={`w-12 h-12 rounded-2xl flex items-center justify-center transition-all ${activeStage === stage.id ? 'bg-indigo-600 text-white shadow-lg' : 'bg-slate-100 text-slate-300 group-hover:bg-indigo-50 group-hover:text-indigo-600'}`}>
                     {React.cloneElement(stage.icon, { size: 24 })}
                  </div>
                  <div className="text-left">
                     <p className={`text-[10px] font-black uppercase tracking-widest ${activeStage === stage.id ? 'text-indigo-600' : 'text-slate-400'}`}>Stage {stage.id}</p>
                     <p className={`text-sm font-black tracking-tight ${activeStage === stage.id ? 'text-slate-900' : 'text-slate-500'}`}>{stage.title}</p>
                  </div>
                  <ChevronRight className={`ml-auto transition-all ${activeStage === stage.id ? 'text-indigo-600 translate-x-1' : 'opacity-0'}`} size={18} />
               </button>
            ))}
         </div>

         {/* Stage Detail Card */}
         <div className="lg:col-span-3">
            <div className="bg-white rounded-[50px] border border-slate-200 shadow-sm p-12 space-y-12 animate-in slide-in-from-right-10 duration-500">
               
               <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-8">
                  <div className="flex items-center gap-8">
                     <div className={`w-20 h-20 rounded-[32px] flex items-center justify-center text-white shadow-xl ${darkColors[current.color]}`}>
                        {React.cloneElement(current.icon, { size: 40 })}
                     </div>
                     <div>
                        <span className="bg-slate-100 text-slate-500 px-4 py-1 rounded-full text-[10px] font-black uppercase tracking-widest">Phase {current.id}</span>
                        <h3 className="text-4xl font-black text-slate-900 tracking-tighter mt-3">{current.title}</h3>
                        <p className="text-slate-400 font-bold uppercase tracking-widest text-xs mt-1">Responsible Entity: <span className="text-indigo-600">{current.role}</span></p>
                     </div>
                  </div>
                  {activeStage < STAGES[STAGES.length - 1].id && (
                     <button 
                        onClick={() => setActiveStage(STAGES[activeStage < 2 ? activeStage + 1 : activeStage + 1].id)} // handling the 2.5 ID
                        className="bg-slate-900 text-white px-8 py-4 rounded-3xl font-black text-xs uppercase tracking-widest flex items-center gap-3 hover:bg-indigo-600 transition-all shadow-xl active:scale-95"
                     >
                        Next Stage <ArrowRight size={18} />
                     </button>
                  )}
               </div>

               <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
                  <div className="space-y-8">
                     <div className="space-y-6">
                        <h4 className="text-xl font-black flex items-center gap-3"><Activity className="text-indigo-600" /> Operational Protocol</h4>
                        <div className="space-y-4">
                           {current.process.map((step, i) => (
                             <div key={i} className="flex gap-4 p-5 bg-slate-50 rounded-3xl border border-slate-100 group hover:border-indigo-200 transition-all">
                                <div className="w-8 h-8 rounded-xl bg-white flex items-center justify-center text-indigo-600 font-black text-xs shadow-sm border border-slate-100 group-hover:scale-110 transition-transform">
                                   {i + 1}
                                </div>
                                <p className="text-sm font-bold text-slate-600 leading-relaxed flex-1">{step}</p>
                             </div>
                           ))}
                        </div>
                     </div>
                  </div>

                  <div className="space-y-8">
                     <div className="bg-indigo-950 rounded-[44px] p-10 text-white shadow-2xl relative overflow-hidden group border border-indigo-900">
                        <GitMerge className="absolute -right-6 -top-6 w-32 h-32 opacity-10" />
                        <h4 className="text-xl font-black mb-6 flex items-center gap-3"><ChevronRight className="text-emerald-400" /> Transition Logic</h4>
                        <p className="text-sm leading-relaxed font-medium text-indigo-100/80 italic">
                           "{current.transition}"
                        </p>
                     </div>

                     <div className="bg-white p-10 rounded-[44px] border border-slate-200 shadow-sm space-y-6">
                        <h4 className="text-xl font-black flex items-center gap-3"><Info className="text-amber-500" /> View Architecture</h4>
                        <div className="p-6 bg-slate-50 rounded-3xl border border-slate-100">
                           <p className="text-xs font-bold text-slate-500 leading-relaxed">
                              <span className="text-slate-900 font-black uppercase block mb-2">Visual Descriptor:</span>
                              {current.visuals}
                           </p>
                        </div>
                     </div>
                  </div>
               </div>

               <div className="pt-12 border-t border-slate-100 flex flex-col md:flex-row items-center justify-between gap-8">
                  <div className="flex items-center gap-4">
                     <div className="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center">
                        <ShieldCheck size={24} />
                     </div>
                     <div>
                        <p className="text-[10px] font-black uppercase text-slate-400">Governance Level</p>
                        <p className="text-sm font-black text-slate-900">Enterprise Certified Workflow</p>
                     </div>
                  </div>
                  <div className="flex items-center gap-3">
                     {STAGES.map((s) => (
                        <div key={s.id} className={`w-3 h-3 rounded-full transition-all duration-500 ${activeStage === s.id ? 'bg-indigo-600 w-8' : 'bg-slate-200'}`} />
                     ))}
                  </div>
               </div>

            </div>
         </div>

      </div>

    </div>
  );
};

export default WorkflowBlueprintView;
