
-- The project creates a comprehensive system for an insurance company to record the various activities performed by their business
-- The system eliminates the need for manual calculations and provides quick and easy access to data, which can then be manipulated
-- It caters to a variety of stakeholders such as customers, agents, and management

-- The SQL script contains a variety of create table statements, as well as indices and constraints which
-- define relationships between the fields in multiple tables. 

USE Insurance

-- The Customer table records identifying information for every customer
-- It uses the customer ID as its primary key

CREATE TABLE Customer (
    Customer_ID VARCHAR(10) NOT NULL PRIMARY KEY, 
    First_Name VARCHAR(20) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL, 
    Gender VARCHAR(10) NULL,
    Address VARCHAR(50) NOT NULL,
    City VARCHAR(20) NOT NULL,
    Country VARCHAR(20) NOT NULL,
    Phone VARCHAR(20) NOT NULL, -- Format: +1-1234567890
    Email VARCHAR(50) NULL,
    Marital_Status BIT NOT NULL -- 1: Married, 0: Single
);


-- The Incident table holds the total list of incidents that have occurred
-- Uses the incident_ID as its primary key
CREATE TABLE Incident (
    Incident_ID VARCHAR(10) NOT NULL PRIMARY KEY, 
    Type VARCHAR(20) NOT NULL,
    Date DATE NOT NULL, 
    Description VARCHAR(255) NOT NULL
);

-- This table contains a list of the incident reports filed by agents
-- It uses the Report_ID as its primary key but also obtains the incident_ID and customer_ID
-- from the Incident and Customer Tables respectively
-- This is to account for the fact that multiple customers could have filed a report for the same incident

CREATE TABLE Incident_Report (
    Report_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Incident_ID VARCHAR(10) NOT NULL,
    Customer_ID VARCHAR(10) NOT NULL,
    Inspector_Name VARCHAR(50) NULL, -- More inspector info can be found in the staff table
    Estimated_Cost FLOAT NULL,
    Description VARCHAR(255) NULL,
    CONSTRAINT fk_ir1 FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    CONSTRAINT fk_ir2 FOREIGN KEY (Incident_ID) REFERENCES Incident(Incident_ID)
);

-- The table contains the information for the associated companies
-- Uses the company_ID as its primary key
CREATE TABLE Company (
    Company_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Contact_Number VARCHAR(20) NOT NULL,
    Email VARCHAR(50) NULL,
    Website VARCHAR(50) NULL,
    Address VARCHAR(50) NOT NULL,
    City VARCHAR(20) NOT NULL,
    Country VARCHAR(20) NOT NULL
);

-- Lists the variety of departments within these companies and their contact info
-- The primary key is both the department and company ID in this case because the company oversees the departments
-- Appropriate reference to the company table to obtain the Company ID
CREATE TABLE Department (
    Department_ID VARCHAR(10) NOT NULL,
    Company_ID VARCHAR(10) NOT NULL,
    Name VARCHAR(50) NOT NULL,
    Staff_Count INTEGER NULL,
    Office_Count INTEGER NULL,
    PRIMARY KEY (Department_ID, Company_ID),
    CONSTRAINT fk_department FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID)
);

-- This table contains the information for Vehicle Service companies specifically,
-- Uses the service ID as its primary key but references the Department table to obtain the Department_ID
CREATE TABLE Vehicle_Service (
    Service_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Department_ID VARCHAR(10) NOT NULL,
	Company_ID VARCHAR(10) NOT NULL,
    Name VARCHAR(50) NOT NULL,
    Address VARCHAR(50) NULL,
    Contact VARCHAR(20) NOT NULL,
    Service_Type VARCHAR(20) NULL, 
    CONSTRAINT fk_vs FOREIGN KEY (Department_ID, Company_ID) REFERENCES Department (Department_ID, Company_ID)
);

