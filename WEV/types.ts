
export enum UserRole {
  ADMIN = 'Admin',
  SALES = 'Sales',
  FINANCE = 'Credit Control',
  APPROVER = 'Approving Authority',
  LOGISTICS = 'Logistics Team',
  BILLING = 'Billing Team',
  WAREHOUSE = 'Warehouse/Packing',
  DELIVERY = 'Delivery Team',
  PROCUREMENT = 'Procurement Team',
  PROCUREMENT_HEAD = 'Procurement Head'
}

export enum OrderStatus {
  PENDING_CREDIT_APPROVAL = 'Pending Credit Approval',
  ON_HOLD = 'On Hold',
  PENDING_WH_SELECTION = 'Pending WH Selection',
  PENDING_PACKING = 'Pending Packing',
  PART_PACKED = 'Part Packed',
  PENDING_LOGISTICS = 'Pending Logistics',
  REJECTED = 'Rejected',
  READY_FOR_BILLING = 'Ready for Billing',
  READY_FOR_DISPATCH = 'Ready for Dispatch',
  PICKED_UP = 'Picked Up',
  OUT_FOR_DELIVERY = 'Out For Delivery',
  DELIVERED = 'Delivered',
  PART_ACCEPTED = 'Part Accepted',
  RETURNED_TO_WH = 'Returned to Warehouse',
  BACKORDER = 'Backorder'
}

export interface AgingBuckets {
  '0 to 7': number;
  '7 to 15': number;
  '15 to 30': number;
  '30 to 45': number;
  '45 to 90': number;
  '90 to 120': number;
  '120 to 150': number;
  '150 to 180': number;
  '>180': number;
}

export interface User {
  id: string; 
  name: string;
  role: string;
  status: 'Active' | 'Inactive';
  isApprover: boolean;
  monthlyTarget?: number;      // Value Target
  monthlyQtyTarget?: number;   // Quantity Target
  grossMonthlySalary?: number;
}

export interface Customer {
  id: string;
  name: string;
  type: string; // From "Customer Type" in screenshot
  outstanding: number;
  overdue: number;
  ageingDays: number;
  creditLimit: number;
  securityChqStatus: 'Yes' | 'No' | 'N/A';
  creditDays: string;
  agingBuckets: AgingBuckets;
  assignedSalespersonId?: string;
  salesManager?: string;
  employeeResponsible?: string;
  status?: string;
  distributionChannel?: string;
  customerClass?: string;
  location?: string;
  email?: string;
  postalCode?: string;
  address?: string;
  constitution?: 'Partnership' | 'Company' | 'Proprietorship';
  partnerDirectorNames?: string;
  telephoneMobile?: string;
  gstNo?: string;
  fssaiLicenseNo?: string;
  panCard?: string;
  regionState?: string;
  saleOffice?: string;
  saleOrganization?: string;
  division?: string;
  gstCertificateFile?: string;
  panCardFile?: string;
  securityChequeFile?: string;
}

export interface ODMaster {
  customerId: string;
  channel: string;
  salesManager: string;
  customerClass: string;
  employeeResponsible: string;
  customerName: string;
  creditDays: string;
  creditLimit: number;
  securityChq: string;
  distChannel: string;
  outstandingAmt: number;
  overdueAmt: number;
  diffYesterdayToday: number;
  aging: AgingBuckets;
}

export interface BatchInfo {
  batch: string;
  mfgDate: string;
  expDate: string;
  quantity: number;
  weight?: string;
  stockAvailable?: number;
}

export interface Product {
  id: string;
  skuCode: string; 
  name: string;
  category: string;
  unit: 'PCS' | 'KG'; 
  price: number;      
  baseRate: number;   
  stock: number;
  barcode?: string;
  availableBatches?: BatchInfo[];
  productShortName?: string;
  distributionChannel?: string;
  specie?: string;
  productWeight?: string;
  productPacking?: string;
  mrp?: number;
  gst?: number;
  hsnCode?: string;
  countryOfOrigin?: string;
}

export interface OrderItem {
  productId: string;
  productName: string;
  skuCode?: string;
  quantity: number;
  unit: 'PCS' | 'KG';
  packedQuantity?: number;
  deliveredQuantity?: number;
  price: number;      
  baseRate: number;  
  previousRate?: number; 
  remarks?: string;   
  barcode?: string;
  weight?: string;
  batch?: string;
  mfgDate?: string;
  expDate?: string;
  batches?: BatchInfo[]; 
}

export interface StatusHistoryEntry {
  status: OrderStatus;
  timestamp: string;
}

export interface LogisticsDetails {
  thermacolBoxCount: number;
  thermacolBoxRate?: number;
  thermacolBoxAmount: number;
  dryIceKg: number;
  dryIceRate?: number;
  dryIceAmount: number;
  whToStationAmount: number;
  stationToLocAmount: number;
  whToCustAmount: number;
  mode: string;
  transporterId: string;
  vehicleNo: string;
  vehicleProvider?: 'Internal' | 'Porter' | 'Other'; 
  deliveryAgentId?: string;
  distanceKm?: number;
}

export interface Order {
  id: string;
  customerId: string;
  customerName: string;
  items: OrderItem[];
  status: OrderStatus;
  statusHistory: StatusHistoryEntry[];
  createdAt: string;
  salespersonId: string;
  warehouseSource?: 'Kurla warehouse' | 'DP world' | 'Kool Solution' | 'Arihant - Delhi' | 'Jolly Bangalore' | 'IOPL Kurla' | 'IOPL DP WORLD' | 'IOPL Arihant Delhi' | 'IOPL Jolly Bng';
  logistics?: LogisticsDetails;
  invoiceNo?: string;
  invoiceUrl?: string; 
  invoiceName?: string;
  invoiceFile?: string; 
  packedBoxes?: number;
  deliveryProof?: string; 
  rejectionReason?: string;
  agentConfirmedAt?: string;
  generalRemarks?: string;
  cloudStoragePath?: string;
  vaultTimestamp?: string;
  poAttachment?: string; 
  poFileName?: string;
  isSTN?: boolean;
  fromWarehouse?: string;
  toWarehouse?: string;
}

export interface ProcurementItem {
  id: string;
  supplierName: string;
  skuName: string;
  skuCode: string;
  sipChecked: boolean;
  labelsChecked: boolean;
  docsChecked: boolean;
  attachment?: string;
  attachmentName?: string;
  status: 'Pending' | 'Awaiting Head Approval' | 'Approved';
  clearedBy?: string;
  approvedBy?: string;
  createdAt: string;
}

// --- PMS Types ---
export type KRAType = 'Unrestricted' | 'Restricted' | 'As per slab';

export interface KRA {
  id: number;
  name: string;
  criteria: string;
  target: number;
  achieved: number;
  weightage: number;
  type: KRAType;
}

export interface ODRegionBalance {
  chennai: number;
  self: number;
  hyd: number;
}

export interface IncentiveSlab {
  lowerBand: number;
  higherBand: number;
  incentivePercent: number;
}

export interface PerformanceRecord {
  userId: string;
  userName: string;
  month: string; // e.g., 'Feb'26'
  grossMonthlySalary: number;
  kras: KRA[];
  odBalances?: ODRegionBalance;
}

export interface NotificationTask {
  id: string;
  title: string;
  description: string;
  type: 'action' | 'info' | 'warning';
  orderId?: string;
  timestamp: string;
}
