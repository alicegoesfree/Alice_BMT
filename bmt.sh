#!/bin/bash

# Get the current date in "YYYY-MM-DD" format
current_date=$(date +%Y-%m-%d)

# Calculate the time of the beginning of the day in seconds since the epoch
start_of_day_seconds=$(date -d "$current_date" +%s)

# Get the current time with the maximum precision
current_time_seconds=$(date +%s.%N | awk -F. '{print $1"."substr(sprintf("%.9f", $2/1000000000), 3)}')

# Calculate the exact time elapsed since midnight
time_since_midnight_seconds=$(echo "$current_time_seconds - $start_of_day_seconds" | bc -l)

# Adjust for times before 2 AM UTC (7200 seconds = 2 hours). This assumes the script runs before 2 AM UTC.
if (( $(echo "$time_since_midnight_seconds < 7200" | bc -l) )); then
  time_since_midnight_seconds=$(echo "$time_since_midnight_seconds + 86400" | bc -l)
fi

# 2) Calculate the offset of the current time in seconds relative to UTC+1
utc_offset_hours=$(date +%z) #Get UTC offset
utc_offset_hours=$(echo "${utc_offset_hours:1}" / 100 - 1 | bc) # Extract hours and adjust for UTC+1
utc_offset_seconds=$(echo "$utc_offset_hours * 3600" | bc) #Convert hours to seconds

# 3) Calculate the exact time from the beginning of the day according to UTC+1
total_time_utc1=$(echo "$time_since_midnight_seconds - $utc_offset_seconds " | bc)

# 4) Divide the result by 86.4 to get the Internet time (86400 seconds in a day)
internet_time=$(echo "scale=2; $total_time_utc1 / 86.4" | bc) #Calculate internet time

i=$(printf "%.2f" "$internet_time") #Format to two decimal places

# 5) Pad with leading zeros for single and double-digit internet times

# Check if internet time is less than 10, add leading 00
if (( $(echo "$internet_time < 10" | bc -l) )); then
		i="00${i}"
# Check if internet time is less than 100, add leading 0
elif (( $(echo "$internet_time < 100" | bc -l) )); then
		i="0${i}"
fi

echo -n $i #Output internet time
