
import React, { useState, useMemo } from 'react';
import { User, UserRole, DailyProtocol, ChecklistTask } from '../types';
import { 
  CheckCircle2, 
  ShieldAlert, 
  ShieldCheck,
  LogOut, 
  AlertTriangle,
  ClipboardList,
  Lock,
  Zap,
  ArrowRight,
  Info,
  Warehouse,
  Thermometer,
  CloudUpload,
  UserCheck,
  Clock
} from 'lucide-react';

interface DailyProtocolViewProps {
  currentUser: User;
  onProtocolUpdate: (protocol: DailyProtocol) => void;
  existingProtocols: DailyProtocol[];
}

// Extending the task type locally to handle headings
interface GroupedTask extends ChecklistTask {
  group: 'General' | 'Kurla - Pradip' | 'Dp World - Roshan';
}

const DailyProtocolView: React.FC<DailyProtocolViewProps> = ({ currentUser, onProtocolUpdate, existingProtocols }) => {
  const today = new Date().toISOString().split('T')[0];
  
  const getInitialTasks = (role: string): GroupedTask[] => {
    const baseTasks: GroupedTask[] = [
      { id: 'gen-1', label: 'Shift Handover & Briefing', completed: false, doneCount: 0, pendingCount: 0, group: 'General' },
      { id: 'gen-2', label: 'Safety Gear (PPE) Audit', completed: false, doneCount: 0, pendingCount: 0, group: 'General' },
    ];

    // Facility specific tasks for Pradip @ Kurla
    const kurlaTasks: GroupedTask[] = [
      { id: 'ku-1', label: 'Production entry in google sheet', completed: false, doneCount: 0, pendingCount: 0, group: 'Kurla - Pradip' },
      { id: 'ku-2', label: 'Inward entry in google sheet', completed: false, doneCount: 0, pendingCount: 0, group: 'Kurla - Pradip' },
      { id: 'ku-3', label: 'Outward entry in google sheet invoice no & batch', completed: false, doneCount: 0, pendingCount: 0, group: 'Kurla - Pradip' },
      { id: 'ku-4', label: 'STN mail protocol', completed: false, doneCount: 0, pendingCount: 0, group: 'Kurla - Pradip' },
      { id: 'ku-5', label: 'STN confirmations audit', completed: false, doneCount: 0, pendingCount: 0, group: 'Kurla - Pradip' },
      { id: 'ku-6', label: 'Negative stock in Google Sheet audit', completed: false, doneCount: 0, pendingCount: 0, group: 'Kurla - Pradip' },
      { id: 'ku-7', label: 'Unpack Stock details verification', completed: false, doneCount: 0, pendingCount: 0, group: 'Kurla - Pradip' },
      { id: 'ku-8', label: 'Consumables Stock Report submission', completed: false, doneCount: 0, pendingCount: 0, group: 'Kurla - Pradip' },
    ];

    // Facility specific tasks for Roshan @ DP World
    const dpWorldTasks: GroupedTask[] = [
      { id: 'dp-1', label: 'Repackaging entry in google sheet', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
      { id: 'dp-2', label: 'Inward entry in google sheet verification', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
      { id: 'dp-3', label: 'Outward entry in google sheet with invoice no & batch', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
      { id: 'dp-4', label: 'STN / Dispatch mail protocol', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
      { id: 'dp-5', label: 'STN confirmations (Awaiting Response)', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
      { id: 'dp-6', label: 'Negative stock in Google Sheet check', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
      { id: 'dp-7', label: 'Unpack Stock details audit', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
      { id: 'dp-8', label: 'Consumables Stock Report finalization', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
      { id: 'dp-9', label: 'Pallets count physical verification', completed: false, doneCount: 0, pendingCount: 0, group: 'Dp World - Roshan' },
    ];

    return [...baseTasks, ...kurlaTasks, ...dpWorldTasks];
  };

  const [currentProtocol, setCurrentProtocol] = useState<DailyProtocol>(() => {
    const existing = existingProtocols.find(p => p.date === today && p.userId === currentUser.id);
    if (existing) return existing;
    return {
      userId: currentUser.id,
      date: today,
      tasks: getInitialTasks(currentUser.role),
      isClosed: false
    };
  });

  const [isVaulting, setIsVaulting] = useState(false);

  const updateTask = (taskId: string, field: keyof ChecklistTask, value: any) => {
    if (currentProtocol.isClosed) return;
    const updated = {
      ...currentProtocol,
      tasks: currentProtocol.tasks.map(t => 
        t.id === taskId ? { 
          ...t, 
          [field]: value, 
          timestamp: field === 'completed' && value === true ? new Date().toISOString() : t.timestamp 
        } : t
      )
    };
    setCurrentProtocol(updated);
    onProtocolUpdate(updated);
  };

  const allReady = useMemo(() => currentProtocol.tasks.every(t => t.completed), [currentProtocol.tasks]);
  const progress = Math.round((currentProtocol.tasks.filter(t => t.completed).length / currentProtocol.tasks.length) * 100);

  const handleCloseDay = async () => {
    if (!allReady) return;
    setIsVaulting(true);
    await new Promise(r => setTimeout(r, 2000));
    const closed = { ...currentProtocol, isClosed: true, closedAt: new Date().toISOString() };
    setCurrentProtocol(closed);
    onProtocolUpdate(closed);
    setIsVaulting(false);
  };

  const taskGroups = ['General', 'Kurla - Pradip', 'Dp World - Roshan'] as const;

  return (
    <div className="max-w-[1400px] mx-auto space-y-10 animate-in fade-in duration-700 pb-24">
      
      {/* Protocol Dashboard Header */}
      <div className="bg-slate-900 rounded-[50px] p-12 text-white shadow-2xl relative overflow-hidden group border border-slate-800">
         <div className="absolute top-0 right-0 p-10 opacity-10 text-indigo-400 group-hover:scale-110 transition-transform duration-1000">
            <ClipboardList size={250} />
         </div>
         <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-10">
            <div className="flex items-center gap-8">
               <div className="w-24 h-24 bg-gradient-to-br from-indigo-600 to-indigo-400 rounded-[32px] flex items-center justify-center text-white shadow-2xl shadow-indigo-500/20">
                  <ShieldCheck size={48} />
               </div>
               <div>
                  <h2 className="text-5xl font-black tracking-tighter">Shift Audit Console</h2>
                  <p className="text-indigo-400 font-black uppercase tracking-[0.3em] text-xs mt-3 flex items-center gap-2">
                     <UserCheck size={14}/> {currentUser.name} • Nexus Global Protocol
                  </p>
               </div>
            </div>
            <div className="bg-white/5 backdrop-blur-md p-8 rounded-[40px] border border-white/10 flex items-center gap-8 shadow-inner">
               <div className="text-right">
                  <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Shift Progress</p>
                  <p className="text-4xl font-black">{progress}%</p>
               </div>
               <div className="w-16 h-16 rounded-full border-4 border-white/5 flex items-center justify-center">
                  <div className="w-12 h-12 rounded-full bg-indigo-500 animate-pulse flex items-center justify-center">
                     <Lock size={20} />
                  </div>
               </div>
            </div>
         </div>
      </div>

      {!currentProtocol.isClosed && (
        <div className="grid grid-cols-1 xl:grid-cols-4 gap-10">
           
           <div className="xl:col-span-3 space-y-12">
              {taskGroups.map(group => (
                <div key={group} className="space-y-6">
                   <div className="flex items-center justify-between px-4">
                      <h3 className={`text-sm font-black uppercase tracking-[0.4em] flex items-center gap-3 ${group === 'General' ? 'text-slate-400' : group.includes('Kurla') ? 'text-indigo-500' : 'text-emerald-500'}`}>
                         {group.includes('General') ? <Zap size={18}/> : <Warehouse size={18}/>}
                         {group}
                      </h3>
                      <span className="text-[10px] font-bold text-slate-300 uppercase">Operational Protocol</span>
                   </div>

                   <div className="bg-white rounded-[44px] border border-slate-200 shadow-sm overflow-hidden divide-y divide-slate-50">
                      {currentProtocol.tasks.filter((t: any) => (t.group || 'General') === group).map(task => (
                        <div key={task.id} className={`p-8 flex flex-col md:flex-row items-center gap-10 transition-all ${task.completed ? 'bg-slate-50/50' : 'hover:bg-slate-50/30'}`}>
                           <div className="flex items-center gap-6 flex-1">
                              <button 
                                onClick={() => updateTask(task.id, 'completed', !task.completed)}
                                className={`w-14 h-14 rounded-2xl border-4 transition-all flex items-center justify-center shrink-0 ${task.completed ? 'bg-emerald-500 border-emerald-400 text-white shadow-lg' : 'bg-white border-slate-100 hover:border-indigo-300'}`}
                              >
                                 {task.completed ? <CheckCircle2 size={32} /> : <div className="w-3 h-3 rounded-full bg-slate-100" />}
                              </button>
                              <div>
                                 <p className={`text-lg font-black tracking-tight ${task.completed ? 'text-slate-400 line-through' : 'text-slate-900'}`}>{task.label}</p>
                                 {task.timestamp && <p className="text-[9px] font-black text-emerald-600 uppercase mt-1 tracking-widest flex items-center gap-1"><Clock size={10}/> Verified at {new Date(task.timestamp).toLocaleTimeString()}</p>}
                              </div>
                           </div>

                           <div className="flex items-center gap-4 w-full md:w-auto">
                              <div className="flex-1 md:w-32 space-y-1">
                                 <label className="text-[9px] font-black text-slate-400 uppercase ml-1">Actual Done</label>
                                 <input 
                                   type="number" 
                                   className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 font-black text-center focus:border-indigo-500 outline-none transition-all"
                                   value={task.doneCount || ''}
                                   placeholder="0"
                                   onChange={e => updateTask(task.id, 'doneCount', parseInt(e.target.value) || 0)}
                                 />
                              </div>
                              <div className="flex-1 md:w-32 space-y-1">
                                 <label className="text-[9px] font-black text-slate-400 uppercase ml-1">Pending</label>
                                 <input 
                                   type="number" 
                                   className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 font-black text-center focus:border-rose-500 outline-none transition-all"
                                   value={task.pendingCount || ''}
                                   placeholder="0"
                                   onChange={e => updateTask(task.id, 'pendingCount', parseInt(e.target.value) || 0)}
                                 />
                              </div>
                           </div>
                        </div>
                      ))}
                   </div>
                </div>
              ))}
           </div>

           <div className="xl:col-span-1 space-y-6">
              <div className="bg-slate-900 rounded-[50px] p-10 text-white shadow-2xl border border-slate-800 sticky top-10 flex flex-col justify-between min-h-[600px] group">
                 <div className="space-y-12">
                    <div className="flex items-center gap-5">
                       <div className="w-14 h-14 bg-white/5 rounded-3xl flex items-center justify-center border border-white/10 group-hover:scale-110 transition-transform">
                          <Thermometer size={28} className="text-indigo-400" />
                       </div>
                       <div>
                          <h4 className="text-2xl font-black tracking-tight">Vault Protocol</h4>
                          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mt-1">Status: {allReady ? 'CLEARED' : 'PENDING'}</p>
                       </div>
                    </div>

                    <div className="space-y-8">
                       <div className="flex justify-between items-center text-[10px] font-black uppercase tracking-widest">
                          <span className="text-slate-400">Items Scanned</span>
                          <span className="text-white">{currentProtocol.tasks.length} Checkpoints</span>
                       </div>
                       <div className="flex justify-between items-center text-[10px] font-black uppercase tracking-widest">
                          <span className="text-slate-400">Throughput Total</span>
                          <span className="text-indigo-400">{currentProtocol.tasks.reduce((s,t)=>s+t.doneCount, 0)} Units</span>
                       </div>
                       <div className="w-full h-1 bg-white/5 rounded-full overflow-hidden">
                          <div className="h-full bg-indigo-500 transition-all duration-1000" style={{width: `${progress}%`}} />
                       </div>
                    </div>

                    {isVaulting ? (
                      <div className="py-12 text-center space-y-6 animate-in zoom-in-95">
                         <div className="w-16 h-16 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto shadow-indigo-500/20 shadow-2xl" />
                         <p className="text-[11px] font-black uppercase tracking-[0.3em] text-indigo-400">Archiving Shift Data...</p>
                      </div>
                    ) : (
                      <div className="pt-10">
                        <button 
                          onClick={handleCloseDay}
                          disabled={!allReady}
                          className="w-full bg-emerald-500 text-white py-7 rounded-[32px] font-black text-sm uppercase tracking-[0.2em] shadow-xl hover:bg-emerald-400 transition-all active:scale-95 disabled:opacity-20 flex items-center justify-center gap-4"
                        >
                           Commit Daily Audit <ArrowRight size={20} />
                        </button>
                        
                        <div className="space-y-4 mt-8">
                           <div className="flex items-center gap-3 p-5 bg-rose-500/10 rounded-2xl border border-rose-500/20">
                              <ShieldAlert size={18} className="text-rose-400 shrink-0" />
                              <p className="text-[10px] text-rose-300 leading-relaxed font-black uppercase tracking-widest">
                                 Compliance Notice: Attendance will be considered only after the performance of all the tasks.
                              </p>
                           </div>
                           <div className="flex items-center gap-3 p-5 bg-white/5 rounded-2xl border border-white/5">
                              <Info size={16} className="text-indigo-400 shrink-0" />
                              <p className="text-[10px] text-slate-400 leading-relaxed font-medium italic">
                                 Closure requires 100% verification across Kurla and DP World facility tasks.
                              </p>
                           </div>
                        </div>
                      </div>
                    )}
                 </div>
              </div>
           </div>

        </div>
      )}

      {currentProtocol.isClosed && (
        <div className="bg-white rounded-[60px] border border-slate-200 shadow-2xl p-24 text-center space-y-10 animate-in zoom-in-95 duration-700 max-w-4xl mx-auto border-t-8 border-t-emerald-500">
           <div className="w-32 h-32 bg-emerald-50 text-emerald-600 rounded-[50px] flex items-center justify-center mx-auto shadow-inner border border-emerald-100">
              <ShieldCheck size={64} />
           </div>
           <div>
              <h3 className="text-6xl font-black text-slate-900 tracking-tighter">Shift Synchronized</h3>
              <p className="text-slate-400 font-bold uppercase tracking-[0.3em] mt-6 text-sm">Pradip & Roshan Facility Protocols Verified and Vaulted</p>
           </div>
           <div className="flex items-center justify-center gap-10 py-10 border-y border-slate-50">
              <div className="text-center">
                 <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Archived At</p>
                 <p className="text-lg font-black text-slate-900">{new Date(currentProtocol.closedAt!).toLocaleTimeString()}</p>
              </div>
              <div className="w-px h-12 bg-slate-100" />
              <div className="text-center">
                 <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Protocol Compliance</p>
                 <span className="px-4 py-1.5 bg-emerald-500 text-white rounded-full text-[10px] font-black uppercase tracking-widest">100% Secured</span>
              </div>
           </div>
           <button onClick={() => window.location.reload()} className="px-16 py-7 bg-slate-900 text-white rounded-[32px] font-black text-sm uppercase tracking-[0.25em] hover:bg-indigo-600 transition-all shadow-2xl">Restart Session</button>
        </div>
      )}
    </div>
  );
};

export default DailyProtocolView;
