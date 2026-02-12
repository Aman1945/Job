# LEGAL COMPLIANCE REGISTER
**NexusOMS Enterprise**  
**Version**: 1.0  
**Last Updated**: February 12, 2026

---

## 1. APPLICABLE LAWS AND REGULATIONS

| Law/Regulation | Jurisdiction | Applicability | Compliance Owner | Review Frequency |
|----------------|--------------|---------------|------------------|------------------|
| **GDPR** (General Data Protection Regulation) | EU | Customer data from EU | CISO | Quarterly |
| **Indian IT Act 2000** | India | All operations | Legal | Annually |
| **ISO 27001:2022** | International | Information security | CISO | Annually |
| **ISO 9001:2015** | International | Quality management | Quality Manager | Annually |
| **Companies Act 2013** | India | Corporate governance | CFO | Annually |
| **GST Act** | India | Financial transactions | Finance | Monthly |
| **Labour Laws** | India | Employee management | HR | Annually |

---

## 2. GDPR COMPLIANCE

### 2.1 Requirements
- Right to Access (Article 15)
- Right to Rectification (Article 16)
- Right to Erasure (Article 17)
- Right to Data Portability (Article 20)
- Breach Notification (Article 33-34)

### 2.2 Implementation
- **Data Inventory**: Customer data, order data, user data
- **Legal Basis**: Consent, contract, legitimate interest
- **Data Retention**: See INFORMATION_SECURITY_POLICY.md
- **GDPR Endpoints**: `/api/gdpr/forget/:userId`, `/api/gdpr/export/:userId`
- **DPO Contact**: dpo@nexusoms.com

### 2.3 Compliance Status
✅ Data mapping complete  
✅ Privacy policy published  
✅ Consent mechanisms implemented  
✅ GDPR endpoints operational  
✅ Breach notification procedure in place

---

## 3. ISO 27001:2022 COMPLIANCE

### 3.1 Implemented Controls

| Control | Description | Status |
|---------|-------------|--------|
| A.5.15 | Access Control | ✅ Implemented (RBAC) |
| A.5.16 | Identity Management | ✅ Implemented (JWT) |
| A.5.17 | Authentication | ✅ Implemented (bcrypt) |
| A.8.10 | Information Deletion | ✅ Implemented (GDPR routes) |
| A.8.16 | Monitoring Activities | ✅ Implemented (Audit logs) |
| A.8.24 | Cryptography | ✅ Implemented (TLS, AES-256) |
| A.5.24-28 | Incident Management | ✅ Documented (IRP) |
| A.5.29-30 | Business Continuity | ✅ Documented (BCP) |

### 3.2 Certification Status
- **Target Date**: June 2026
- **Certification Body**: TBD
- **Stage 1 Audit**: April 2026
- **Stage 2 Audit**: May 2026

---

## 4. INDIAN IT ACT 2000

### 4.1 Key Provisions
- **Section 43**: Penalty for damage to computer systems
- **Section 66**: Computer-related offenses
- **Section 72**: Breach of confidentiality and privacy
- **Section 85**: Offenses by companies

### 4.2 Compliance Measures
- Data protection policies in place
- Access controls implemented
- Audit trails maintained
- Employee confidentiality agreements

---

## 5. DATA PROTECTION REQUIREMENTS

### 5.1 Personal Data Categories
- **Customer Data**: Name, address, phone, email
- **Employee Data**: Name, email, role, salary
- **Order Data**: Customer ID, products, amounts
- **Audit Data**: User actions, timestamps, IP addresses

### 5.2 Data Processing Activities
- Order management
- Customer relationship management
- Performance management
- Financial reporting

### 5.3 Data Transfers
- **Within India**: Permitted
- **To EU**: GDPR compliance required
- **To Other Countries**: Adequacy assessment required

---

## 6. COMPLIANCE MONITORING

### 6.1 Compliance Checks
- **Monthly**: GST compliance, financial reporting
- **Quarterly**: GDPR compliance, ISO 27001 controls
- **Annually**: Full compliance audit, policy reviews

### 6.2 Compliance Metrics
- Number of data breaches: Target 0
- GDPR requests processed: Track monthly
- Audit findings: Track and remediate
- Training completion: 100% annually

---

## 7. NON-COMPLIANCE RISKS

| Risk | Impact | Mitigation |
|------|--------|------------|
| GDPR violation | €20M fine or 4% revenue | GDPR endpoints, training |
| Data breach | Legal liability, reputation | Security controls, IRP |
| ISO non-compliance | Certification loss | Regular audits, reviews |
| Tax non-compliance | Penalties, legal action | Automated GST filing |

---

## 8. COMPLIANCE TRAINING

### 8.1 Mandatory Training
- **GDPR Awareness**: All employees, annually
- **Information Security**: All employees, annually
- **Quality Management**: Relevant staff, annually

### 8.2 Training Records
- Maintained in HR system
- Completion tracked quarterly
- Certificates issued upon completion

---

## 9. DOCUMENT CONTROL

**Owner**: Legal Department  
**Approved By**: CEO  
**Next Review**: February 12, 2027  
**Distribution**: Management, CISO, Quality Manager
