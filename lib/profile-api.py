import os
from typing import Optional
from fastapi import FastAPI
from pydantic import BaseModel
from dotenv import load_dotenv
from supabase import create_client
from datetime import datetime
load_dotenv()

app=FastAPI()

class User(BaseModel):
    Username:str
    Name:str
    DOB:str
    Phone:str
    Address:str
    Email:str

@app.post("/create-profile")
async def create_profile(user:User):
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_KEY")
    supabase = create_client(url, key)
    data=user.model_dump()
    response = supabase.table("User Profile").insert(data).execute()
@app.get("/get-profile/{username}")
async def get_profile(username:str):
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_KEY")
    supabase = create_client(url, key)
    data = supabase.table("User Profile").select("*").eq("Username", username).execute()
    return data
@app.put("/update-profile/{username}")
async def update_profile(username:str,user:User):
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_KEY")
    supabase = create_client(url, key)
    data = supabase.table("User Profile").update(user.model_dump()).eq("Username", username).execute()