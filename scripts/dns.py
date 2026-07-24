import os
import sys
import time
import requests
from dotenv import load_dotenv

from utils.command import subCommand
from utils.docker import run_docker_compose_up, run_docker_compose_down, run_docker_compose

# Load variables from .env file
load_dotenv()

DNS_IP = os.getenv("DNS_IP", os.getenv('VPS_PUBLIC_IP', '0.0.0.0'))
DNS_URL = f"http://{DNS_IP}:5380"
ADMIN_PASS = os.getenv("DNS_MANAGER_PASS", "geeksForGeeks1506")
ZONE_NAME = "internal"
ZONE_FILE_PATH = "share/dns/internal.zone"

def up(exitOnError: bool = False):
    run_docker_compose_up([ 'core', 'dns' ], exitOnError=exitOnError)

def down(exitOnError: bool = False):
    run_docker_compose_down([ 'dns' ], exitOnError=exitOnError)

def wait_for_api():
    """Polls the API until the Technitium container is ready."""
    print("⏳ Waiting for Technitium API to be ready...")
    while True:
        try:
            # Technitium handles simple status checks on the base dashboard info endpoint
            response = requests.get(f"{DNS_URL}/api/dashboard/info", timeout=3)
            if response.status_code == 200:
                print("🏁 API is online!")
                break
        except requests.exceptions.RequestException:
            pass
        time.sleep(2)

def get_token():
    """Authenticates with the server and extracts the session token."""
    print("🔑 Authenticating and retrieving session token...")
    login_url = f"{DNS_URL}/api/user/login"
    
    # Technitium uses query parameters or form parameters for authentication
    params = {
        "user": "admin",
        "pass": ADMIN_PASS
    }
    
    response = requests.get(login_url, params=params)
    response.raise_for_status()
    
    data = response.json()
    if data.get("status") == "ok":
        # Technitium returns {"status": "ok", "token": "..."}
        return data.get("token")
    else:
        raise Exception(f"Authentication failed: {data.get('errorMessage')}")

def create_zone_if_missing(token, zone_name):
    """Ensures the primary zone exists on the Technitium server."""
    print(f"🛠️ Verifying / Creating Primary Zone '{zone_name}'...")
    create_url = f"{DNS_URL}/api/zones/create"
    
    params = {
        "token": token,
        "zone": zone_name,
        "type": "Primary" # Options: Primary, Secondary, Stub, Forwarder
    }
    
    response = requests.get(create_url, params=params)
    response.raise_for_status()
    
    data = response.json()
    # If it returns "ok", it was created. If it returns an error because it 
    # already exists, we can safely ignore it and move to import.
    if data.get("status") == "ok":
        print(f"✅ Zone '{zone_name}' created successfully.")
    elif "already exists" in data.get("errorMessage", "").lower():
        print(f"ℹ️ Zone '{zone_name}' already exists, proceeding to import.")
    else:
        raise Exception(f"Failed to ensure zone exists: {data.get('errorMessage')}")

def import_zone(token, zone_name, file_content):
    """Pushes a specified local zone file to Technitium via multipart upload."""
    print(f"📦 Creating and Importing '{zone_name}' via API...")
    import_url = f"{DNS_URL}/api/zones/import"
    
    # Technitium tracks session authentication via the 'token' URL parameter
    params = {
        "token": token,
        "zone": zone_name,
        "overwrite": "true"
    }
    
    # FIX 3: Pass file content as an actual multipart file dictionary upload
    files = {
        "file": (f"{zone_name}.zone", file_content, "text/plain")
    }
    
    response = requests.post(import_url, params=params, files=files)
    response.raise_for_status()
    
    data = response.json()
    if data.get("status") == "ok":
        print("✅ Zone successfully imported!")
    else:
        print(f"❌ API rejected the import: {data.get('errorMessage')}")


# ============================= MAIN =======================================

if __name__ == "__main__":
    match subCommand():
        case 'up':
            up(exitOnError=True)

        case 'down':
            down(exitOnError=True)

        case 'setup':
            try:
                # up(exitOnError=True)
                wait_for_api()
                session_token = get_token()
                create_zone_if_missing(session_token, ZONE_NAME)
                try:
                    with open(ZONE_FILE_PATH, "r", encoding="utf-8") as file:
                        raw_content = file.read()
                    # Replace and assign it back to the variable
                    content = raw_content.replace("PROXY_IP", os.getenv('VPS_PRIVATE_IP', '127.0.0.1'))
                    import_zone(session_token, ZONE_NAME, content)
                except FileNotFoundError:
                    print(f"❌ Error: Zone file not found at {ZONE_FILE_PATH}")
                    sys.exit(1)
            except Exception as e:
                print(f"💥 Deployment setup failed: {e}")
                sys.exit(1)

        case None:
            print("❌ Error: No arguments provided.")

        case _:
            run_docker_compose(['dns'], exitOnError=True)