-- A table associating every vehicle in the system to the customer that owns it
-- Also includes identifying information about the vehicle
-- Uses the Vehicle ID as its primary key but obtains the customer ID from the Customer table.
CREATE TABLE Vehicle (
    Vehicle_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Customer_ID VARCHAR(10) NOT NULL,
    Registration_Number VARCHAR(20) NOT NULL,
    Value INTEGER NULL, 
    Type VARCHAR(20) NULL,
    Make VARCHAR(20) NULL,
    Model VARCHAR(20) NULL,
    Engine_Number VARCHAR(50) NULL,
    Chassis_Number VARCHAR(50) NULL,
    CONSTRAINT fk_vehicle FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- This table contains all applications for potential claims, with the Application ID as the primary key
-- Also references the Customer and Vehicle tables for the IDs.
CREATE TABLE Application (
    Application_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Customer_ID VARCHAR(10) NOT NULL, 
    Vehicle_ID VARCHAR(10) NOT NULL,
    Status VARCHAR(10) NOT NULL,		-- Pending, Issued, Expired, etc.
    Coverage_Description VARCHAR(100) NOT NULL,
    CONSTRAINT fk_application1 FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    CONSTRAINT fk_application2 FOREIGN KEY (Vehicle_ID) REFERENCES Vehicle(Vehicle_ID)
);

-- A table with all the policies that have been issued
-- For the terms, a link can be provided to a separate interface which displays the entire policy
-- References the application table to obtain the ID
CREATE TABLE Policy (
    Policy_Number VARCHAR(20) NOT NULL PRIMARY KEY,
    Application_ID VARCHAR(10) NOT NULL,
    Start_Date DATE NOT NULL,
    Expiry_Date DATE NOT NULL,
    Terms VARCHAR(255) NULL,
    CONSTRAINT fk_policy FOREIGN KEY (Application_ID) REFERENCES Application(Application_ID)
);

-- Contains a record of all the payments received by the firm in regards to a specific policy
-- References the policy table to obtain the policy number
CREATE TABLE Premium_Payment (
    Payment_ID VARCHAR(10) NOT NULL PRIMARY KEY, 
    Policy_Number VARCHAR(20) NOT NULL, 
    Amount FLOAT NOT NULL,
    Payment_Date DATE NOT NULL,
    Receipt_ID VARCHAR(20) NOT NULL UNIQUE,
    CONSTRAINT fk_pp FOREIGN KEY (Policy_Number) REFERENCES Policy(Policy_Number)
);

-- Contains all claims by customers
-- Accesses the Policy and Incident tables to obtain the respective IDs
CREATE TABLE Claim (
    Claim_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Policy_Number VARCHAR(20) NOT NULL,
    Amount FLOAT NOT NULL,
    Incident_ID VARCHAR(10) NOT NULL,
    Damage_Type VARCHAR(20) NOT NULL,
    Date DATE NOT NULL,
    Status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_claim1 FOREIGN KEY (Policy_Number) REFERENCES Policy(Policy_Number),
    CONSTRAINT fk_claim2 FOREIGN KEY (Incident_ID) REFERENCES Incident(Incident_ID)
);

-- Looks at the claims that have been settled and how much has been paid
-- References the claim ID from the Claim table. 
CREATE TABLE Claim_Settlement (
    Settlement_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Claim_ID VARCHAR(10) NOT NULL,
    Amount_Paid FLOAT NOT NULL,
    Settlement_Date DATE NOT NULL,
    CONSTRAINT fk_cs FOREIGN KEY (Claim_ID) REFERENCES Claim(Claim_ID)
);

-- Contains risk assessments for each customer based on a variety of factors
-- Retrieves the customer ID from the customer table
CREATE TABLE Risk_Assessment (
    Assessment_ID VARCHAR(10) PRIMARY KEY,
    Customer_ID VARCHAR(10),
    Age INT,
    Health_Status VARCHAR(100),
    Risk_Level VARCHAR(20), -- Can be calculated through a combination of information obtained from other tables such as vehicle info
    Premium_Multiplier DECIMAL(5, 2),
    CONSTRAINT fk_ra FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID)
);

-- Basic revenue and expenses table which can be further expanded upon
CREATE TABLE Revenue_Expenses (
    Month VARCHAR(20),
    Revenue DECIMAL(15, 2),
    Claims_paid DECIMAL(15, 2),
    Expenses DECIMAL(15, 2),
    Profit DECIMAL(15, 2)
);

-- Helps divide customers by segment, which can then be further added on
-- Calculations can then be done (e.g. the relationship between smokers and car accidents, if it exists)
CREATE TABLE Customer_Segmentation (
    Segment_ID VARCHAR(10) PRIMARY KEY,
    Segment_Name VARCHAR(50),
    Age_Range VARCHAR(20),
    Average_Income DECIMAL(15, 2),
    Risk_Level VARCHAR(20),
    Claim_Frequency VARCHAR(20)
);

