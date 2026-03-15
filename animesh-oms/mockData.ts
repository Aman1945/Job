import { Customer, Product, Order, OrderStatus, User, UserRole, ProcurementItem, PackagingMaterial, LaborSession, ODMaster, SupplyChainAlert, POStatus, DemandForecast, ForecastOverride, WorkingCapitalMetrics } from './types';

// Helper to get relative dates
const getRelDate = (days: number) => {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d.toISOString().split('T')[0];
};

export const MOCK_USERS: User[] = [
  { id: 'animesh.jamuar@bigsams.in', name: 'Animesh Jamuar', role: UserRole.ADMIN, status: 'Active', isApprover: true, whatsappNumber: '+919876543210' },
  { id: 'dhiraj@bigsams.in', name: 'Dhiraj', role: UserRole.QUALITY_PROD_HEAD, status: 'Active', isApprover: false, whatsappNumber: '+919123456789' },
  { id: 'lavin@bigsams.in', name: 'Lavin', role: UserRole.SALES, status: 'Active', isApprover: false, monthlyTarget: 1000000, monthlyQtyTarget: 4000, whatsappNumber: '+919800112233' },
  { id: 'sandeep.chavan@bigsams.in', name: 'Sandeep Chavan', role: UserRole.SALES, status: 'Active', isApprover: false, monthlyTarget: 1500000, monthlyQtyTarget: 6000, whatsappNumber: '+919911223344' },
  { id: 'rakesh.khare@bigsams.in', name: 'Rakesh Khare', role: UserRole.SALES, status: 'Active', isApprover: false, monthlyTarget: 800000, monthlyQtyTarget: 3000 },
  { id: 'mithun.muddappa@bigsams.in', name: 'Mithun Muddappa', role: UserRole.SALES, status: 'Active', isApprover: false, monthlyTarget: 1200000, monthlyQtyTarget: 5000 },
  { id: 'credit.control@bigsams.in', name: 'Pawan (Finance)', role: UserRole.FINANCE, status: 'Active', isApprover: true },
  { id: 'warehouse.lead@bigsams.in', name: 'Manoj Production', role: UserRole.WAREHOUSE, status: 'Active', isApprover: false },
  { id: 'procurement.head@bigsams.in', name: 'Naveen (Procurement)', role: UserRole.PROCUREMENT_HEAD, status: 'Active', isApprover: true },
];

export const MOCK_CUSTOMERS: Customer[] = [
  { id: '190050', name: 'STAFF SALES (Head Office)', type: 'Internal', outstanding: 2500, overdue: 0, ageingDays: 0, creditLimit: 50000, securityChqStatus: 'N/A', creditDays: '30 days', salesManager: 'Lavin', assignedSalespersonId: 'lavin@bigsams.in', agingBuckets: { '0 to 7': 2500, '7 to 15': 0, '15 to 30': 0, '30 to 45': 0, '45 to 90': 0, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 } },
  { id: '190068', name: 'Harbour Exports', type: 'Distributor', outstanding: 145000, overdue: 42000, ageingDays: 45, creditLimit: 200000, securityChqStatus: 'N/A', creditDays: '30 days', salesManager: 'Sandeep Chavan', assignedSalespersonId: 'sandeep.chavan@bigsams.in', agingBuckets: { '0 to 7': 50000, '7 to 15': 20000, '15 to 30': 33000, '30 to 45': 42000, '45 to 90': 0, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 } },
  { id: '190094', name: 'Palkit Impex private limited', type: 'Private Ltd', outstanding: 385000, overdue: 120000, ageingDays: 60, creditLimit: 500000, securityChqStatus: 'Yes', creditDays: '30 days', salesManager: 'Sandeep Chavan', assignedSalespersonId: 'sandeep.chavan@bigsams.in', agingBuckets: { '0 to 7': 85000, '7 to 15': 100000, '15 to 30': 80000, '30 to 45': 120000, '45 to 90': 0, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 } },
  { id: '190187', name: 'VR Fine Foods', type: 'Horeca', outstanding: 650000, overdue: 250000, ageingDays: 95, creditLimit: 1000000, securityChqStatus: 'Yes', creditDays: '30 days', salesManager: 'Rakesh Khare', assignedSalespersonId: 'rakesh.khare@bigsams.in', agingBuckets: { '0 to 7': 100000, '7 to 15': 100000, '15 to 30': 100000, '30 to 45': 100000, '45 to 90': 250000, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 } },
];

