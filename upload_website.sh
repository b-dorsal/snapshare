#!/bin/bash

# Variables
BUCKET_NAME="snapshare-prod-453315-website-static"
DIRECTORY_PATH="./website"

# Upload files to Google Cloud Storage bucket
gsutil -m cp -r ${DIRECTORY_PATH}/* gs://${BUCKET_NAME}/

echo "Website contents uploaded to ${BUCKET_NAME}."
