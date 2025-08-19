#!/bin/bash

# Load environment variables from .env file
set -a
source ./ .env
set +a

# Configurations loaded from .env
S3_BUCKET="$S3_BUCKET"
LOG_DIRECTORY="$LOG_DIRECTORY"
SLACK_WEBHOOK_URL="$SLACK_WEBHOOK_URL"

# Get the log file from the last minute
LAST_MINUTE=$(date --date='1 minute ago' +"%Y%m%d-%H%M")
LOG_FILE="$LOG_DIRECTORY/$LAST_MINUTE.log"
LOG_FILE_S3="$S3_BUCKET/$LAST_MINUTE.log"

# Function to send a Slack notification
send_slack_notification() {
  local message=$1
  curl -X POST -H 'Content-type: application/json' --data "{
    \"text\": \"$message\"
  }" "$SLACK_WEBHOOK_URL"
}

# Upload the log file to S3
upload_log_to_s3() {
  aws s3 cp "$LOG_FILE" "$LOG_FILE_S3"
  if [ $? -eq 0 ]; then
    echo "Log file uploaded successfully to $LOG_FILE_S3"
    return 0
  else
    echo "Error uploading log file to S3" >&2
    return 1
  fi
}

# Delete the local log file after successful upload
delete_local_log_file() {
  if [ -f "$LOG_FILE" ]; then
    rm "$LOG_FILE"
    echo "Local log file $LOG_FILE deleted"
  else
    echo "Log file $LOG_FILE does not exist"
  fi
}

# Main function
main() {
  # Ensure the log file exists before attempting upload
  if [ ! -f "$LOG_FILE" ]; then
    echo "Log file $LOG_FILE does not exist"
    send_slack_notification "Log file $LOG_FILE does not exist. Please check the log generation process."
    return 1
  fi
  
  # Attempt to upload to S3
  upload_log_to_s3
  if [ $? -eq 0 ]; then
    delete_local_log_file  # If upload succeeds, delete the local file
  else
    send_slack_notification "Failed to upload log file $LOG_FILE to S3."
  fi
}

# Execute the main function
main
