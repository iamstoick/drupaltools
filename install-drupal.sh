#!/bin/bash

# Help
usage() {
  echo ""
  echo ""
	echo "  ./install-drupal.sh [project-name] [target] [drupal-version]"
	echo ""
	echo ""
  echo "  project-name                  The name of the project. This will be the name of the downloaded Drupal folder."
	echo "  target                        The directory you wanted the Drupal will be save to."
	echo "  drupal-version                The version of Drupal you wanted to download. Options are: drupal, drupal-7.x, drupal-6"
  echo ""
  echo ""
  echo "  Examples:"
  echo ""
  echo "  ./install-drupal.sh myportfolio /home/gerald/html/ drupal         Download latest recommended release of Drupal core."
  echo "  ./install-drupal.sh myportfolio /home/gerald/html/ drupal-7.x     Download latest 7.x development version of Drupal core."
  echo "  ./install-drupal.sh myportfolio /home/gerald/html/ drupal-6       Download latest recommended release of Drupal 6.x."
  exit 1
}

# Validate the first parameter.
if [ -z "$1" ]; then
  echo "Please check your first parameter, it appears to be empty. Read the guide using ./install-drupal.sh --help"
  exit 1
else 
  # Check if the supplied parameter is --help.
	# Display the help if true.
	if [ "$1" == "--help" ]; then
		usage
	else
    PROJECT=$1
  fi
fi

# Validate second parameter.
if [ -z "$2" ]; then
  echo "Second parameter is required. Read the guide using ./install-drupal.sh --help"
  exit 1
else
  # Check if the path specified exists.
	if [ -d "$2" ]; then
		TARGETPATH=$2
	else
		echo "The path you specified does not exist."
		exit 1
	fi
fi

# Validate the third parameter.
if [ -z "$3" ]; then
  echo "Please check your second parameter, it appears to be empty. Read the guide using ./install-drupal.sh --help"
  exit 1
else 
  if [ "$3" == "drupal-7.x" ]; then
    VERSION=$3
  elif [ "$3" == "drupal-6" ]; then
    VERSION=$3
  elif [ "$3" == "drupal" ]; then
    VERSION=$3    
  else
    echo "The version you entered is wrong."
    exit 1
  fi
fi

# Navigate to the target directory.
cd $TARGETPATH

# Get the Drupal package.
echo "Downloading Drupal package. This may take several seconds or minutes depending on your internet speed..."
drush dl $VERSION

# Rename the directory.
LATESTDIR=$(ls -t . | head -1)
mv $LATESTDIR $PROJECT

# Update the permission.
#chmod 755 -R $PROJECT
# Create file directory.
#mkdir -p $PROJECT/sites/default/files
#chmod 777 -R $PROJECT/sites/default/files

# Navigate inside Drupal directory.
cd $PROJECT

# Setup process.
echo "Would you like to continue?[Yes/No]"
read CONTINUE
if [ "$CONTINUE" == "Yes" ] || [ "$CONTINUE" == "Y" ] || [ "$CONTINUE" == "y" ]; then
  # Run the setup.
	echo "Collect all necessary variables."
  echo ""
  echo "Enter your MySQL username."
  read DBUSERNAME
  echo "Enter your MySQL password."
  read DBPASSWORD
  echo "Enter the MySQL port. By default it should be 3306."
  read DBPORT
  echo "We have to create a new database. Please specify the name."
  read DBNAME
  mysqladmin -u $DBUSERNAME -p$DBPASSWORD create $DBNAME

  echo ""
  echo "Enter the admin email."
  read DRUPALADMINEMAIL
  echo "Enter the admin username."
  read DRUPALUSERNAME
  echo "Enter the Drupal admin password."
  read DRUPALPASSWORD
  echo 'Enter the Drupal sitename.'
  read DRUPALSITENAME
  echo "Enter the Drupal system email."
  read SITEEMAIL
  if [ "$VERSION" == "drupal-6" ]; then
    PROFILE="default"
	else 
	  PROFILE="standard"
	fi
  
  # Run the installer.
  drush site-install $PROFILE --db-url=mysql://$DBUSERNAME:$DBPASSWORD@localhost:$DBPORT/$DBNAME --account-mail=$DRUPALADMINEMAIL --account-name=$DRUPALUSERNAME --account-pass=DRUPALPASSWORD --site-name=$DRUPALSITENAME --site-mail=$SITEEMAIL
  
  echo "Installation done."
  exit 1
else 
  exit 1
fi




