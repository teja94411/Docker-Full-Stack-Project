# --- Backend Stage: Build Dependencies Securely ---
FROM python:3.9-slim AS backend-build

# Set a non-root user early
RUN addgroup --system appgroup && adduser --system --group appuser

WORKDIR /backend

# Install dependencies securely
COPY backend/ .
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir -r requirements.txt

# --- Frontend Stage: Build Frontend ---
FROM node:18-alpine AS frontend-build

WORKDIR /frontend
COPY frontend/ .
RUN npm ci && npm run build

# --- Final Stage: Production ---
FROM nginx:1.25-alpine

# Set secure user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy backend from build stage
COPY --from=backend-build /backend /app/backend

# Copy frontend from build stage
COPY --from=frontend-build /frontend/build /usr/share/nginx/html

# Change ownership for security
RUN chown -R appuser:appgroup /app /usr/share/nginx/html

# Switch to non-root user
USER appuser

# Expose necessary ports
EXPOSE 80 5000

# Start backend & Nginx securely
CMD ["sh", "-c", "python /app/backend/app.py & exec nginx -g 'daemon off;'"]
