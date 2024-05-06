#!/bin/bash

#Checks if the user has root privileges.

if [[ "${UID}" -ne 0 ]]
then
   echo "Permission denied. Please run with root privileges.Please contact system administrator" >&2
   exit 1
fi

# Checks if a file is not provided
if [[ -z "${1}" ]]
then
   echo 'Please provide a valid file name' >&2
   exit 1
fi

# Checks if the file cannot be read
if [[ ! -r "${1}" ]]
then
   echo 'This file is not present or not readable. Please check the file name and try again!' >&2
   exit 1
fi

#Print the header.

echo "Count,IP,Location" > attackers.csv
 
#Counts the number of failed login attempts by IP address.If there are any IP addresses with more than 10 failed login attempts, the number of attempts made, the IP address from which those attempts were made, and the location of the IP address will be displayed.(Hint: use the geoiplookup command to find the location of the IP address.)

# Extract IP addresses with failed SSH login attempts and count them
LOCAL_FILE="${1}"
grep 'Failed password' "${LOCAL_FILE}" | grep 'sshd' | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | while read count ip
do
    # If there are more than 10 failed login attempts
    if [ $count -gt 10 ]
    then
        # Display the number of attempts, the IP address, and the location
        echo "Number of attempts: $count" &>/dev/null
        echo "IP address: $ip" &>/dev/null
        echo "Location: $(geoiplookup $ip | awk -F': ' '{print $2}')" &>/dev/null
        echo "-------------------------" &>/dev/null

#Produces output in CSV (comma-separated values) format with a header of "Count,IP,Location".

         echo "$count,$ip,$location" >> attackers.csv
      fi
done