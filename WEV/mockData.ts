
import { Customer, Product, Order, OrderStatus, User, UserRole, ProcurementItem } from './types';

export const MOCK_USERS: User[] = [
  { 
    id: 'animesh.jamuar@bigsams.in', 
    name: 'Animesh Jamuar', 
    role: UserRole.ADMIN, 
    status: 'Active', 
    isApprover: true 
  },
  { 
    id: 'sandeep.chavan@bigsams.in', 
    name: 'Sandeep Chavan', 
    role: UserRole.SALES, 
    status: 'Active', 
    isApprover: false,
    monthlyTarget: 1200000,
    monthlyQtyTarget: 5000
  },
  { 
    id: 'rakesh.khare@bigsams.in', 
    name: 'Rakesh Khare', 
    role: UserRole.SALES, 
    status: 'Active', 
    isApprover: false,
    monthlyTarget: 800000,
    monthlyQtyTarget: 3000
  },
  { 
    id: 'mithun.muddappa@bigsams.in', 
    name: 'Mithun Muddappa', 
    role: UserRole.SALES, 
    status: 'Active', 
    isApprover: false,
    monthlyTarget: 1500000,
    monthlyQtyTarget: 6000
  },
  { 
    id: 'sandeep.dubey@bigsams.in', 
    name: 'Sandeep Dubey', 
    role: UserRole.SALES, 
    status: 'Active', 
    isApprover: false,
    monthlyTarget: 600000,
    monthlyQtyTarget: 2000
  },
  { id: 'kunal.shah@bigsams.in', name: 'Kunal Shah', role: UserRole.ADMIN, status: 'Active', isApprover: true },
  { id: 'credit.control@bigsams.in', name: 'Pawan', role: UserRole.FINANCE, status: 'Active', isApprover: true },
  { id: 'nitin.kadam@bigsams.in', name: 'Nitin Kadam', role: UserRole.BILLING, status: 'Active', isApprover: false },
  { id: 'logistics@bigsams.in', name: 'Logistics Manager', role: UserRole.LOGISTICS, status: 'Active', isApprover: false },
  { id: 'production@bigsams.in', name: 'Warehouse Lead', role: UserRole.WAREHOUSE, status: 'Active', isApprover: false },
  { id: 'procurement@bigsams.in', name: 'Procurement Executive', role: UserRole.PROCUREMENT, status: 'Active', isApprover: false },
  { id: 'procurement.head@bigsams.in', name: 'Procurement Head', role: UserRole.PROCUREMENT_HEAD, status: 'Active', isApprover: true },
  { id: 'driver.rahul@bigsams.in', name: 'Rahul Sharma', role: UserRole.DELIVERY, status: 'Active', isApprover: false },
  { id: 'driver.vicky@bigsams.in', name: 'Vicky More', role: UserRole.DELIVERY, status: 'Active', isApprover: false },
  { id: 'driver.akash@bigsams.in', name: 'Akash Gupta', role: UserRole.DELIVERY, status: 'Active', isApprover: false },
];

