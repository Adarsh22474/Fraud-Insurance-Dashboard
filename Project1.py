import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import streamlit as st
import seaborn as sns

vendors = pd.read_csv('data/vendor_data.csv')
insurance = pd.read_csv('data/insurance_data.csv')
employees=pd.read_csv('data/employee_data.csv')

# Date conversion
insurance['POLICY_EFF_DT']= pd.to_datetime(insurance['POLICY_EFF_DT'],format ="%Y-%m-%d")
insurance['LOSS_DT'] = pd.to_datetime(insurance['LOSS_DT'], format = "%Y-%m-%d")
insurance['REPORT_DT']= pd.to_datetime(insurance['REPORT_DT'], format = "%Y-%m-%d")

# Missing values
insurance.loc[insurance["VENDOR_ID"].isna(), "VENDOR_ID"] = "No Vendor Alloted"
insurance.loc[insurance["CITY"].isna(), "CITY"] = "Others"
insurance.loc[insurance["INCIDENT_CITY"].isna(), "INCIDENT_CITY"] = "Unknown"

if "ADDRESS_LINE2" in insurance.columns:
    insurance.drop(columns=["ADDRESS_LINE2"], inplace=True)

# Flags, Premium & time features
insurance["approved_flag"] = (insurance["CLAIM_STATUS"] == "A").astype(int)
insurance["declined_flag"] = (insurance["CLAIM_STATUS"] == "D").astype(int)
insurance["total_premium_component"] = insurance["PREMIUM_AMOUNT"] * insurance["TENURE"]
insurance["days_to_report"] = (insurance["REPORT_DT"] - insurance["LOSS_DT"]).dt.days
insurance["early_report_flag"] = (insurance["days_to_report"] <= 1).astype(int)
insurance["year"] = insurance["REPORT_DT"].dt.year
insurance["month"] = insurance["REPORT_DT"].dt.month



# ============================================================
# SIDEBAR FILTERS
# ============================================================
st.sidebar.header("Filters")

state_filter = st.sidebar.multiselect(
    "State",
    insurance["STATE"].unique(),
    default=insurance["STATE"].unique()
)

insurance = insurance[insurance["STATE"].isin(state_filter)]




tab1, tab2, tab3, tab4, tab5 = st.tabs([
    "📊 Overview",
    "📦 Claim Level Analysis",
    "🏷️ Vendor Risk",
    "🧑‍💼 Agent Performance",
    "📈 Temporal Trends",
])


with tab1:
    st.title("Insurance Fraud Analytics")

    st.subheader("Insurance Data")
    st.write(insurance.head())
    st.subheader("Vendor Data")
    st.write(vendors.head())
    st.subheader("Agent Data")
    st.write(employees.head())

# ============================================================
# KPI OVERVIEW
# ============================================================
    Total_Claims = len(insurance)
    Total_Transactions = insurance["TRANSACTION_ID"].nunique()
    Total_Customers = insurance["CUSTOMER_ID"].nunique()
    Insurance_Types = insurance["INSURANCE_TYPE"].nunique()
    Vendor_Count = insurance["VENDOR_ID"].nunique()
    Agent_Count = insurance["AGENT_ID"].nunique()
    Approved_Claims_Count = insurance.loc[insurance.CLAIM_STATUS=="A","POLICY_NUMBER"].nunique()
    Declined_Claims_Count = insurance.loc[insurance.CLAIM_STATUS=="D","POLICY_NUMBER"].nunique()
    Claim_Amount_Processed = insurance.loc[insurance.CLAIM_STATUS=="A","CLAIM_AMOUNT"].sum()
    Total_Premium = insurance.total_premium_component.sum()
    Loss_Ratio = Claim_Amount_Processed / Total_Premium
    Avg_Claim_Amount = insurance["CLAIM_AMOUNT"].mean()
    Avg_Premium = insurance["PREMIUM_AMOUNT"].mean()
    Avg_Tenure = insurance["TENURE"].mean()
    Avg_Customer_Age = insurance["AGE"].mean()
    Avg_Time_to_Report = insurance["days_to_report"].mean()
    c1,c2,c3,c4 = st.columns(4)
    c1,c2,c3,c4 = st.columns(4)
    c1.metric("Total Claims", Total_Claims)
    c2.metric("Total Customers", Total_Customers)
    c3.metric("Total Vendors", Vendor_Count)
    c4.metric("Loss Ratio", f"{Loss_Ratio:.2f}")
    c5,c6,c7,c8 = st.columns(4)
    c5.metric("Approved Claims", Approved_Claims_Count)
    c6.metric("Declined Claims", Declined_Claims_Count)
    c7.metric("Avg Claim Amount", f"${Avg_Claim_Amount:,.0f}")
    c8.metric("Avg Time to Report (days)", f"{Avg_Time_to_Report:.1f}")




