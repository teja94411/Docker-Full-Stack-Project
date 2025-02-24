# Step 1: Build the frontend
FROM node:18 as frontend-build
WORKDIR /frontend
COPY frontend/ . 
RUN npm install && npm run build

# Step 2: Set up the backend
FROM python:3.9-slim as backend
WORKDIR /backend
COPY backend/ . 
RUN pip install --no-cache-dir -r requirements.txt

# Step 3: Final container combining frontend and backend
FROM nginx:latest
WORKDIR /app

# ✅ Use the built images **from previous stages** instead of trying to pull them
COPY --from=frontend-build /frontend/dist /usr/share/nginx/html/
COPY --from=backend /backend /backend

# Expose necessary ports
EXPOSE 80 5000

# Run backend and Nginx together
CMD ["bash", "-c", "python /backend/app.py & nginx -g 'daemon off;'"]
