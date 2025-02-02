from fastapi import FastAPI, HTTPException, BackgroundTasks, Path
import secrets
import asyncio
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi.middleware.cors import CORSMiddleware
import MySQLdb
from pydantic import BaseModel, Field
import bcrypt
import uvicorn


db_config = {
    'host': 'localhost',
    'user': 'root',
    'passwd': '',
    'db': 'drainage_app',
}

conn = MySQLdb.connect(**db_config)

app = FastAPI()

class User(BaseModel):
    username: str
    password: str = Field(None)  # Make password optional
    email: str
    role: str

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Set this to the appropriate origin or "*" to allow all origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

async def remove_otp(email: str):
    await asyncio.sleep(300)  # Remove OTP after 5 minutes
    if email in otp_map:
        del otp_map[email]

otp_map = {}

def send_email(subject, message, to_email):
    try:
        # Set up the email server
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()

        # Replace 'YOUR_EMAIL_USERNAME' and 'YOUR_EMAIL_PASSWORD' with your actual email credentials
        email_username = '1901049@iot.bdu.ac.bd'
        email_password = 'bxbkhmfuvdphbrmn'
        
        server.login(email_username, email_password)

        # Create message
        msg = MIMEMultipart()
        msg['From'] = email_username
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(message, 'plain'))

        # Send the email
        server.sendmail(email_username, to_email, msg.as_string())
        print("Email sent successfully!")
    except smtplib.SMTPException as e:
        print(f"Failed to send email: {e}")
    finally:
        server.quit()

@app.post("/generate_otp/")
async def generate_otp(email: str):
    print(f"Received email: {email}")
    if '@' not in email or '.' not in email:
        raise HTTPException(status_code=400, detail="Invalid email format")

    otp = str(secrets.randbelow(900000) + 100000)  # Generate a 6-digit OTP
    otp_map[email] = otp
    asyncio.create_task(remove_otp(email))
    send_email("User Verification", f"Your OTP is: {otp}", email)
    print(f"OTP for {email} is: {otp}")
    return {"message": "OTP generated successfully."}

@app.post("/validate_otp/")
async def validate_otp(email: str, entered_otp: str):
    if email not in otp_map:
        raise HTTPException(status_code=404, detail="OTP not found for the given email.")
    
    stored_otp = otp_map[email]
    if stored_otp == entered_otp:
        del otp_map[email]
        print(f"OTP for {email} validated successfully.")
        return {"message": "OTP validated successfully."}
    else:
        print(f"OTP validation failed for {email}.")
        raise HTTPException(status_code=400, detail="Invalid OTP.")


@app.post("/users/")
def create_user(user: User):
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    cursor = conn.cursor()
    query = "INSERT INTO user (username, password, email, role) VALUES (%s, %s, %s, %s)"
    cursor.execute(query, (user.username, hashed_password, user.email, user.role))
    conn.commit()
    cursor.close()
    return {'msg': 'create successful'}


@app.get("/getusers/{user_identifier}")
def read_user(user_identifier: str = Path(..., title="User ID or Username")):
    cursor = conn.cursor()
    query = "SELECT id, username, password, email, role FROM user WHERE id=%s OR username=%s"
    cursor.execute(query, (user_identifier, user_identifier))
    user = cursor.fetchone()
    cursor.close()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"id": user[0], "username": user[1], "password": user[2], "email": user[3], "role": user[4]}

@app.get("/get-last-sensor-data")
def get_last_sensor_data():
    cursor = conn.cursor()
    query = "SELECT Temperature, Humidity, Moisture FROM sensor_data ORDER BY ID DESC LIMIT %s"
    cursor.execute(query, (1,))
    row = cursor.fetchone()
    cursor.close()
    conn.commit()
   
    print(row);

    if row:
        return [{
            "temp": row[0],
            "humidity": row[1],
            "moisture": row[2],
        }]
    else:
        return {}

@app.put("/updateusers/")
def update_user(user_id: int, user: User):
    cursor = conn.cursor()

    # Create the update query with only the fields that are present
    query_parts = []
    values = []
    if user.username:
        query_parts.append("username=%s")
        values.append(user.username)
    if user.password:
        hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
        query_parts.append("password=%s")
        values.append(hashed_password)
    if user.email:
        query_parts.append("email=%s")
        values.append(user.email)
    if user.role:
        query_parts.append("role=%s")
        values.append(user.role)
    values.append(user_id)

    query = f"UPDATE user SET {', '.join(query_parts)} WHERE id=%s"
    cursor.execute(query, values)
    conn.commit()
    cursor.close()
    return {"msg": "update successful"}

@app.delete("/delusers/")
def delete_user(username: str):
    cursor = conn.cursor()
    query = "DELETE FROM user WHERE username=%s"
    cursor.execute(query, (username,))
    conn.commit()
    cursor.close()
    return {"deleted_username": username}

@app.post("/login/")
async def login(username: str, password: str):
    cursor = conn.cursor()
    query = "SELECT password FROM user WHERE username=%s"
    cursor.execute(query, (username,))
    result = cursor.fetchone()
    cursor.close()
    if result is None:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    hashed_password = result[0]
    if bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8')):
        return {"message": "Login successful"}
    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")


@app.get("/selectusers/")
def get_all_users():
    cursor = conn.cursor()
    cursor.execute("SELECT id,username, email,role FROM user")
    users = cursor.fetchall()
    cursor.close()
    return users


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
