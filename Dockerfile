# Use Python 3.9 slim as base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd -m -r -s /bin/bash trader \
    && mkdir -p /app/data /app/logs \
    && chown -R trader:trader /app

# Copy requirements first to leverage Docker cache
COPY --chown=trader:trader requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY --chown=trader:trader . .

# Make entrypoint script executable
RUN chmod +x /app/docker-entrypoint.sh

# Switch to non-root user
USER trader

# Create volumes for data and logs
VOLUME ["/app/data", "/app/logs"]

# Expose the port your application will run on
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Set the entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]
