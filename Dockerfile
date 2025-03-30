# Step 1: Build the frontend using a secure Nginx base image
FROM nginx:1.25.3-alpine AS frontend-build
WORKDIR /usr/share/nginx/html
COPY frontend/ . 

# Step 2: Set up the backend using a minimal Python image
FROM python:3.9-slim AS backend
WORKDIR /backend

# Create a non-root user for security
RUN useradd -m appuser
USER appuser

# Copy backend files
COPY backend/ . 

# Install dependencies securely
RUN pip install --no-cache-dir -r requirements.txt

# Step 3: Final production container with frontend + backend
FROM nginx:1.25.3-alpine

WORKDIR /app

# Copy frontend files to Nginx's web root
COPY --from=frontend-build /usr/share/nginx/html /usr/share/nginx/html

# Copy backend files
COPY --from=backend /backend /backend

# Expose necessary ports
EXPOSE 80 5000

# Copy entrypoint script and set execute permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use non-root user for security
RUN adduser -D appuser
USER appuser

# Run entrypoint script
CMD ["/entrypoint.sh"]
