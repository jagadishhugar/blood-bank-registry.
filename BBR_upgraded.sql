
Bbr upgraded · SQL
/* ==========================================================
   EMERGENCY BLOOD BANK REGISTRY
   Upgraded schema + query set
   Dialect: T-SQL (SQL Server)
   ========================================================== */
 
-- ============================================================
-- SECTION 1: SCHEMA
-- ============================================================
 
CREATE TABLE Hospitals (
    HospitalID INT PRIMARY KEY IDENTITY(1,1),
    HospitalName VARCHAR(100) NOT NULL,
    Latitude DECIMAL(9,6) NOT NULL,
    Longitude DECIMAL(9,6) NOT NULL,
    EmergencyContact VARCHAR(15) NOT NULL
);
 
CREATE TABLE Donors (
    DonorID INT PRIMARY KEY IDENTITY(1,1),
    DonorName VARCHAR(100) NOT NULL,
    BloodType VARCHAR(3) CHECK (BloodType IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    LastDonatedDate DATE NULL,
    Latitude DECIMAL(9,6) NOT NULL,
    Longitude DECIMAL(9,6) NOT NULL,
    ContactNumber VARCHAR(15)
);
 
CREATE TABLE BloodStock (
    StockID INT PRIMARY KEY IDENTITY(1,1),
    HospitalID INT FOREIGN KEY REFERENCES Hospitals(HospitalID),
    BloodType VARCHAR(3) CHECK (BloodType IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    UnitsAvailable INT DEFAULT 0,
    LastUpdated DATETIME DEFAULT GETDATE()
);
 
CREATE TABLE BloodRequests (
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    HospitalID INT FOREIGN KEY REFERENCES Hospitals(HospitalID),
    RequiredType VARCHAR(3),
    UrgencyLevel INT CHECK (UrgencyLevel BETWEEN 1 AND 5),
    RequestStatus VARCHAR(20) DEFAULT 'Pending',
    RequestDate DATETIME DEFAULT GETDATE()
);
 
CREATE TABLE DonationHistory (
    DonationID INT PRIMARY KEY IDENTITY(1,1),
    DonorID INT FOREIGN KEY REFERENCES Donors(DonorID),
    HospitalID INT FOREIGN KEY REFERENCES Hospitals(HospitalID),
    DonationDate DATE DEFAULT GETDATE(),
    QuantityML INT DEFAULT 450
);
 
-- ============================================================
-- SECTION 2: INDEXES
-- Added on columns that are filtered/joined on most often across
-- the query set below. Without these, every BloodType lookup and
-- every Donor/Hospital join in DonationHistory does a full scan.
-- ============================================================
 
CREATE INDEX IX_BloodStock_BloodType ON BloodStock(BloodType);
CREATE INDEX IX_BloodStock_HospitalID ON BloodStock(HospitalID);
CREATE INDEX IX_Donors_BloodType ON Donors(BloodType);
CREATE INDEX IX_BloodRequests_Status_Urgency ON BloodRequests(RequestStatus, UrgencyLevel);
CREATE INDEX IX_DonationHistory_DonorID ON DonationHistory(DonorID);
CREATE INDEX IX_DonationHistory_HospitalID ON DonationHistory(HospitalID);
 
-- ============================================================
-- SECTION 3: SEED DATA
-- ============================================================
 
INSERT INTO Hospitals (HospitalName, Latitude, Longitude, EmergencyContact) VALUES
('City Central Hospital', 12.9716, 77.5946, '080-11112222'),
('St. Marys Trauma Care', 12.9352, 77.6245, '080-33334444'),
('Metro General Clinic', 13.0827, 80.2707, '044-55556666'),
('Sunrise Specialty Center', 19.0760, 72.8777, '022-77778888'),
('Apollo Life Hospital', 17.3850, 78.4867, '040-99990000'),
('Red Cross Medical', 28.6139, 77.2090, '011-12123434'),
('Global Health Institute', 22.5726, 88.3639, '033-56567878'),
('Unity Childrens Hospital', 13.0350, 77.5970, '080-23234545'),
('Care First Medical', 18.5204, 73.8567, '020-67678989'),
('Nightingale Nursing Home', 12.9141, 74.8560, '082-45456767');
 
INSERT INTO Donors (DonorName, BloodType, LastDonatedDate, Latitude, Longitude, ContactNumber) VALUES
('Arjun Mehta', 'O+', '2025-12-10', 12.9710, 77.5940, '9900112233'),
('Sarah Williams', 'O-', '2026-01-05', 12.9350, 77.6240, '9845012345'),
('Ravi Kumar', 'A+', NULL, 13.0800, 80.2700, '9740123456'),
('Priya Sharma', 'B-', '2025-08-20', 19.0750, 72.8770, '9632012345'),
('John Doe', 'AB+', '2026-02-14', 17.3800, 78.4800, '9521012345'),
('Anita Desai', 'A-', '2025-11-25', 28.6130, 77.2080, '9410012345'),
('Michael Ross', 'B+', '2025-10-30', 22.5700, 88.3600, '9300012345'),
('Sneha Reddy', 'O+', NULL, 13.0300, 77.5950, '9200012345'),
('Vikram Singh', 'AB-', '2026-03-01', 18.5200, 73.8560, '9100012345'),
('David Miller', 'O-', '2025-09-15', 12.9100, 74.8550, '9000012345');
 
INSERT INTO BloodStock (HospitalID, BloodType, UnitsAvailable) VALUES
(1, 'O+', 15), (1, 'O-', 2), (2, 'A+', 8), (3, 'B-', 4),
(4, 'AB+', 10), (5, 'A-', 3), (6, 'B+', 12), (7, 'O+', 20),
(8, 'AB-', 1), (9, 'O-', 0);
 
INSERT INTO BloodRequests (HospitalID, RequiredType, UrgencyLevel, RequestStatus) VALUES
(1, 'O-', 5, 'Pending'),
(3, 'A+', 3, 'Fulfilled'),
(2, 'O+', 4, 'Pending'),
(5, 'B-', 5, 'Pending'),
(6, 'AB+', 2, 'Pending'),
(4, 'A-', 1, 'Cancelled'),
(8, 'B+', 4, 'Pending'),
(10, 'O-', 5, 'Pending'),
(7, 'AB-', 3, 'Fulfilled'),
(9, 'O+', 5, 'Pending');
 
INSERT INTO DonationHistory (DonorID, HospitalID, DonationDate, QuantityML) VALUES
(1, 1, '2025-12-10', 450),
(2, 2, '2026-01-05', 450),
(4, 4, '2025-08-20', 350),
(5, 5, '2026-02-14', 450),
(6, 6, '2025-11-25', 450),
(7, 7, '2025-10-30', 400),
(9, 9, '2026-03-01', 450),
(10, 10, '2025-09-15', 450),
(1, 8, '2025-05-10', 450),
(2, 1, '2025-04-12', 450);
 
-- ============================================================
-- SECTION 4: CORE QUERIES (originals, kept as the "fundamentals" layer)
-- ============================================================
 
-- 1. List all hospitals and their emergency contacts
SELECT HospitalName, EmergencyContact FROM Hospitals;
 
-- 2. Find all donors with the 'O-' universal blood type
SELECT DonorName, ContactNumber FROM Donors WHERE BloodType = 'O-';
 
-- 3. Check current stock levels for all blood types at 'City Central Hospital'
SELECT BloodType, UnitsAvailable FROM BloodStock
WHERE HospitalID = (SELECT HospitalID FROM Hospitals WHERE HospitalName = 'City Central Hospital');
 
-- 4. List all donors who have never donated before (LastDonatedDate is NULL)
SELECT DonorName FROM Donors WHERE LastDonatedDate IS NULL;
 
-- 5. Show all 'Pending' blood requests with an Urgency Level of 5
SELECT * FROM BloodRequests WHERE RequestStatus = 'Pending' AND UrgencyLevel = 5;
 
-- 6. Find hospitals that currently have zero units of 'O-' blood
SELECT HospitalName FROM Hospitals H
JOIN BloodStock S ON H.HospitalID = S.HospitalID
WHERE S.BloodType = 'O-' AND S.UnitsAvailable = 0;
 
-- 7. Count how many donors are available for each blood type
SELECT BloodType, COUNT(*) AS DonorCount FROM Donors GROUP BY BloodType;
 
-- 8. List donors who are medically eligible (haven't donated in the last 90 days)
SELECT DonorName, BloodType FROM Donors
WHERE LastDonatedDate IS NULL OR DATEDIFF(DAY, LastDonatedDate, GETDATE()) > 90;
 
-- 9. Find donors located in the same city area (latitude/longitude range) as Hospital ID 1
SELECT DonorName FROM Donors
WHERE Latitude BETWEEN 12.9 AND 13.0 AND Longitude BETWEEN 77.5 AND 77.6;
 
-- 10. Show total units of blood available across all hospitals combined
SELECT SUM(UnitsAvailable) AS GlobalStock FROM BloodStock;
 
-- 11. Retrieve the donation history for a specific donor (e.g., 'Arjun Mehta')
SELECT DonationDate, QuantityML FROM DonationHistory
WHERE DonorID = (SELECT DonorID FROM Donors WHERE DonorName = 'Arjun Mehta');
 
-- 12. Calculate the total volume of blood (ML) collected in the year 2025
SELECT SUM(QuantityML) FROM DonationHistory WHERE YEAR(DonationDate) = 2025;
 
-- 13. Find the hospital that has received the most donations
SELECT TOP 1 HospitalName, COUNT(DonationID) AS TotalDonations
FROM Hospitals H JOIN DonationHistory DH ON H.HospitalID = DH.HospitalID
GROUP BY HospitalName ORDER BY TotalDonations DESC;
 
-- 14. List requests that were 'Fulfilled' in the last 30 days
SELECT * FROM BloodRequests WHERE RequestStatus = 'Fulfilled'
AND DATEDIFF(DAY, RequestDate, GETDATE()) <= 30;
 
-- 15. Identify the most requested blood type
SELECT TOP 1 RequiredType, COUNT(*) AS RequestCount
FROM BloodRequests GROUP BY RequiredType ORDER BY RequestCount DESC;
 
-- 16. Show donor name, blood type, and the name of the hospital where they last donated
SELECT D.DonorName, D.BloodType, H.HospitalName, DH.DonationDate
FROM Donors D
JOIN DonationHistory DH ON D.DonorID = DH.DonorID
JOIN Hospitals H ON DH.HospitalID = H.HospitalID;
 
-- 17. Find hospitals that have more than 10 units of ANY blood type
SELECT DISTINCT HospitalName FROM Hospitals H
JOIN BloodStock S ON H.HospitalID = S.HospitalID
WHERE S.UnitsAvailable > 10;
 
-- 18. Calculate the average quantity of blood per donation
SELECT AVG(QuantityML) AS AvgDonation FROM DonationHistory;
 
-- 19. List donors who have donated more than once
SELECT DonorName FROM Donors D
JOIN DonationHistory DH ON D.DonorID = DH.DonorID
GROUP BY DonorName HAVING COUNT(DonationID) > 1;
 
-- 20. Show the total units of blood available per blood type across the entire network
SELECT BloodType, SUM(UnitsAvailable) AS TotalUnits FROM BloodStock GROUP BY BloodType;
 
-- 21. Identify donors who will become eligible to donate in the next 7 days
SELECT DonorName, DATEADD(DAY, 90, LastDonatedDate) AS NextEligibilityDate
FROM Donors WHERE DATEDIFF(DAY, LastDonatedDate, GETDATE()) BETWEEN 83 AND 90;
 
-- 22. Update stock: Increase 'A+' units by 5 for Hospital ID 2
UPDATE BloodStock SET UnitsAvailable = UnitsAvailable + 5
WHERE HospitalID = 2 AND BloodType = 'A+';
 
-- 23. List hospitals that have NOT placed any blood requests yet
SELECT HospitalName FROM Hospitals
WHERE HospitalID NOT IN (SELECT DISTINCT HospitalID FROM BloodRequests);
 
-- 24. Find the donor who donated most recently
SELECT TOP 1 DonorName, LastDonatedDate FROM Donors
WHERE LastDonatedDate IS NOT NULL ORDER BY LastDonatedDate DESC;
 
-- 25. Delete 'Cancelled' requests older than 1 year to clean up the database
DELETE FROM BloodRequests WHERE RequestStatus = 'Cancelled'
AND DATEDIFF(YEAR, RequestDate, GETDATE()) >= 1;
 
 
-- ============================================================
-- SECTION 5: WINDOW FUNCTIONS & CTEs (the "analytics" layer)
-- ============================================================
 
-- 26. Rank donors by total donation count (ties share a rank)
;WITH DonorTotals AS (
    SELECT D.DonorID, D.DonorName, D.BloodType, COUNT(DH.DonationID) AS DonationCount
    FROM Donors D
    LEFT JOIN DonationHistory DH ON D.DonorID = DH.DonorID
    GROUP BY D.DonorID, D.DonorName, D.BloodType
)
SELECT DonorName, BloodType, DonationCount,
       RANK() OVER (ORDER BY DonationCount DESC) AS DonationRank
FROM DonorTotals;
 
-- 27. Running monthly total of blood volume collected (ML), network-wide
;WITH MonthlyTotals AS (
    SELECT
        DATEFROMPARTS(YEAR(DonationDate), MONTH(DonationDate), 1) AS DonationMonth,
        SUM(QuantityML) AS MonthlyML
    FROM DonationHistory
    GROUP BY DATEFROMPARTS(YEAR(DonationDate), MONTH(DonationDate), 1)
)
SELECT DonationMonth, MonthlyML,
       SUM(MonthlyML) OVER (ORDER BY DonationMonth ROWS UNBOUNDED PRECEDING) AS RunningTotalML
FROM MonthlyTotals
ORDER BY DonationMonth;
 
-- 28. Most recent donation per donor, without a self-join (ROW_NUMBER)
;WITH RankedDonations AS (
    SELECT DH.DonorID, DH.DonationDate, DH.QuantityML, DH.HospitalID,
           ROW_NUMBER() OVER (PARTITION BY DH.DonorID ORDER BY DH.DonationDate DESC) AS rn
    FROM DonationHistory DH
)
SELECT D.DonorName, RD.DonationDate, RD.QuantityML, H.HospitalName
FROM RankedDonations RD
JOIN Donors D ON D.DonorID = RD.DonorID
JOIN Hospitals H ON H.HospitalID = RD.HospitalID
WHERE RD.rn = 1;
 
-- 29. Percentage of network-wide stock each hospital holds, per blood type
SELECT H.HospitalName, S.BloodType, S.UnitsAvailable,
       SUM(S.UnitsAvailable) OVER (PARTITION BY S.BloodType) AS TypeTotal,
       CAST(100.0 * S.UnitsAvailable / NULLIF(SUM(S.UnitsAvailable) OVER (PARTITION BY S.BloodType), 0) AS DECIMAL(5,2)) AS PctOfTypeStock
FROM BloodStock S
JOIN Hospitals H ON H.HospitalID = S.HospitalID
ORDER BY S.BloodType, PctOfTypeStock DESC;
 
-- 30. Days since each hospital's last stock update, ranked oldest-first
SELECT HospitalName, BloodType, LastUpdated,
       DATEDIFF(DAY, LastUpdated, GETDATE()) AS DaysSinceUpdate,
       DENSE_RANK() OVER (ORDER BY LastUpdated ASC) AS StalenessRank
FROM BloodStock S
JOIN Hospitals H ON H.HospitalID = S.HospitalID;
 
 
-- ============================================================
-- SECTION 6: GEOSPATIAL — NEAREST HOSPITAL PER DONOR
-- Uses the Haversine formula to compute great-circle distance (km)
-- between each donor and every hospital, then picks the closest.
-- This is the highest-value query in the project: it turns
-- otherwise-decorative lat/long columns into something that
-- actually powers a "find your nearest donation point" feature.
-- ============================================================
 
;WITH DonorHospitalDistance AS (
    SELECT
        D.DonorID,
        D.DonorName,
        D.BloodType,
        H.HospitalID,
        H.HospitalName,
        6371 * ACOS(
            CASE
                WHEN D.DonorID = D.DonorID THEN
                    ROUND(
                        CAST(
                            COS(RADIANS(D.Latitude)) * COS(RADIANS(H.Latitude))
                            * COS(RADIANS(H.Longitude) - RADIANS(D.Longitude))
                            + SIN(RADIANS(D.Latitude)) * SIN(RADIANS(H.Latitude))
                        AS DECIMAL(18,15)), 15)
            END
        ) AS DistanceKM
    FROM Donors D
    CROSS JOIN Hospitals H
),
RankedDistances AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY DonorID ORDER BY DistanceKM ASC) AS rn
    FROM DonorHospitalDistance
)
SELECT DonorName, BloodType, HospitalName, ROUND(DistanceKM, 2) AS NearestHospitalKM
FROM RankedDistances
WHERE rn = 1
ORDER BY NearestHospitalKM ASC;
 
-- 31. Variant: nearest hospital that also currently stocks the donor's blood type
;WITH DonorHospitalDistance AS (
    SELECT
        D.DonorID, D.DonorName, D.BloodType,
        H.HospitalID, H.HospitalName,
        6371 * ACOS(
            ROUND(
                CAST(
                    COS(RADIANS(D.Latitude)) * COS(RADIANS(H.Latitude))
                    * COS(RADIANS(H.Longitude) - RADIANS(D.Longitude))
                    + SIN(RADIANS(D.Latitude)) * SIN(RADIANS(H.Latitude))
                AS DECIMAL(18,15)), 15)
        ) AS DistanceKM
    FROM Donors D
    CROSS JOIN Hospitals H
),
Eligible AS (
    SELECT DHD.*, S.UnitsAvailable,
           ROW_NUMBER() OVER (PARTITION BY DHD.DonorID ORDER BY DHD.DistanceKM ASC) AS rn
    FROM DonorHospitalDistance DHD
    JOIN BloodStock S
        ON S.HospitalID = DHD.HospitalID AND S.BloodType = DHD.BloodType
)
SELECT DonorName, BloodType, HospitalName, UnitsAvailable, ROUND(DistanceKM, 2) AS DistanceKM
FROM Eligible
WHERE rn = 1
ORDER BY DistanceKM ASC;
 
 
-- ============================================================
-- SECTION 7: VIEW — CRITICAL STOCK MONITOR
-- Surfaces any hospital/blood-type combo that's running low
-- (< 5 units) or has an unfulfilled high-urgency request against it.
-- A dashboard or alerting job would query this view directly
-- instead of re-deriving the logic every time.
-- ============================================================
 
CREATE VIEW vw_CriticalStock AS
SELECT
    H.HospitalName,
    S.BloodType,
    S.UnitsAvailable,
    CASE
        WHEN S.UnitsAvailable = 0 THEN 'OUT OF STOCK'
        WHEN S.UnitsAvailable < 5 THEN 'LOW STOCK'
        ELSE 'OK'
    END AS StockStatus,
    (SELECT COUNT(*) FROM BloodRequests R
     WHERE R.HospitalID = H.HospitalID
       AND R.RequiredType = S.BloodType
       AND R.RequestStatus = 'Pending'
       AND R.UrgencyLevel >= 4) AS OpenHighUrgencyRequests
FROM BloodStock S
JOIN Hospitals H ON H.HospitalID = S.HospitalID;
 
-- Usage:
-- SELECT * FROM vw_CriticalStock WHERE StockStatus <> 'OK' ORDER BY OpenHighUrgencyRequests DESC;
 
 
-- ============================================================
-- SECTION 8: TRANSACTION — RECORD A DONATION END-TO-END
-- Wraps three dependent writes (log donation, increase stock,
-- close out a matching pending request) in a single transaction
-- so a failure partway through can't leave stock and history
-- out of sync.
-- ============================================================
 
CREATE PROCEDURE sp_ProcessDonation
    @DonorID INT,
    @HospitalID INT,
    @QuantityML INT = 450
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @BloodType VARCHAR(3);
    SELECT @BloodType = BloodType FROM Donors WHERE DonorID = @DonorID;
 
    IF @BloodType IS NULL
    BEGIN
        RAISERROR('Donor not found.', 16, 1);
        RETURN;
    END
 
    BEGIN TRY
        BEGIN TRANSACTION;
 
        -- 1. Log the donation
        INSERT INTO DonationHistory (DonorID, HospitalID, DonationDate, QuantityML)
        VALUES (@DonorID, @HospitalID, GETDATE(), @QuantityML);
 
        -- 2. Update donor's last donated date
        UPDATE Donors SET LastDonatedDate = GETDATE() WHERE DonorID = @DonorID;
 
        -- 3. Increase blood stock at the receiving hospital
        --    (units credited as whole 450ml-equivalent donations)
        IF EXISTS (SELECT 1 FROM BloodStock WHERE HospitalID = @HospitalID AND BloodType = @BloodType)
            UPDATE BloodStock
            SET UnitsAvailable = UnitsAvailable + 1, LastUpdated = GETDATE()
            WHERE HospitalID = @HospitalID AND BloodType = @BloodType;
        ELSE
            INSERT INTO BloodStock (HospitalID, BloodType, UnitsAvailable, LastUpdated)
            VALUES (@HospitalID, @BloodType, 1, GETDATE());
 
        -- 4. Auto-fulfill the oldest matching pending request at this hospital, if any
        UPDATE TOP (1) BloodRequests
        SET RequestStatus = 'Fulfilled'
        WHERE HospitalID = @HospitalID
          AND RequiredType = @BloodType
          AND RequestStatus = 'Pending';
 
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
 
-- Usage example:
-- EXEC sp_ProcessDonation @DonorID = 3, @HospitalID = 3, @QuantityML = 450;
 
