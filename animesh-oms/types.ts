
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
  PROCUREMENT_HEAD = 'Procurement Head',
  QC = 'Quality Control',
  QUALITY_PROD_HEAD = 'Quality And Production head'
}

export enum OrderStatus {
  PENDING_CREDIT_APPROVAL = 'Pending Credit Approval',
  ON_HOLD = 'On Hold',
  PENDING_WH_SELECTION = 'Pending WH Selection',
  PENDING_PACKING = 'Pending Packing',
  PENDING_QC = 'Pending Quality Control',
  PART_PACKED = 'Part Packed',
  PENDING_LOGISTICS = 'Pending Logistics',
  REJECTED = 'Rejected',
  READY_FOR_BILLING = 'Ready for Billing',
  READY_FOR_DISPATCH = 'Ready for Dispatch',
  DISPATCHED = 'Dispatched',
  PICKED_UP = 'Picked Up',
  OUT_FOR_DELIVERY = 'Out For Delivery',
  DELIVERED = 'Delivered',
  PART_ACCEPTED = 'Part Accepted',
  RETURNED_TO_WH = 'Returned to Warehouse',
  BACKORDER = 'Backorder',
  CANCELLED = 'Cancelled'
}

export interface StopCoordinates {
  lat: number;
  lng: number;
}

export interface RouteStop {
  id: string;
  referenceId: string; // Order ID, STN ID, or RTV ID
  type: 'DELIVERY' | 'STOCK_TRANSFER' | 'RETURN_PICKUP';
  name: string;
  address: string;
  coords: StopCoordinates;
  status: 'PENDING' | 'ARRIVED' | 'COMPLETED' | 'FAILED';
  sequence: number;
  eta?: string;
  distanceFromPrev?: number;
  weightKg: number;
  volumeCft: number;
  timeWindow?: { start: string; end: string };
  isCritical?: boolean;
}

export interface DeliveryRoute {
  id: string;
  vehicleId: string;
  driverId: string;
  depotId: string; // Starting Warehouse
  stops: RouteStop[];
  totalDistance: number;
  estimatedTimeMin: number;
  status: 'PLANNED' | 'ACTIVE' | 'COMPLETED';
  startTime?: string;
  endTime?: string;
}

export interface Vehicle {
  id: string;
  regNo: string;
  type: 'E-Van' | '7ft Truck' | 'Biker';
  capacityKg: number;
  capacityCft: number;
  currentLat?: number;
  currentLng?: number;
  status: 'IDLE' | 'ON_ROUTE' | 'MAINTENANCE';
}

export interface ConsumablePurchase {
  id: string;
  requesterId: string;
  requesterName: string;
  itemName: string;
  purpose: string;
  qty: number;
  ratePerPcs: number;
  durationDays: string;
  totalValue: number;
  vendor: string;
  piAttachment?: string;
  piFileName?: string;
  status: 'Pending Approval' | 'Approved' | 'Rejected';
  approvedBy?: string;
  remarks?: string;
  createdAt: string;
}

export interface User {
  id: string; 
  name: string;
  role: string;
  status: 'Active' | 'Inactive';
  isApprover: boolean;
  whatsappNumber?: string;
  monthlyTarget?: number;
  monthlyQtyTarget?: number;
  grossMonthlySalary?: number;
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
  type: 'Domestic' | 'Import';
  portOfLoading?: string;
  portOfDischarge?: string;
  modeOfTransport?: 'Air' | 'Sea' | 'Road';
  countryOfOrigin?: string;
  supplierAddress?: string;
  productDescription?: string;
  hsCode?: string;
  quantity?: number;
  uom?: string;
  productSpecs?: string;
  validityDate?: string;
}

