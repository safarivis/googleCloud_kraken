#!/usr/bin/env fish

# Run gcloud commands using Docker
docker run --rm -i \
  -v /home/ldp/Work/Trading:/workspace \
  -v $HOME/.config/gcloud:/root/.config/gcloud \
  -w /workspace \
  google/cloud-sdk:latest $argv