-- If reinsurance is pursued for a policy/group of policies, this table stores that information as well
-- References the policy ID from the Policy table
CREATE TABLE Reinsurance_Info (
    Reinsurance_ID VARCHAR(10) PRIMARY KEY,
    Policy_Number VARCHAR(20),
    Reinsurer_Name VARCHAR(100),
    Reinsurance_Type VARCHAR(50),
    Coverage_Limit DECIMAL(15, 2),
    Deductible DECIMAL(15, 2),
    CONSTRAINT fk_reinsurance FOREIGN KEY (Policy_Number) REFERENCES Policy(Policy_Number)
);


-- Customer Feedback table
-- Obtains the customer_ID from the Customer table.
CREATE TABLE Feedback_Info (
    Feedback_ID VARCHAR(10) PRIMARY KEY,
    Customer_ID VARCHAR(10),
    Feedback_Type VARCHAR(50),
    Rating INT,
    Feedback_Text TEXT,
    Feedback_Date DATE,
    CONSTRAINT fk_feedback FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID)
);


CREATE TABLE Staff (
	Staff_ID VARCHAR(10) NOT NULL PRIMARY KEY,
	Company_ID VARCHAR(10) NOT NULL,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
	Address VARCHAR(50) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    Contact_Number VARCHAR(15),
    Email VARCHAR(100)
	CONSTRAINT fk_staff FOREIGN KEY (Company_ID) REFERENCES Company (Company_ID)
);

ALTER TABLE Staff
ADD Password VARCHAR(20) NOT NULL;

CREATE TABLE Audit_Log (
    Log_ID VARCHAR(10) PRIMARY KEY,
    Table_Name VARCHAR(50) NOT NULL,
    Operation_Type VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    Changed_By VARCHAR(50) NOT NULL,
    Change_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Original_Data TEXT,
    New_Data TEXT
);



INSERT INTO Customer (Customer_ID, First_Name, Last_Name, DOB, Gender, Address, City, Country, Phone, Email, Marital_Status) VALUES
('CUST0001', 'John', 'Doe', '1980-01-01', 'Male', '123 Elm St', 'Springfield', 'USA', '+1-1234567890', 'john.doe@example.com', 1),
('CUST0002', 'Jane', 'Smith', '1990-02-15', 'Female', '456 Maple Rd', 'Rivertown', 'USA', '+1-9876543210', 'jane.smith@example.com', 0),
('CUST0003', 'Michael', 'Brown', '1975-03-20', 'Male', '789 Oak Ln', 'Hillview', 'USA', '+1-5556667777', NULL, 1),
('CUST0004', 'Emily', 'White', '1985-04-10', 'Female', '321 Pine St', 'Lakeside', 'USA', '+1-4443332222', 'emily.white@example.com', 0),
('CUST0005', 'David', 'Clark', '1995-05-30', 'Male', '654 Cedar Dr', 'Baytown', 'USA', '+1-9998887777', NULL, 1),
('CUST0006', 'Sophia', 'Wilson', '2000-06-25', 'Female', '987 Birch Ave', 'Sunnyvale', 'USA', '+1-1112223333', 'sophia.wilson@example.com', 0),
('CUST0007', 'Liam', 'Davis', '1992-07-15', 'Male', '159 Spruce Way', 'Meadowville', 'USA', '+1-2224445555', 'liam.davis@example.com', 1),
('CUST0008', 'Olivia', 'Martinez', '1988-08-05', 'Female', '753 Willow Ct', 'Crestwood', 'USA', '+1-3335556666', NULL, 1),
('CUST0009', 'Ethan', 'Garcia', '1997-09-12', 'Male', '852 Redwood Pl', 'Bridgeport', 'USA', '+1-4446667777', 'ethan.garcia@example.com', 0),
('CUST0010', 'Ava', 'Anderson', '1982-10-20', 'Female', '963 Aspen Blvd', 'Greendale', 'USA', '+1-5557778888', NULL, 1);


INSERT INTO Incident (Incident_ID, Type, Date, Description) VALUES
('INC0001', 'Fire', '2024-01-01', 'House fire in residential area'),
('INC0002', 'Theft', '2024-02-10', 'Burglary at office building'),
('INC0003', 'Flood', '2024-03-15', 'Flooding due to heavy rain'),
('INC0004', 'Accident', '2024-04-20', 'Car collision on highway'),
('INC0005', 'Vandalism', '2024-05-25', 'Graffiti on commercial property'),
('INC0006', 'Hail', '2024-06-30', 'Hail damage to vehicles'),
('INC0007', 'Earthquake', '2024-07-15', 'Structural damage to buildings'),
('INC0008', 'Fire', '2024-08-10', 'Forest fire affecting nearby homes'),
('INC0009', 'Theft', '2024-09-05', 'Robbery at jewelry store'),
('INC0010', 'Flood', '2024-10-20', 'River overflow caused by storm');


