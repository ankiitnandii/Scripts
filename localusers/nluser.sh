#!/bin/bash

# Enforces that it be executed with superuser (root) privileges.
if [[ ${UID} -ne 0 ]]
then
        echo "You are not root. Please execute this script with root privileges" >&2
        exit 1
fi

# Provides a usage statement much like you would find in a man page if the user does not supply an account name on the command line and returns an exit status of 1.
if [[ "${#}" -lt 1 ]]
then
        echo "Usage: $0 <username> [comment]" >&2
        exit 1
fi

# Uses the first argument provided on the command line as the username for the account.  Any remaining arguments on the commandline will be treated as the comment for the account.
USERNAME=$1

shift           # Remove the first argument from the list of arguments
COMMENT=$@      # Remaining arguments (if any) are treated as comment

useradd -m -c "$COMMENT" "$USERNAME"

# Automatically generates a password for the new account.
PASSWORD=$(date +%s%N${RANDOM}| sha256sum | head -c 48)
echo "${PASSWORD}" | passwd -e --stdin "${USERNAME}"

# Informs the user if the account was not able to be created for some reason.
if [ $? -eq 0 ]; then
    echo "User $USERNAME created successfully."
else
    echo "Failed to create user $USERNAME." >&2
    exit 1
fi

# Displays the username, password, and host where the account was created.
echo "The username for whom the account is created is: ${USERNAME}"
echo "Generated password for user $USERNAME: $PASSWORD"
echo "The host where the account is created is: ${HOSTNAME}"

#Suppress all other commands.
#We can do it by suppressing the error messages.