with tab2:
        st.title("Claim_Level Analysis")
        st.subheader(" Claim Amount Summary")
        
    # -------------------- CLAIM AMOUNT SUMMARY --------------------#

        min_claim = insurance['CLAIM_AMOUNT'].min()
        max_claim = insurance['CLAIM_AMOUNT'].max()
        avg_claim = insurance['CLAIM_AMOUNT'].mean()
        total_claims = insurance.shape[0]


        c1, c2, c3, c4 = st.columns(4)

        c1.metric("Total Claims", total_claims)
        c2.metric("Min Claim Amount", f"${min_claim:,.0f}")
        c3.metric("Max Claim Amount", f"${max_claim:,.0f}")
        c4.metric("Avg Claim Amount", f"${avg_claim:,.0f}")

        # -------------------- CLAIM AMOUNT BY INSURANCE TYPE --------------------

        insurance_type_summary = (insurance .groupby("INSURANCE_TYPE")["CLAIM_AMOUNT"].agg(Total_Claim_Amount="sum", Claim_Count="count", Avg_Claim_Amount="mean").reset_index().sort_values(by="Total_Claim_Amount", ascending=False))

        st.subheader(" Claim Summary by Insurance Type")
        st.dataframe(insurance_type_summary,use_container_width=True)
        st.subheader("📊 Total Claim Amount by Insurance Type")

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.barplot(data=insurance_type_summary,x="INSURANCE_TYPE",y="Total_Claim_Amount",ax=ax)
        ax.set_ylabel("Total Claim Amount")
        ax.set_xlabel("Insurance Type")
        ax.tick_params(axis='x', rotation=45)
        st.pyplot(fig)
        # -------------------- CLAIM AMOUNT SHARE --------------------

        st.subheader("🧩 Claim Amount Share by Insurance Type")

        claim_share = (insurance.groupby("INSURANCE_TYPE")["CLAIM_AMOUNT"].sum()/ insurance["CLAIM_AMOUNT"].sum()) * 100

        fig, ax = plt.subplots(figsize=(6, 6))
        ax.pie(claim_share,labels=claim_share.index,autopct='%1.1f%%',startangle=90)
        ax.set_title("Claim Amount Distribution")
        st.pyplot(fig)


        # -------------------- PREMIUM DISTRIBUTION --------------------

        

        insurance['total_premium_component'] = insurance['PREMIUM_AMOUNT'] * insurance['TENURE']

        premium_dist = (insurance.groupby("INSURANCE_TYPE")["total_premium_component"].sum()/ insurance["total_premium_component"].sum()) * 100

        st.subheader("💳 Premium Distribution by Insurance Type")

        fig, ax = plt.subplots(figsize=(6, 6))
        ax.pie(premium_dist.values,labels=premium_dist.index,autopct='%1.1f%%',startangle=90)
        ax.set_title("Premium Share by Insurance Type")
        st.pyplot(fig)


       # -------------------- LOSS RATIO ANALYSIS --------------------

        approved_claims = insurance.loc[insurance['CLAIM_STATUS'] == 'A']
        approved_claims['premium_component'] = (approved_claims['PREMIUM_AMOUNT'] * approved_claims['TENURE'])

        loss_ratio_base = (approved_claims.groupby('INSURANCE_TYPE').agg(Total_Claims_Paid=('CLAIM_AMOUNT', 'sum'),Total_Premium=('premium_component', 'sum')).reset_index())

        loss_ratio_base['Loss_Ratio'] = (loss_ratio_base['Total_Claims_Paid'] / loss_ratio_base['Total_Premium'])

        st.subheader("📉 Loss Ratio by Insurance Type")

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.barplot(data=loss_ratio_base,x="INSURANCE_TYPE",y="Loss_Ratio",ax=ax)

        ax.axhline(1, color='red', linestyle='--', label='Break-even')
        ax.legend()
        ax.tick_params(axis='x', rotation=45)

        st.pyplot(fig)



        # -------------------- TIME TO REPORT ANALYSIS --------------------

        approved_claims['Time_to_Report'] = (approved_claims['REPORT_DT'] - approved_claims['LOSS_DT']).dt.days

        time_summary = (approved_claims.groupby("Time_to_Report").agg(Claim_Count=('CLAIM_AMOUNT', 'count'),Avg_Severity=('CLAIM_AMOUNT', 'mean')).reset_index())
        st.subheader("⏱️ Time to Report vs Claim Severity")
        max_days = st.slider("Max Days to Report", 0, 3, 5)

        filtered_time = time_summary[time_summary['Time_to_Report'] <= max_days]

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.barplot(
            data=filtered_time,
            x="Time_to_Report",
            y="Avg_Severity",
            ax=ax
        )

        ax.set_xlabel("Days to Report")
        ax.set_ylabel("Average Claim Amount")
        ax.tick_params(axis='x', rotation=45)

        st.pyplot(fig)


        # -------------------- APPROVAL RATE ANALYSIS --------------------

        insurance['approved_flag'] = (insurance['CLAIM_STATUS'] == 'A').astype(int)
        insurance['declined_flag'] = (insurance['CLAIM_STATUS'] == 'D').astype(int)

        approval_base = (insurance.groupby('INSURANCE_TYPE').agg(total_claims=('CLAIM_STATUS', 'count'),approved_claims=('approved_flag', 'sum'),declined_claims=('declined_flag', 'sum')).reset_index())

        approval_base['approval_rate_pct'] = (approval_base['approved_claims'] * 100 / approval_base['total_claims']).round(2)

        st.subheader("✅ Approval Rate by Insurance Type")

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.barplot(data=approval_base.sort_values('approval_rate_pct', ascending=False),x="INSURANCE_TYPE", y="approval_rate_pct",ax=ax)
        ax.set_ylabel("Approval Rate (%)")
        ax.tick_params(axis='x', rotation=45)

        st.pyplot(fig)

        # -------------------- STATE-WISE CLAIM DISTRIBUTION --------------------

        state_wise = (
            insurance.groupby("STATE")
            .agg(
                Claim_Count=("CLAIM_AMOUNT", "count"),
                Claim_Amount=("CLAIM_AMOUNT", "sum")
            )
            .reset_index()
        )

        state_wise['Claim_Amount_pct'] = (
            state_wise['Claim_Amount'] * 100 / state_wise['Claim_Amount'].sum()
        )

        st.subheader("🗺️ Claim Amount Share by State")

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.barplot(
            data=state_wise.sort_values("Claim_Amount_pct", ascending=False).head(10),
            x="STATE",
            y="Claim_Amount_pct",
            ax=ax
        )

        ax.tick_params(axis='x', rotation=45)
        st.pyplot(fig)

       # -------------------- INCIDENT HOUR ANALYSIS --------------------

        hourly_severity = (insurance.groupby("INCIDENT_HOUR_OF_THE_DAY").agg(Avg_Severity=("CLAIM_AMOUNT", "mean")).reset_index())

        st.subheader("🕒 Average Claim Severity by Hour")
       
        fig, ax = plt.subplots(figsize=(8, 5))
        sns.barplot(data=hourly_severity,x="INCIDENT_HOUR_OF_THE_DAY",y="Avg_Severity",ax=ax)
        st.pyplot(fig)