INSERT INTO Incident_Report (Report_ID, Incident_ID, Customer_ID, Inspector_Name, Estimated_Cost, Description) VALUES
('IR0001', 'INC0001', 'CUST0001', 'Inspector A', 15000.00, 'Fire damage to kitchen and living room'),
('IR0002', 'INC0002', 'CUST0002', 'Inspector B', 3000.00, 'Theft of electronics and valuables'),
('IR0003', 'INC0003', 'CUST0003', NULL, 8000.00, 'Flooded basement and damaged furniture'),
('IR0004', 'INC0004', 'CUST0004', 'Inspector C', 12000.00, 'Collision damage to both cars'),
('IR0005', 'INC0005', 'CUST0005', 'Inspector D', 2000.00, 'Vandalism to storefront'),
('IR0006', 'INC0006', 'CUST0006', 'Inspector E', 5000.00, 'Hail damage to roof and windows'),
('IR0007', 'INC0007', 'CUST0007', NULL, 30000.00, 'Earthquake structural damage'),
('IR0008', 'INC0008', 'CUST0008', 'Inspector F', 25000.00, 'Forest fire damage to backyard and garage'),
('IR0009', 'INC0009', 'CUST0009', 'Inspector G', 1500.00, 'Theft of cash and jewelry'),
('IR0010', 'INC0010', 'CUST0010', NULL, 7000.00, 'Flooding of first floor of house');


INSERT INTO Company (Company_ID, Name, Contact_Number, Email, Website, Address, City, Country) VALUES
('COMP001', 'Global Insurance Co.', '+1-1112223333', 'info@globalins.com', 'www.globalins.com', '123 Corporate Blvd', 'Springfield', 'USA'),
('COMP002', 'Secure Shield Ltd.', '+1-4445556666', 'support@secureshield.com', 'www.secureshield.com', '456 Business Rd', 'Rivertown', 'USA'),
('COMP003', 'Prime Coverage Inc.', '+1-7778889999', NULL, 'www.primecoverage.com', '789 Enterprise Ave', 'Hillview', 'USA'),
('COMP004', 'Trust Assure LLC', '+1-1234567890', 'contact@trustassure.com', NULL, '321 Market St', 'Lakeside', 'USA'),
('COMP005', 'SafeGuard Solutions', '+1-9876543210', 'info@safeguard.com', 'www.safeguard.com', '654 Commerce Dr', 'Baytown', 'USA'),
('COMP006', 'Elite Risk Group', '+1-2223334444', 'support@eliterisk.com', 'www.eliterisk.com', '987 Innovation Ln', 'Sunnyvale', 'USA'),
('COMP007', 'Pinnacle Protection', '+1-5556667777', NULL, NULL, '159 Venture Way', 'Meadowville', 'USA'),
('COMP008', 'Fortress Assurance', '+1-3334445555', 'info@fortress.com', 'www.fortress.com', '753 Strategy Ct', 'Crestwood', 'USA'),
('COMP009', 'Integrity Insure', '+1-4445556666', 'contact@integrityinsure.com', NULL, '852 Reliability Rd', 'Bridgeport', 'USA'),
('COMP010', 'Unity Coverage', '+1-1112223333', NULL, 'www.unitycoverage.com', '963 Harmony Blvd', 'Greendale', 'USA');


INSERT INTO Department (Department_ID, Company_ID, Name, Staff_Count, Office_Count) VALUES
('DEP001', 'COMP001', 'Claims', 50, 5),
('DEP002', 'COMP001', 'Underwriting', 30, 3),
('DEP003', 'COMP002', 'Customer Service', 40, 4),
('DEP004', 'COMP003', 'IT Support', 25, 2),
('DEP005', 'COMP004', 'Policy Administration', 35, 3),
('DEP006', 'COMP005', 'Risk Assessment', 20, 2),
('DEP007', 'COMP006', 'Actuarial', 15, 1),
('DEP008', 'COMP007', 'Sales', 60, 6),
('DEP009', 'COMP008', 'Marketing', 10, 1),
('DEP010', 'COMP009', 'Compliance', 12, 2);


