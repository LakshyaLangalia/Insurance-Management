from flask import Flask, render_template, request, redirect, url_for, flash
import pyodbc
import re
import os
import csv
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user

# runs the app as a flask application (function to run is at the bottom of the code)
app = Flask(__name__)
app.secret_key = "woeruowieuroieu" 

# initializes the login manager and links it to the flask app
login_manager = LoginManager()
login_manager.init_app(app)

# specifies the route to redirect to if a user tries to access a page that requires authentication
login_manager.login_view = "login"

# connecting the SQL db to the python script
connection = pyodbc.connect(
    r"Driver={ODBC Driver 17 for SQL Server};"
    r"Server=(localdb)\localdb73;"
    "Database=Insurance;"
    "Trusted_Connection=yes;"
)
cursor = connection.cursor()

# defines the user object used by flask login. UserMixin is used to implement the login
# functionality without having to manually implement it
class User(UserMixin):
    def __init__(self, id, email, password, first_name=None, last_name=None, position=None):
        self.id = id
        self.email = email
        self.password = password
        self.first_name = first_name
        self.last_name = last_name
        self.position = position


# loads a user database based on the user id -- specifically, sends a request to the 
# database to retrieve items where the user_id is given
@login_manager.user_loader
def load_user(user_id):
    try:
        cursor.execute("SELECT Staff_ID, Email, Password, First_Name, Last_Name, Position FROM Staff WHERE Staff_ID = ?", user_id)
        user_data = cursor.fetchone()
        if user_data:
            return User(
                id=user_data[0], 
                email=user_data[1], 
                password=user_data[2], 
                first_name=user_data[3], 
                last_name=user_data[4], 
                position=user_data[5]
            )
    except Exception as e:
        print(f"Error loading user: {e}")
    return None


# the login method -- if its a post request, then obtains the email and password from the template

# if the record exists and the passwords match, user is defined as a User with the corresponding id email and password
# then it logs you in through the method provided by flask_login and automatically redirects to home page
# if its a get request then simply return the template.
@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = request.form["email"]
        password = request.form["password"]

        # Fetch the user from the database
        cursor.execute("SELECT Staff_ID, Email, Password FROM Staff WHERE Email = ?", (email,))
        user_data = cursor.fetchone()

        if user_data and user_data[2] == password:  # Password matches
            user = User(id=user_data[0], email=user_data[1], password=user_data[2])
            login_user(user)  # Log in the user

            flash("Login successful!", "success")

            return redirect(url_for("index"))

        else:
            flash("Invalid email or password.", "error")

    return render_template("login.html")

# uses the logout function provided by flask login, and this is only displayed
# if the user is already logged in. and redirects to login page
@app.route("/logout")
@login_required
def logout():
    logout_user()
    flash("You have been logged out.", "success")
    return redirect(url_for("login"))

# the next four functions are to ensure proper entry within the database, based on the constraints
# that are provided within the sql file (some values being non null, etc.) the function below takes
# care of non null and values that may be too long
def validate_non_null(field_name, field_value, max_length=None):
    if not field_value:
        flash(f"{field_name} is required and cannot be empty.", "error")
        return False
    if max_length and len(field_value) > max_length:
        flash(f"{field_name} exceeds the maximum length of {max_length}.", "error")
        return False
    return True

# validates that the numbers entered are positive (e.g. quantities, money, etc.)
def validate_positive_float(field_name, field_value):
    try:
        value = float(field_value)
        if value <= 0:
            flash(f"{field_name} must be a positive number.", "error")
            return False
        return True
    except ValueError:
        flash(f"{field_name} must be a valid number.", "error")
        return False
    
# validates the the email entered is a valid email
def validate_email(field_name, value):
    if not re.match(r"[^@]+@[^@]+\.[^@]+", value):
        flash(f"{field_name} is not a valid email address.", "error")
        return False
    return True

# validates that any url entered is secure and a real url
def validate_url(field_name, value):
    if not re.match(r"https?://[^\s/$.?#].[^\s]*", value):
        flash(f"{field_name} is not a valid URL.", "error")
        return False
    return True