export interface Customer {
  id: string;
  name: string;
  type: string; 
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
  distributionChannel_ID?: string;
  division?: string;
  gstCertificateFile?: string;
  panCardFile?: string;
  securityChequeFile?: string;
  coords?: StopCoordinates;
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

export interface Product {
  id: string;
  skuCode: string; 
  name: string;
  category: string;
  unit: 'PCS' | 'KG' | 'PKT'; 
  price: number;      
  baseRate: number;   
  stock: number;
  warehouseStock?: Record<string, number>; 
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
  imageUrl?: string;
  type?: 'Raw' | 'Finished';
  openingStock?: number;
  avgDailySales?: number; 
}

export interface BatchInfo {
  batch: string;
  mfgDate: string;
  expDate: string;
  quantity: number;
}

export interface OrderItem {
  productId: string;
  productName: string;
  skuCode?: string;
  quantity: number;
  unit: 'PCS' | 'KG' | 'PKT';
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

export interface LogisticsDetails {
  thermacolBoxCount?: number;
  thermacolBoxRate?: number;
  thermacolBoxAmount?: number;
  dryIceKg?: number;
  dryIceRate?: number;
  dryIceAmount?: number;
  whToStationAmount?: number;
  stationToLocAmount?: number;
  whToCustAmount?: number;
  mode?: string;
  transporterId?: string;
  vehicleNo?: string;
  deliveryAgentId?: string;
  vehicleProvider?: 'Internal' | 'Porter' | 'Other';
  distanceKm?: number;
}

export type KRAType = 'Unrestricted' | 'Restricted' | 'As per slab';

export interface QCDetails {
  tempVerified?: boolean;
  actualTemp?: number;
  packagingIntact?: boolean;
  weightVerified?: boolean;
  labelClarity?: boolean;
  invoiceDcAttached?: boolean;
  qcPassed?: boolean;
  qcAgentId?: string;
  qcTimestamp?: string;
  qcRemarks?: string;
  qcImage?: string;
}

export interface Order {
  id: string;
  customerId: string;
  customerName: string;
  items: OrderItem[];
  status: OrderStatus;
  statusHistory: { status: OrderStatus; timestamp: string; userName?: string }[];
  createdAt: string;
  salespersonId: string;
  warehouseSource?: string;
  logistics?: LogisticsDetails;
  qc?: QCDetails;
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
  weightKg?: number;
}

export interface PackagingMaterial {
  id: string;
  name: string;
  category: string;
  unit: string;
  moq: number;
  balance: number;
  lastMovementDate?: string;
}

export interface PackagingTransaction {
  id: string;
  materialId: string;
  type: 'IN' | 'OUT';
  qty: number;
  date: string;
  batch?: string;
  mfgDate?: string;
  expDate?: string;
  vendorName?: string;
  referenceNo?: string;
  attachment?: string;
}

export interface InventoryTransaction {
  id: string;
  timestamp: string;
  productId: string;
  type: string;
  qty: number;
  referenceId: string;
}

export interface ProductionLog {
  id: string;
  timestamp: string;
  rawSkuId: string;
  rawQtyUsed: number;
  finishedSkuId: string;
  finishedQtyProduced: number;
  yieldPercent: number;
  batchNo: string;
  operatorId: string;
  laborSessionId: string;
  unitLaborCost: number;
  packagingConsumed: { materialId: string; qty: number }[];
}

export interface LaborSession {
  id: string;
  date: string;
  headcount: number;
  ratePerLabour: number;
  shiftStart: string;
  dispatchTime: string;
  shiftEnd: string;
  totalCost: number;
  loadingCost: number;
  repackagingCost: number;
}

export interface ChecklistTask {
  id: string;
  label: string;
  completed: boolean;
  doneCount: number;
  pendingCount: number;
  timestamp?: string;
}

export interface DailyProtocol {
  userId: string;
  date: string;
  tasks: ChecklistTask[];
  isClosed: boolean;
  closedAt?: string;
}

export interface RTVReturn {
  id: string;
  customerId: string;
  customerName: string;
  dnNumber: string;
  dnAttachment?: string;
  receiptDate: string;
  receiptPhotos: string[];
  items: RTVItem[];
  status: 'Logged' | 'QC_Pending' | 'Completed' | 'Rejected';
  inspectedBy?: string;
  inspectionDate?: string;
  totalValuation: number;
  createdAt: string;
  weightKg?: number;
}

export interface RTVItem {
  productId: string;
  productName: string;
  skuCode: string;
  batchNo: string;
  dnQuantity: number;
  receivedQuantity: number;
  condition: 'Usable' | 'Damaged' | 'Expired';
  isExpired: boolean;
  unitPrice: number;
  lineValuation: number;
  itemPhoto?: string;
  remarks?: string;
}

export interface InvoiceDetail {
  invoiceNo: string;
  invoiceDate: string;
  dueDate: string;
  billAmount: number;
  receivedAmount: number;
  balanceAmount: number;
  daysOverdue: number;
}

export interface ReminderLog {
  timestamp: string;
  mode: 'WhatsApp' | 'Email' | 'SMS';
  sender: string;
  status: 'Sent' | 'Delivered' | 'Failed';
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
  invoices?: InvoiceDetail[];
  reminderHistory?: ReminderLog[];
}

export interface YearlyPerformance {
  userName: string;
  category: string;
  appraiser: string;
  scores: { month: string; score: number }[];
}

export interface PerformanceRecord {
  userId: string;
  userName: string;
  month: string;
  grossMonthlySalary: number;
  odBalances?: {
    chennai: number;
    self: number;
    hyd: number;
  };
  yearlyPerformance?: YearlyPerformance;
  kras: KRA[];
}

export interface KRA {
  id: number;
  name: string;
  criteria: string;
  target: number;
  achieved: number;
  weightage: number;
  type: KRAType;
  finalScore?: number;
}

export interface IncentiveSlab {
  lowerBand: number;
  higherBand: number;
  incentivePercent: number;
}

export interface BOM {
  finishedSkuId: string;
  items: { materialId: string; quantity: number }[];
}

export interface ProductionPlanItem {
  productId: string;
  quantity: number;
}

export interface MaterialRequirement {
  materialId: string;
  materialName: string;
  category: string;
  grossRequired: number;
  onHand: number;
  shortfall: number;
  unit: string;
}

export interface ForecastOverride {
  id: string;
  skuId: string;
  originalForecast: number;
  newForecast: number;
  userId: string;
  userName: string;
  reason: string;
  impactOnServiceLevel: number;
  impactOnInventory: number;
  impactOnLogisticsCost: number;
  timestamp: string;
}

export interface SupplyChainAlert {
  id: string;
  type: 'Demand Spike' | 'Stockout Risk' | 'Supplier Delay' | 'Lead Time Increase' | 'Low Fill Rate';
  severity: 'Low' | 'Medium' | 'High' | 'Critical';
  skuId: string;
  skuName: string;
  message: string;
  recommendedAction: string;
  timestamp: string;
  isResolved: boolean;
}

export interface POStatus {
  id: string;
  supplierId: string;
  supplierName: string;
  skuId: string;
  skuName: string;
  orderQty: number;
  expectedDate: string;
  actualDate?: string;
  status: 'On Time' | 'Delayed' | 'At Risk';
  riskScore: number;
  agingDays: number;
}

export interface WorkingCapitalMetrics {
  inventoryValue: number;
  agingValue: number;
  slowMovingValue: number;
  deadStockPercent: number;
  cashBlockedInExcess: number;
  forecastVarianceImpact: number;
}

export interface DemandForecast {
  skuId: string;
  skuName: string;
  historicalAvg: number;
  aiPredicted: number;
  adjustedForecast: number;
  accuracyPercent: number;
  lastMonthActual: number;
}

export interface InventoryHealth {
  skuId: string;
  skuName: string;
  category: string;
  totalStock: number;
  healthyStock: number;
  agingStock: number;
  slowMoving: number;
  excess: number;
  expiryRisk: number;
  deadStock: number;
  probabilityOfConsumption: number; // 0-100
  locationHeatmap: Record<string, number>;
}