INSERT INTO Vehicle_Service (Service_ID, Department_ID, Company_ID, Name, Address, Contact, Service_Type) VALUES
('VS001', 'DEP001', 'COMP001', 'AutoFix Garage', '123 Mechanic Ln', '+1-1113334444', 'Repair'),
('VS002', 'DEP003', 'COMP002', 'Rapid Repairs', '456 Workshop Rd', '+1-2224445555', 'Maintenance'),
('VS003', 'DEP004', 'COMP003', 'CarCare Center', '789 Service Blvd', '+1-3335556666', 'Repair'),
('VS004', 'DEP005', 'COMP004', 'QuickFix Motors', '321 Auto St', '+1-4446667777', 'Inspection'),
('VS005', 'DEP006', 'COMP005', 'SafeDrive Garage', '654 Checkpoint Dr', '+1-5557778888', 'Repair'),
('VS006', 'DEP007', 'COMP006', 'Elite Auto Services', '987 Mechanic Ln', '+1-6668889999', 'Customization'),
('VS007', 'DEP008', 'COMP007', 'Pinnacle Auto Shop', '159 Auto Blvd', '+1-7779990000', 'Repair'),
('VS008', 'DEP009', 'COMP008', 'Fortress Repairs', '753 Safety Rd', '+1-8880001111', 'Inspection'),
('VS009', 'DEP010', 'COMP009', 'Integrity Motors', '852 Auto Ct', '+1-9991112222', 'Repair'),
('VS010', 'DEP001', 'COMP001', 'Unity Vehicle Services', '963 Harmony Ave', '+1-1112223334', 'Maintenance');


INSERT INTO Vehicle (Vehicle_ID, Customer_ID, Registration_Number, Value, Type, Make, Model, Engine_Number, Chassis_Number) VALUES
('VEH0001', 'CUST0001', 'REG1234', 20000, 'Sedan', 'Toyota', 'Camry', 'ENG5678', 'CHS1234'),
('VEH0002', 'CUST0002', 'REG2345', 25000, 'SUV', 'Honda', 'CR-V', 'ENG6789', 'CHS2345'),
('VEH0003', 'CUST0003', 'REG3456', 30000, 'Truck', 'Ford', 'F-150', 'ENG7890', 'CHS3456'),
('VEH0004', 'CUST0004', 'REG4567', NULL, 'Sedan', 'Nissan', 'Altima', 'ENG8901', 'CHS4567'),
('VEH0005', 'CUST0005', 'REG5678', 18000, 'Hatchback', 'Hyundai', 'i20', 'ENG9012', 'CHS5678'),
('VEH0006', 'CUST0006', 'REG6789', 22000, 'SUV', 'Kia', 'Sportage', 'ENG0123', 'CHS6789'),
('VEH0007', 'CUST0007', 'REG7890', 28000, 'Sedan', 'Mazda', '6', 'ENG1234', 'CHS7890'),
('VEH0008', 'CUST0008', 'REG8901', 35000, 'Coupe', 'BMW', '3 Series', 'ENG2345', 'CHS8901'),
('VEH0009', 'CUST0009', 'REG9012', 27000, 'SUV', 'Chevrolet', 'Equinox', 'ENG3456', 'CHS9012'),
('VEH0010', 'CUST0010', 'REG0123', 15000, 'Hatchback', 'Volkswagen', 'Polo', 'ENG4567', 'CHS0123');


INSERT INTO Application (Application_ID, Customer_ID, Vehicle_ID, Status, Coverage_Description) VALUES
('APP0001', 'CUST0001', 'VEH0001', 'Pending', 'Comprehensive coverage for fire, theft, and accidents'),
('APP0002', 'CUST0002', 'VEH0002', 'Issued', 'Collision and liability coverage'),
('APP0003', 'CUST0003', 'VEH0003', 'Expired', 'Full coverage with additional roadside assistance'),
('APP0004', 'CUST0004', 'VEH0004', 'Pending', 'Liability only coverage'),
('APP0005', 'CUST0005', 'VEH0005', 'Issued', 'Comprehensive coverage for natural disasters'),
('APP0006', 'CUST0006', 'VEH0006', 'Expired', 'Collision coverage'),
('APP0007', 'CUST0007', 'VEH0007', 'Pending', 'Comprehensive coverage for vandalism and accidents'),
('APP0008', 'CUST0008', 'VEH0008', 'Issued', 'Comprehensive coverage for theft and fire'),
('APP0009', 'CUST0009', 'VEH0009', 'Expired', 'Liability and uninsured motorist coverage'),
('APP0010', 'CUST0010', 'VEH0010', 'Pending', 'Comprehensive coverage with deductible options');