export const MOCK_OD_MASTER: ODMaster[] = [
  {
    customerId: '190068',
    channel: 'Distributor',
    salesManager: 'Sandeep Chavan',
    customerClass: 'Tier A',
    employeeResponsible: 'Sandeep Chavan',
    customerName: 'Harbour Exports',
    creditDays: '30 Days',
    creditLimit: 200000,
    securityChq: 'N/A',
    distChannel: '19',
    outstandingAmt: 145000,
    overdueAmt: 42000,
    diffYesterdayToday: -5000,
    aging: {
      '0 to 7': 50000,
      '7 to 15': 20000,
      '15 to 30': 33000,
      '30 to 45': 42000,
      '45 to 90': 0,
      '90 to 120': 0,
      '120 to 150': 0,
      '150 to 180': 0,
      '>180': 0
    }
  },
  {
    customerId: '190094',
    channel: 'Private Ltd',
    salesManager: 'Sandeep Chavan',
    customerClass: 'Tier B',
    employeeResponsible: 'Sandeep Chavan',
    customerName: 'Palkit Impex private limited',
    creditDays: '45 Days',
    creditLimit: 500000,
    securityChq: 'Yes',
    distChannel: '19',
    outstandingAmt: 385000,
    overdueAmt: 120000,
    diffYesterdayToday: 12000,
    aging: {
      '0 to 7': 85000,
      '7 to 15': 100000,
      '15 to 30': 80000,
      '30 to 45': 0,
      '45 to 90': 120000,
      '90 to 120': 0,
      '120 to 150': 0,
      '150 to 180': 0,
      '>180': 0
    }
  },
  {
    customerId: '190187',
    channel: 'Horeca',
    salesManager: 'Rakesh Khare',
    customerClass: 'Tier A+',
    employeeResponsible: 'Rakesh Khare',
    customerName: 'VR Fine Foods',
    creditDays: '15 Days',
    creditLimit: 1000000,
    securityChq: 'Yes',
    distChannel: '10',
    outstandingAmt: 650000,
    overdueAmt: 250000,
    diffYesterdayToday: 0,
    aging: {
      '0 to 7': 50000,
      '7 to 15': 50000,
      '15 to 30': 50000,
      '30 to 45': 50000,
      '45 to 90': 100000,
      '90 to 120': 100000,
      '120 to 150': 50000,
      '150 to 180': 100000,
      '>180': 100000
    }
  },
  {
    customerId: '190555',
    channel: 'Retail',
    salesManager: 'Lavin',
    customerClass: 'Tier C',
    employeeResponsible: 'Lavin',
    customerName: 'Gourmet Central Retail',
    creditDays: '30 Days',
    creditLimit: 100000,
    securityChq: 'No',
    distChannel: '20',
    outstandingAmt: 85000,
    overdueAmt: 15000,
    diffYesterdayToday: 2000,
    aging: {
      '0 to 7': 70000,
      '7 to 15': 15000,
      '15 to 30': 0,
      '30 to 45': 0,
      '45 to 90': 0,
      '90 to 120': 0,
      '120 to 150': 0,
      '150 to 180': 0,
      '>180': 0
    }
  }
];