# home route -- renders the index.html template
@app.route("/")
@login_required
def index():
    return render_template("index.html")

# adding a customer, which can either be a get or post request

# if its a post request, take all the information entered in the form and store them in separate variables
# if all the constraints are passed (non null values, etc.) then execute the corresponding SQL query

# if its a get req then simply show the page

# the same format follows for all the add_... functions
@app.route("/add_customer", methods=["GET", "POST"])
def add_customer():
    if request.method == "POST":
        customer_id = request.form["customer_id"]
        first_name = request.form["first_name"]
        last_name = request.form["last_name"]
        dob = request.form["dob"]
        gender = request.form["gender"]
        address = request.form["address"]
        city = request.form["city"]
        country = request.form["country"]
        phone = request.form["phone"]
        email = request.form["email"]
        marital_status = request.form["marital_status"]

        if all([
            validate_non_null("Customer ID", customer_id, max_length=10),
            validate_non_null("First Name", first_name, max_length=50),
            validate_non_null("Last Name", last_name, max_length=50),
            validate_non_null("Date of Birth", dob),
            validate_non_null("Gender", gender, max_length=10),
            validate_non_null("Address", address, max_length=255),
            validate_non_null("City", city, max_length=50),
            validate_non_null("Country", country, max_length=50),
            validate_non_null("Phone", phone, max_length=20),
            validate_non_null("Email", email, max_length=50),
            validate_non_null("Marital Status", marital_status, max_length=20)
        ]):
            try:
                query = """
                    INSERT INTO Customer (Customer_ID, First_Name, Last_Name, DOB, Gender, Address, City, Country, Phone, Email, Marital_Status)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, customer_id, first_name, last_name, dob, gender, address, city, country, phone, email, marital_status)
                connection.commit()
                flash("Customer added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Customer: {e}", "error")

    return render_template("add_customer.html")



@app.route("/add_incident", methods=["GET", "POST"])
def add_incident():
    if request.method == "POST":
        incident_id = request.form["incident_id"]
        incident_type = request.form["type"]
        date = request.form["date"]
        description = request.form["description"]

        if all([
            validate_non_null("Incident ID", incident_id, max_length=10),
            validate_non_null("Type", incident_type, max_length=20),
            validate_non_null("Date", date),
            validate_non_null("Description", description, max_length=255)
        ]):
            try:
                query = """
                    INSERT INTO Incident (Incident_ID, Type, Date, Description)
                    VALUES (?, ?, ?, ?)
                """
                cursor.execute(query, incident_id, incident_type, date, description)
                connection.commit()
                flash("Incident added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Incident: {e}", "error")

    return render_template("add_incident.html")


@app.route("/add_incident_report", methods=["GET", "POST"])
def add_incident_report():
    if request.method == "POST":
        report_id = request.form["report_id"]
        incident_id = request.form["incident_id"]
        customer_id = request.form["customer_id"]
        inspector_name = request.form.get("inspector_name")  # Optional field
        estimated_cost = request.form.get("estimated_cost")  # Optional field
        description = request.form.get("description")  # Optional field

        if all([
            validate_non_null("Report ID", report_id, max_length=10),
            validate_non_null("Incident ID", incident_id, max_length=10),
            validate_non_null("Customer ID", customer_id, max_length=10)
        ]):
            if estimated_cost and not validate_positive_float("Estimated Cost", estimated_cost):
                return render_template("form.html")  # Stop if cost is invalid

            try:
                query = """
                    INSERT INTO Incident_Report (Report_ID, Incident_ID, Customer_ID, Inspector_Name, Estimated_Cost, Description)
                    VALUES (?, ?, ?, ?, ?, ?)
                """
                cursor.execute(
                    query,
                    report_id,
                    incident_id,
                    customer_id,
                    inspector_name,
                    float(estimated_cost) if estimated_cost else None,
                    description
                )
                connection.commit()
                flash("Incident Report added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Incident Report: {e}", "error")

    return render_template("add_incident_report.html")


@app.route("/add_company", methods=["GET", "POST"])
def add_company():
    if request.method == "POST":
        company_id = request.form["company_id"]
        name = request.form["name"]
        contact_number = request.form["contact_number"]
        email = request.form.get("email")  # Optional
        website = request.form.get("website")  # Optional
        address = request.form["address"]
        city = request.form["city"]
        country = request.form["country"]

        if all([
            validate_non_null("Company ID", company_id, max_length=10),
            validate_non_null("Name", name, max_length=50),
            validate_non_null("Contact Number", contact_number, max_length=20),
            validate_non_null("Address", address, max_length=255),
            validate_non_null("City", city, max_length=50),
            validate_non_null("Country", country, max_length=50)
        ]):
            if email and not validate_email("Email", email):
                return render_template("form.html")
            if website and not validate_url("Website", website):
                return render_template("form.html")

            try:
                query = """
                    INSERT INTO Company (Company_ID, Name, Contact_Number, Email, Website, Address, City, Country)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, company_id, name, contact_number, email, website, address, city, country)
                connection.commit()
                flash("Company added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Company: {e}", "error")

    return render_template("add_company.html")

