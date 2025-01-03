# This script is a supplement to the Insurance SQL database, helping to ease the data entry process
# for a user of the database. 


######################################################

# importing the necessary libraries

import pyodbc
import pandas as pd
import os

######################################################

# Connecting the SQL server to the Python script
connection = pyodbc.connect(
    r"Driver={ODBC Driver 17 for SQL Server};"
    r"Server=(localdb)\localdb73;"
    "Database=Insurance;"
    "Trusted_Connection=yes;"
)

cursor = connection.cursor()

######################################################

# Functions that insert records into various tables. 
def insert_customer(customer_id, first_name, last_name, dob, gender, address, city, country, phone, email, marital_status):
    try:
        query = """
            INSERT INTO Customer (Customer_ID, First_Name, Last_Name, DOB, Gender, Address, City, Country, Phone, Email, Marital_Status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, customer_id, first_name, last_name, dob, gender, address, city, country, phone, email, marital_status)
        connection.commit()
        print("Customer inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Customer:", e)

def insert_incident(incident_id, type, date, description):
    try:
        query = """
            INSERT INTO Incident (Incident_ID, Type, Date, Description)
            VALUES (?, ?, ?, ?)
        """
        cursor.execute(query, incident_id, type, date, description)
        connection.commit()
        print("Incident inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Incident:", e)

def insert_incident_report(report_id, incident_id, customer_id, inspector_name, estimated_cost, description):
    try:
        query = """
            INSERT INTO Incident_Report (Report_ID, Incident_ID, Customer_ID, Inspector_Name, Estimated_Cost, Description)
            VALUES (?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, report_id, incident_id, customer_id, inspector_name, estimated_cost, description)
        connection.commit()
        print("Incident Report inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Incident Report:", e)

def insert_company(company_id, name, contact_number, email, website, address, city, country):
    try:
        query = """
            INSERT INTO Company (Company_ID, Name, Contact_Number, Email, Website, Address, City, Country)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, company_id, name, contact_number, email, website, address, city, country)
        connection.commit()
        print("Company inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Company:", e)

def insert_department(department_id, company_id, name, staff_count, office_count):
    try:
        query = """
            INSERT INTO Department (Department_ID, Company_ID, Name, Staff_Count, Office_Count)
            VALUES (?, ?, ?, ?, ?)
        """
        cursor.execute(query, department_id, company_id, name, staff_count, office_count)
        connection.commit()
        print("Department inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Department:", e)

def insert_vehicle_service(service_id, department_id, company_id, name, address, contact, service_type):
    try:
        query = """
            INSERT INTO Vehicle_Service (Service_ID, Department_ID, Company_ID, Name, Address, Contact, Service_Type)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, service_id, department_id, company_id, name, address, contact, service_type)
        connection.commit()
        print("Vehicle Service inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Vehicle Service:", e)

def insert_vehicle(vehicle_id, customer_id, registration_number, value, type, make, model, engine_number, chassis_number):
    try:
        query = """
            INSERT INTO Vehicle (Vehicle_ID, Customer_ID, Registration_Number, Value, Type, Make, Model, Engine_Number, Chassis_Number)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, vehicle_id, customer_id, registration_number, value, type, make, model, engine_number, chassis_number)
        connection.commit()
        print("Vehicle inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Vehicle:", e)

def insert_application(application_id, customer_id, vehicle_id, status, coverage_description):
    try:
        query = """
            INSERT INTO Application (Application_ID, Customer_ID, Vehicle_ID, Status, Coverage_Description)
            VALUES (?, ?, ?, ?, ?)
        """
        cursor.execute(query, application_id, customer_id, vehicle_id, status, coverage_description)
        connection.commit()
        print("Application inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Application:", e)

def insert_policy(policy_number, application_id, start_date, expiry_date, terms):
    try:
        query = """
            INSERT INTO Policy (Policy_Number, Application_ID, Start_Date, Expiry_Date, Terms)
            VALUES (?, ?, ?, ?, ?)
        """
        cursor.execute(query, policy_number, application_id, start_date, expiry_date, terms)
        connection.commit()
        print("Policy inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Policy:", e)

def insert_premium_payment(payment_id, policy_number, amount, payment_date, receipt_id):
    try:
        query = """
            INSERT INTO Premium_Payment (Payment_ID, Policy_Number, Amount, Payment_Date, Receipt_ID)
            VALUES (?, ?, ?, ?, ?)
        """
        cursor.execute(query, payment_id, policy_number, amount, payment_date, receipt_id)
        connection.commit()
        print("Premium Payment inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Premium Payment:", e)

def insert_claim(claim_id, policy_number, amount, incident_id, damage_type, date, status):
    try:
        query = """
            INSERT INTO Claim (Claim_ID, Policy_Number, Amount, Incident_ID, Damage_Type, Date, Status)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, claim_id, policy_number, amount, incident_id, damage_type, date, status)
        connection.commit()
        print("Claim inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Claim:", e)

def insert_claim_settlement(settlement_id, claim_id, amount_paid, settlement_date):
    try:
        query = """
            INSERT INTO Claim_Settlement (Settlement_ID, Claim_ID, Amount_Paid, Settlement_Date)
            VALUES (?, ?, ?, ?)
        """
        cursor.execute(query, settlement_id, claim_id, amount_paid, settlement_date)
        connection.commit()
        print("Claim Settlement inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Claim Settlement:", e)

