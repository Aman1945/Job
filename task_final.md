# NexusOMS Final RBAC & Workflow Sync

## 1. Requirement Analysis [ ]
- [ ] Map all Login IDs to their respective Roles and Stages
- [ ] Re-verify the conflicting QC/Credit Control requirement for Dheeraj
- [ ] Check if `downloads` source directory contains additional business logic

## 2. Backend & Data Sync [ ]
- [ ] Verify `models/User.js` roles match the new list
- [ ] Audit `list_creds.js` or equivalent to ensure test accounts exist
- [ ] Implementation of high-cost alert auto-notifications (Animesh)

## 3. Flutter App Dashboard Sync [/]
- [/] Apply strict "Creation" hide for all non-Sales/Admin
- [ ] Update Finance/Credit IDs (Kshama, Pawan) visibility
- [ ] Finalize WH Manager and WH House IDs (Amit, ops)
- [ ] Sync QC Head and Billing IDs (Nitin, Pradip)
- [ ] Finalize Logistics Leads (Pratish, Animesh, Lawin)

## 4. Angular Web App Dashboard Sync [/]
- [/] Mirror Flutter's strict filtering logic
- [ ] Implement stage-specific routing guards
- [ ] Verify local API connectivity (CORS/BaseUrl)

## 5. Verification & Flow Documentation [ ]
- [ ] Create detailed "App Flow Explorer" for the user
- [ ] Verify with specific logins: `credit.control@bigsams.in`, `operations@bigsams.in`, etc.
