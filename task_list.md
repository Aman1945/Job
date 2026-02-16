# NexusOMS Workflow Refinement Task List

## 1. Data Model Enhancements [/]
- [ ] Add `location`, `department`, `channel` fields to User model (Backend & Flutter)
- [ ] Update `User` model on backend to support multiple departments
- [ ] Update `Order` model to include `distributionChannel` and `location` for better tracking

## 2. Screen Implementation Audit [ ]
- [ ] Audit Stage 3.5 (QC): Currently using `LiveOrdersScreen`, need a dedicated `QualityControlScreen`
- [ ] Audit Stage 6 (Hub): Check if `LogisticsHubScreen` supports manifest creation
- [ ] Audit Stage 7 (Delivery): Verify POD upload functionality in `DeliveryExecutionScreen`

## 3. Dashboard & RBAC Tuning [ ]
- [ ] Refine `DashboardScreen` to filter stages not just by `role` but also by `department` if needed
- [ ] Implement the "15% High Cost Alert" logic specifically in the `LogisticsCostScreen`

## 4. Master Data UI Updates [ ]
- [ ] Update `MasterDataScreen` forms to include new User fields (Location, Department, Channel)
- [ ] Ensure `CustomerMaster` handles class-based logic (Horeca, Retail, etc.)

## 5. Verification & Deployment [ ]
- [ ] Test cross-role workflows (Sales -> Credit -> WH -> Billing)
- [ ] Final sync to GitHub and Render
