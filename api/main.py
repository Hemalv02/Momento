from datetime import datetime
import time
from fastapi import FastAPI, HTTPException
from supabase import create_client, Client
from dotenv import load_dotenv
import os
from schema import RegisterData, LoginData, ChatData, FeedbackData

# Load environment variables
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    raise ValueError("Supabase URL or Key is not set in environment variables.")

# Initialize Supabase client and FastAPI app
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
app = FastAPI()

# Helper function for Supabase error handling
def handle_supabase_response(response):
    if not response or response.get("error"):
        raise HTTPException(status_code=500, detail=response.get("error", {}).get("message", "Unknown error"))
    return response.get("data")

# Register endpoint
@app.post("/register", summary="Register a new user")
async def register_user(user: RegisterData):
    try:
        print(f"[{datetime.now()}] Starting user registration...")

        # Log start time
        start_time = time.time()

        # Sign up the user
        response = supabase.auth.sign_up({
            "email": user.email,
            "password": user.password
        })

        # Log end time
        end_time = time.time()
        print(f"[{datetime.now()}] Completed sign-up call. Duration: {end_time - start_time:.4f} seconds")

        # Extract user ID
        user_id = response.user.id
        if not user_id:
            raise HTTPException(status_code=400, detail="User registration failed.")

        # Insert user data into the "users" table
        data = supabase.table("users").insert({
            "id": user_id,
            "email": user.email,
            "name": user.name,
            "username": user.username,
            "date_of_birth": user.date_of_birth
        }).execute()

        print(f"[{datetime.now()}] User data inserted into 'users' table.")

        return {"message": "User registered successfully.", "user_id": user_id}
    
    except Exception as e:
        print(f"[{datetime.now()}] Error during registration: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/login", summary="Log in a user")
async def login_user(user: LoginData):
    try:
        # Sign in the user
        start_time = time.time()

        response = supabase.auth.sign_in_with_password(
            {"email": user.email, "password": user.password}
        )
        end_time = time.time()
        print(f"[{datetime.now()}] Completed login call. Duration: {end_time - start_time:.4f} seconds")
        user_data = response.user
        if not user_data:
            raise HTTPException(status_code=400, detail="Invalid email or password.")
        return {"message": "Login successful."}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("get_user_id")
async def get_user_data():
    try:
        response = supabase.auth.get_user()
        if not response :
            raise HTTPException(status_code=401, detail="No user is currently logged in.")
        user_id=response.user.id
        return user_id
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/chat", summary="Post a chat message")
async def post_chat(chat: ChatData):
    try:
        data = supabase.table("chat").insert(chat.dict()).execute()
        return {"message": "Chat message posted successfully.", "data": handle_supabase_response(data)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/chat/{event_id}", summary="Get all chat messages for an event")
async def get_chat(event_id: int):
    try:
        response = supabase.table("chat").select("*").eq("event_id", event_id).execute()
        return {"message": "Chat messages retrieved successfully.", "data": handle_supabase_response(response)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/feedback", summary="Submit feedback for an event")
async def submit_feedback(feedback: FeedbackData):
    try:
        data = supabase.table("feedback").insert(feedback.dict()).execute()
        return {"message": "Feedback submitted successfully.", "data": handle_supabase_response(data)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/feedback/{event_id}", summary="Get feedback for an event")
async def get_feedback(event_id: int):
    try:
        response = supabase.table("feedback").select("*").eq("event_id", event_id).execute()
        return {"message": "Feedback retrieved successfully.", "data": handle_supabase_response(response)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
