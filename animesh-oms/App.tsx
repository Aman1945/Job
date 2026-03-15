
import React, { useState, useMemo, useEffect, useRef } from 'react';
import { UserRole, Order, OrderStatus, Customer, Product, User, ODMaster, ProcurementItem, PackagingMaterial, PackagingTransaction, InventoryTransaction, ProductionLog, LaborSession, DailyProtocol, RTVReturn, ConsumablePurchase, DeliveryRoute, Vehicle, SupplyChainAlert, POStatus, DemandForecast, ForecastOverride, WorkingCapitalMetrics } from './types';
import ControlTowerView from './views/ControlTowerView';
import { MOCK_USERS, MOCK_CUSTOMERS, MOCK_PRODUCTS, INITIAL_ORDERS, INITIAL_PROCUREMENT, MOCK_PACKAGING, MOCK_LABOR_SESSIONS, MOCK_OD_MASTER, MOCK_ALERTS, MOCK_PO_STATUS, MOCK_FORECASTS, MOCK_OVERRIDES, MOCK_WORKING_CAPITAL } from './mockData';
import CEODashboardView from './views/CEODashboardView';
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
import PriceListView from './views/PriceListView';
import NearExpiryView from './views/NearExpiryView';
import PackagingInventoryView from './views/PackagingInventoryView';
import InventoryHubView from './views/InventoryHubView';
import SalesManagerDashboardView from './views/SalesManagerDashboardView';
import QualityControlView from './views/QualityControlView';
import DailyProtocolView from './views/DailyProtocolView';
import RTVView from './views/RTVView';
import MaterialPlanningView from './views/MaterialPlanningView';
import WorkflowBlueprintView from './views/WorkflowBlueprintView';
import ConsumablePurchaseView from './views/ConsumablePurchaseView';
import CreditAlertView from './views/CreditAlertView';
import RouteOptimizationView from './views/RouteOptimizationView';
import DriverRouteView from './views/DriverRouteView';
import DebtorInformationView from './views/DebtorInformationView';
import { 
  LayoutDashboard, ShoppingCart, Package, Truck, 
  Users, BarChart3, PlusCircle, Menu, 
  X, Bell, Activity, Navigation, LogOut, Database,
  Receipt, ShieldCheck, Zap, Box, ListChecks, FileText, DollarSign, Archive, TrendingUp, History, Warehouse,
  ClipboardList, UserPlus, RefreshCcw, Medal, Tag, AlertTriangle, Layers, Book, Scale, AreaChart as AreaChartIcon,
  UserCircle,
  ShieldAlert,
  CalendarCheck,
  RotateCcw,
  Cpu,
  Crown,
  GitMerge,
  Droplet,
  MessageSquare,
  CheckCircle,
  Mail,
  MapPin,
  Route,
  Wallet,
  Brain
} from 'lucide-react';
import { sendWhatsAppNotification, WHATSAPP_MESSAGES } from './services/whatsappService';

const MOCK_VEHICLES: Vehicle[] = [
  { id: 'V1', regNo: 'MH-12-NX-001', type: '7ft Truck', capacityKg: 1500, capacityCft: 200, status: 'IDLE' },
  { id: 'V2', regNo: 'MH-12-NX-002', type: 'E-Van', capacityKg: 800, capacityCft: 120, status: 'IDLE' },
  { id: 'V3', regNo: 'MH-12-NX-003', type: 'Biker', capacityKg: 30, capacityCft: 5, status: 'IDLE' },
];

