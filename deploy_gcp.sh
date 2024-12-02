#!/bin/bash

# Set your GCP project ID
PROJECT_ID="kraken-443513"
REGION="us-central1"  # Choose your preferred region
SERVICE_NAME="trading-bot"

# Install Google Cloud SDK if not already installed
if ! command -v gcloud &> /dev/null; then
    echo "Installing Google Cloud SDK..."
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-446.0.0-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-446.0.0-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh --quiet
    source ./google-cloud-sdk/path.bash.inc
    rm google-cloud-cli-446.0.0-linux-x86_64.tar.gz
fi

# Initialize gcloud and set project
gcloud init --console-only
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    containerregistry.googleapis.com

# Build and push the Docker image
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"
docker build -t $IMAGE_NAME .
docker push $IMAGE_NAME

# Deploy to Cloud Run
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_NAME \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --port 8000 \
    --set-env-vars="$(cat .env | tr '\n' ',')"

echo "Deployment complete! Your service will be available at the URL shown above."
echo "To view logs: gcloud logging read \"resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME\""
