# INCIDENT ASSESSMENT PROCEDURE
**NexusOMS Enterprise - ISO 27001:2022 Control A.5.24**  
**Version**: 1.0  
**Effective Date**: February 12, 2026

---

## 1. PURPOSE

Define the process for assessing information security incidents to determine severity, impact, and appropriate response actions.

---

## 2. SCOPE

Applies to all suspected or confirmed information security incidents including:
- Unauthorized access
- Data breaches
- Malware infections
- Denial of Service (DoS) attacks
- Physical security breaches
- System failures with security implications

---

## 3. INCIDENT ASSESSMENT CRITERIA

### 3.1 Severity Classification

| Severity | Criteria | Response Time | Escalation |
|----------|----------|---------------|------------|
| **Critical** | - Data breach affecting >1000 records<br>- Complete system compromise<br>- Ransomware attack<br>- Active data exfiltration | 15 minutes | Immediate to CISO + Management |
| **High** | - Unauthorized access to sensitive data<br>- Malware infection<br>- Significant service disruption<br>- Attempted data breach | 1 hour | CISO within 1 hour |
| **Medium** | - Suspicious activity detected<br>- Minor security policy violation<br>- Phishing attempt<br>- Failed intrusion attempt | 4 hours | IT Manager within 4 hours |
| **Low** | - Isolated security event<br>- False positive alert<br>- Minor policy violation | 24 hours | Log for review |

---

### 3.2 Impact Assessment

**Confidentiality Impact**:
- **High**: Sensitive data exposed (customer PII, financial data, credentials)
- **Medium**: Internal data exposed (business plans, employee data)
- **Low**: Public information exposed

**Integrity Impact**:
- **High**: Critical data modified or deleted (orders, financial records)
- **Medium**: Non-critical data modified (logs, reports)
- **Low**: Temporary or easily recoverable changes

**Availability Impact**:
- **High**: Complete system outage, >4 hours downtime
- **Medium**: Partial service disruption, 1-4 hours downtime
- **Low**: Minor performance degradation, <1 hour downtime

---

## 4. ASSESSMENT PROCESS

### STEP 1: Initial Triage (0-15 minutes)

**Questions to Answer**:
1. What happened?
2. When was it detected?
3. What systems are affected?
4. Is the incident ongoing?
5. Is there immediate risk?

**Initial Assessment Form**:
```
Incident ID: INC-YYYY-MM-DD-XXX
Reported By: _______________
Date/Time Detected: _______________
Detection Method: Alert / User Report / Monitoring / Other

Affected Systems:
[ ] Order Management
[ ] Customer Database
[ ] Payment System
[ ] Logistics
[ ] Other: _______________

Incident Type:
[ ] Unauthorized Access
[ ] Data Breach
[ ] Malware
[ ] DoS/DDoS
[ ] Physical Security
[ ] Other: _______________

Ongoing: Yes / No
Immediate Risk: Yes / No
```

**Action**: Assign preliminary severity (Critical/High/Medium/Low)

---

### STEP 2: Detailed Assessment (15 minutes - 2 hours)

**2.1 Scope Determination**
- Number of systems affected: ___
- Number of users affected: ___
- Data types involved: ___
- Geographic scope: ___

**2.2 Impact Analysis**

**Confidentiality**:
```
Data Exposed: Yes / No / Unknown
Type of Data: _______________
Number of Records: _______________
Sensitivity: High / Medium / Low
```

**Integrity**:
```
Data Modified: Yes / No / Unknown
Data Deleted: Yes / No / Unknown
Backup Available: Yes / No
Recovery Time: _______________
```

**Availability**:
```
Service Disrupted: Yes / No
Downtime Duration: _______________
Users Affected: _______________
Business Impact: _______________
```

**2.3 Root Cause Hypothesis**
- Attack vector: _______________
- Vulnerability exploited: _______________
- Attacker profile: Internal / External / Unknown

**2.4 Evidence Collection**
- [ ] System logs captured
- [ ] Network traffic captured
- [ ] Screenshots taken
- [ ] Memory dump collected
- [ ] Affected files preserved

---

### STEP 3: Severity Determination (2-4 hours)

**Severity Matrix**:

| Impact | Scope: Single System | Scope: Multiple Systems | Scope: Critical Systems |
|--------|---------------------|------------------------|------------------------|
| **High C/I/A** | High | High | Critical |
| **Medium C/I/A** | Medium | High | High |
| **Low C/I/A** | Low | Medium | Medium |

**Final Severity**: Critical / High / Medium / Low

**Justification**: _______________

---

### STEP 4: Response Recommendation (4-6 hours)

