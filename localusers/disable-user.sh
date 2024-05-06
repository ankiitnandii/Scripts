#!/bin/bash

# Function to display usage
function usage {
    echo "Usage: ${0} [-dra] <LOGIN>..."
    echo "  -d Deletes accounts instead of disabling them."
    echo "  -r Removes the home directory associated with the account(s)."
    echo "  -a Creates an archive of the home directory associated with the accounts(s) and stores the archive in the /archives directory."
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
        a) 
	   ARCHIVE=true
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

    # Disable the account
    
    if [ "${DISABLE}" = true ]
    then	
        if (chage -E 0 $account_name)
        then
            echo "The ${account_name} has been disabled"
        else
            echo "Failed to disable account: $account_name" >&2
	    exit 1 
        fi
    fi

    #Remove the home directory

    if [ "${REMOVE}" = true ]
    then
        if (rm -r /home/$account_name)
        then
            echo "The home directory of the user ${account_name} is successfully removed"
        else
            echo "Failed to remove home directory for account: $account_name" >&2
	    exit 1
        fi
    fi

    #Archive the home directory

    if [ "${ARCHIVE}" = true ]
    then
	mkdir archives &>/dev/null
        if tar -zcf archives/${account_name}.tar.gz /home/$account_name
        then
            echo "The account ${account_name} has been archived"
        else
            echo "Failed to archive home directory for account: $account_name" >&2
	    exit 1
        fi
    fi
done