export const MOCK_CUSTOMERS: Customer[] = [
  { 
    id: '190068', name: 'Harbour Exports', type: 'Distributor', outstanding: 45000, overdue: 12000, ageingDays: 45, creditLimit: 100000,
    securityChqStatus: 'N/A', creditDays: '30 days', assignedSalespersonId: 'sandeep.chavan@bigsams.in',
    salesManager: 'Sandeep Chavan', employeeResponsible: 'Sandeep Chavan', status: 'Active',
    distributionChannel: 'Wholesale', customerClass: 'C', location: 'Maharashtra', email: 'sandeep.chavan@bigsams.in',
    address: 'Harbour Exports, Mumbai, MAHARASHTRA',
    agingBuckets: { '0 to 7': 5000, '7 to 15': 3000, '15 to 30': 4000, '30 to 45': 12000, '45 to 90': 0, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 }
  },
  { 
    id: '190081', name: 'Cash Sales-Institution', type: 'Retail', outstanding: 0, overdue: 0, ageingDays: 0, creditLimit: 2,
    securityChqStatus: 'N/A', creditDays: '0 days', assignedSalespersonId: 'sandeep.dubey@bigsams.in',
    salesManager: 'Sandeep Chavan', employeeResponsible: 'Sandeep Dubey', status: 'Active',
    distributionChannel: 'Horeca', customerClass: 'D', location: 'Maharashtra', email: 'sandeep.dubey@bigsams.in',
    address: 'Cash Sales-Institution, MAHARASHTRA',
    agingBuckets: { '0 to 7': 0, '7 to 15': 0, '15 to 30': 0, '30 to 45': 0, '45 to 90': 0, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 }
  },
  { 
    id: '190190', name: 'AQUAMARINE SPECIALITY SEAFOOD', type: 'Distributor', outstanding: 890000, overdue: 0, ageingDays: 22, creditLimit: 1500000,
    securityChqStatus: 'N/A', creditDays: '30 days', assignedSalespersonId: 'mithun.muddappa@bigsams.in',
    salesManager: 'Mithun Muddappa', employeeResponsible: 'Mithun Muddappa', status: 'Active',
    distributionChannel: 'Wholesale', customerClass: 'A', location: 'Karnataka', email: 'mithun.muddappa@bigsams.in',
    postalCode: '560002', address: '14/2 JC ROAD, Shanti Bangara, BANGALORE',
    agingBuckets: { '0 to 7': 200000, '7 to 15': 300000, '15 to 30': 390000, '30 to 45': 0, '45 to 90': 0, '90 to 120': 0, '120 to 150': 0, '150 to 180': 0, '>180': 0 }
  }
];

export const MOCK_PRODUCTS: Product[] = [
  { 
    id: '2004643', skuCode: '2004643', name: 'BREADED FISH FINGERS 200G', productShortName: 'BREADED FISH FINGERS 200G',
    distributionChannel: 'RETAIL/HD', specie: 'BREADED', productWeight: '0.2', productPacking: 'PKTS',
    mrp: 220, price: 220, baseRate: 180, gst: 5, hsnCode: '16042000', countryOfOrigin: 'INDIA',
    category: 'Frozen Foods', unit: 'PCS', stock: 1500, barcode: '890002004643' 
  },
  { 
    id: '2006332', skuCode: '2006332', name: 'ORANGE TOBIKO JAPAN 30 GM', productShortName: 'ORANGE TOBIKO JAPAN 30 GM',
    distributionChannel: 'RETAIL/HD', specie: 'FISH EGG', productWeight: '0.03', productPacking: 'PKTS',
    mrp: 550, price: 550, baseRate: 480, gst: 5, hsnCode: '16043200', countryOfOrigin: 'JAPAN',
    category: 'Seafood Specialties', unit: 'PCS', stock: 300, barcode: '890002006332' 
  }
];

export const INITIAL_ORDERS: Order[] = [
  {
    id: 'ORD-55001', customerId: '190190', customerName: 'AQUAMARINE SPECIALITY SEAFOOD',
    items: [{ 
      productId: '2004643', 
      productName: 'BREADED FISH FINGERS 200G', 
      skuCode: '2004643', 
      quantity: 10, 
      price: 220, 
      barcode: '890002004643',
      unit: 'PCS',
      baseRate: 180
    }],
    status: OrderStatus.PENDING_CREDIT_APPROVAL, salespersonId: 'mithun.muddappa@bigsams.in',
    statusHistory: [{ status: OrderStatus.PENDING_CREDIT_APPROVAL, timestamp: new Date(Date.now() - 3600000).toISOString() }],
    createdAt: new Date(Date.now() - 3600000).toISOString()
  }
];

export const INITIAL_PROCUREMENT: ProcurementItem[] = [
  {
    id: 'PRC-1001',
    supplierName: 'Global Fisheries Ltd',
    skuName: 'Frozen Salmon Fillets 500G',
    skuCode: 'SKU-SM-01',
    sipChecked: true,
    labelsChecked: false,
    docsChecked: true,
    status: 'Pending',
    createdAt: new Date().toISOString()
  },
  {
    id: 'PRC-1002',
    supplierName: 'Ocean Fresh Imports',
    skuName: 'Tuna Steak Premium 200G',
    skuCode: 'SKU-TN-42',
    sipChecked: false,
    labelsChecked: false,
    docsChecked: false,
    status: 'Pending',
    createdAt: new Date().toISOString()
  }
];