**Recommended Actions**:
- [ ] Immediate containment required
- [ ] Isolate affected systems
- [ ] Disable compromised accounts
- [ ] Block malicious IPs
- [ ] Notify affected parties
- [ ] Engage external experts
- [ ] Notify law enforcement
- [ ] Notify regulatory authorities

**Resource Requirements**:
- Personnel: _______________
- Tools: _______________
- Budget: _______________
- External support: _______________

---

## 5. REGULATORY NOTIFICATION ASSESSMENT

### 5.1 GDPR Breach Notification
**Criteria**: Personal data of EU residents compromised

**Assessment**:
- [ ] Personal data involved: Yes / No
- [ ] EU residents affected: Yes / No
- [ ] High risk to rights and freedoms: Yes / No

**Action Required**:
- If Yes to all: Notify Data Protection Authority within 72 hours
- If high risk: Notify affected individuals without undue delay

### 5.2 Indian IT Act Notification
**Criteria**: Cyber crime or significant data breach

**Assessment**:
- [ ] Criminal activity suspected: Yes / No
- [ ] Significant data breach: Yes / No

**Action Required**:
- Report to local cyber crime cell
- Preserve evidence for investigation

---

## 6. STAKEHOLDER NOTIFICATION MATRIX

| Severity | Internal Notification | External Notification | Timeline |
|----------|----------------------|----------------------|----------|
| **Critical** | - CISO (immediate)<br>- CEO/CTO (15 min)<br>- All staff (1 hour) | - Customers (4 hours)<br>- Regulators (24-72 hours)<br>- Media (if required) | Immediate |
| **High** | - CISO (1 hour)<br>- Management (4 hours)<br>- Relevant staff (4 hours) | - Affected customers (24 hours)<br>- Regulators (if required) | Within 4 hours |
| **Medium** | - IT Manager (4 hours)<br>- Department heads (8 hours) | - None (unless escalates) | Within 24 hours |
| **Low** | - IT Team (24 hours) | - None | Within 48 hours |

---

## 7. ASSESSMENT DOCUMENTATION

### 7.1 Incident Assessment Report Template

```
INCIDENT ASSESSMENT REPORT

Incident ID: _______________
Assessment Date: _______________
Assessed By: _______________

1. INCIDENT SUMMARY
   - Type: _______________
   - Detection Time: _______________
   - Assessment Time: _______________

2. SCOPE AND IMPACT
   - Systems Affected: _______________
   - Users Affected: _______________
   - Data Involved: _______________
   - Confidentiality Impact: High / Medium / Low
   - Integrity Impact: High / Medium / Low
   - Availability Impact: High / Medium / Low

3. SEVERITY DETERMINATION
   - Initial Severity: _______________
   - Final Severity: _______________
   - Justification: _______________

4. ROOT CAUSE ANALYSIS
   - Attack Vector: _______________
   - Vulnerability: _______________
   - Contributing Factors: _______________

5. RESPONSE RECOMMENDATIONS
   - Immediate Actions: _______________
   - Containment Strategy: _______________
   - Eradication Plan: _______________
   - Recovery Steps: _______________

6. NOTIFICATION REQUIREMENTS
   - Internal: _______________
   - External: _______________
   - Regulatory: _______________

7. RESOURCE REQUIREMENTS
   - Personnel: _______________
   - Tools: _______________
   - Budget: _______________

8. TIMELINE
   - Detection: _______________
   - Assessment Complete: _______________
   - Containment Target: _______________
   - Recovery Target: _______________

Assessed By: _______________
Approved By: _______________
Date: _______________
```

---

## 8. ASSESSMENT TOOLS

### 8.1 Technical Tools
- Log analysis tools (ELK Stack, Splunk)
- Network monitoring (Wireshark, tcpdump)
- Malware analysis (VirusTotal, sandbox)
- Forensic tools (FTK, EnCase)

### 8.2 Assessment Checklists
- Data breach assessment checklist
- Malware incident checklist
- Unauthorized access checklist
- DoS attack checklist

---

## 9. TRAINING

All incident response team members must be trained in:
- Incident assessment criteria
- Impact analysis techniques
- Evidence collection procedures
- Regulatory notification requirements

**Frequency**: Annually + after major incidents

---

## 10. CONTINUOUS IMPROVEMENT

### 10.1 Post-Incident Review
- Was severity correctly assessed?
- Was response appropriate?
- Were notifications timely?
- What can be improved?

### 10.2 Procedure Updates
- Review assessment criteria quarterly
- Update based on lessons learned
- Incorporate new threat intelligence
- Align with regulatory changes

---

**Approved By**: _______________  
**Date**: _______________  
**Next Review**: February 12, 2027
