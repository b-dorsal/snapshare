import os
import re
from google.cloud import storage
from google.auth import default
from google.auth.transport import requests
from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)


EVENT_KEY_PATTERN = r'^[a-zA-Z]{3}\d{4}$'
BUCKET_NAME = os.environ.get("BUCKET_NAME")
CORS_DOMAIN = os.environ.get("CORS_DOMAIN")
@app.route("/get-upload-url", methods=["POST", "OPTIONS"])
def get_upload_url(request):


    if request.method == "OPTIONS":
        headers = {
            "Access-Control-Allow-Origin": CORS_DOMAIN,
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type"
        }
        return jsonify({"status": "success"}), 200, headers

    event_key = request.json.get('eventKey', None)
    if not event_key or not re.match(EVENT_KEY_PATTERN, event_key):
        return jsonify({"error": "A valid event key is required"}), 400
    
    
    credentials, project = default()
    if credentials.token is None:
        credentials.refresh(requests.Request())
    client = storage.Client(credentials=credentials, project=project)
    # client = storage.Client()  # Uses default credentials from Cloud Function
    bucket = client.bucket(BUCKET_NAME)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    file_list = request.json.get('files', [])
    signed_urls = []
    
    for file_info in file_list:
        filename = file_info.get("name", "unknown")
        content_type = file_info.get("contentType", "application/octet-stream")

        # Create unique filename with timestamp
        blob = bucket.blob(f"uploads/{timestamp}/{filename}")

        # Generate signed URL
        url = blob.generate_signed_url(
            version="v4",
            expiration=3600,  # URL valid for 1 hour
            method="PUT",
            content_type=content_type,
            service_account_email="600560866587-compute@developer.gserviceaccount.com",
            access_token=credentials.token,
        )

        signed_urls.append({"name": filename, "url": url})
    response = jsonify({"urls": signed_urls})
    response.headers.add("Access-Control-Allow-Origin", CORS_DOMAIN)
    response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS")
    response.headers.add("Access-Control-Allow-Headers", "Content-Type")

    return response
