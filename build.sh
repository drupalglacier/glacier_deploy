#!/bin/bash
# Load the bootstrap script.
source _bootstrap.sh



# Warn the user that features will be reverted.
if [ "$ENVIRONMENT" == "dev" ]
then
  printf "${YELLOW}Warning: features will be reverted! Are you sure you want to proceed? [y/n]${NC}\n"
  read YN

  if [ "$YN" != "y" ]
  then
    printf "${RED}Build process cancelled! Update your features and run again.${NC}\n"
    exit 0
  fi
fi



# Create a snaphsot of the current state if the "-no-snapshot" option isn't set.
if [ "$1" != "-no-snapshot" ]
then
  ./snapshot.sh
fi



# Enable the site maintenance mode (in none dev environments).
if [ "$ENVIRONMENT" != "dev" ]
then
  ( cd $DOCROOT && drush -y vset maintenance_mode 1 )
fi



# Build the make file.
( cd $DOCROOT && drush -y make $MAKE_FILE ./ )



# Apply any database updates required (as with running update.php).
( cd $DOCROOT && drush -y updb )



# Revert all enabled feature modules on your site.
( cd $DOCROOT && drush -y fra )



# Disable the site maintenance mode.
( cd $DOCROOT && drush -y vset maintenance_mode 0 )
