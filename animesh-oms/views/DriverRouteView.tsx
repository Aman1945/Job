
import React, { useState, useEffect } from 'react';
import { DeliveryRoute, RouteStop, User, OrderStatus } from '../types';
import { 
  Navigation, 
  MapPin, 
  CheckCircle2, 
  Camera, 
  Box, 
  RotateCcw, 
  ArrowRight, 
  Phone, 
  MessageSquare,
  ShieldCheck,
  Zap,
  Map as MapIcon,
  ChevronRight,
  ChevronLeft,
  X,
  Clock,
  ExternalLink,
  Smartphone,
  CheckCircle,
  Truck
} from 'lucide-react';

interface DriverRouteViewProps {
  activeRoute: DeliveryRoute | null;
  currentUser: User;
  onUpdateStop: (routeId: string, stopId: string, status: RouteStop['status']) => void;
  onMissionComplete: (routeId: string) => void;
}

const DriverRouteView: React.FC<DriverRouteViewProps> = ({ 
  activeRoute, currentUser, onUpdateStop, onMissionComplete 
}) => {
  const [currentStopIndex, setCurrentStopIndex] = useState(0);
  const [isCapturingPod, setIsCapturingPod] = useState(false);
  const [podPhoto, setPodPhoto] = useState<string | null>(null);
  const [otp, setOtp] = useState('');
  
  if (!activeRoute) {
    return (
      <div className="max-w-md mx-auto h-[80vh] flex flex-col items-center justify-center text-center p-10 animate-in fade-in">
         <div className="w-24 h-24 bg-slate-50 rounded-[40px] flex items-center justify-center text-slate-200 mb-8">
            <Truck size={48} />
         </div>
         <h3 className="text-2xl font-black text-slate-900 uppercase">Standby Mode</h3>
         <p className="text-sm text-slate-400 mt-2 font-medium">Mission assignments will appear here once optimized and dispatched by the Hub.</p>
      </div>
    );
  }

  const currentStop = activeRoute.stops[currentStopIndex];
  const isLastStop = currentStopIndex === activeRoute.stops.length - 1;

  const handleArrive = () => {
    onUpdateStop(activeRoute.id, currentStop.id, 'ARRIVED');
  };

  const handleCompleteStop = async () => {
    if (!podPhoto) {
      alert("Proof of delivery photo is mandatory.");
      return;
    }
    
    onUpdateStop(activeRoute.id, currentStop.id, 'COMPLETED');
    setPodPhoto(null);
    setIsCapturingPod(false);
    
    if (isLastStop) {
      onMissionComplete(activeRoute.id);
    } else {
      setCurrentStopIndex(prev => prev + 1);
    }
  };

  return (
    <div className="max-w-md mx-auto space-y-6 pb-32 animate-in slide-in-from-bottom-10 duration-700">
      
      {/* Route Info Header */}
      <div className="bg-slate-900 rounded-[44px] p-8 text-white shadow-2xl relative overflow-hidden group">
         <Navigation className="absolute -right-6 -bottom-6 w-32 h-32 opacity-10 text-emerald-400 group-hover:scale-110 transition-transform duration-700" />
         <div className="relative z-10">
            <div className="flex items-center gap-3 mb-4">
               <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
               <span className="text-[10px] font-black uppercase tracking-[0.2em] text-emerald-400">Mission Active: {activeRoute.id}</span>
            </div>
            <h3 className="text-3xl font-black tracking-tight">Trip Sequence</h3>
            <div className="flex justify-between items-center mt-6 p-4 bg-white/5 rounded-3xl border border-white/10">
               <div>
                  <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1">Stops Left</p>
                  <p className="text-2xl font-black">{activeRoute.stops.length - currentStopIndex} / {activeRoute.stops.length}</p>
               </div>
               <div className="text-right">
                  <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1">Est. Completion</p>
                  <p className="text-2xl font-black text-emerald-400">~{25 * (activeRoute.stops.length - currentStopIndex)} min</p>
               </div>
            </div>
         </div>
      </div>

      {/* Active Stop Interaction */}
      <div className="bg-white rounded-[50px] border border-slate-200 shadow-xl overflow-hidden animate-in zoom-in-95 duration-500">
         <div className={`p-8 border-b flex items-center justify-between ${currentStop.type === 'RETURN_PICKUP' ? 'bg-rose-600' : 'bg-indigo-600'} text-white`}>
            <div>
               <p className="text-[10px] font-black uppercase tracking-[0.3em] opacity-80">Active Stop #{currentStop.sequence}</p>
               <h4 className="text-xl font-black truncate max-w-[200px] mt-1">{currentStop.name}</h4>
            </div>
            <div className="w-12 h-12 bg-white/20 rounded-2xl flex items-center justify-center backdrop-blur-md">
               {currentStop.type === 'DELIVERY' ? <Box size={24}/> : <RotateCcw size={24}/>}
            </div>
         </div>

         <div className="p-8 space-y-8">
            <div className="space-y-4">
               <div className="flex items-start gap-4">
                  <MapPin className="text-emerald-500 mt-1 shrink-0" size={20} />
                  <div>
                     <p className="text-sm font-bold text-slate-900 leading-snug">{currentStop.address}</p>
                     <p className="text-[10px] font-black text-slate-400 uppercase mt-2">Geofence Status: Within 500m</p>
                  </div>
               </div>
               <div className="grid grid-cols-2 gap-3">
                  <button className="flex items-center justify-center gap-2 py-4 bg-slate-50 rounded-2xl text-[10px] font-black uppercase text-slate-900 border border-slate-100"><Phone size={14}/> Call Client</button>
                  <button className="flex items-center justify-center gap-2 py-4 bg-slate-50 rounded-2xl text-[10px] font-black uppercase text-slate-900 border border-slate-100"><MapIcon size={14}/> Open Maps</button>
               </div>
            </div>

            {currentStop.status === 'PENDING' ? (
               <button 
                 onClick={handleArrive}
                 className="w-full bg-slate-900 text-white py-6 rounded-[32px] font-black text-xs uppercase tracking-[0.25em] shadow-xl flex items-center justify-center gap-3 active:scale-95"
               >
                  I have Arrived <CheckCircle2 size={18}/>
               </button>
            ) : (
               <div className="space-y-6 animate-in slide-in-from-bottom-4">
                  <div className="p-6 bg-emerald-50 rounded-[32px] border-2 border-emerald-100 flex items-center gap-4 text-emerald-700">
                     <ShieldCheck size={28}/>
                     <p className="text-xs font-black uppercase tracking-widest">Arrived & Ready for POD</p>
                  </div>
                  
                  <div className="space-y-4">
                     <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Proof of Fulfillment</label>
                     <button 
                       onClick={() => setIsCapturingPod(true)}
                       className={`w-full aspect-video rounded-[36px] border-4 border-dashed transition-all flex flex-col items-center justify-center gap-3 overflow-hidden ${podPhoto ? 'border-emerald-500 bg-white' : 'border-slate-100 bg-slate-50'}`}
                     >
                        {podPhoto ? (
                          <img src={podPhoto} className="w-full h-full object-cover" />
                        ) : (
                          <>
                            <Camera size={32} className="text-slate-300" />
                            <p className="text-[10px] font-black text-slate-400 uppercase">Capture Delivery Evidence</p>
                          </>
                        )}
                     </button>
                  </div>

                  <div className="space-y-2">
                     <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Customer OTP Confirmation</label>
                     <input 
                       type="text" 
                       placeholder="Enter 4-Digit Code" 
                       maxLength={4}
                       className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-center font-black text-2xl tracking-[0.5em] focus:border-indigo-600 outline-none transition-all"
                       value={otp}
                       onChange={e => setOtp(e.target.value)}
                     />
                  </div>

                  <button 
                    onClick={handleCompleteStop}
                    disabled={!podPhoto || otp.length < 4}
                    className="w-full bg-emerald-600 text-white py-7 rounded-[32px] font-black text-sm uppercase tracking-[0.2em] shadow-xl shadow-emerald-500/20 active:scale-95 transition-all disabled:opacity-30"
                  >
                    Finish Stop #{currentStop.sequence}
                  </button>
               </div>
            )}
         </div>
      </div>

      {/* Mini Timeline of the rest of the route */}
      <div className="bg-white rounded-[44px] border border-slate-200 p-8 shadow-sm">
         <h5 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-6">Coming Up Next</h5>
         <div className="space-y-6">
            {activeRoute.stops.slice(currentStopIndex + 1).map((stop, i) => (
              <div key={stop.id} className="flex items-center gap-4 group">
                 <div className="w-8 h-8 rounded-xl bg-slate-50 flex items-center justify-center text-[10px] font-black text-slate-300 border border-slate-100 group-hover:bg-indigo-50 group-hover:text-indigo-600 transition-all">
                    {stop.sequence}
                 </div>
                 <div className="flex-1">
                    <p className="text-xs font-black text-slate-700">{stop.name}</p>
                    <p className="text-[8px] text-slate-400 font-bold uppercase">{stop.type.replace('_', ' ')}</p>
                 </div>
                 <ChevronRight size={14} className="text-slate-200" />
              </div>
            ))}
            {currentStopIndex === activeRoute.stops.length - 1 && (
               <div className="py-4 text-center">
                  <p className="text-[10px] font-black text-emerald-600 uppercase">Final Destination Reached</p>
               </div>
            )}
         </div>
      </div>

      {/* Simulated Camera Overlay */}
      {isCapturingPod && (
        <div className="fixed inset-0 z-[100] bg-black flex flex-col animate-in fade-in">
           <div className="flex-1 relative">
              <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&q=80&w=800')] bg-cover" />
              <div className="absolute inset-0 border-[20px] border-white/10" />
              <button onClick={() => setIsCapturingPod(false)} className="absolute top-10 right-10 p-4 text-white"><X size={32}/></button>
           </div>
           <div className="h-48 bg-slate-900 flex items-center justify-center">
              <button 
                onClick={() => {
                  setPodPhoto('https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&q=80&w=400');
                  setIsCapturingPod(false);
                }}
                className="w-20 h-20 rounded-full bg-white border-8 border-slate-700 shadow-2xl active:scale-90 transition-all" 
              />
           </div>
        </div>
      )}
    </div>
  );
};

export default DriverRouteView;
