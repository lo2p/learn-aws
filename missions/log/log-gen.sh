#!/bin/bash

# Load environment variables from .env file
set -a
source ./ .env
set +a

# Directory where logs will be stored (from .env)
LOG_DIRECTORY="$LOG_DIRECTORY"

# Initial file name based on the current minute
LOG_FILE="$LOG_DIRECTORY/$(date +"%Y%m%d-%H%M").log"

# Function to get the current time in %Y%m%d-%H%M format (for file name)
get_current_time() {
  echo $(date +"%Y%m%d-%H%M")
}

# Infinite loop to generate logs
while true; do
    # Get the current time
    CURRENT_TIME=$(get_current_time)

    # If the current time differs from the file's time, create a new log file
    if [[ "$CURRENT_TIME" != "$(basename "$LOG_FILE" .log)" ]]; then
        LOG_FILE="$LOG_DIRECTORY/$CURRENT_TIME.log"  # Update log file name
    fi

    # Get current date and time for log entry
    DATETIME=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Collect system metrics
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
    DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//')

    # Log the data to the current log file
    echo "$DATETIME | CPU: $CPU_USAGE% | MEM: $MEM_USAGE% | DISK: $DISK_USAGE%" >> $LOG_FILE
    
    # Sleep for 5 seconds before logging again
    sleep 5
done