export const MOCK_PRODUCTS: Product[] = [
  { 
    id: 'SM-BLK', 
    skuCode: 'SM-BLK', 
    name: 'Smoked Salmon – Black', 
    category: 'Smoked Seafood', 
    unit: 'KG', 
    price: 2100, 
    baseRate: 2000, 
    stock: 150, 
    warehouseStock: { 'IOPL Kurla': 100, 'IOPL DP WORLD': 50 }, 
    type: 'Finished', 
    openingStock: 100, 
    avgDailySales: 2,
    availableBatches: [
      { batch: 'BT-001', mfgDate: getRelDate(-180), expDate: getRelDate(45), quantity: 80 },
      { batch: 'BT-002', mfgDate: getRelDate(-30), expDate: getRelDate(200), quantity: 70 }
    ]
  },
  { 
    id: 'SAL-C-BLK', 
    skuCode: 'SAL-C-BLK', 
    name: 'Salmon Fillet Trim C – Black', 
    category: 'Salmon Fillets', 
    unit: 'KG', 
    price: 1850, 
    baseRate: 1750, 
    stock: 400, 
    warehouseStock: { 'IOPL Kurla': 200, 'IOPL Arihant Delhi': 200 }, 
    type: 'Finished', 
    openingStock: 300, 
    avgDailySales: 20,
    availableBatches: [
      { batch: 'BT-992', mfgDate: getRelDate(-10), expDate: getRelDate(180), quantity: 400 }
    ]
  },
  { 
    id: 'TUN-LOIN', 
    skuCode: 'TUN-LOIN', 
    name: 'Tuna Loin', 
    category: 'Fresh Fish', 
    unit: 'KG', 
    price: 1200, 
    baseRate: 1100, 
    stock: 2500, 
    warehouseStock: { 'IOPL Kurla': 1500, 'IOPL DP WORLD': 1000 }, 
    type: 'Raw', 
    openingStock: 500, 
    avgDailySales: 15,
    availableBatches: [
      { batch: 'RAW-01', mfgDate: getRelDate(-5), expDate: getRelDate(15), quantity: 2500 }
    ]
  },
  { 
    id: 'MACKEREL', 
    skuCode: 'MACKEREL', 
    name: 'Mackerel', 
    category: 'Fresh Fish', 
    unit: 'KG', 
    price: 350, 
    baseRate: 300, 
    stock: 1000, 
    warehouseStock: { 'IOPL Kurla': 500, 'IOPL Jolly Bng': 500 }, 
    type: 'Finished', 
    openingStock: 800, 
    avgDailySales: 0.5,
    availableBatches: [
      { batch: 'MK-009', mfgDate: getRelDate(-200), expDate: getRelDate(-5), quantity: 1000 }
    ]
  },
];

export const MOCK_LABOR_SESSIONS: LaborSession[] = [
  {
    id: 'LS-001',
    date: getRelDate(0),
    headcount: 5,
    ratePerLabour: 1000,
    shiftStart: '08:00',
    dispatchTime: '12:00',
    shiftEnd: '18:00',
    totalCost: 5000,
    loadingCost: 2000,
    repackagingCost: 3000
  }
];

export const INITIAL_ORDERS: Order[] = [
  {
    id: 'ORD-88291',
    customerId: '190068',
    customerName: 'Harbour Exports',
    status: OrderStatus.PENDING_CREDIT_APPROVAL,
    createdAt: getRelDate(-1),
    salespersonId: 'lavin@bigsams.in',
    items: [
      { productId: 'SAL-C-BLK', productName: 'Salmon Fillet Trim C – Black', quantity: 20, unit: 'KG', price: 1850, baseRate: 1750 }
    ],
    statusHistory: [{ status: OrderStatus.PENDING_CREDIT_APPROVAL, timestamp: getRelDate(-1), userName: 'Lavin' }]
  },
  {
    id: 'INV-44210',
    customerId: '190187',
    customerName: 'VR Fine Foods',
    status: OrderStatus.DELIVERED,
    invoiceNo: 'EXT-9921',
    createdAt: getRelDate(-15),
    salespersonId: 'rakesh.khare@bigsams.in',
    items: [
      { productId: 'SM-BLK', productName: 'Smoked Salmon – Black', quantity: 50, unit: 'KG', price: 2100, baseRate: 2000 }
    ],
    statusHistory: [
      { status: OrderStatus.PENDING_CREDIT_APPROVAL, timestamp: getRelDate(-16), userName: 'Rakesh Khare' },
      { status: OrderStatus.PENDING_WH_SELECTION, timestamp: getRelDate(-15.5), userName: 'Pawan (Finance)' },
      { status: OrderStatus.PENDING_PACKING, timestamp: getRelDate(-15.4), userName: 'Animesh Jamuar' },
      { status: OrderStatus.READY_FOR_BILLING, timestamp: getRelDate(-15.2), userName: 'Manoj Production' },
      { status: OrderStatus.DELIVERED, timestamp: getRelDate(-15), userName: 'Delivery Agent' }
    ]
  }
];

export const MOCK_PACKAGING: PackagingMaterial[] = [
  { id: 'PKG-001', name: 'Small Seafood Poly Pkts', unit: 'PCS', moq: 1000, balance: 1200, category: 'Poly Pkts', lastMovementDate: getRelDate(-2) }
];

