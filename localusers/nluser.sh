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

# Uses the first argument provided on the command line as the username for the account.

USERNAME=$1

# Remaining arguments (if any) are treated as comment

shift

COMMENT=$@

useradd -m -c "$COMMENT" "$USERNAME" &> /dev/null

# Check if the user is created.

if [[ $? -ne 0 ]]
then
	echo "Sorry, the user could not be created!" >&2
	exit 1
fi

#Automatically generates a password for the new account.

PASSWORD=$(date +%s%N${RANDOM}| sha256sum | head -c 48)
echo "${PASSWORD}" | passwd --stdin "${USERNAME}" &> /dev/null

#Check to see if the password is created.

if [[ $? -ne 0 ]]
then
	echo "Your password could not be generated!" >&2
	exit 1
fi

#Forces user to change password on first login

passwd -e ${USERNAME} &> /dev/null

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
exit 0

#Suppress all other commands.
#We can do it by suppressing the error messages.
