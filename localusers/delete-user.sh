#!/bin/bash

#This script deletes existing users.

# Function to display usage
function usage {
    echo "Usage: ${0} [-dr] <LOGIN>"
    echo "  -d Deletes accounts."
    echo "  -r Removes the home directory."
    exit 1
}

# Enforces that it be executed with superuser (root) privileges.
if [[ "${UID}" -ne 0 ]]
then
    echo 'Permissions denied. Please contact system administrator' >&2
    exit 1
fi

# Parse options
while getopts dra option
do
    case "${option}" in
        d)
           DELETE=true
           ;;
	r)
           REMOVE=true
	   ;;
        *)
           usage
           ;;
    esac
done

# Remove the options from the positional parameters
shift $((OPTIND-1))

# Check if at least one account name is supplied
if [ "$#" -eq 0 ]
then
    usage
fi

# Loop through all account names provided
for account_name in "$@"
do
    # Get the UID of the account
    uid=$(id -u ${account_name}) &>/dev/null

    # Refuses to disable or delete any accounts that have a UID less than 1,000.
    if [[ "${uid}" -lt 1000 ]]
    then
        echo 'You cannot delete this account' >&2
        exit 1
    fi
# Remove the home directory

if [ "${REMOVE}" = true ]
then
     if (rm -r /home/$account_name)
     then
         echo "The home directory of the user ${account_name} is successfully removed"
	 exit 0
     else
            echo "Failed to remove home directory for account: $account_name" >&2
            exit 1
     fi
fi

#Deletes the user

if [ "${DELETE}" = true ]
then
    if (userdel $account_name)
    then
	echo "The user $account_name is deleted successfully."
	exit 0
    else
	echo "The user $account_name is NOT deleted" >&2
	exit 1
    fi
fi
done