@app.route("/add_department", methods=["GET", "POST"])
def add_department():
    if request.method == "POST":
        department_id = request.form["department_id"]
        company_id = request.form["company_id"]
        name = request.form["name"]
        staff_count = request.form.get("staff_count")  # Optional
        office_count = request.form.get("office_count")  # Optional

        if all([
            validate_non_null("Department ID", department_id, max_length=10),
            validate_non_null("Company ID", company_id, max_length=10),
            validate_non_null("Name", name, max_length=50),
        ]):
            try:
                query = """
                    INSERT INTO Department (Department_ID, Company_ID, Name, Staff_Count, Office_Count)
                    VALUES (?, ?, ?, ?, ?)
                """
                cursor.execute(query, department_id, company_id, name, staff_count, office_count)
                connection.commit()
                flash("Department added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Department: {e}", "error")

    return render_template("add_department.html")


@app.route("/add_vehicle_service", methods=["GET", "POST"])
def add_vehicle_service():
    if request.method == "POST":
        service_id = request.form["service_id"]
        department_id = request.form["department_id"]
        company_id = request.form["company_id"]
        name = request.form["name"]
        address = request.form.get("address")  # Optional
        contact = request.form["contact"]
        service_type = request.form.get("service_type")  # Optional

        if all([
            validate_non_null("Service ID", service_id, max_length=10),
            validate_non_null("Department ID", department_id, max_length=10),
            validate_non_null("Company ID", company_id, max_length=10),
            validate_non_null("Name", name, max_length=50),
            validate_non_null("Contact", contact, max_length=20),
        ]):
            try:
                query = """
                    INSERT INTO Vehicle_Service (Service_ID, Department_ID, Company_ID, Name, Address, Contact, Service_Type)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, service_id, department_id, company_id, name, address, contact, service_type)
                connection.commit()
                flash("Vehicle Service added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Vehicle Service: {e}", "error")

    return render_template("add_vehicle_service.html")


@app.route("/add_vehicle", methods=["GET", "POST"])
def add_vehicle():
    if request.method == "POST":
        vehicle_id = request.form["vehicle_id"]
        customer_id = request.form["customer_id"]
        registration_number = request.form["registration_number"]
        value = request.form.get("value")  # Optional
        vehicle_type = request.form.get("type")  # Optional
        make = request.form.get("make")  # Optional
        model = request.form.get("model")  # Optional
        engine_number = request.form.get("engine_number")  # Optional
        chassis_number = request.form.get("chassis_number")  # Optional

        if all([
            validate_non_null("Vehicle ID", vehicle_id, max_length=10),
            validate_non_null("Customer ID", customer_id, max_length=10),
            validate_non_null("Registration Number", registration_number, max_length=20),
        ]):
            try:
                query = """
                    INSERT INTO Vehicle (Vehicle_ID, Customer_ID, Registration_Number, Value, Type, Make, Model, Engine_Number, Chassis_Number)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, vehicle_id, customer_id, registration_number, value, vehicle_type, make, model, engine_number, chassis_number)
                connection.commit()
                flash("Vehicle added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Vehicle: {e}", "error")

    return render_template("add_vehicle.html")