with tab3:
     # -------------------- VENDOR RISK SUMMARY --------------------

        vendor_summary = (insurance.groupby('VENDOR_ID').agg(Claim_Count=('POLICY_NUMBER', 'count'),Avg_Claim_Severity=('CLAIM_AMOUNT', 'mean'),Approved_Claims=('approved_flag', 'sum'),Declined_Claims=('declined_flag', 'sum')).reset_index().sort_values(by='Avg_Claim_Severity', ascending=False))

        st.subheader("🏷️ Vendor Risk Summary")
        st.dataframe(vendor_summary, use_container_width=True)

    

        top_n = st.slider("Select Top Vendors by Severity", 5, 20, 10)

        fig, ax = plt.subplots(figsize=(10, 5))

        sns.barplot(data=vendor_summary.head(top_n),x="VENDOR_ID",y="Avg_Claim_Severity",ax=ax)

        ax.set_xlabel("Vendor ID")
        ax.set_ylabel("Average Claim Severity")
        ax.tick_params(axis='x', rotation=45)

        st.pyplot(fig)



        # -------------------- VENDOR LOSS RATIO --------------------

        vendor_approved = insurance.loc[insurance['CLAIM_STATUS'] == 'A']
        vendor_approved['premium_component'] = (vendor_approved['PREMIUM_AMOUNT'] * vendor_approved['TENURE'])

        vendor_loss_ratio = (vendor_approved.groupby('VENDOR_ID').agg(Claims_Paid=('CLAIM_AMOUNT', 'sum'),Premium_Collected=('premium_component', 'sum')).reset_index())

        vendor_loss_ratio['Loss_Ratio'] = (vendor_loss_ratio['Claims_Paid'] /vendor_loss_ratio['Premium_Collected'])

        vendor_loss_ratio = vendor_loss_ratio.sort_values(by='Loss_Ratio', ascending=False)

        st.subheader("📉 Vendor Loss Ratio (Approved Claims)")

        top_n = st.slider("Show Top N Vendors", 5, 20, 10)

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.barplot(data=vendor_loss_ratio.head(top_n),x='VENDOR_ID',y='Loss_Ratio',ax=ax)
        ax.axhline(1, linestyle='--', color='red', label='Break-even')
        ax.legend()
        ax.tick_params(axis='x', rotation=45)

        st.pyplot(fig)


        # -------------------- EARLY REPORTING BEHAVIOR --------------------

        insurance['days_to_report'] = (insurance['REPORT_DT'] - insurance['LOSS_DT']).dt.days
        insurance['early_report_flag'] = (insurance['days_to_report'] <= 1).astype(int)

        vendor_early_reporting = (insurance.groupby('VENDOR_ID').agg(total_claims=('VENDOR_ID', 'count'),early_reports=('early_report_flag', 'sum')).reset_index())

        vendor_early_reporting['early_report_pct'] = (vendor_early_reporting['early_reports'] * 100 /vendor_early_reporting['total_claims'])

        vendor_early_reporting = vendor_early_reporting.sort_values(by='early_report_pct', ascending=False)
        st.subheader("⏱️ Early Reporting Rate by Vendor")

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.barplot(
            data=vendor_early_reporting.head(10),
            x='VENDOR_ID',
            y='early_report_pct',
            ax=ax
        )

        ax.set_ylabel("Early Reporting (%)")
        ax.tick_params(axis='x', rotation=45)

        st.pyplot(fig)


        # -------------------- VENDOR STATE CONCENTRATION --------------------

        vendor_claims = insurance.loc[
            insurance['VENDOR_ID'] != 'No Vendor Alloted'
        ]

        vendor_state_summary = (vendor_claims.groupby(['VENDOR_ID', 'STATE']).agg(Claim_Count=('CLAIM_AMOUNT', 'count'),Avg_Claim=('CLAIM_AMOUNT', 'mean'),Total_Claim=('CLAIM_AMOUNT', 'sum')).reset_index().sort_values(by='Total_Claim', ascending=False))

        st.subheader("🗺️ Vendor–State Claim Concentration")
        st.dataframe( vendor_state_summary.head(50), use_container_width=True)


        
        top_n = st.slider("Select Top Vendor–State Combinations",min_value=5, max_value=30,value=10)
        top_vendor_state = vendor_state_summary.head(top_n)

        fig, ax = plt.subplots(figsize=(10, 5))

        sns.barplot(data=top_vendor_state,x="Total_Claim",y="VENDOR_ID",hue="STATE",ax=ax)

        ax.set_xlabel("Total Claim Amount")
        ax.set_ylabel("Vendor ID")

        st.pyplot(fig)



