
import React, { useState, useMemo, useEffect, useRef } from 'react';
import { UserRole, Order, OrderStatus, Customer, Product, User, NotificationTask, ODMaster, ProcurementItem } from './types';
import { MOCK_USERS, MOCK_CUSTOMERS, MOCK_PRODUCTS, INITIAL_ORDERS, INITIAL_PROCUREMENT } from './mockData';
import DashboardView from './views/DashboardView';
import LiveOrderView from './views/LiveOrderView';
import OrderListView from './views/OrderListView';
import OrderDetailsView from './views/OrderDetailsView';
import OrderFormView from './views/OrderFormView';
import MasterDataView from './views/MasterDataView';
import ReportingView from './views/ReportingView';
import LoginView from './views/LoginView';
import LogisticsAssignmentView from './views/LogisticsAssignmentView';
import DeliveryExecutionView from './views/DeliveryExecutionView';
import InvoicingView from './views/InvoicingView';
import LogisticsCostView from './views/LogisticsCostView';
import SalesHubView from './views/SalesHubView';
import OrderArchiveView from './views/OrderArchiveView';
import WHSelectionView from './views/WHSelectionView';
import ProcurementView from './views/ProcurementView';
import CustomerCreationView from './views/CustomerCreationView';
import STNBookingView from './views/STNBookingView';
import PMSView from './views/PMSView';
import { 
  LayoutDashboard, ShoppingCart, Package, Truck, 
  Users, BarChart3, PlusCircle, Menu, 
  X, Bell, Activity, Navigation, LogOut, Database,
  Receipt, ShieldCheck, Zap, Box, ListChecks, FileText, DollarSign, Archive, TrendingUp, History, Warehouse,
  ClipboardList, UserPlus, RefreshCcw, Medal
} from 'lucide-react';