INSERT INTO Policy (Policy_Number, Application_ID, Start_Date, Expiry_Date, Terms) VALUES
('POL00001', 'APP0001', '2023-01-01', '2024-01-01', 'Standard terms and conditions apply. Coverage is subject to policy exclusions.'),
('POL00002', 'APP0002', '2023-02-15', '2024-02-15', 'Liability coverage is provided with a $500 deductible.'),
('POL00003', 'APP0003', '2022-03-01', '2023-03-01', 'Full coverage with no deductible for roadside assistance.'),
('POL00004', 'APP0004', '2023-04-10', '2024-04-10', 'Limited liability coverage with no add-ons.'),
('POL00005', 'APP0005', '2023-05-20', '2024-05-20', 'Includes coverage for natural disasters with a $1000 deductible.'),
('POL00006', 'APP0006', '2022-06-30', '2023-06-30', 'Collision-only coverage with a $500 deductible.'),
('POL00007', 'APP0007', '2023-07-15', '2024-07-15', 'Comprehensive coverage with optional rider for accidents.'),
('POL00008', 'APP0008', '2023-08-05', '2024-08-05', 'Fire and theft coverage. Additional terms available online.'),
('POL00009', 'APP0009', '2022-09-10', '2023-09-10', 'Includes uninsured motorist coverage. Deductible: $750.'),
('POL00010', 'APP0010', '2023-10-20', '2024-10-20', 'Comprehensive coverage with flexible deductible options.');


INSERT INTO Premium_Payment (Payment_ID, Policy_Number, Amount, Payment_Date, Receipt_ID) VALUES
('PAY00001', 'POL00001', 1200.00, '2023-01-10', 'RCPT001'),
('PAY00002', 'POL00002', 950.50, '2023-02-20', 'RCPT002'),
('PAY00003', 'POL00003', 1500.00, '2022-03-05', 'RCPT003'),
('PAY00004', 'POL00004', 750.00, '2023-04-15', 'RCPT004'),
('PAY00005', 'POL00005', 1100.00, '2023-05-25', 'RCPT005'),
('PAY00006', 'POL00006', 800.00, '2022-06-05', 'RCPT006'),
('PAY00007', 'POL00007', 1250.00, '2023-07-20', 'RCPT007'),
('PAY00008', 'POL00008', 1000.00, '2023-08-10', 'RCPT008'),
('PAY00009', 'POL00009', 900.00, '2022-09-15', 'RCPT009'),
('PAY00010', 'POL00010', 1300.00, '2023-10-25', 'RCPT010');


INSERT INTO Claim (Claim_ID, Policy_Number, Amount, Incident_ID, Damage_Type, Date, Status) VALUES
('CLM00001', 'POL00001', 5000.00, 'INC001', 'Collision', '2023-06-10', 'Approved'),
('CLM00002', 'POL00002', 3000.00, 'INC002', 'Theft', '2023-07-15', 'Pending'),
('CLM00003', 'POL00003', 4500.00, 'INC003', 'Fire', '2022-08-05', 'Rejected'),
('CLM00004', 'POL00004', 2500.00, 'INC004', 'Flood', '2023-09-10', 'Approved'),
('CLM00005', 'POL00005', 7000.00, 'INC005', 'Earthquake', '2023-10-05', 'Pending'),
('CLM00006', 'POL00006', 3500.00, 'INC006', 'Collision', '2022-11-15', 'Approved'),
('CLM00007', 'POL00007', 2000.00, 'INC007', 'Vandalism', '2023-12-01', 'Rejected'),
('CLM00008', 'POL00008', 6000.00, 'INC008', 'Theft', '2024-01-05', 'Pending'),
('CLM00009', 'POL00009', 4000.00, 'INC009', 'Fire', '2023-02-20', 'Approved'),
('CLM00010', 'POL00010', 5500.00, 'INC010', 'Flood', '2023-03-15', 'Pending');