with tab4:
            # -------------------- AGENT APPROVAL RATE --------------------

        agent_level = (insurance.groupby('AGENT_ID').agg(Total_Claims=('CLAIM_STATUS', 'count'),Approved_Claims=('approved_flag', 'sum'),Declined_Claims=('declined_flag', 'sum')).reset_index())

        agent_level['approval_rate_pct'] = (agent_level['Approved_Claims'] * 100 / agent_level['Total_Claims']).round(2)

        agent_level['approval_rate_category'] = pd.cut(agent_level['approval_rate_pct'],bins=[0, 95, 99.99, 100],labels=['<95%', '95%–99%', '100%'],include_lowest=True)

        st.subheader("🧑‍💼 Agent Approval Rate Summary")

        st.dataframe(agent_level.sort_values('approval_rate_pct'),use_container_width=True)


        # -------------------- AGENT APPROVAL RATE BUCKET SUMMARY --------------------

        approval_bucket_summary = (
            agent_level
            .groupby('approval_rate_category')
            .agg(Agent_Count=('AGENT_ID', 'count'))
            .reset_index()
        )

        total_agents = approval_bucket_summary['Agent_Count'].sum()

        approval_bucket_summary['pct_share'] = (
            approval_bucket_summary['Agent_Count'] * 100 / total_agents
        ).round(2)
        st.subheader("📊 Agent Approval Rate Distribution")

        fig, ax = plt.subplots(figsize=(6, 4))
        sns.barplot(
            data=approval_bucket_summary,
            x='approval_rate_category',
            y='Agent_Count',
            ax=ax)

        ax.set_xlabel("Approval Rate Category")
        ax.set_ylabel("Number of Agents")

        st.pyplot(fig)

        # -------------------- AGENT CLAIM BEHAVIOR --------------------

        agent_claim_behavior = (insurance.groupby("AGENT_ID").agg(Total_Claims=('POLICY_NUMBER', 'count'),Avg_Claim_Severity=('CLAIM_AMOUNT', 'mean'),Claim_Deviation=('CLAIM_AMOUNT', 'std')).reset_index().sort_values(by='Avg_Claim_Severity', ascending=False))

        st.subheader("💸 High Severity & Volatile Agents")

        top_n_agents = st.slider("Show Top N Agents", 5, 20, 10)

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.scatterplot(
            data=agent_claim_behavior.head(top_n_agents),
            x='Claim_Deviation',
            y='Avg_Claim_Severity',
            size='Total_Claims',
            sizes=(50, 300),
            ax=ax
        )

        ax.set_xlabel("Claim Amount Deviation")
        ax.set_ylabel("Average Claim Severity")

        st.pyplot(fig)


