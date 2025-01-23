#!/bin/sh

if [ -n "$BUCKET_NAME" ]; then
  # Start the MinIO server in the background
  minio server /data &
  
  # Wait until the MinIO server is up and running
  sleep 5
  
  # Configure the mc client
  mc alias set myminio http://127.0.0.1:$PORT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
  
  # Create a bucket
  mc mb myminio/$BUCKET_NAME
  
  # Run the MinIO server in the foreground
  wait
else
  # Start the MinIO server in the foreground
  minio server /data
fi