INSERT INTO Claim_Settlement (Settlement_ID, Claim_ID, Amount_Paid, Settlement_Date) VALUES
('SETT0001', 'CLM00001', 4800.00, '2023-06-15'),
('SETT0002', 'CLM00002', NULL, NULL),
('SETT0003', 'CLM00003', NULL, NULL),
('SETT0004', 'CLM00004', 2400.00, '2023-09-20'),
('SETT0005', 'CLM00005', NULL, NULL),
('SETT0006', 'CLM00006', 3400.00, '2022-11-20'),
('SETT0007', 'CLM00007', NULL, NULL),
('SETT0008', 'CLM00008', NULL, NULL),
('SETT0009', 'CLM00009', 3900.00, '2023-02-25'),
('SETT0010', 'CLM00010', NULL, NULL);


INSERT INTO Risk_Assessment (Assessment_ID, Customer_ID, Age, Health_Status, Risk_Level, Premium_Multiplier) VALUES
('RA0001', 'CUST0001', 35, 'Healthy', 'Low', 1.10),
('RA0002', 'CUST0002', 42, 'Smoker', 'Medium', 1.25),
('RA0003', 'CUST0003', 29, 'Overweight', 'Medium', 1.20),
('RA0004', 'CUST0004', 50, 'Diabetic', 'High', 1.50),
('RA0005', 'CUST0005', 40, 'Healthy', 'Low', 1.05),
('RA0006', 'CUST0006', 33, 'Smoker', 'Medium', 1.30),
('RA0007', 'CUST0007', 48, 'Healthy', 'Low', 1.10),
('RA0008', 'CUST0008', 55, 'Heart Issues', 'High', 1.60),
('RA0009', 'CUST0009', 27, 'Underweight', 'Low', 1.05),
('RA0010', 'CUST0010', 39, 'Healthy', 'Medium', 1.20);


INSERT INTO Revenue_Expenses (Month, Revenue, Claims_paid, Expenses, Profit) VALUES
('January 2023', 500000.00, 200000.00, 100000.00, 200000.00),
('February 2023', 480000.00, 180000.00, 95000.00, 205000.00),
('March 2023', 520000.00, 220000.00, 110000.00, 190000.00),
('April 2023', 510000.00, 190000.00, 105000.00, 215000.00),
('May 2023', 530000.00, 210000.00, 102000.00, 218000.00),
('June 2023', 550000.00, 230000.00, 115000.00, 205000.00),
('July 2023', 570000.00, 250000.00, 120000.00, 200000.00),
('August 2023', 540000.00, 200000.00, 110000.00, 230000.00),
('September 2023', 560000.00, 220000.00, 115000.00, 225000.00),
('October 2023', 580000.00, 240000.00, 120000.00, 220000.00);


INSERT INTO Customer_Segmentation (Segment_ID, Segment_Name, Age_Range, Average_Income, Risk_Level, Claim_Frequency) VALUES
('SEG0001', 'Young Professionals', '25-35', 60000.00, 'Low', 'Occasional'),
('SEG0002', 'Middle-Aged Families', '36-50', 85000.00, 'Medium', 'Moderate'),
('SEG0003', 'Retirees', '51-65', 50000.00, 'Medium', 'Low'),
('SEG0004', 'High-Net-Worth Individuals', '30-60', 150000.00, 'Low', 'Rare'),
('SEG0005', 'Small Business Owners', '35-55', 90000.00, 'Medium', 'Moderate'),
('SEG0006', 'Frequent Travelers', '30-45', 70000.00, 'Medium', 'Occasional'),
('SEG0007', 'Young Families', '25-40', 75000.00, 'Medium', 'Frequent'),
('SEG0008', 'Health Conscious Individuals', '25-50', 80000.00, 'Low', 'Rare'),
('SEG0009', 'Risk Takers', '20-35', 40000.00, 'High', 'Frequent'),
('SEG0010', 'Senior Citizens', '65+', 45000.00, 'Medium', 'Low');