with tab5:
        insurance['year_month'] = insurance['REPORT_DT'].dt.to_period('M').astype(str)
        
        # -------------------- MONTHLY CLAIMS SUMMARY --------------------

        monthly_claims_summary = (insurance.groupby(['year_month']).agg(Total_Claims=('CLAIM_AMOUNT', 'count'),Total_Claim_Amount=('CLAIM_AMOUNT', 'sum'), Avg_Claim_Amount=('CLAIM_AMOUNT', 'mean')).reset_index().sort_values('year_month'))

        st.subheader("📅 Monthly Claims Trend")

        metric_choice = st.selectbox(
            "Select Metric",
            ["Total_Claims", "Total_Claim_Amount", "Avg_Claim_Amount"]
        )

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.lineplot(data=monthly_claims_summary,x='year_month',y=metric_choice,marker='o',ax=ax)
        ax.set_xlabel("Year-Month")
        ax.set_ylabel(metric_choice.replace("_", " "))
        ax.tick_params(axis='x', rotation=45)

        st.pyplot(fig)


        # -------------------- TIME TO REPORT DRIFT --------------------

        time_to_report_drift = (
            insurance
            .groupby(['year_month'])
            .agg(
                Avg_Time_to_Report=('days_to_report', 'mean')
            )
            .reset_index()
            .sort_values('year_month')
        )
        st.subheader("⏱️ Average Time-to-Report Drift")

        fig, ax = plt.subplots(figsize=(10, 5))
        sns.lineplot(data=time_to_report_drift, x='year_month', y='Avg_Time_to_Report',marker='o',ax=ax)
        ax.set_xlabel("Year-Month")
        ax.set_ylabel("Avg Days to Report")
        ax.tick_params(axis='x', rotation=45)

        st.pyplot(fig)

  










