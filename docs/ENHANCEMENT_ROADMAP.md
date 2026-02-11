# NexusOMS Enhancement Roadmap
**Status**: In Progress | **Theme**: White/Light (Dashboard Matching)

## 🎯 Objective
Complete all pending features (excluding Tally/SAP) with premium UI matching Dashboard aesthetics.

---

## 📋 Feature Implementation Checklist

### ✅ Phase 1: Logistics Hub - Bulk Operations
**Status**: 80% Complete | **Priority**: HIGH

#### Pending Items:
- [ ] **Bulk Select All** - Fix "Select All" checkbox functionality
- [ ] **Bulk Assignment Panel** - Enhanced UI with driver cards
- [ ] **Trip Summary Preview** - Show total boxes, weight before dispatch
- [ ] **Backend API** - `/api/logistics/bulk-assign` endpoint
- [ ] **Success Animation** - Confirmation with trip details

#### Files to Modify:
- `flutter/lib/screens/logistics_hub_screen.dart`
- `backend/server.js` (Add bulk assignment route)

---

### 🔄 Phase 2: Credit Control - Financial Intelligence
**Status**: 40% Complete | **Priority**: HIGH

#### Features to Add:
- [ ] **Payment History Timeline** - Visual timeline of past payments
- [ ] **Credit Aging Analysis** - 30/60/90 days overdue breakdown
- [ ] **Outstanding Balance Card** - Total pending amount with alerts
- [ ] **Approval with Notes** - Add reason/comments on approval/rejection
- [ ] **Customer Credit Profile** - Detailed financial summary

#### New Components:
```dart
Widget _buildPaymentTimeline(List<Payment> payments)
Widget _buildAgingChart(Customer customer)
Widget _buildCreditScoreCard(double score)
```

#### Backend Requirements:
- Payment history API: `GET /api/customers/:id/payments`
- Credit aging API: `GET /api/customers/:id/aging`

#### Files to Modify:
- `flutter/lib/screens/credit_control_screen.dart`
- `flutter/lib/models/models.dart` (Add Payment model)
- `backend/server.js` (Add payment routes)

---

### 📊 Phase 3: Analytics & PMS - Visual Intelligence
**Status**: 30% Complete | **Priority**: MEDIUM

#### Charts to Implement:
- [ ] **Sales Trend Line Chart** - Last 30 days revenue
- [ ] **Order Status Pie Chart** - Distribution visualization
- [ ] **Performance Bar Chart** - User-wise comparison
- [ ] **Regional Heat Map** - City-wise sales (optional)

#### Library:
```yaml
dependencies:
  fl_chart: ^0.68.0
```

#### Components:
```dart
Widget _buildSalesTrendChart(List<Order> orders)
Widget _buildStatusPieChart(Map<String, int> statusData)
Widget _buildPerformanceBarChart(List<User> users)
```

#### Files to Modify:
- `flutter/lib/screens/analytics_screen.dart`
- `flutter/lib/screens/pms_screen.dart`
- `flutter/lib/screens/sales_hub_screen.dart`
- `flutter/pubspec.yaml` (Add fl_chart)

---

### 🏭 Phase 4: Product Master - Image Upload
**Status**: 50% Complete | **Priority**: MEDIUM

#### Features:
- [ ] **Camera Integration** - Take product photo directly
- [ ] **Gallery Picker** - Select from device
- [ ] **Image Preview** - Show before upload
- [ ] **Cloud Upload** - Save to backend/cloud storage
- [ ] **Multi-Image Support** - Up to 5 images per product

#### Library:
```yaml
dependencies:
  image_picker: ^1.0.7
```

#### Implementation:
```dart
Future<void> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: source);
  if (image != null) {
    setState(() => _selectedImage = File(image.path));
  }
}
```

#### Files to Modify:
- `flutter/lib/screens/add_product_screen.dart`
- `backend/server.js` (Add image upload route)

---

### 📦 Phase 5: Warehouse Operations - Barcode Scanning
**Status**: 20% Complete | **Priority**: LOW

#### Features:
- [ ] **QR/Barcode Scanner UI** - Camera overlay
- [ ] **Scan Validation** - Match with order items
- [ ] **Batch Scanning** - Multiple items at once
- [ ] **Error Handling** - Invalid/duplicate scans

#### Library:
```yaml
dependencies:
  mobile_scanner: ^4.0.1
```

#### Files to Modify:
- `flutter/lib/screens/warehouse_inventory_screen.dart`

---

### 📈 Phase 6: Reporting - Advanced Filters
**Status**: 60% Complete | **Priority**: MEDIUM

#### Enhancements:
- [ ] **Date Range Picker** - Custom period selection
- [ ] **Category Filter** - Product category wise
- [ ] **Region Filter** - City/State wise
- [ ] **Salesperson Filter** - Individual performance
- [ ] **Export Options** - PDF, Excel, CSV with actual data

#### Components:
```dart
Widget _buildFilterChips(List<String> categories)
Widget _buildDateRangePicker()
Widget _buildExportDialog()
```

#### Files to Modify:
- `flutter/lib/screens/reporting_screen.dart`
- `backend/server.js` (Enhanced report generation)

---

### 💰 Phase 7: Logistics Cost - Auto Calculator
**Status**: 10% Complete | **Priority**: LOW

#### Features:
- [ ] **Distance Calculator** - Google Maps API integration
- [ ] **Fuel Cost Formula** - Per km calculation
- [ ] **Driver Allowance** - Daily/trip based
- [ ] **Toll Charges** - Route-specific
- [ ] **Total Cost Summary** - Breakdown view

#### Formula:
```
Total Cost = (Distance × Fuel Rate) + Driver Allowance + Toll + Misc
```

#### Files to Modify:
- `flutter/lib/screens/logistics_cost_screen.dart`
- `backend/server.js` (Add cost calculation API)

---

### 🎨 Phase 8: UI/UX Polish
**Status**: Ongoing | **Priority**: HIGH

#### Standards:
- ✅ White theme with slate accents
- ✅ Rounded corners (16-32px)
- ✅ Consistent padding (16-24px)
- ✅ Shadow depth (0.02-0.05 opacity)
- ✅ Font weights (w600-w900)
- ✅ Emerald accent color (#10B981)

#### Responsive Breakpoints:
```dart
final isMobile = constraints.maxWidth < 600;
final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
final isDesktop = constraints.maxWidth >= 900;
```

---

## 🚀 Implementation Order

### Week 1:
1. ✅ Logistics Hub Bulk Assignment
2. ✅ Credit Control Payment History
3. ✅ Analytics Charts (fl_chart)

### Week 2:
4. ✅ Product Master Image Upload
5. ✅ Reporting Filters
6. ✅ Logistics Cost Calculator

### Week 3:
7. ✅ Warehouse Barcode Scanner
8. ✅ UI/UX Final Polish
9. ✅ Testing & Bug Fixes

---

## 📝 Notes
- **Tally/SAP Integration**: Excluded as per requirements
- **Theme**: White/Light matching Dashboard
- **Responsiveness**: All screens mobile-first
- **Backend**: Node.js + MongoDB
- **State Management**: Provider pattern

---

**Last Updated**: 2026-02-11
**Next Review**: After Phase 1 completion
