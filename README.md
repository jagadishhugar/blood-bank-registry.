Readme · MD
# 🩸 Emergency Blood Bank Registry
 
A relational database system that models a real-world blood donation network — tracking donors, hospitals, live blood stock, emergency requests, and donation history. Built to go beyond basic CRUD by including **geospatial donor-to-hospital matching**, **analytics with window functions**, a **critical-stock monitoring view**, and a **transactional donation-processing procedure**.
 
> Built and tested on **Microsoft SQL Server (T-SQL)**.
 
---
 
## 📌 Why this project
 
Most student database projects stop at schema + basic SELECTs. This one is designed to answer a real operational question a blood bank network would actually ask:
 
- *"Which donor is physically closest to a hospital that's critically low on their blood type, right now?"*
- *"If a donation comes in, how do we update stock and close out a matching request atomically, without leaving the database in an inconsistent state if something fails midway?"*
## 🧱 Schema Overview
 
| Table | Purpose |
|---|---|
| `Hospitals` | Hospital locations (lat/long) and emergency contact info |
| `Donors` | Donor details, blood type, location, last donation date |
| `BloodStock` | Live unit count per blood type, per hospital |
| `BloodRequests` | Emergency blood requests with urgency level and status |
| `DonationHistory` | Log of every donation: who, where, when, how much |
 
**Relationships:**
- `BloodStock.HospitalID` → `Hospitals.HospitalID`
- `BloodRequests.HospitalID` → `Hospitals.HospitalID`
- `DonationHistory.DonorID` → `Donors.DonorID`
- `DonationHistory.HospitalID` → `Hospitals.HospitalID`
## ⚙️ Tech Stack
 
- **Database:** Microsoft SQL Server (T-SQL)
- **Concepts used:** DDL/DML, CHECK constraints, foreign keys, indexes, CTEs, window functions (`RANK`, `ROW_NUMBER`, `DENSE_RANK`), views, stored procedures, `TRY...CATCH` error handling, transactions
## ✨ Key Features
 
### 1. Geospatial nearest-hospital matching
Uses the **Haversine formula** to calculate real great-circle distance (km) between every donor and every hospital — including a variant that only matches hospitals currently stocking the donor's blood type. Turns static lat/long columns into an actual "find your nearest donation point" feature.
 
### 2. Analytics layer (CTEs + window functions)
- Donor donation-count leaderboard (`RANK()`)
- Running monthly network-wide donation totals
- Most recent donation per donor without a self-join (`ROW_NUMBER()`)
- Each hospital's share of network-wide stock per blood type
- Stock-staleness ranking (`DENSE_RANK()`) to flag hospitals with outdated inventory
### 3. `vw_CriticalStock` view
A single queryable view that flags any hospital/blood-type combination that's out of stock, low on stock, or has open high-urgency requests against it — the kind of view a real dashboard or alerting job would sit on top of.
 
### 4. `sp_ProcessDonation` stored procedure
Wraps a full donation event — logging the donation, updating the donor's eligibility date, incrementing hospital stock, and auto-fulfilling a matching pending request — in a single transaction with rollback on failure, so a mid-process error can't leave stock and history out of sync.
 
### 5. Indexing
Indexes added on the columns actually filtered or joined across the query set (`BloodType`, `HospitalID`, `RequestStatus` + `UrgencyLevel`, `DonorID`), with reasoning documented inline.
 
## 🚀 Setup & Run (MSSQL)
 
1. Install **SQL Server** (Express edition is free) and **SQL Server Management Studio (SSMS)**.
2. Open SSMS and connect to your local server instance.
3. Create a new database:
```sql
   CREATE DATABASE BloodBankRegistry;
   GO
   USE BloodBankRegistry;
   GO
```
4. Open `BBR_upgraded.sql` in SSMS and execute it top to bottom (or run it in sections — schema, seed data, then queries).
5. Try the highlight queries:
```sql
   -- Nearest hospital that currently stocks each donor's blood type
   -- (Section 6, query 31, in BBR_upgraded.sql)
 
   -- Critical stock dashboard view
   SELECT * FROM vw_CriticalStock WHERE StockStatus <> 'OK' ORDER BY OpenHighUrgencyRequests DESC;
 
   -- Process a donation end-to-end
   EXEC sp_ProcessDonation @DonorID = 3, @HospitalID = 3, @QuantityML = 450;
```
 
## 📂 Files
 
| File | Description |
|---|---|
| `BBR_upgraded.sql` | Full schema, indexes, seed data, 25 core queries, analytics queries, geospatial matching, view, and stored procedure |
 
## 🔭 Possible Extensions
 
- Port to PostgreSQL/MySQL for free cloud hosting demos (e.g. Supabase, Railway)
- Wrap in a REST API (FastAPI/Flask) so it can be queried from a live web demo
- Add a trigger to auto-flag `RequestStatus = 'Cancelled'` requests for cleanup after 1 year instead of running the DELETE manually
- Build a simple Streamlit/Power BI dashboard on top of `vw_CriticalStock`

## 👤 Author

**Jagadish Hugar**  
[![Portfolio](https://shields.io/badge/My_Portfolio-4285F4.svg?logo=mainwp&logoColor=white)](https://jagadishhugar.github.io/portfolio)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?logo=linkedin&logoColor=white)](https://linkedin.com/in/jagadishhugar) 
[![GitHub](https://img.shields.io/badge/GitHub-8A2BE2.svg?logo=GitHub&logoColor=white)](https://github.com/jagadishhugar)
 
