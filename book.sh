#!/bin/bash

echo "Starting the Jenkins job..."

# Example task 1: Print the current date and time
echo "Current date and time: $(date)"

# Example task 2: List files in the current directory
echo "Listing files in the current directory:"
ls -l

# Example task 3: Running a simple command, like a simple build (e.g., Maven)
echo "Running Maven build..."
mvn clean install

echo "running backend server"

echo "Jenkins job completed successfully!"
