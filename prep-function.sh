#!/bin/bash

echo "Starting function preparation..."

# Remove any existing zip file
rm -f function.zip

# Go to the function directory
cd function

# Zip all files in the directory
zip -r ../function.zip .

echo "Function zip created successfully!"

# Optional: Show the contents of the zip file
echo "Zip contents:"
unzip -l ../function.zip