@app.route("/add_application", methods=["GET", "POST"])
def add_application():
    if request.method == "POST":
        application_id = request.form["application_id"]
        customer_id = request.form["customer_id"]
        vehicle_id = request.form["vehicle_id"]
        status = request.form["status"]
        coverage_description = request.form["coverage_description"]

        if all([
            validate_non_null("Application ID", application_id, max_length=10),
            validate_non_null("Customer ID", customer_id, max_length=10),
            validate_non_null("Vehicle ID", vehicle_id, max_length=10),
            validate_non_null("Status", status, max_length=10),
            validate_non_null("Coverage Description", coverage_description, max_length=100),
        ]):
            try:
                query = """
                    INSERT INTO Application (Application_ID, Customer_ID, Vehicle_ID, Status, Coverage_Description)
                    VALUES (?, ?, ?, ?, ?)
                """
                cursor.execute(query, application_id, customer_id, vehicle_id, status, coverage_description)
                connection.commit()
                flash("Application added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Application: {e}", "error")

    return render_template("add_application.html")


@app.route("/add_policy", methods=["GET", "POST"])
def add_policy():
    if request.method == "POST":
        policy_number = request.form["policy_number"]
        application_id = request.form["application_id"]
        start_date = request.form["start_date"]
        expiry_date = request.form["expiry_date"]
        terms = request.form.get("terms")  # Optional

        if all([
            validate_non_null("Policy Number", policy_number, max_length=20),
            validate_non_null("Application ID", application_id, max_length=10),
            validate_non_null("Start Date", start_date),
            validate_non_null("Expiry Date", expiry_date),
        ]):
            try:
                query = """
                    INSERT INTO Policy (Policy_Number, Application_ID, Start_Date, Expiry_Date, Terms)
                    VALUES (?, ?, ?, ?, ?)
                """
                cursor.execute(query, policy_number, application_id, start_date, expiry_date, terms)
                connection.commit()
                flash("Policy added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.Error as e:
                flash(f"Error inserting Policy: {e}", "error")

    return render_template("add_policy.html")

@app.route("/add_premium_payment", methods=["GET", "POST"])
def add_premium_payment():
    if request.method == "POST":
        payment_id = request.form["payment_id"]
        policy_number = request.form["policy_number"]
        amount = request.form["amount"]
        payment_date = request.form["payment_date"]
        receipt_id = request.form["receipt_id"]

        if all([
            validate_non_null("Payment ID", payment_id, max_length=10),
            validate_non_null("Policy Number", policy_number, max_length=20),
            validate_non_null("Amount", amount),
            validate_non_null("Payment Date", payment_date),
            validate_non_null("Receipt ID", receipt_id, max_length=20)
        ]):

            try:
                query = """
                    INSERT INTO Premium_Payment (Payment_ID, Policy_Number, Amount, Payment_Date, Receipt_ID)
                    VALUES (?, ?, ?, ?, ?)
                """
                cursor.execute(query, payment_id, policy_number, amount, payment_date, receipt_id)
                connection.commit()
                flash("Premium Payment added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.IntegrityError as e:
                flash(f"Error inserting Premium Payment: {e}", "error")

    return render_template("add_premium_payment.html")


@app.route("/add_claim", methods=["GET", "POST"])
def add_claim():
    if request.method == "POST":
        claim_id = request.form["claim_id"]
        policy_number = request.form["policy_number"]
        amount = request.form["amount"]
        incident_id = request.form["incident_id"]
        damage_type = request.form["damage_type"]
        date = request.form["date"]
        status = request.form["status"]

        if all([
            validate_non_null("Claim ID", claim_id, max_length=10),
            validate_non_null("Policy Number", policy_number, max_length=20),
            validate_non_null("Amount", amount),
            validate_non_null("Incident ID", incident_id, max_length=10),
            validate_non_null("Damage Type", damage_type, max_length=20),
            validate_non_null("Date", date),
            validate_non_null("Status", status, max_length=20)
        ]):
            try:
                query = """
                    INSERT INTO Claim (Claim_ID, Policy_Number, Amount, Incident_ID, Damage_Type, Date, Status)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, claim_id, policy_number, amount, incident_id, damage_type, date, status)
                connection.commit()
                flash("Claim added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.IntegrityError as e:
                flash(f"Error inserting Claim: {e}", "error")

    return render_template("add_claim.html")


@app.route("/add_claim_settlement", methods=["GET", "POST"])
def add_claim_settlement():
    if request.method == "POST":
        settlement_id = request.form["settlement_id"]
        claim_id = request.form["claim_id"]
        amount_paid = request.form["amount_paid"]
        settlement_date = request.form["settlement_date"]

        if all([
            validate_non_null("Settlement ID", settlement_id, max_length=10),
            validate_non_null("Claim ID", claim_id, max_length=10),
            validate_non_null("Amount Paid", amount_paid),
            validate_non_null("Settlement Date", settlement_date)
        ]):
            try:
                query = """
                    INSERT INTO Claim_Settlement (Settlement_ID, Claim_ID, Amount_Paid, Settlement_Date)
                    VALUES (?, ?, ?, ?)
                """
                cursor.execute(query, settlement_id, claim_id, amount_paid, settlement_date)
                connection.commit()
                flash("Claim Settlement added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.IntegrityError as e:
                flash(f"Error inserting Claim Settlement: {e}", "error")

    return render_template("add_claim_settlement.html")


@app.route("/add_risk_assessment", methods=["GET", "POST"])
def add_risk_assessment():
    if request.method == "POST":
        assessment_id = request.form["assessment_id"]
        customer_id = request.form["customer_id"]
        age = request.form["age"]
        health_status = request.form["health_status"]
        risk_level = request.form["risk_level"]
        premium_multiplier = request.form["premium_multiplier"]

        if all([
            validate_non_null("Assessment ID", assessment_id, max_length=10),
            validate_non_null("Customer ID", customer_id, max_length=10),
            validate_non_null("Age", age),
            validate_non_null("Health Status", health_status, max_length=100),
            validate_non_null("Risk Level", risk_level, max_length=20),
            validate_non_null("Premium Multiplier", premium_multiplier)
        ]):

            try:
                query = """
                    INSERT INTO Risk_Assessment (Assessment_ID, Customer_ID, Age, Health_Status, Risk_Level, Premium_Multiplier)
                    VALUES (?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, assessment_id, customer_id, age, health_status, risk_level, premium_multiplier)
                connection.commit()
                flash("Risk Assessment added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.IntegrityError as e:
                flash(f"Error inserting Risk Assessment: {e}", "error")

    return render_template("add_risk_assessment.html")


@app.route("/add_reinsurance_info", methods=["GET", "POST"])
def add_reinsurance_info():
    if request.method == "POST":
        reinsurance_id = request.form["reinsurance_id"]
        policy_number = request.form["policy_number"]
        reinsurer_name = request.form["reinsurer_name"]
        reinsurance_type = request.form["reinsurance_type"]
        coverage_limit = request.form["coverage_limit"]
        deductible = request.form["deductible"]

        if all([
            validate_non_null("Reinsurance ID", reinsurance_id, max_length=10),
            validate_non_null("Policy Number", policy_number, max_length=20),
            validate_non_null("Reinsurer Name", reinsurer_name, max_length=100),
            validate_non_null("Reinsurance Type", reinsurance_type, max_length=50),
            validate_non_null("Coverage Limit", coverage_limit),
            validate_non_null("Deductible", deductible)
        ]):

            try:
                query = """
                    INSERT INTO Reinsurance_Info (Reinsurance_ID, Policy_Number, Reinsurer_Name, Reinsurance_Type, Coverage_Limit, Deductible)
                    VALUES (?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, reinsurance_id, policy_number, reinsurer_name, reinsurance_type, coverage_limit, deductible)
                connection.commit()
                flash("Reinsurance Information added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.IntegrityError as e:
                flash(f"Error inserting Reinsurance Info: {e}", "error")

    return render_template("add_reinsurance_info.html")


@app.route("/add_feedback_info", methods=["GET", "POST"])
def add_feedback_info():
    if request.method == "POST":
        feedback_id = request.form["feedback_id"]
        customer_id = request.form["customer_id"]
        feedback_type = request.form["feedback_type"]
        rating = request.form["rating"]
        feedback_text = request.form["feedback_text"]
        feedback_date = request.form["feedback_date"]

        if all([
            validate_non_null("Feedback ID", feedback_id, max_length=10),
            validate_non_null("Customer ID", customer_id, max_length=10),
            validate_non_null("Feedback Type", feedback_type, max_length=50),
            validate_non_null("Rating", rating),
            validate_non_null("Feedback Text", feedback_text),
            validate_non_null("Feedback Date", feedback_date)
        ]):
            try:
                query = """
                    INSERT INTO Feedback_Info (Feedback_ID, Customer_ID, Feedback_Type, Rating, Feedback_Text, Feedback_Date)
                    VALUES (?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, feedback_id, customer_id, feedback_type, rating, feedback_text, feedback_date)
                connection.commit()
                flash("Feedback Information added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.IntegrityError as e:
                flash(f"Error inserting Feedback Info: {e}", "error")

    return render_template("add_feedback_info.html")

@app.route("/add_staff", methods=["GET", "POST"])
def add_staff():
    if request.method == "POST":
        staff_id = request.form["staff_id"]
        company_id = request.form["company_id"]
        first_name = request.form["first_name"]
        last_name = request.form["last_name"]
        address = request.form["address"]
        position = request.form["position"]
        contact_number = request.form["contact_number"]
        email = request.form["email"]

        if all([
            validate_non_null("Staff ID", staff_id, max_length=10),
            validate_non_null("Company ID", company_id, max_length=10),
            validate_non_null("First Name", first_name, max_length=50),
            validate_non_null("Last Name", last_name, max_length=50),
            validate_non_null("Address", address, max_length=50),
            validate_non_null("Position", position, max_length=50),
            validate_non_null("Contact Number", contact_number, max_length=15),
            validate_non_null("Email", email, max_length=100)
        ]):
            try:
                query = """
                    INSERT INTO Staff (Staff_ID, Company_ID, First_Name, Last_Name, Address, Position, Contact_Number, Email)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """
                cursor.execute(query, staff_id, company_id, first_name, last_name, address, position, contact_number, email)
                connection.commit()
                flash("Staff added successfully.", "success")
                return redirect(url_for("index"))
            except pyodbc.IntegrityError as e:
                flash(f"Error inserting Staff: {e}", "error")

    return render_template("add_staff.html")

# allows the user to upload a csv. if its a post request then obtain the table name and file and store
# them in separate variables. if the file exists and is a csv then read the csv using the csv library
# skip the header row if it exists, then insert the records into the table using a for loop

# the query is constructed dynamically using the construct insert query function. 
@app.route("/upload_csv", methods=["GET", "POST"])
def upload_csv():
    if request.method == "POST":
        table_name = request.form["table_name"]
        file = request.files["csv_file"]

        if file and file.filename.endswith('csv'):
            csv_content = csv.reader(file.stream)

            header = next(csv_content)

            # Insert records into the selected table
            try:
                for row in csv_content:
                    insert_query = construct_insert_query(table_name, header, row)
                    cursor.execute(insert_query)
                connection.commit()
                flash(f"Records successfully inserted into {table_name}.", "success")
                return redirect(url_for("upload_csv"))
            except Exception as e:
                flash(f"Error inserting records: {str(e)}", "error")

    return render_template("upload_csv.html")

# to generate a record, get the table name and header for every row in the csv
# then return the f string which dynamically constructs the query. 
def construct_insert_query(table_name, header, row):
    columns = ', '.join(header)
    values = ', '.join([f"'{value}'" for value in row])
    return f"INSERT INTO {table_name} ({columns}) VALUES ({values})"

# run the app
if __name__ == "__main__":
    app.run(debug=True)
