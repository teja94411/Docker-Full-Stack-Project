#!/bin/sh

# Enable debugging logs (for troubleshooting in production)
set -e

# Start the Python backend in the background with logging
python /backend/app.py > /backend/app.log 2>&1 &

# Start Nginx in the foreground (this keeps the container running)
exec nginx -g "daemon off;"
