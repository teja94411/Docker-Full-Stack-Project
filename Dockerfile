# --- Backend Stage: Prepare Python Application ---
FROM python:3.9-slim AS backend

# Create a non-root user
RUN addgroup --system appgroup && adduser --system --group appuser

WORKDIR /backend

# Install required dependencies
COPY backend/ .
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir -r requirements.txt

# Change ownership for security
RUN chown -R appuser:appgroup /backend

# --- Final Stage: Serve Frontend with Nginx ---
FROM nginx:alpine

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy backend from previous stage
COPY --from=backend /backend /app/backend

# Copy frontend static files to Nginx web root
COPY frontend/ /usr/share/nginx/html

# Ensure correct ownership
RUN chown -R appuser:appgroup /app /usr/share/nginx/html

# Switch to non-root user
USER appuser

# Expose required ports
EXPOSE 80 5000

# Start backend and Nginx
CMD ["sh", "-c", "python /app/backend/app.py & exec nginx -g 'daemon off;'"]