const App: React.FC = () => {
  const [activeTab, setActiveTab] = useState<string>('dashboard');
  const [selectedOrderId, setSelectedOrderId] = useState<string | null>(null);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [waToast, setWaToast] = useState<{recipient: string, message: string, timestamp: string} | null>(null);
  const [emailToast, setEmailToast] = useState<{recipient: string, subject: string, attachmentCount: number, timestamp: string} | null>(null);

  const hasInitialized = useRef(false);

  useEffect(() => {
    const handleWaEvent = (e: any) => {
      setWaToast(e.detail);
      setTimeout(() => setWaToast(null), 5000);
    };
    const handleEmailEvent = (e: any) => {
      setEmailToast(e.detail);
      setTimeout(() => setEmailToast(null), 5000);
    };
    window.addEventListener('whatsapp-dispatched', handleWaEvent);
    window.addEventListener('email-dispatched', handleEmailEvent);
    return () => {
      window.removeEventListener('whatsapp-dispatched', handleWaEvent);
      window.removeEventListener('email-dispatched', handleEmailEvent);
    };
  }, []);

  const getRescuedData = (key: string, defaultValue: any) => {
    const current = localStorage.getItem(key);
    if (current) {
      try {
        const parsed = JSON.parse(current);
        return parsed;
      } catch(e) {}
    }
    return defaultValue;
  };

  const [orders, setOrders] = useState<Order[]>(() => getRescuedData('nexus_orders_v13', INITIAL_ORDERS));
  const [customers, setCustomers] = useState<Customer[]>(() => getRescuedData('nexus_customers_v13', MOCK_CUSTOMERS));
  const [products, setProducts] = useState<Product[]>(() => getRescuedData('nexus_products_v13', MOCK_PRODUCTS));
  const [users, setUsers] = useState<User[]>(() => getRescuedData('nexus_users_v13', MOCK_USERS));
  const [odMaster, setOdMaster] = useState<ODMaster[]>(() => getRescuedData('nexus_odmaster_v13', MOCK_OD_MASTER));
  const [procurement, setProcurement] = useState<ProcurementItem[]>(() => getRescuedData('nexus_procurement_v2', INITIAL_PROCUREMENT));
  const [packagingMaterials, setPackagingMaterials] = useState<PackagingMaterial[]>(() => getRescuedData('nexus_pkg_mat_v1', MOCK_PACKAGING));
  const [packagingTransactions, setPackagingTransactions] = useState<PackagingTransaction[]>(() => getRescuedData('nexus_pkg_tx_v1', []));
  const [inventoryTransactions, setInventoryTransactions] = useState<InventoryTransaction[]>(() => getRescuedData('nexus_inv_tx_v1', []));
  const [productionLogs, setProductionLogs] = useState<ProductionLog[]>(() => getRescuedData('nexus_prod_logs_v1', []));
  const [laborSessions, setLaborSessions] = useState<LaborSession[]>(() => getRescuedData('nexus_labor_v1', MOCK_LABOR_SESSIONS));
  const [protocols, setProtocols] = useState<DailyProtocol[]>(() => getRescuedData('nexus_protocols_v1', []));
  const [rtvReturns, setRtvReturns] = useState<RTVReturn[]>(() => getRescuedData('nexus_rtv_v1', []));
  const [consumablePurchases, setConsumablePurchases] = useState<ConsumablePurchase[]>(() => getRescuedData('nexus_consumables_v1', []));
  const [activeRoutes, setActiveRoutes] = useState<DeliveryRoute[]>(() => getRescuedData('nexus_routes_v1', []));
  const [vehicles, setVehicles] = useState<Vehicle[]>(() => getRescuedData('nexus_vehicles_v1', MOCK_VEHICLES));
  const [alerts, setAlerts] = useState<SupplyChainAlert[]>(() => getRescuedData('nexus_alerts_v1', MOCK_ALERTS));
  const [poStatus, setPoStatus] = useState<POStatus[]>(() => getRescuedData('nexus_po_v1', MOCK_PO_STATUS));
  const [forecasts, setForecasts] = useState<DemandForecast[]>(() => getRescuedData('nexus_forecasts_v1', MOCK_FORECASTS));
  const [overrides, setOverrides] = useState<ForecastOverride[]>(() => getRescuedData('nexus_overrides_v1', MOCK_OVERRIDES));
  const [workingCapital, setWorkingCapital] = useState<WorkingCapitalMetrics>(() => getRescuedData('nexus_capital_v1', MOCK_WORKING_CAPITAL));

  const [currentUser, setCurrentUser] = useState<User | null>(null);

  const safeSave = (key: string, data: any) => {
    localStorage.setItem(key, JSON.stringify(data));
  };

  useEffect(() => { 
    if (hasInitialized.current) {
      safeSave('nexus_orders_v13', orders || []);
      safeSave('nexus_customers_v13', customers || []);
      safeSave('nexus_products_v13', products || []);
      safeSave('nexus_users_v13', users || []);
      safeSave('nexus_odmaster_v13', odMaster || []);
      safeSave('nexus_procurement_v2', procurement || []);
      safeSave('nexus_pkg_mat_v1', packagingMaterials || []);
      safeSave('nexus_pkg_tx_v1', packagingTransactions || []);
      safeSave('nexus_inv_tx_v1', inventoryTransactions || []);
      safeSave('nexus_prod_logs_v1', productionLogs || []);
      safeSave('nexus_labor_v1', laborSessions || []);
      safeSave('nexus_protocols_v1', protocols || []);
      safeSave('nexus_rtv_v1', rtvReturns || []);
      safeSave('nexus_consumables_v1', consumablePurchases || []);
      safeSave('nexus_routes_v1', activeRoutes || []);
      safeSave('nexus_vehicles_v1', vehicles || []);
      safeSave('nexus_alerts_v1', alerts || []);
      safeSave('nexus_po_v1', poStatus || []);
      safeSave('nexus_forecasts_v1', forecasts || []);
      safeSave('nexus_overrides_v1', overrides || []);
      safeSave('nexus_capital_v1', workingCapital || []);
    }
  }, [orders, customers, products, users, odMaster, procurement, packagingMaterials, packagingTransactions, inventoryTransactions, productionLogs, laborSessions, protocols, rtvReturns, consumablePurchases, activeRoutes, vehicles, alerts, poStatus, forecasts, overrides, workingCapital]);

  useEffect(() => {
    const saved = localStorage.getItem('nexus_logged_user_v12');
    if (saved) setCurrentUser(JSON.parse(saved));
    hasInitialized.current = true;
  }, []);

  const currentRoute = useMemo(() => {
    if (!currentUser) return null;
    return activeRoutes.find(r => r.driverId === currentUser.id && r.status === 'ACTIVE') || null;
  }, [activeRoutes, currentUser?.id]);

  const handleLogin = (user: User) => {
    setCurrentUser(user);
    localStorage.setItem('nexus_logged_user_v12', JSON.stringify(user));
    if (user.role === UserRole.DELIVERY) setActiveTab('driver-mission');
    else if (user.role === UserRole.SALES) setActiveTab('sales-hub');
    else if (user.role === UserRole.PROCUREMENT || user.role === UserRole.PROCUREMENT_HEAD) setActiveTab('procurement');
    else if (user.role === UserRole.WAREHOUSE || user.role === UserRole.QUALITY_PROD_HEAD) setActiveTab('inventory-hub');
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

  const handleProtocolUpdate = (updated: DailyProtocol) => {
    setProtocols(prev => {
      const idx = prev.findIndex(p => p.userId === updated.userId && p.date === updated.date);
      if (idx >= 0) {
        const newArr = [...prev];
        newArr[idx] = updated;
        return newArr;
      }
      return [...prev, updated];
    });
  };

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
            products={products}
          />
        );
      }
    }

    switch (activeTab) {
      case 'control-tower':
        return (
          <ControlTowerView 
            orders={orders} 
            customers={customers} 
            products={products} 
            procurement={procurement} 
            users={users} 
            alerts={alerts}
            poStatus={poStatus}
            forecasts={forecasts}
            overrides={overrides}
            workingCapital={workingCapital}
          />
        );
      case 'dashboard': return <CEODashboardView orders={orders} customers={customers} products={products} procurement={procurement} users={users} />;
      case 'sales-manager-dashboard': return <SalesManagerDashboardView orders={orders} users={users} />;
      case 'sales-hub': return <SalesHubView orders={orders} products={products} currentUser={currentUser} />;
      case 'pms': return <PMSView currentUser={currentUser} />;
      case 'live-orders': return <LiveOrderView orders={orders} onSelectOrder={setSelectedOrderId} />;
      case 'procurement': return <ProcurementView procurement={procurement} products={products} currentUser={currentUser} onUpdate={setProcurement} />;
      case 'material-planning': return <MaterialPlanningView products={products} packaging={packagingMaterials} orders={orders} currentUser={currentUser} onUpdateProcurement={setProcurement} />;
      case 'inventory-hub': return <InventoryHubView products={products} orders={orders} packaging={packagingMaterials} transactions={inventoryTransactions} productionLogs={productionLogs} laborSessions={laborSessions} onUpdateProducts={setProducts} onUpdateTransactions={setInventoryTransactions} onUpdateProductionLogs={setProductionLogs} onUpdateLaborSessions={setLaborSessions} currentUser={currentUser} />;
      case 'packaging-inventory': return <PackagingInventoryView materials={packagingMaterials} transactions={packagingTransactions} onUpdateMaterials={setPackagingMaterials} onUpdateTransactions={setPackagingTransactions} currentUser={currentUser} />;
      case 'horeca-catalogue': return <PriceListView products={products} type="Horeca" />;
      case 'retail-catalogue': return <PriceListView products={products} type="Retail" />;
      case 'near-expiry': return <NearExpiryView products={products} customers={customers} currentUser={currentUser} onSubmitOrder={(o) => { setOrders([o, ...orders]); setActiveTab('credit-control'); }} />;
      case 'customer-creation': return <CustomerCreationView users={users} onSubmit={(newCust) => { setCustomers(prev => [newCust, ...prev]); setActiveTab('book-order'); }} />;
      case 'book-order': return <OrderFormView customers={customers} products={products} currentUser={currentUser} allOrders={orders} onSubmit={(o) => { 
          setOrders([o, ...orders]); 
          setActiveTab('credit-control');
          const totalVal = o.items.reduce((s,i)=>s+(i.price*i.quantity),0);
          sendWhatsAppNotification(currentUser, WHATSAPP_MESSAGES.SALES_ORDER_BOOKED(o.id, o.customerName, totalVal));
        }} onBulkSubmit={(newOrders) => { setOrders([...newOrders, ...orders]); setActiveTab('credit-control'); }} />;
      case 'book-stn': return <STNBookingView products={products} currentUser={currentUser} onSubmit={(stn) => { setOrders([stn, ...orders]); setActiveTab('wh-selection'); }} />;
      case 'credit-control': return <OrderListView orders={orders} onSelect={setSelectedOrderId} onUpdateOrder={(upd) => setOrders(prev => prev.map(o => o.id === upd.id ? upd : o))} currentUser={currentUser} stageFilter={OrderStatus.PENDING_CREDIT_APPROVAL} />;
      case 'wh-selection': return <WHSelectionView orders={orders} onUpdateOrders={setOrders} onSelectOrder={setSelectedOrderId} />;
      case 'warehouse': return <OrderListView orders={orders} onSelect={setSelectedOrderId} onUpdateOrder={(upd) => setOrders(prev => prev.map(o => o.id === upd.id ? upd : o))} currentUser={currentUser} stageFilter={OrderStatus.PENDING_PACKING} multiStageFilter={[OrderStatus.PENDING_PACKING, OrderStatus.PART_PACKED, OrderStatus.BACKORDER]} />;
      case 'quality-control': return <QualityControlView orders={orders} currentUser={currentUser} onUpdateOrder={(upd) => setOrders(prev => prev.map(o => o.id === upd.id ? upd : o))} onSelectOrder={setSelectedOrderId} />;
      case 'logistics-cost': return <LogisticsCostView orders={orders} onUpdateOrders={setOrders} onSelectOrder={setSelectedOrderId} />;
      case 'invoicing': return <InvoicingView orders={orders} onUpdateOrders={setOrders} onSelectOrder={setSelectedOrderId} />;
      case 'logistics-hub': return <LogisticsAssignmentView orders={orders} users={users} onBulkUpdate={setOrders} />;
      case 'route-optimization': return <RouteOptimizationView orders={orders} rtvs={rtvReturns} vehicles={vehicles} deliveryAgents={users.filter(u => u.role === UserRole.DELIVERY)} onRouteCreated={(r) => setActiveRoutes([r, ...activeRoutes])} />;
      case 'driver-mission': return <DriverRouteView activeRoute={currentRoute} currentUser={currentUser} onUpdateStop={(rid, sid, status) => {
         const updated = activeRoutes.map(r => r.id === rid ? { ...r, stops: r.stops.map(s => s.id === sid ? { ...s, status } : s) } : r);
         setActiveRoutes(updated);
      }} onMissionComplete={(rid) => {
         const updated = activeRoutes.map(r => r.id === rid ? { ...r, status: 'COMPLETED' as any } : r);
         setActiveRoutes(updated);
      }} />;
      case 'execution': return <DeliveryExecutionView orders={orders} currentUser={currentUser} onUpdateOrders={setOrders} onOpenDetails={setSelectedOrderId} />;
      case 'master': return <MasterDataView customers={customers} products={products} users={users} odMaster={odMaster} onUpdateCustomers={setCustomers} onUpdateProducts={setProducts} onUpdateUsers={setUsers} onUpdateOdMaster={setOdMaster} currentUser={currentUser} />;
      case 'reports': return <ReportingView orders={orders} />;
      case 'archive': return <OrderArchiveView orders={orders} onSelectOrder={setSelectedOrderId} />;
      case 'all-orders': return <OrderListView orders={orders} onSelect={setSelectedOrderId} onUpdateOrder={(upd) => setOrders(prev => prev.map(o => o.id === upd.id ? upd : o))} currentUser={currentUser} />;
      case 'daily-routine': return <DailyProtocolView currentUser={currentUser} existingProtocols={protocols} onProtocolUpdate={handleProtocolUpdate} />;
      case 'rtv': return <RTVView customers={customers} products={products} orders={orders} returns={rtvReturns} currentUser={currentUser} onUpdateReturns={setRtvReturns} />;
      case 'blueprint': return <WorkflowBlueprintView />;
      case 'consumables': return <ConsumablePurchaseView currentUser={currentUser} purchases={consumablePurchases} onUpdatePurchases={setConsumablePurchases} />;
      case 'credit-alerts': return <CreditAlertView odMaster={odMaster} orders={orders} currentUser={currentUser} />;
      case 'debtor-info': return <DebtorInformationView odMaster={odMaster} currentUser={currentUser} onUpdateOdMaster={setOdMaster} />;
      default: return <CEODashboardView orders={orders} customers={customers} products={products} procurement={procurement} users={users} />;
    }
  };

  const isOperational = [
    UserRole.WAREHOUSE, 
    UserRole.QC, 
    UserRole.LOGISTICS, 
    UserRole.ADMIN, 
    UserRole.QUALITY_PROD_HEAD, 
    UserRole.DELIVERY, 
    UserRole.PROCUREMENT, 
    UserRole.PROCUREMENT_HEAD,
    UserRole.SALES
  ].includes(currentUser.role as UserRole);

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden relative">
      {/* WhatsApp Toast Simulation */}
      {waToast && (
        <div className="fixed top-8 right-8 z-[200] w-80 animate-in slide-in-from-right-10">
           <div className="bg-[#25D366] text-white p-5 rounded-3xl shadow-2xl flex gap-4 border-b-4 border-emerald-700">
              <div className="w-12 h-12 bg-white/20 rounded-2xl flex items-center justify-center shrink-0">
                 <MessageSquare size={24} />
              </div>
              <div className="min-w-0">
                 <p className="text-[10px] font-black uppercase text-emerald-100 flex items-center gap-1">
                    <CheckCircle size={10}/> WhatsApp Sent • {waToast.timestamp}
                 </p>
                 <p className="text-xs font-black truncate">To: {waToast.recipient}</p>
                 <p className="text-[11px] mt-1 leading-tight line-clamp-2 opacity-90">{waToast.message}</p>
              </div>
           </div>
        </div>
      )}

      {/* Email Toast Simulation */}
      {emailToast && (
        <div className={`fixed ${waToast ? 'top-40' : 'top-8'} right-8 z-[200] w-80 animate-in slide-in-from-right-10 transition-all duration-500`}>
           <div className="bg-indigo-600 text-white p-5 rounded-3xl shadow-2xl flex gap-4 border-b-4 border-indigo-800">
              <div className="w-12 h-12 bg-white/20 rounded-2xl flex items-center justify-center shrink-0">
                 <Mail size={24} />
              </div>
              <div className="min-w-0">
                 <p className="text-[10px] font-black uppercase text-indigo-100 flex items-center gap-1">
                    <CheckCircle size={10}/> Email Dispatched • {emailToast.timestamp}
                 </p>
                 <p className="text-xs font-black truncate">To: {emailToast.recipient}</p>
                 <p className="text-[11px] mt-1 leading-tight line-clamp-2 opacity-90">{emailToast.subject} • {emailToast.attachmentCount} Files</p>
              </div>
           </div>
        </div>
      )}

      {/* Mobile Sidebar Backdrop */}
      {isSidebarOpen && (
        <div 
          className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-40 lg:hidden animate-in fade-in duration-300"
          onClick={() => setIsSidebarOpen(false)}
        />
      )}

      <aside className={`fixed inset-y-0 left-0 z-50 w-72 bg-emerald-950 text-white flex flex-col transition-transform lg:relative lg:translate-x-0 ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full shadow-2xl'}`}>
        <div className="p-6 border-b border-white/10 flex items-center justify-between bg-emerald-900/50">
          <h1 className="text-2xl font-black text-white flex items-center gap-2 tracking-tighter">
            <ShieldCheck className="w-8 h-8 text-emerald-400" /> Animesh<span className="text-emerald-400"> - OMS</span>
          </h1>
          <button className="lg:hidden" onClick={() => setIsSidebarOpen(false)}><X size={20}/></button>
        </div>
        <nav className="flex-1 p-4 space-y-1 overflow-y-auto no-scrollbar">
          <div className="px-4 py-3 text-[10px] font-black text-emerald-500 uppercase tracking-widest opacity-60">Compliance & Shift</div>
          {isOperational && <NavItem icon={<CalendarCheck size={18}/>} label="Daily Protocol" active={activeTab === 'daily-routine'} onClick={() => {setActiveTab('daily-routine'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          
          <div className="px-4 py-3 text-[10px] font-black text-emerald-500 uppercase tracking-widest opacity-60">Control Center</div>
          <NavItem icon={<Brain size={18} className={activeTab === 'control-tower' ? '' : 'text-indigo-400 animate-pulse'}/>} label="AI Control Tower" active={activeTab === 'control-tower'} onClick={() => {setActiveTab('control-tower'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          {currentUser.role === UserRole.ADMIN && <NavItem icon={<Crown size={18}/>} label="Executive Pulse" active={activeTab === 'dashboard'} onClick={() => {setActiveTab('dashboard'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          {currentUser.role === UserRole.ADMIN && <NavItem icon={<AreaChartIcon size={18}/>} label="Sales Leadership" active={activeTab === 'sales-manager-dashboard'} onClick={() => {setActiveTab('sales-manager-dashboard'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          {currentUser.role === UserRole.SALES && <NavItem icon={<TrendingUp size={18}/>} label="Sales Hub" active={activeTab === 'sales-hub'} onClick={() => {setActiveTab('sales-hub'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          <NavItem icon={<Activity size={18} className={activeTab === 'live-orders' ? 'animate-pulse' : ''} />} label="Live Missions" active={activeTab === 'live-orders'} onClick={() => {setActiveTab('live-orders'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<History size={18}/>} label="Order Archive" active={activeTab === 'archive'} onClick={() => {setActiveTab('archive'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<ListChecks size={18}/>} label="Global Mission Queue" active={activeTab === 'all-orders'} onClick={() => {setActiveTab('all-orders'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          
          <div className="pt-6 px-4 py-3 text-[10px] font-black text-emerald-500 uppercase tracking-widest opacity-60">Fleet & Logistics Core</div>
          <NavItem icon={<Route size={18}/>} label="Route Optimization" active={activeTab === 'route-optimization'} onClick={() => {setActiveTab('route-optimization'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          {currentUser.role === UserRole.DELIVERY && <NavItem icon={<Navigation size={18}/>} label="Driver Terminal" active={activeTab === 'driver-mission'} onClick={() => {setActiveTab('driver-mission'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          <NavItem icon={<MapPin size={18}/>} label="Logistics Hub" active={activeTab === 'logistics-hub'} onClick={() => {setActiveTab('logistics-hub'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Truck size={18}/>} label="Execution" active={activeTab === 'execution'} onClick={() => {setActiveTab('execution'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          
          <div className="pt-6 px-4 py-3 text-[10px] font-black text-emerald-500 uppercase tracking-widest opacity-60">Supply Chain Lifecycle</div>
          <NavItem icon={<UserPlus size={18}/>} label="0. New Customer" active={activeTab === 'customer-creation'} onClick={() => {setActiveTab('customer-creation'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<PlusCircle size={18}/>} label="1. Book Order" active={activeTab === 'book-order'} onClick={() => {setActiveTab('book-order'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<RefreshCcw size={18}/>} label="1.1 Stock Transfer" active={activeTab === 'book-stn'} onClick={() => {setActiveTab('book-stn'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<AlertTriangle size={18}/>} label="1.2 Clearance Terminal" active={activeTab === 'near-expiry'} onClick={() => {setActiveTab('near-expiry'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Zap size={18}/>} label="2. Credit Control" active={activeTab === 'credit-control'} onClick={() => {setActiveTab('credit-control'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          {currentUser.role === UserRole.ADMIN && <NavItem icon={<AlertTriangle size={18} className={activeTab === 'credit-alerts' ? '' : 'text-rose-400'}/>} label="2.1 Credit Alerts" active={activeTab === 'credit-alerts'} onClick={() => {setActiveTab('credit-alerts'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          <NavItem icon={<Warehouse size={18}/>} label="2.5 WH Assignment" active={activeTab === 'wh-selection'} onClick={() => {setActiveTab('wh-selection'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Box size={18}/>} label="3. Warehouse" active={activeTab === 'warehouse'} onClick={() => {setActiveTab('warehouse'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<CheckCircle size={18}/>} label="3.5 Quality Control" active={activeTab === 'quality-control'} onClick={() => {setActiveTab('quality-control'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<DollarSign size={18}/>} label="4. Logistics Cost" active={activeTab === 'logistics-cost'} onClick={() => {setActiveTab('logistics-cost'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Receipt size={18}/>} label="5. Invoicing" active={activeTab === 'invoicing'} onClick={() => {setActiveTab('invoicing'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<RotateCcw size={18}/>} label="5.1 Customer RTV" active={activeTab === 'rtv'} onClick={() => {setActiveTab('rtv'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          
          <div className="pt-6 px-4 py-3 text-[10px] font-black text-emerald-500 uppercase tracking-widest opacity-60">System Intelligence</div>
          <NavItem icon={<Wallet size={18}/>} label="Debtor Information" active={activeTab === 'debtor-info'} onClick={() => {setActiveTab('debtor-info'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<GitMerge size={18}/>} label="Workflow Blueprint" active={activeTab === 'blueprint'} onClick={() => {setActiveTab('blueprint'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Database size={18}/>} label="Organization" active={activeTab === 'master'} onClick={() => {setActiveTab('master'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<BarChart3 size={18}/>} label="Analytics" active={activeTab === 'reports'} onClick={() => {setActiveTab('reports'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<ClipboardList size={18}/>} label="Procurement Inbound" active={activeTab === 'procurement'} onClick={() => {setActiveTab('procurement'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Cpu size={18}/>} label="Material Planning" active={activeTab === 'material-planning'} onClick={() => {setActiveTab('material-planning'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Scale size={18}/>} label="Inventory Hub" active={activeTab === 'inventory-hub'} onClick={() => {setActiveTab('inventory-hub'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          {isOperational && <NavItem icon={<ShoppingCart size={18}/>} label="Consumable Purchase" active={activeTab === 'consumables'} onClick={() => {setActiveTab('consumables'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
          <NavItem icon={<Layers size={18}/>} label="Packaging Stock" active={activeTab === 'packaging-inventory'} onClick={() => {setActiveTab('packaging-inventory'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Tag size={18}/>} label="Horeca Catalogue" active={activeTab === 'horeca-catalogue'} onClick={() => {setActiveTab('horeca-catalogue'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          <NavItem icon={<Book size={18}/>} label="Retail Catalogue" active={activeTab === 'retail-catalogue'} onClick={() => {setActiveTab('retail-catalogue'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />
          {(currentUser.role === UserRole.SALES || currentUser.role === UserRole.ADMIN) && <NavItem icon={<Medal size={18}/>} label="Incentive Terminal" active={activeTab === 'pms'} onClick={() => {setActiveTab('pms'); setSelectedOrderId(null); setIsSidebarOpen(false);}} />}
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
  <button onClick={onClick} className={`w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl text-xs font-black uppercase tracking-widest transition-all ${active ? 'bg-emerald-500 text-white shadow-lg' : 'text-emerald-100/70 hover:bg-white/10 hover:text-white'}`}>
    {icon} {label}
  </button>
);

export default App;
