# Mission

# Log Generation

Log File Format
Logs are generated in the format `(%Y%m%d-%H%M).log`

Log Content
Each log entry contains the following system metrics:

- CPU Usage: Percentage of CPU used.

- Memory Usage: Percentage of memory used.

- Disk Usage: Percentage of disk space used.

- These metrics are logged in the following format
`YYYY-MM-DD HH:MM:SS | CPU: xx% | MEM: xx% | DISK: xx%`

Log Creation Interval

- Logs are generated every 5 seconds.

- If the time falls within the same minute, the log entries are appended to the same file.

- If the minute changes, a new log file is created.

# Log Upload and Notification

Log Upload to S3

- At the start of each minute, the script attempts to upload the log file from the previous minute to an S3 bucket.

- If the upload is successful, the local log file is deleted.

Failure Notification

- If the log upload fails, a Slack notification is sent using a webhook URL.

- The message includes details about the failed upload, including the file path and time of failure.