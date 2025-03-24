# Step 1: Build the frontend using Nginx
FROM nginx:latest as frontend-build
WORKDIR /usr/share/nginx/html
COPY frontend/ . 

# Step 2: Set up the backend using Python
FROM python:3.9-slim as backend
WORKDIR /backend
COPY backend/ . 
RUN pip install --no-cache-dir -r requirements.txt

# Step 3: Final container combining frontend and backend
FROM nginx:latest

WORKDIR /app

# Copy frontend files to Nginx's web root
COPY --from=frontend-build /usr/share/nginx/html /usr/share/nginx/html

# Copy backend files
COPY --from=backend /backend /backend

# Expose necessary ports
EXPOSE 80 5000

# Start backend and Nginx
CMD ["bash", "-c", "python /backend/app.py & nginx -g 'daemon off;'"]