export const INITIAL_PROCUREMENT: ProcurementItem[] = [
  {
    id: 'PRC-1022',
    supplierName: 'Arctic Fresh Norway',
    skuName: 'Salmon Fillet Trim C – Black',
    skuCode: 'SAL-C-BLK',
    sipChecked: true,
    labelsChecked: true,
    docsChecked: true,
    status: 'Approved',
    approvedBy: 'Naveen',
    createdAt: getRelDate(-10),
    type: 'Import',
    portOfLoading: 'Oslo',
    portOfDischarge: 'Mumbai NHAVA SHEVA',
    modeOfTransport: 'Sea',
    countryOfOrigin: 'Norway',
    supplierAddress: 'Lofoten Islands, Norway',
    productDescription: 'Atlantic Salmon Whole Cleaned',
    hsCode: '03031300',
    quantity: 5000,
    uom: 'KG',
    productSpecs: 'G&H, Fresh Frozen',
    validityDate: getRelDate(60)
  },
  {
    id: 'PRC-5011',
    supplierName: 'Ocean Catch Chennai',
    skuName: 'Tuna Loin',
    skuCode: 'TUN-LOIN',
    sipChecked: true,
    labelsChecked: true,
    docsChecked: true,
    status: 'Approved',
    approvedBy: 'Naveen',
    createdAt: getRelDate(-2),
    type: 'Domestic'
  }
];

export const MOCK_ALERTS: SupplyChainAlert[] = [
  {
    id: 'ALT-001',
    type: 'Stockout Risk',
    severity: 'Critical',
    skuId: 'SAL-C-BLK',
    skuName: 'Salmon Fillet Trim C – Black',
    message: 'SKU SAL-C-BLK will stockout in 14 days if current trend continues.',
    recommendedAction: 'Increase production order by 200kg or transfer from DP World.',
    timestamp: getRelDate(0),
    isResolved: false
  },
  {
    id: 'ALT-002',
    type: 'Demand Spike',
    severity: 'Medium',
    skuId: 'SM-BLK',
    skuName: 'Smoked Salmon – Black',
    message: 'Unusual order spike detected in Horeca channel (3x normal volume).',
    recommendedAction: 'Verify with Sales Manager and adjust mid-cycle forecast.',
    timestamp: getRelDate(-1),
    isResolved: false
  },
  {
    id: 'ALT-003',
    type: 'Supplier Delay',
    severity: 'High',
    skuId: 'TUN-LOIN',
    skuName: 'Tuna Loin',
    message: 'Supplier Arctic Fresh Norway reporting 5-day delay in shipment PRC-1022.',
    recommendedAction: 'Adjust production schedule for finished goods.',
    timestamp: getRelDate(-2),
    isResolved: false
  }
];

export const MOCK_PO_STATUS: POStatus[] = [
  {
    id: 'PO-9901',
    supplierId: 'SUP-01',
    supplierName: 'Arctic Fresh Norway',
    skuId: 'SAL-C-BLK',
    skuName: 'Salmon Fillet Trim C – Black',
    orderQty: 5000,
    expectedDate: getRelDate(5),
    status: 'Delayed',
    riskScore: 85,
    agingDays: 12
  },
  {
    id: 'PO-9902',
    supplierId: 'SUP-02',
    supplierName: 'Ocean Catch Chennai',
    skuId: 'TUN-LOIN',
    skuName: 'Tuna Loin',
    orderQty: 2000,
    expectedDate: getRelDate(2),
    status: 'On Time',
    riskScore: 10,
    agingDays: 3
  }
];

export const MOCK_FORECASTS: DemandForecast[] = [
  {
    skuId: 'SAL-C-BLK',
    skuName: 'Salmon Fillet Trim C – Black',
    historicalAvg: 1200,
    aiPredicted: 1450,
    adjustedForecast: 1450,
    accuracyPercent: 92,
    lastMonthActual: 1380
  },
  {
    skuId: 'SM-BLK',
    skuName: 'Smoked Salmon – Black',
    historicalAvg: 800,
    aiPredicted: 950,
    adjustedForecast: 1100,
    accuracyPercent: 88,
    lastMonthActual: 920
  }
];

export const MOCK_OVERRIDES: ForecastOverride[] = [
  {
    id: 'OVR-001',
    skuId: 'SM-BLK',
    originalForecast: 950,
    newForecast: 1100,
    userId: 'lavin@bigsams.in',
    userName: 'Lavin',
    reason: 'Upcoming Marriott Promotion mid-month',
    impactOnServiceLevel: 5.2,
    impactOnInventory: -2.1,
    impactOnLogisticsCost: 0.5,
    timestamp: getRelDate(-3)
  }
];

export const MOCK_WORKING_CAPITAL: WorkingCapitalMetrics = {
  inventoryValue: 4500000,
  agingValue: 1200000,
  slowMovingValue: 800000,
  deadStockPercent: 4.5,
  cashBlockedInExcess: 550000,
  forecastVarianceImpact: 250000
};
