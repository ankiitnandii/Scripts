#!/bin/bash

# Enforces that it be executed with superuser (root) privileges.

if [ "$(id -u)" -ne 0 ]; then
    echo "You are not the root"
    exit 1
fi

# Prompts the person who executed the script to enter the username (login)

read -p 'Enter a username for the account: ' USER_NAME

# Prompts the person who executed the script to enter the name for person who will be using the account

read -p 'Enter the real name of the user: ' COMMENT

# Prompts the person who executed the script to enter the initial password for the account.

read -p 'Enter the password: ' PASSWD

# Creates a new user on the local system with the input provided by the user.

useradd -c "${COMMENT}" -m ${USER_NAME}

# Set the password of the user and force the user to reset at first login

echo "${PASSWD}" | passwd --stdin -e ${USER_NAME}

# Informs the user if the account was not able to be created for some reason. If the account is not created, the script is to return an exit status of 1.

if [ $? -ne 0 ]; then
    echo "Your account was not created!"
    exit 1
fi

# Displays the username, password, and host where the account was created.

echo "The username is: ${USER_NAME}"
echo "The password is: ${PASSWD}"
echo "The host on which the script executed is: ${HOSTNAME}"