const App: React.FC = () => {
  const [activeTab, setActiveTab] = useState<string>('dashboard');
  const [selectedOrderId, setSelectedOrderId] = useState<string | null>(null);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const hasInitialized = useRef(false);

  const getRescuedData = (key: string, defaultValue: any[]) => {
    const current = localStorage.getItem(key);
    if (current) {
      try {
        const parsed = JSON.parse(current);
        if (Array.isArray(parsed) && parsed.length > 0) return parsed;
      } catch(e) {}
    }
    return defaultValue;
  };

  const [orders, setOrders] = useState<Order[]>(() => getRescuedData('nexus_orders_v12', INITIAL_ORDERS));
  const [customers, setCustomers] = useState<Customer[]>(() => getRescuedData('nexus_customers_v12', MOCK_CUSTOMERS));
  const [products, setProducts] = useState<Product[]>(() => getRescuedData('nexus_products_v12', MOCK_PRODUCTS));
  const [users, setUsers] = useState<User[]>(() => getRescuedData('nexus_users_v12', MOCK_USERS));
  const [odMaster, setOdMaster] = useState<ODMaster[]>(() => getRescuedData('nexus_odmaster_v12', []));
  const [procurement, setProcurement] = useState<ProcurementItem[]>(() => getRescuedData('nexus_procurement_v1', INITIAL_PROCUREMENT));

  const [currentUser, setCurrentUser] = useState<User | null>(null);

  const safeSave = (key: string, data: any[]) => {
    localStorage.setItem(key, JSON.stringify(data));
  };

  useEffect(() => { 
    if (hasInitialized.current) {
      safeSave('nexus_orders_v12', orders || []);
      safeSave('nexus_customers_v12', customers || []);
      safeSave('nexus_products_v12', products || []);
      safeSave('nexus_users_v12', users || []);
      safeSave('nexus_odmaster_v12', odMaster || []);
      safeSave('nexus_procurement_v1', procurement || []);
    }
  }, [orders, customers, products, users, odMaster, procurement]);

  useEffect(() => {
    const saved = localStorage.getItem('nexus_logged_user_v12');
    if (saved) setCurrentUser(JSON.parse(saved));
    hasInitialized.current = true;
  }, []);

  const handleLogin = (user: User) => {
    setCurrentUser(user);
    localStorage.setItem('nexus_logged_user_v12', JSON.stringify(user));
    if (user.role === UserRole.DELIVERY) setActiveTab('execution');
    else if (user.role === UserRole.SALES) setActiveTab('sales-hub');
    else if (user.role === UserRole.PROCUREMENT || user.role === UserRole.PROCUREMENT_HEAD) setActiveTab('procurement');
    else setActiveTab('dashboard');
  };

  const handleLogout = () => {
    setCurrentUser(null);
    localStorage.removeItem('nexus_logged_user_v12');
    setSelectedOrderId(null);
  };

  if (!currentUser) {
    return <LoginView onLogin={handleLogin} availableUsers={users} />;
  }

  const renderContent = () => {
    if (selectedOrderId) {
      const order = orders.find(o => o.id === selectedOrderId);
      if (order) {
        return (
          <OrderDetailsView 
            order={order} 
            onBack={() => setSelectedOrderId(null)} 
            onUpdate={(upd) => setOrders(prev => prev.map(o => o.id === upd.id ? upd : o))}
            user={currentUser}
            customer={customers.find(c => c.id === order.customerId) || ({} as any)}
          />
        );
      }
    }

    switch (activeTab) {
      case 'dashboard': return <DashboardView orders={orders} onViewOrder={setSelectedOrderId} />;
      case 'sales-hub': return <SalesHubView orders={orders} products={products} currentUser={currentUser} />;
      case 'pms': return <PMSView currentUser={currentUser} />;
      case 'live-orders': return <LiveOrderView orders={orders} onSelectOrder={setSelectedOrderId} />;
      case 'procurement': return <ProcurementView procurement={procurement} products={products} currentUser={currentUser} onUpdate={setProcurement} />;
      case 'customer-creation': return <CustomerCreationView users={users} onSubmit={(newCust) => { setCustomers(prev => [newCust, ...prev]); setActiveTab('book-order'); }} />;
      
      case 'book-order': return <OrderFormView customers={customers} products={products} currentUser={currentUser} allOrders={orders} onSubmit={(o) => { setOrders([o, ...orders]); setActiveTab('credit-control'); }} />;
      case 'book-stn': return <STNBookingView products={products} currentUser={currentUser} onSubmit={(stn) => { setOrders([stn, ...orders]); setActiveTab('wh-selection'); }} />;
      
      case 'credit-control': return <OrderListView orders={orders} onSelect={setSelectedOrderId} onUpdateOrder={(upd) => setOrders(prev => prev.map(o => o.id === upd.id ? upd : o))} currentUser={currentUser} stageFilter={OrderStatus.PENDING_CREDIT_APPROVAL} />;
      
      case 'wh-selection': return <WHSelectionView orders={orders} onUpdateOrders={setOrders} onSelectOrder={setSelectedOrderId} />;

      case 'warehouse': return <OrderListView orders={orders} onSelect={setSelectedOrderId} onUpdateOrder={(upd) => setOrders(prev => prev.map(o => o.id === upd.id ? upd : o))} currentUser={currentUser} stageFilter={OrderStatus.PENDING_PACKING} />;
      
      case 'logistics-cost': return <LogisticsCostView orders={orders} onUpdateOrders={setOrders} onSelectOrder={setSelectedOrderId} />;
      
      case 'invoicing': return <InvoicingView orders={orders} onUpdateOrders={setOrders} onSelectOrder={setSelectedOrderId} />;
      
      case 'logistics-hub': return <LogisticsAssignmentView orders={orders} users={users} onBulkUpdate={setOrders} />;
      
      case 'execution': return <DeliveryExecutionView orders={orders} currentUser={currentUser} onUpdateOrders={setOrders} onOpenDetails={setSelectedOrderId} />;

      case 'master': return <MasterDataView customers={customers} products={products} users={users} odMaster={odMaster} onUpdateCustomers={setCustomers} onUpdateProducts={setProducts} onUpdateUsers={setUsers} onUpdateOdMaster={setOdMaster} currentUser={currentUser} />;
      case 'reports': return <ReportingView orders={orders} />;
      case 'archive': return <OrderArchiveView orders={orders} onSelectOrder={setSelectedOrderId} />;
      default: return <DashboardView orders={orders} onViewOrder={setSelectedOrderId} />;
    }
  };

  const isSales = currentUser.role === UserRole.SALES;
  const isAdmin = currentUser.role === UserRole.ADMIN;
  const isProcurement = currentUser.role === UserRole.PROCUREMENT || currentUser.role === UserRole.PROCUREMENT_HEAD;

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden relative">
      <aside className={`fixed inset-y-0 left-0 z-50 w-72 bg-emerald-950 text-white flex flex-col transition-transform lg:relative lg:translate-x-0 ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <div className="p-6 border-b border-white/10 flex items-center justify-between bg-emerald-900/50">
          <h1 className="text-2xl font-black text-white flex items-center gap-2 tracking-tighter">
            <ShieldCheck className="w-8 h-8 text-emerald-400" /> Nexus<span className="text-emerald-400">OMS</span>
          </h1>
          <button className="lg:hidden" onClick={() => setIsSidebarOpen(false)}><X size={20}/></button>
        </div>

        <nav className="flex-1 p-4 space-y-1 overflow-y-auto no-scrollbar">
          <div className="px-4 py-3 text-[10px] font-black text-emerald-500 uppercase tracking-widest opacity-60">Control Center</div>
          {!isSales && !isProcurement && <NavItem icon={<LayoutDashboard size={18}/>} label="Executive Pulse" active={activeTab === 'dashboard'} onClick={() => {setActiveTab('dashboard'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          {isSales && <NavItem icon={<TrendingUp size={18}/>} label="Sales Hub" active={activeTab === 'sales-hub'} onClick={() => {setActiveTab('sales-hub'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          <NavItem icon={<Activity size={18} className={activeTab === 'live-orders' ? 'animate-pulse' : ''} />} label="Live Missions" active={activeTab === 'live-orders'} onClick={() => {setActiveTab('live-orders'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<History size={18}/>} label="Order Archive" active={activeTab === 'archive'} onClick={() => {setActiveTab('archive'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          
          <div className="pt-6 px-4 py-3 text-[10px] font-black text-emerald-500 uppercase tracking-widest opacity-60">Supply Chain Lifecycle</div>
          
          <NavItem icon={<UserPlus size={18}/>} label="0. New Customer" active={activeTab === 'customer-creation'} onClick={() => {setActiveTab('customer-creation'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<PlusCircle size={18}/>} label="1. Book Order" active={activeTab === 'book-order'} onClick={() => {setActiveTab('book-order'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<RefreshCcw size={18}/>} label="1.1 Stock Transfer" active={activeTab === 'book-stn'} onClick={() => {setActiveTab('book-stn'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Zap size={18}/>} label="2. Credit Control" active={activeTab === 'credit-control'} onClick={() => {setActiveTab('credit-control'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Warehouse size={18}/>} label="2.5 WH Assignment" active={activeTab === 'wh-selection'} onClick={() => {setActiveTab('wh-selection'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Box size={18}/>} label="3. Warehouse" active={activeTab === 'warehouse'} onClick={() => {setActiveTab('warehouse'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<DollarSign size={18}/>} label="4. Logistics Cost" active={activeTab === 'logistics-cost'} onClick={() => {setActiveTab('logistics-cost'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Receipt size={18}/>} label="5. Invoicing" active={activeTab === 'invoicing'} onClick={() => {setActiveTab('invoicing'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Navigation size={18}/>} label="6. Logistics Hub" active={activeTab === 'logistics-hub'} onClick={() => {setActiveTab('logistics-hub'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Truck size={18}/>} label="7. Execution" active={activeTab === 'execution'} onClick={() => {setActiveTab('execution'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />

          <div className="pt-6 px-4 py-3 text-[10px] font-black text-emerald-500 uppercase tracking-widest opacity-60">System Intelligence</div>
          <NavItem icon={<Database size={18}/>} label="Organization" active={activeTab === 'master'} onClick={() => {setActiveTab('master'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<BarChart3 size={18}/>} label="Analytics" active={activeTab === 'reports'} onClick={() => {setActiveTab('reports'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<ClipboardList size={18}/>} label="Procurement Inbound" active={activeTab === 'procurement'} onClick={() => {setActiveTab('procurement'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          {(isSales || isAdmin) && <NavItem icon={<Medal size={18}/>} label="Incentive Terminal" active={activeTab === 'pms'} onClick={() => {setActiveTab('pms'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
        </nav>

        <div className="p-4 bg-emerald-950/80">
          <div className="flex items-center gap-3 p-3 bg-white/5 rounded-xl border border-white/5">
            <div className="w-8 h-8 rounded-full bg-emerald-500 flex items-center justify-center text-xs font-bold">{currentUser.name[0]}</div>
            <div className="flex-1 min-w-0">
              <p className="text-xs font-bold truncate text-white">{currentUser.name}</p>
              <p className="text-[10px] text-emerald-400 font-black uppercase tracking-wider">{currentUser.role}</p>
            </div>
            <button onClick={handleLogout} className="text-emerald-300 hover:text-rose-400 transition-colors"><LogOut size={16} /></button>
          </div>
        </div>
      </aside>

      <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-6 lg:px-8 shadow-sm shrink-0">
           <div className="flex items-center gap-4">
              <button className="lg:hidden p-2 -ml-2 text-slate-600" onClick={() => setIsSidebarOpen(true)}><Menu size={24}/></button>
              <div className="hidden lg:flex items-center gap-2">
                 <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                 <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Enterprise Core Terminal Online</span>
              </div>
           </div>
        </header>
        <div className="flex-1 overflow-y-auto p-4 lg:p-10 no-scrollbar">{renderContent()}</div>
      </main>
    </div>
  );
};

const NavItem: React.FC<{icon: any, label: string, active: boolean, onClick: any}> = ({ icon, label, active, onClick }) => (
  <button onClick={onClick} className={`w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl text-xs font-black uppercase tracking-widest transition-all ${active ? 'bg-emerald-500 text-white shadow-lg' : 'text-emerald-300/60 hover:bg-white/5 hover:text-white'}`}>
    {icon} {label}
  </button>
);

export default App;
