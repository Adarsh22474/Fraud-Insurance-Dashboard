# 🚨 Insurance Claims Fraud Detection & Cost Control Analytics System

## 👤 Author
**Adarsh Gupta**  
Domain: Insurance | Fraud & Risk Analytics  

---

##  Project Overview
This project is an **end-to-end Fraud Analytics and Claims Cost Control system** built to simulate how insurance companies detect **fraudulent claims, cost leakages, and operational inefficiencies** across the claims lifecycle.

The project integrates:
- Business problem formulation
- SQL-based data audit and exploratory analysis
- Multi-level descriptive & diagnostic analytics
- Interactive Power BI dashboards
- A Python-based Streamlit web application

The primary focus is on **decision-support analytics for fraud investigation and risk management teams**, not just visualization.

---

##  Business Context & Problem Statement
Insurance companies face rising losses due to:
- Inflated repair invoices from vendors
- Suspicious vendor–agent–customer collusion
- High-risk customers filing early or repeated claims
- Weak claim approval controls
- Fragmented data across claims, vendors, and employees

### Business Objective
To build a **Unified Fraud Detection & Claims Cost Control Analytics System** that enables stakeholders to:
- Identify suspicious claims early
- Detect high-risk vendors, customers, and employees
- Control claim leakage
- Improve pricing, underwriting, and investigation decisions

---

## 📂 Data Source
Dataset sourced from Kaggle:  
https://www.kaggle.com/datasets/mastmustu/insurance-claims-fraud-data

### Tables Used
- **Insurance** (Fact table – claims & policies)
- **Vendor** (Repair & service vendors)
- **Employee** (Claims adjusters / agents)

An ER diagram was created to understand relational dependencies.

---

##  Project Workflow

### 1️⃣ Dataset Selection & Business Understanding
- Evaluated multiple datasets before selecting a **multi-table relational insurance fraud dataset**
- Defined fraud and cost control objectives before any analysis
- Identified stakeholders and their decision needs upfront

---

### 2️⃣ Data Audit & Validation (SQL)
Conducted a detailed **data audit using SQL**, including:
- Row counts & uniqueness checks
- Null and missing value analysis
- Distribution checks for claim amounts
- Consistency checks across monetary fields
- Date sanity checks (LOSS_DT vs REPORT_DT)

This ensured **analytical reliability before visualization**.

---

### 3️⃣ Exploratory & Diagnostic Analysis
Analysis was conducted at **five analytical levels**:

---

###  Claim-Level Analysis
- Claim amount distribution & heavy right skew detection
- Outlier detection using statistical thresholds (p95, p99)
- Claim severity vs insurance type
- Loss ratio analysis by product
- Reporting delay analysis (LOSS_DT vs REPORT_DT)
- Time-of-day risk analysis
- Geographic claim severity patterns
- Approval rate analysis (systemic over-approval detection)

**Key Insight:**  
A small % of high-severity claims drive the majority of losses; Life and Property insurance dominate loss exposure.

---

###  Customer-Level Analysis
- Age-based and tenure-based risk profiling
- Early-tenure and mid-tenure fraud hotspot identification
- Loss ratio vs customer lifecycle
- Geographic customer risk clustering

**Key Insight:**  
Customers with **6–12 months tenure** exhibit the highest loss ratios — a classic fraud pattern.

---

###  Vendor-Level Analysis
- Vendor claim severity benchmarking
- Vendor concentration (Pareto analysis)
- Vendor approval rate anomalies
- Loss ratio analysis by vendor
- Vendor–agent combination risk analysis
- Identification of traceability gaps (“No Vendor Allotted”)

**Key Insight:**  
Several vendors show **100% approval rates and extreme loss ratios**, indicating strong collusion risk.

---

###  Employee / Agent-Level Analysis
- Adjuster approval rate analysis
- Settlement amount variance by agent
- Identification of agents with perfect approvals
- Agent–vendor network red flags

**Key Insight:**  
Widespread perfect approval behavior suggests systemic control weaknesses.

---

###  Temporal & Trend Analysis
- Monthly and yearly claim trend analysis
- Seasonality detection
- Sudden spike detection (fraud wave indicators)
- Time-to-report drift analysis

**Key Insight:**  
A massive spike in mid-2020 suggests either event-driven losses or organized fraud clusters.

---

##  Power BI Dashboard
A **5-page interactive Power BI dashboard** was created and published on Power BI Service.

🔗 Power BI Report Link:  
https://app.powerbi.com/groups/me/reports/61d7eabd-9f70-4cfa-8f0f-441c964e9c73/735c3deb3bf355fbeec4

### Dashboards Included
1. Claim Overview & Anomaly Dashboard  
2. Customer Risk Dashboard  
3. Vendor Risk Dashboard  
4. Employee / Adjuster Risk Dashboard   

Each dashboard includes:
- Business KPIs
- Drill-downs
- Slicers for dynamic investigation
- Stakeholder-focused visuals

---

##  Python & Streamlit Web Application
The same analytical logic was replicated using **Python in VS Code**, followed by deployment using **Streamlit**.

🔗 Live App:  
https://fraud-insurance-dashboard-1.onrender.com/

Purpose:
- Enable interactive exploration
- Simulate self-service analytics for investigators
- Demonstrate end-to-end deployment capability

---

##  Technology Stack
- **SQL** – Data audit, EDA, KPI computation
- **Power BI** – Business intelligence & dashboards
- **Python** – Analysis & data manipulation
- **Streamlit** – Web application deployment
- **Pandas, Matplotlib, Seaborn**

---

##  Stakeholders Supported
- Fraud Investigation Team
- Risk & Compliance Team
- Claims Operations
- Vendor Management
- Pricing & Underwriting
- Senior Management

---

## 📈 Business Impact (Simulated)
- Early fraud flagging for high-risk claims
- Identification of vendor and agent collusion risks
- Improved claim cost control visibility
- Data-driven investigation prioritization

---

##  Key Skills Demonstrated
- Business problem formulation
- Fraud analytics thinking
- SQL-based data auditing
- Multi-level EDA & diagnostic analysis
- Dashboard storytelling
- End-to-end analytics deployment

---

##  Future Enhancements Thought Of:
- Fraud risk scoring models
- Network analysis for collusion detection
- Real-time fraud alerts
- ML-based anomaly detection

---

## ⭐ Why This Project Matters
This project demonstrates **full-time readiness for Data Analyst / Fraud Analyst roles** by combining **business context, analytical rigor, and production-style delivery**.




