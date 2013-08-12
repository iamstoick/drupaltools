#!/bin/bash
#
# Virtual Host creator for debian-based system.
# Written by: Gerald Z. Villorente
# This piece of code is for creating virtual host entry.
# I used this to create vhost under my Ubuntu/Apache environment.
#
# HowTo:
# This file should be executable in order to make it working.
# You can use chmod a+x createvhost.sh.


# Usage: sudo ./createVhost.sh [projectName] [fakeDomain] [projectPath]
# Ex: sudo ./createVhost.sh mydrupalblog dev.mydrupalblog.com /home/gerald/dev/html/drupalblog

# Help function.
help() {
  echo ""
  echo "This piece of code is for creating virtual host entry."
  echo ""
  echo "Usage: sudo ./createvhost.sh [projectName] [fakeDomain] [projectPath]"
  echo "Ex: sudo ./createvhost.sh mydrupalblog dev.mydrupalblog.com /home/gerald/dev/html/drupalblog"
  echo ""
  echo ""
  echo "Arguments:"  
  echo " projectName                  The name of your project. This will be the filename or the config filename."
  echo " fakeDomain                   This is a fake domain and the value of ServerName."
  echo " projectPath                  The directory where your project currently resides."

  exit 1
}

# Validate that we run this script as sudoer.
ROOT_UID=0
EXECUTOR_ID=$(id -u)
if [ "$EXECUTOR_ID" -ne "$ROOT_UID" ]; then
  echo "Must be run as sudoer."
  exit 0
fi

# Check if the parameter is help.
# Display the help if true.
if [ "$1" == "--help" ]; then
  help
fi

# Validate the first parameter.
if [ -z "$1" ]; then
  echo "Please check your first parameter, it appears to be empty. Read the guide using sudo ./createvhost.sh --help"
else 
  projectName=$1
fi

# Validate the second parameter.
if [ -z "$2" ]; then
  echo "Please check your second parameter, it appears to be empty. Read the guide using sudo ./createvhost.sh --help"
else  
  fakeDomain=$2
fi

# Validate the third parameter.
if [ -z "$3" ]; then
  echo "Please check your third parameter, it appears to be empty. Read the guide using sudo ./createvhost.sh --help"
else
  # Validate if path does exist.
  if [ ! -d "$3" ]; then
    echo "The path you specified does not exist."
    echo ""
    echo "Give me the correct path!"
    read path
    # TODO - Create a function that will check and read the user input.
    # This function will be useful so the user dont need to re-run the
    # script again. 
    if [ ! -d "$path" ]; then
      echo "Please check the correct path and run the script again."
      exit 1
    else
      projectPath=$path
    fi
  else 
    projectPath=$3
  fi
fi

# Create the config file.
touch /etc/apache2/sites-available/$1

# Insert the configuration.
echo -e "<VirtualHost *:80> \n\tServerName $fakeDomain \n\tDocumentRoot $projectPath \n</VirtualHost>" > /etc/apache2/sites-available/$1

#Update hosts file
echo "127.0.0.1  $fakeDomain" >> /etc/hosts

# Enable the config file.
a2ensite $1

# Restart Apache service.
sudo /etc/init.d/apache2 restart

echo ""
echo ""
echo "Done!"
