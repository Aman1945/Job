
import React, { useState, useMemo } from 'react';
import { User, PerformanceRecord, KRA, KRAType, IncentiveSlab } from '../types';
import { 
  Target, 
  Trophy, 
  TrendingUp, 
  TrendingDown, 
  Info, 
  Calculator, 
  ShieldCheck, 
  Calendar,
  AlertCircle,
  ArrowRight,
  DollarSign
} from 'lucide-react';

interface PMSViewProps {
  currentUser: User;
}

const INCENTIVE_SLABS: IncentiveSlab[] = [
  { lowerBand: 90, higherBand: 95, incentivePercent: 10 },
  { lowerBand: 96, higherBand: 100, incentivePercent: 15 },
  { lowerBand: 101, higherBand: 105, incentivePercent: 20 },
  { lowerBand: 106, higherBand: 110, incentivePercent: 25 },
];

const OD_WEIGHTAGE_SLABS = [
  { limit: 363459, score: 30 },
  { limit: 1250000, score: 24 },
  { limit: 1900000, score: 18 },
  { limit: 2550000, score: 12 },
  { limit: 3200000, score: 6 },
  { limit: 4000000, score: 0 },
];

const PMSView: React.FC<PMSViewProps> = ({ currentUser }) => {
  // Mock data for Mithun Muddappa as per screenshot
  const [record, setRecord] = useState<PerformanceRecord>({
    userId: currentUser.id,
    userName: currentUser.name,
    month: "Feb'26",
    grossMonthlySalary: 131089,
    odBalances: {
      chennai: 49562,
      self: 248920,
      hyd: 64977
    },
    kras: [
      { id: 1, name: "Weekly Fresh Salmon Sales (Quantity) including LULU", criteria: "SM Budget", target: 1232, achieved: 1232, weightage: 15, type: 'Unrestricted' },
      { id: 2, name: "Hyderabad non Retail sales", criteria: "SM Budget", target: 1625800, achieved: 1625800, weightage: 5, type: 'Unrestricted' },
      { id: 3, name: "Chennai non Retail sales", criteria: "SM Budget", target: 600000, achieved: 600000, weightage: 5, type: 'Unrestricted' },
      { id: 4, name: "Monthly visit to Cochin & Chennai, Hyderabad (2 out of 3 locations)", criteria: "", target: 3, achieved: 3, weightage: 5, type: 'Restricted' },
      { id: 5, name: "Fresh Salmon Sales - Horeca", criteria: "SM Budget", target: 498800, achieved: 498800, weightage: 5, type: 'Unrestricted' },
      { id: 6, name: "Home Delivery Sales", criteria: "AMS+30%", target: 140000, achieved: 140000, weightage: 5, type: 'Restricted' },
      { id: 7, name: "Contribution % (All products & All Channels) without Retail", criteria: "", target: 25, achieved: 25, weightage: 30, type: 'As per slab' },
      { id: 8, name: "Contract Sales", criteria: "", target: 500000, achieved: 500000, weightage: 10, type: 'As per slab' },
      { id: 9, name: "OD's Balance till 31st Jan'26", criteria: "", target: 363459, achieved: 363459, weightage: 30, type: 'As per slab' },
    ]
  });

  const odTotal = useMemo(() => {
    if (!record.odBalances) return 0;
    return record.odBalances.chennai + record.odBalances.self + record.odBalances.hyd;
  }, [record.odBalances]);

  const getKRAFinalScore = (kra: KRA) => {
    if (kra.id === 9) {
      // Specialized logic for OD Balance
      const slab = OD_WEIGHTAGE_SLABS.find(s => odTotal <= s.limit);
      return slab ? slab.score : 0;
    }

    if (kra.target === 0) return 0;
    const rawScore = (kra.achieved / kra.target) * kra.weightage;
    
    if (kra.type === 'Restricted') {
      return Math.min(rawScore, kra.weightage);
    }
    
    return rawScore;
  };

  const calculatedKRAs = useMemo(() => {
    return record.kras.map(k => ({
      ...k,
      finalScore: getKRAFinalScore(k)
    }));
  }, [record, odTotal]);

  const totalWeightage = useMemo(() => calculatedKRAs.reduce((s, k) => s + k.weightage, 0), [calculatedKRAs]);
  const totalFinalScore = useMemo(() => calculatedKRAs.reduce((s, k) => s + k.finalScore, 0), [calculatedKRAs]);

  const incentiveDetails = useMemo(() => {
    const scorePct = totalFinalScore;
    let baseIncentivePct = 0;

    // Find applicable slab
    const slab = INCENTIVE_SLABS.find(s => scorePct >= s.lowerBand && scorePct <= s.higherBand);
    if (slab) {
      baseIncentivePct = slab.incentivePercent;
    } else if (scorePct > 110) {
      // "For Every 5% hike in band additional 5%"
      const excess = scorePct - 110;
      const additionalHikes = Math.floor(excess / 5);
      baseIncentivePct = 25 + ((additionalHikes + 1) * 5);
    }

    const payableAmount = (baseIncentivePct / 100) * record.grossMonthlySalary;

    return { scorePct, baseIncentivePct, payableAmount };
  }, [totalFinalScore, record.grossMonthlySalary]);

  const updateAchieved = (id: number, val: number) => {
    setRecord(prev => ({
      ...prev,
      kras: prev.kras.map(k => k.id === id ? { ...k, achieved: val } : k)
    }));
  };

  return (
    <div className="max-w-[1600px] mx-auto space-y-10 pb-24 animate-in fade-in duration-700">
      
      {/* Header Info */}
      <div className="bg-slate-900 rounded-[50px] p-12 text-white shadow-2xl relative overflow-hidden group border border-slate-800">
         <Trophy className="absolute -right-12 -bottom-12 w-96 h-96 opacity-10 text-emerald-400 group-hover:scale-110 transition-transform duration-1000" />
         <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-10">
            <div className="flex items-center gap-8">
               <div className="w-24 h-24 bg-emerald-500 rounded-[32px] flex items-center justify-center text-white shadow-xl shadow-emerald-500/20">
                  <Calculator size={48} />
               </div>
               <div>
                  <h2 className="text-5xl font-black tracking-tighter">{record.userName}</h2>
                  <p className="text-xl font-bold text-emerald-400 uppercase tracking-widest mt-2">{record.month} Incentive Terminal</p>
               </div>
            </div>
            <div className="flex gap-6">
               <div className="bg-white/5 border border-white/10 p-6 rounded-[32px] text-right">
                  <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Gross Monthly Salary</p>
                  <p className="text-3xl font-black text-white tracking-tighter">₹{record.grossMonthlySalary.toLocaleString()}</p>
               </div>
               <div className="bg-emerald-500 p-6 rounded-[32px] text-right shadow-xl shadow-emerald-500/20">
                  <p className="text-[10px] font-black text-emerald-100 uppercase tracking-widest mb-1">Payable Incentive</p>
                  <p className="text-3xl font-black text-white tracking-tighter">₹{incentiveDetails.payableAmount.toLocaleString()}</p>
               </div>
            </div>
         </div>
      </div>

      {/* Main KRA Table */}
      <div className="bg-white rounded-[50px] border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-8 border-b bg-slate-50/50 flex items-center justify-between">
           <h3 className="text-xl font-black text-slate-900 uppercase tracking-tight flex items-center gap-3"><Target className="text-indigo-600" /> Key Result Area Achievement Matrix</h3>
           <div className={`px-6 py-2 rounded-full border flex items-center gap-3 ${totalWeightage === 100 ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 'bg-rose-50 text-rose-600 border-rose-100'}`}>
              <AlertCircle size={16} />
              <span className="text-[10px] font-black uppercase tracking-widest">Weightage Sum: {totalWeightage} / 100</span>
           </div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50/50 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] border-b">
              <tr>
                <th className="px-8 py-6 w-16">#</th>
                <th className="px-6 py-6 min-w-[300px]">Goal Description</th>
                <th className="px-6 py-6">Criteria</th>
                <th className="px-6 py-6 text-right">Target</th>
                <th className="px-6 py-6 text-right">Achieved</th>
                <th className="px-6 py-6 text-center">Weightage</th>
                <th className="px-6 py-6 text-center">Final Score</th>
                <th className="px-8 py-6">Protocol</th>
              </tr>
            </thead>
            <tbody className="divide-y text-sm font-bold text-slate-700">
              {calculatedKRAs.map(kra => (
                <tr key={kra.id} className="hover:bg-slate-50 transition-colors group">
                  <td className="px-8 py-6 text-slate-300">{kra.id}</td>
                  <td className="px-6 py-6 font-black text-slate-900">{kra.name}</td>
                  <td className="px-6 py-6">
                    <span className="bg-slate-100 px-3 py-1 rounded-lg text-[9px] uppercase tracking-widest">{kra.criteria || 'Standard'}</span>
                  </td>
                  <td className="px-6 py-6 text-right font-black">{kra.target.toLocaleString()}</td>
                  <td className="px-6 py-6 text-right">
                    <input 
                      type="number" 
                      className="bg-transparent border-b-2 border-slate-100 focus:border-indigo-600 outline-none text-right font-black w-32 p-1"
                      value={kra.achieved}
                      onChange={e => updateAchieved(kra.id, parseFloat(e.target.value) || 0)}
                    />
                  </td>
                  <td className="px-6 py-6 text-center">{kra.weightage}</td>
                  <td className="px-6 py-6 text-center">
                    <span className={`text-lg font-black ${kra.finalScore >= kra.weightage ? 'text-emerald-600' : 'text-indigo-600'}`}>
                      {kra.finalScore.toFixed(1)}
                    </span>
                  </td>
                  <td className="px-8 py-6">
                    <span className={`text-[9px] font-black uppercase px-2 py-1 rounded border ${
                      kra.type === 'Unrestricted' ? 'bg-indigo-50 text-indigo-600 border-indigo-100' :
                      kra.type === 'Restricted' ? 'bg-amber-50 text-amber-600 border-amber-100' :
                      'bg-slate-50 text-slate-500 border-slate-200'
                    }`}>
                      {kra.type}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot className="bg-slate-900 text-white font-black text-lg">
               <tr>
                  <td colSpan={6} className="px-8 py-8 text-right uppercase tracking-[0.2em] text-xs text-slate-400">Total Operational Score</td>
                  <td className="px-6 py-8 text-center text-4xl tracking-tighter">{totalFinalScore.toFixed(1)}%</td>
                  <td className="px-8 py-8"></td>
               </tr>
            </tfoot>
          </table>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-10">
        {/* OD Balance Breakdown - Row 9 Specifics */}
        <div className="bg-white rounded-[50px] border border-slate-200 shadow-sm p-10 space-y-10">
           <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-indigo-50 text-indigo-600 rounded-2xl flex items-center justify-center">
                 <TrendingDown size={24} />
              </div>
              <div>
                 <h4 className="text-xl font-black text-slate-900 uppercase tracking-tight">OD Balance Score Matrix</h4>
                 <p className="text-xs text-slate-400 font-medium">Calculation detail for KRA #9</p>
              </div>
           </div>

           <div className="grid grid-cols-3 gap-6">
              <BalanceCard label="Chennai OD" val={record.odBalances?.chennai || 0} color="indigo" />
              <BalanceCard label="Personal OD" val={record.odBalances?.self || 0} color="emerald" />
              <BalanceCard label="Hyd OD" val={record.odBalances?.hyd || 0} color="amber" />
           </div>

           <div className="bg-slate-900 rounded-3xl p-8 text-white flex justify-between items-center shadow-xl">
              <div>
                 <p className="text-[10px] font-black uppercase tracking-widest text-slate-400">Total Closing Balance</p>
                 <p className="text-4xl font-black tracking-tighter">₹{odTotal.toLocaleString()}</p>
              </div>
              <div className="text-right">
                 <p className="text-[10px] font-black uppercase tracking-widest text-emerald-400">Score Awarded</p>
                 <p className="text-4xl font-black tracking-tighter text-emerald-400">{getKRAFinalScore(record.kras.find(k=>k.id===9)!).toFixed(0)}</p>
              </div>
           </div>

           <div className="space-y-4">
              <p className="text-[10px] font-black uppercase text-slate-400 tracking-widest">Weightage Slab Protocol</p>
              <div className="grid grid-cols-6 gap-2">
                 {OD_WEIGHTAGE_SLABS.map((slab, i) => (
                   <div key={i} className={`p-3 rounded-xl border text-center transition-all ${odTotal <= slab.limit && (i === 0 || odTotal > OD_WEIGHTAGE_SLABS[i-1].limit) ? 'bg-emerald-50 border-emerald-500 scale-105' : 'bg-slate-50 border-slate-100 opacity-40'}`}>
                      <p className="text-[8px] font-black text-slate-400 mb-1">UP TO</p>
                      <p className="text-[10px] font-black truncate">{slab.limit < 1000000 ? `${slab.limit/1000}K` : `${(slab.limit/1000000).toFixed(1)}M`}</p>
                      <div className="h-px bg-slate-200 my-2" />
                      <p className="text-lg font-black text-slate-900">{slab.score}</p>
                   </div>
                 ))}
              </div>
           </div>
        </div>

        {/* Incentive Payout Matrix */}
        <div className="bg-white rounded-[50px] border border-slate-200 shadow-sm p-10 space-y-10">
           <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center">
                 <DollarSign size={24} />
              </div>
              <div>
                 <h4 className="text-xl font-black text-slate-900 uppercase tracking-tight">Incentive Payout Policy</h4>
                 <p className="text-xs text-slate-400 font-medium">Achievement score to currency conversion</p>
              </div>
           </div>

           <div className="space-y-4">
              {INCENTIVE_SLABS.map((slab, i) => (
                <div key={i} className={`flex items-center justify-between p-5 rounded-[32px] border transition-all ${incentiveDetails.baseIncentivePct === slab.incentivePercent ? 'bg-indigo-600 border-indigo-500 text-white shadow-xl shadow-indigo-600/20 scale-[1.02]' : 'bg-slate-50 border-slate-100 opacity-60'}`}>
                   <div className="flex items-center gap-6">
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center font-black text-xs ${incentiveDetails.baseIncentivePct === slab.incentivePercent ? 'bg-white/20' : 'bg-white shadow-sm text-slate-400'}`}>
                         {i+1}
                      </div>
                      <div>
                         <p className={`text-[10px] font-black uppercase tracking-widest ${incentiveDetails.baseIncentivePct === slab.incentivePercent ? 'text-indigo-200' : 'text-slate-400'}`}>Score Range</p>
                         <p className="text-lg font-black">{slab.lowerBand}% — {slab.higherBand}%</p>
                      </div>
                   </div>
                   <div className="text-right">
                      <p className={`text-[10px] font-black uppercase tracking-widest ${incentiveDetails.baseIncentivePct === slab.incentivePercent ? 'text-indigo-200' : 'text-slate-400'}`}>Payout Factor</p>
                      <p className="text-2xl font-black">{slab.incentivePercent}%</p>
                   </div>
                </div>
              ))}
              
              {totalFinalScore > 110 && (
                <div className="p-8 rounded-[40px] bg-emerald-500 text-white shadow-2xl animate-pulse">
                   <div className="flex items-center justify-between mb-4">
                      <h5 className="text-sm font-black uppercase tracking-[0.2em]">Extreme Achievement Bonus</h5>
                      <TrendingUp size={24} />
                   </div>
                   <p className="text-3xl font-black tracking-tighter">Total Payout Factor: {incentiveDetails.baseIncentivePct}%</p>
                   <p className="text-xs font-medium text-emerald-100 mt-2">Extended band protocol applied for scores {'>'} 110%</p>
                </div>
              )}
           </div>

           <div className="pt-6 border-t border-slate-100 flex items-center gap-6">
              <div className="flex-1 bg-slate-900 rounded-[32px] p-6 text-white text-center">
                 <p className="text-[10px] font-black text-indigo-400 uppercase mb-1">Total Score</p>
                 <p className="text-3xl font-black">{totalFinalScore.toFixed(1)}%</p>
              </div>
              <div className="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center text-slate-300">
                 <ArrowRight size={20} />
              </div>
              <div className="flex-1 bg-emerald-500 rounded-[32px] p-6 text-white text-center shadow-lg shadow-emerald-500/20">
                 <p className="text-[10px] font-black text-emerald-100 uppercase mb-1">Incentive Amt</p>
                 <p className="text-3xl font-black">₹{incentiveDetails.payableAmount.toLocaleString()}</p>
              </div>
           </div>
        </div>
      </div>
    </div>
  );
};

const BalanceCard = ({ label, val, color }: { label: string, val: number, color: string }) => {
  const colors: Record<string, string> = {
    indigo: 'text-indigo-600 bg-indigo-50 border-indigo-100',
    emerald: 'text-emerald-600 bg-emerald-50 border-emerald-100',
    amber: 'text-amber-600 bg-amber-50 border-amber-100'
  };
  return (
    <div className={`p-6 rounded-3xl border shadow-sm ${colors[color]}`}>
       <p className="text-[10px] font-black uppercase tracking-widest mb-1 opacity-70">{label}</p>
       <p className="text-xl font-black tracking-tight">₹{val.toLocaleString()}</p>
    </div>
  );
};

export default PMSView;
