
-- The project creates a comprehensive system for an insurance company to record the various activities performed by their business
-- The system eliminates the need for manual calculations and provides quick and easy access to data, which can then be manipulated
-- It caters to a variety of stakeholders such as customers, agents, and management

-- The SQL script contains a variety of create table statements, as well as indices and constraints which
-- define relationships between the fields in multiple tables. 

USE InsuranceManagement

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
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Incident_ID) REFERENCES Incident(Incident_ID)
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
    FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID)
);

-- This table contains the information for Vehicle Service companies specifically,
-- Uses the service ID as its primary key but references the Department table to obtain the Department_ID
CREATE TABLE Vehicle_Service (
    Service_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Department_ID VARCHAR(10) NOT NULL,
    Name VARCHAR(50) NOT NULL,
    Address VARCHAR(50) NULL,
    Contact VARCHAR(20) NOT NULL,
    Service_Type VARCHAR(20) NULL, 
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
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
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- This table contains all applications for potential claims, with the Application ID as the primary key
-- Also references the Customer and Vehicle tables for the IDs.
CREATE TABLE Application (
    Application_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Customer_ID VARCHAR(10) NOT NULL, 
    Vehicle_ID VARCHAR(10) NOT NULL,
    Status VARCHAR(10) NOT NULL,		-- Pending, Issued, Expired, etc.
    Coverage_Description VARCHAR(100) NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicle(Vehicle_ID)
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
    FOREIGN KEY (Application_ID) REFERENCES Application(Application_ID)
);

-- Contains a record of all the payments received by the firm in regards to a specific policy
-- References the policy table to obtain the policy number
CREATE TABLE Premium_Payment (
    Payment_ID VARCHAR(10) NOT NULL PRIMARY KEY, 
    Policy_Number VARCHAR(20) NOT NULL, 
    Amount FLOAT NOT NULL,
    Payment_Date DATE NOT NULL,
    Receipt_ID VARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (Policy_Number) REFERENCES Policy(Policy_Number)
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
    FOREIGN KEY (Policy_Number) REFERENCES Policy(Policy_Number),
    FOREIGN KEY (Incident_ID) REFERENCES Incident(Incident_ID)
);

-- Looks at the claims that have been settled and how much has been paid
-- References the claim ID from the Claim table. 
CREATE TABLE Claim_Settlement (
    Settlement_ID VARCHAR(10) NOT NULL PRIMARY KEY,
    Claim_ID VARCHAR(10) NOT NULL,
    Amount_Paid FLOAT NOT NULL,
    Settlement_Date DATE NOT NULL,
    FOREIGN KEY (Claim_ID) REFERENCES Claim(Claim_ID)
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
    FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID)
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
    FOREIGN KEY (Policy_Number) REFERENCES Policy(Policy_Number)
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
    FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID)
);
