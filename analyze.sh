#!/bin/bash

FILE_TO_ANALYZE=$1

# Check if the file is provided
if [ -z "$FILE_TO_ANALYZE" ]; then
  echo "Usage: $0 <file-to-analyze>"
  exit 1
fi

# Check if the file exists
if [ ! -f "$FILE_TO_ANALYZE" ]; then
  echo "File not found: $FILE_TO_ANALYZE"
  exit 1
fi

# Step 1: File information
echo "File Information:"
file "$FILE_TO_ANALYZE"
echo "----------------"

# Step 2: Extract strings
echo "Extracted Strings:"
strings "$FILE_TO_ANALYZE" | head -n 20
echo "----------------"

# Step 3: Run ClamAV scan
echo "Running ClamAV Scan:"
clamscan "$FILE_TO_ANALYZE"
echo "----------------"

# Step 4: YARA scan (if rules are available)
if [ -d "/yara-rules" ]; then
  echo "Running YARA Scan:"
  yara -r /yara-rules "$FILE_TO_ANALYZE"
  echo "----------------"
fi

# Step 5: Start tcpdump in the background to monitor network traffic
echo "Starting network traffic capture with tcpdump..."
tcpdump -i any -w /analysis/network_capture.pcap &

# Step 6: Trace system calls with strace (only for executable files)
if [ -x "$FILE_TO_ANALYZE" ]; then
  echo "Tracing system calls with strace..."
  strace -f -o /analysis/strace_output.txt "$FILE_TO_ANALYZE" &
  STRACE_PID=$!
  sleep 5  # Allow some time for the process to execute

  # Kill strace and the process after a timeout (e.g., 10 seconds)
  sleep 10
  echo "Stopping strace..."
  kill -SIGTERM $STRACE_PID
fi

# Step 7: Stop tcpdump
echo "Stopping network traffic capture..."
pkill -SIGINT tcpdump
echo "----------------"

# Step 8: Custom Python analysis script (if any)
# python3 custom_analysis.py "$FILE_TO_ANALYZE"

echo "Analysis complete. Results stored in /analysis directory."
