
import React, { useState } from 'react';
import { User } from '../types';
import { ShieldCheck, ArrowRight, Lock } from 'lucide-react';

interface LoginViewProps {
  onLogin: (user: User) => void;
  availableUsers: User[];
}

const LoginView: React.FC<LoginViewProps> = ({ onLogin, availableUsers }) => {
  const [selectedEmail, setSelectedEmail] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const user = availableUsers.find(u => u.id === selectedEmail);
    if (user) onLogin(user);
  };

  return (
    <div className="min-h-screen bg-slate-900 flex items-center justify-center p-6 relative overflow-hidden">
      <div className="absolute top-0 left-0 w-full h-full opacity-10 pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-indigo-500 rounded-full blur-[120px]" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-violet-500 rounded-full blur-[120px]" />
      </div>

      <div className="w-full max-w-md relative z-10 animate-in fade-in zoom-in-95 duration-500">
        <div className="bg-slate-800/50 backdrop-blur-xl border border-white/10 rounded-3xl p-8 shadow-2xl">
          <div className="text-center mb-10">
            <div className="w-16 h-16 bg-indigo-500/20 rounded-2xl flex items-center justify-center mx-auto mb-6 border border-indigo-500/30">
              <ShieldCheck className="text-indigo-400" size={32} />
            </div>
            <h1 className="text-3xl font-black text-white tracking-tight mb-2">NexusOMS</h1>
            <p className="text-slate-400 text-sm">Enterprise Logistics & Order Hub</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-2">
              <label className="text-[10px] font-bold text-slate-500 uppercase tracking-widest px-1">Select Identity</label>
              <div className="relative">
                <select 
                  className="w-full bg-slate-900/50 border border-white/10 rounded-2xl px-5 py-4 text-white focus:ring-2 focus:ring-indigo-500/50 appearance-none outline-none transition-all"
                  value={selectedEmail}
                  onChange={(e) => setSelectedEmail(e.target.value)}
                  required
                >
                  <option value="">Select your organization email...</option>
                  {availableUsers.map(u => (
                    <option key={u.id} value={u.id}>{u.name} ({u.role})</option>
                  ))}
                </select>
                <div className="absolute right-5 top-1/2 -translate-y-1/2 pointer-events-none text-slate-500">
                  <ArrowRight size={18} />
                </div>
              </div>
            </div>

            <button 
              type="submit"
              disabled={!selectedEmail}
              className="w-full bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white font-bold py-4 rounded-2xl transition-all shadow-xl shadow-indigo-600/20 flex items-center justify-center gap-3 active:scale-[0.98]"
            >
              Secure Access
              <Lock size={18} />
            </button>
          </form>

          <div className="mt-10 pt-6 border-t border-white/5 flex items-center justify-center gap-4 grayscale opacity-50">
             <div className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">ISO 27001 Certified</div>
             <div className="w-1 h-1 bg-slate-700 rounded-full" />
             <div className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">End-to-End Encryption</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginView;