INSERT INTO Reinsurance_Info (Reinsurance_ID, Policy_Number, Reinsurer_Name, Reinsurance_Type, Coverage_Limit, Deductible) VALUES
('RI0001', 'POL00001', 'Global Reinsure Inc.', 'Proportional', 50000.00, 1000.00),
('RI0002', 'POL00002', 'SafeCover Reinsurance', 'Non-Proportional', 75000.00, 2000.00),
('RI0003', 'POL00003', 'Fortress Reinsurance', 'Proportional', 100000.00, 500.00),
('RI0004', 'POL00004', 'SecureShield Reinsurance', 'Excess of Loss', 120000.00, 1500.00),
('RI0005', 'POL00005', 'SafeCover Reinsurance', 'Quota Share', 60000.00, 800.00),
('RI0006', 'POL00006', 'Global Reinsure Inc.', 'Stop Loss', 70000.00, 1000.00),
('RI0007', 'POL00007', 'Fortress Reinsurance', 'Excess of Loss', 85000.00, 1500.00),
('RI0008', 'POL00008', 'SecureShield Reinsurance', 'Proportional', 95000.00, 1200.00),
('RI0009', 'POL00009', 'Global Reinsure Inc.', 'Quota Share', 110000.00, 1800.00),
('RI0010', 'POL00010', 'SafeCover Reinsurance', 'Non-Proportional', 125000.00, 2000.00);


INSERT INTO Feedback_Info (Feedback_ID, Customer_ID, Feedback_Type, Rating, Feedback_Text, Feedback_Date) VALUES
('FBK0001', 'CUST0001', 'Service', 5, 'Excellent service! Highly recommend.', '2023-02-10'),
('FBK0002', 'CUST0002', 'Claim', 4, 'Claim process was smooth but a bit slow.', '2023-03-15'),
('FBK0003', 'CUST0003', 'Policy', 3, 'Policy details were unclear.', '2023-04-20'),
('FBK0004', 'CUST0004', 'Incident', 2, 'Agent was unresponsive initially.', '2023-05-25'),
('FBK0005', 'CUST0005', 'Service', 5, 'Very helpful staff and quick resolution.', '2023-06-30'),
('FBK0006', 'CUST0006', 'Claim', 4, 'Good experience overall.', '2023-07-15'),
('FBK0007', 'CUST0007', 'Policy', 3, 'Premium is slightly expensive.', '2023-08-10'),
('FBK0008', 'CUST0008', 'Incident', 1, 'Poor follow-up on incident reporting.', '2023-09-05'),
('FBK0009', 'CUST0009', 'Service', 4, 'Satisfied with the overall experience.', '2023-10-20'),
('FBK0010', 'CUST0010', 'Claim', 5, 'Fast and efficient claim settlement.', '2023-11-25');


INSERT INTO Staff (Staff_ID, Company_ID, First_Name, Last_Name, Address, Position, Contact_Number, Email, Password) VALUES
('STF0001', 'COMP001', 'John', 'Doe', '123 Elm Street', 'Insurance Agent', '+1-1234567890', 'john.doe@insurance.com', 'Morocco'),
('STF0002', 'COMP001', 'Jane', 'Smith', '456 Oak Avenue', 'Claims Adjuster', '+1-2345678901', 'jane.smith@insurance.com', 'Algeria'),
('STF0003', 'COMP001', 'Bob', 'Brown', '789 Pine Road', 'Risk Analyst', '+1-3456789012', 'bob.brown@insurance.com', 'Tunisia'),
('STF0004', 'COMP002', 'Alice', 'Johnson', '321 Maple Lane', 'Underwriter', '+1-4567890123', 'alice.johnson@insurance.com', 'Libya'),
('STF0005', 'COMP003', 'Charlie', 'Davis', '654 Cedar Street', 'Customer Service', '+1-5678901234', 'charlie.davis@insurance.com', 'Egypt'),
('STF0006', 'COMP003', 'Emily', 'Miller', '987 Birch Boulevard', 'Claims Supervisor', '+1-6789012345', 'emily.miller@insurance.com', 'Mauritania'),
('STF0007', 'COMP004', 'Frank', 'Wilson', '111 Spruce Terrace', 'IT Support', '+1-7890123456', 'frank.wilson@insurance.com', 'Mali'),
('STF0008', 'COMP004', 'Grace', 'Taylor', '222 Willow Court', 'Policy Administrator', '+1-8901234567', 'grace.taylor@insurance.com', 'Niger'),
('STF0009', 'COMP005', 'Hank', 'Anderson', '333 Ash Circle', 'Actuary', '+1-9012345678', 'hank.anderson@insurance.com', 'Chad'),
('STF0010', 'COMP005', 'Ivy', 'Thomas', '444 Poplar Place', 'Legal Advisor', '+1-0123456789', 'ivy.thomas@insurance.com', 'Sudan');

