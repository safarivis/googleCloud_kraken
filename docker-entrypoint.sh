#!/bin/bash
set -e

# Function to wait for a service to be ready
wait_for_service() {
    local service=$1
    local port=$2
    local retries=30
    local wait=1
    
    echo "Waiting for $service to be ready..."
    while ! nc -z localhost $port; do
        if [ "$retries" -eq 0 ]; then
            echo "$service is not available"
            exit 1
        fi
        retries=$((retries-1))
        sleep $wait
    done
    echo "$service is ready!"
}

# Create necessary directories if they don't exist
mkdir -p /app/data /app/logs

# Set proper permissions
chown -R trader:trader /app/data /app/logs

# Start the health check service
python health_check.py &
wait_for_service "Health Check Service" 8000

# Start the trading bot
echo "Starting trading bot..."
exec python live_vol_adaptive.py