def insert_risk_assessment(assessment_id, customer_id, age, health_status, risk_level, premium_multiplier):
    try:
        query = """
            INSERT INTO Risk_Assessment (Assessment_ID, Customer_ID, Age, Health_Status, Risk_Level, Premium_Multiplier)
            VALUES (?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, assessment_id, customer_id, age, health_status, risk_level, premium_multiplier)
        connection.commit()
        print("Risk Assessment inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Risk Assessment:", e)

def insert_revenue_expenses(month, revenue, claims_paid, expenses, profit):
    try:
        query = """
            INSERT INTO Revenue_Expenses (Month, Revenue, Claims_paid, Expenses, Profit)
            VALUES (?, ?, ?, ?, ?)
        """
        cursor.execute(query, month, revenue, claims_paid, expenses, profit)
        connection.commit()
        print("Revenue/Expenses inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Revenue/Expenses:", e)

def insert_customer_segmentation(segment_id, segment_name, age_range, average_income, risk_level, claim_frequency):
    try:
        query = """
            INSERT INTO Customer_Segmentation (Segment_ID, Segment_Name, Age_Range, Average_Income, Risk_Level, Claim_Frequency)
            VALUES (?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, segment_id, segment_name, age_range, average_income, risk_level, claim_frequency)
        connection.commit()
        print("Customer Segmentation inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Customer Segmentation:", e)

def insert_reinsurance_info(reinsurance_id, policy_number, reinsurer_name, reinsurance_type, coverage_limit, deductible):
    try:
        query = """
            INSERT INTO Reinsurance_Info (Reinsurance_ID, Policy_Number, Reinsurer_Name, Reinsurance_Type, Coverage_Limit, Deductible)
            VALUES (?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, reinsurance_id, policy_number, reinsurer_name, reinsurance_type, coverage_limit, deductible)
        connection.commit()
        print("Reinsurance Info inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Reinsurance Info:", e)

def insert_feedback_info(feedback_id, customer_id, feedback_type, rating, feedback_text, feedback_date):
    try:
        query = """
            INSERT INTO Feedback_Info (Feedback_ID, Customer_ID, Feedback_Type, Rating, Feedback_Text, Feedback_Date)
            VALUES (?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, feedback_id, customer_id, feedback_type, rating, feedback_text, feedback_date)
        connection.commit()
        print("Feedback Info inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Feedback Info:", e)

def insert_staff(staff_id, company_id, first_name, last_name, address, position, contact_number, email):
    try:
        query = """
            INSERT INTO Staff (Staff_ID, Company_ID, First_Name, Last_Name, Address, Position, Contact_Number, Email)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, staff_id, company_id, first_name, last_name, address, position, contact_number, email)
        connection.commit()
        print("Staff inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Staff:", e)

def insert_audit_log(log_id, table_name, operation_type, changed_by, change_date, original_data, new_data):
    try:
        query = """
            INSERT INTO Audit_Log (Log_ID, Table_Name, Operation_Type, Changed_By, Change_Date, Original_Data, New_Data)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, log_id, table_name, operation_type, changed_by, change_date, original_data, new_data)
        connection.commit()
        print("Audit Log inserted successfully.")
    except pyodbc.Error as e:
        print("Error inserting Audit Log:", e)

##############################################

# Dictionary mapping the table name to the insert functions defined above

insert_functions = {
    "Customer": insert_customer,
    "Incident": insert_incident,
    "Incident_Report": insert_incident_report,
    "Company": insert_company,
    "Department": insert_department,
    "Vehicle_Service": insert_vehicle_service,
    "Vehicle": insert_vehicle,
    "Application": insert_application,
    "Policy": insert_policy,
    "Premium_Payment": insert_premium_payment,
    "Claim": insert_claim,
    "Claim_Settlement": insert_claim_settlement,
    "Risk_Assessment": insert_risk_assessment,
    "Revenue_Expenses": insert_revenue_expenses,
    "Customer_Segmentation": insert_customer_segmentation,
    "Reinsurance_Info": insert_reinsurance_info,
    "Feedback_Info": insert_feedback_info,
    "Staff": insert_staff,
    "Audit_Log": insert_audit_log,
}

##############################################

# Function that uploads the csv file and adds the records to the appropriate table
# The user simply has to input the table name and the file name

def uploader():

    file_path = input("Enter the path to the CSV file: ").strip()

    if not file_path:
        print("File not found.")
        return
    
    table_name = input("Enter the table name: ").strip()

    if table_name not in insert_functions:
        print("Invalid table name.")
        return
    
    try:
        # Converts the CSV into a DataFrame
        data = pd.read_csv(file_path)

        # The where() method replaces values that are false with the specified value
        # In this case, we replace NaN with None for SQL compatibility.
        # The pd.notnull(data) creates a mask where False indicates a NaN,
        # and True indicates a non-null value.
        data = data.where(pd.notnull(data), None)

        # looks up the appropriate function using the table name
        insert_function = insert_functions[table_name]

        # iterates through every row in the csv/dataframe, and converts the row into a named tuple
        # the index isn't included to ensure that only the data columns are part of the record
        # we use named tuples because we can access fields by name instead of position
        # we can then use the tuples to pass data through the insertion function appropriately
        for record in data.itertuples(index=False):
            try:
                # since every record is now a tuple, we use * to unpack the tuple and pass it as
                # individual arguments to the function as required.
                insert_function(*record)
            except TypeError as e:
                print(f"Error inserting record: {record} -- {e}")

    except Exception as e:
        print("Error processing the file: ", e)


uploader()
