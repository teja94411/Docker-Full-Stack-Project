#!/bin/bash

threshold=80  # No spaces around the equal sign

# Check disk usage and compare with the threshold
df -h | awk -v thresh=$threshold '$5+0 >= thresh { 
    system("echo Warning: " $1 " is " $5 " full!")
    echo "task completed successfully"
}'
