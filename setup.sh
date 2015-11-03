#!/bin/bash
CURRENT_DIRECTORY=$(pwd)
ENVIRONMENT_DIRECTORY="$(dirname "$CURRENT_DIRECTORY")/environment"
PROJECT_MACHINE_NAME="project"
PROJECT_HUMAN_READABLE_NAME="Project"
ACCOUNT_MAIL="ACCOUNT_MAIL"
ACCOUNT_NAME="admin"
DATABASE="DATABASE"
DATABASE_USERNAME="DATABASE_USERNAME"
DATABASE_PASSWORD="DATABASE_PASSWORD"
DATABASE_HOST="127.0.0.1"
DATABASE_PORT=""
DATABASE_DRIVER="mysql"
DATABASE_PREFIX=""
ADMIN_BASE_THEME="shiny"

# Get settings from the script call.
# e.g. ./setup.sh --environment-directory=/path/to/envirnonment --project-machine-name=project --project-human-readable-name=Project --account-mail=mail --account-name=admin --database=database --database-username=username --database-password=password --database-host=127.0.0.1 --admin-base-theme=shiny
for i in "$@"
do
case $i in
    -ed=*|--environment-directory=*)
    ENVIRONMENT_DIRECTORY="${i#*=}"
    shift
    ;;
    -pmn=*|--project-machine-name=*)
    PROJECT_MACHINE_NAME="${i#*=}"
    shift
    ;;
    -phrn=*|--project-human-readable-name=*)
    PROJECT_HUMAN_READABLE_NAME="${i#*=}"
    shift
    ;;
    -am=*|--account-mail=*)
    ACCOUNT_MAIL="${i#*=}"
    shift
    ;;
    -an=*|--account-name=*)
    ACCOUNT_NAME="${i#*=}"
    shift
    ;;
    -db=*|--database=*)
    DATABASE="${i#*=}"
    shift
    ;;
    -dbu=*|--database-username=*)
    DATABASE_USERNAME="${i#*=}"
    shift
    ;;
    -dbpw=*|--database-password=*)
    DATABASE_PASSWORD="${i#*=}"
    shift
    ;;
    -dbh=*|--database-host=*)
    DATABASE_HOST="${i#*=}"
    shift
    ;;
    -dbpo=*|--database-port=*)
    DATABASE_PORT="${i#*=}"
    shift
    ;;
    -dbd=*|--database-driver=*)
    DATABASE_DRIVER="${i#*=}"
    shift
    ;;
    -dbpre=*|--database-prefix=*)
    DATABASE_PREFIX="${i#*=}"
    shift
    ;;
    -adbt=*|--admin-base-theme=*)
    ADMIN_BASE_THEME="${i#*=}"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
done



# Setup the basic environment.
if [ ! -f $ENVIRONMENT_DIRECTORY/config.cfg ]
then
  mkdir -p $ENVIRONMENT_DIRECTORY
  cp config.cfg.example $ENVIRONMENT_DIRECTORY/config.cfg
fi

source $ENVIRONMENT_DIRECTORY/config.cfg



# Build the make file.
if [ ! -f $LOCAL_MAKE_FILE ]
then
  mkdir -p $LOCAL_WORKSPACE/all
  cp glacier.make.example $LOCAL_MAKE_FILE
fi

drush -y make $LOCAL_MAKE_FILE $LOCAL_DOCROOT/tmp
rsync -av $LOCAL_DOCROOT/tmp/ $LOCAL_DOCROOT
rm -Rf $LOCAL_DOCROOT/tmp



# Install Drupal.
( cd $LOCAL_DOCROOT && drush -y site-install minimal --account-mail=$ACCOUNT_MAIL --account-name=$ACCOUNT_NAME --db-url="$DATABASE_DRIVER://$DATABASE_USERNAME:$DATABASE_PASSWORD@$DATABASE_HOST/$DATABASE" --site-name="$PROJECT_HUMAN_READABLE_NAME" )



# Replace the settings.php generated by the install process
# with a modified version.
chmod -R 755 $LOCAL_WORKSPACE/default
chmod 755 $LOCAL_WORKSPACE/default/settings.php
rm -f $LOCAL_WORKSPACE/default/settings.php
cp settings.php.example $LOCAL_WORKSPACE/default/settings.php

# Replace placeholder strings in the main settings file.
sed -i -e "s#PATH_TO_LOCAL_SETTINGS_PLACEHOLDER#$ENVIRONMENT_DIRECTORY/settings.local.php#g" $LOCAL_WORKSPACE/default/settings.php

# Set secure permissions.
chmod 444 $LOCAL_WORKSPACE/default/settings.php

if [ ! -f $ENVIRONMENT_DIRECTORY/settings.local.php ]
then
  cp settings.local.php.example $ENVIRONMENT_DIRECTORY/settings.local.php

  # Replace database credentials placeholder strings.
  sed -i -e "s#DATABASE_PLACEHOLDER#$DATABASE#g" $ENVIRONMENT_DIRECTORY/settings.local.php
  sed -i -e "s#DATABASE_USERNAME_PLACEHOLDER#$DATABASE_USERNAME#g" $ENVIRONMENT_DIRECTORY/settings.local.php
  sed -i -e "s#DATABASE_PASSWORD_PLACEHOLDER#$DATABASE_PASSWORD#g" $ENVIRONMENT_DIRECTORY/settings.local.php
  sed -i -e "s#DATABASE_HOST_PLACEHOLDER#$DATABASE_HOST#g" $ENVIRONMENT_DIRECTORY/settings.local.php
  sed -i -e "s#DATABASE_PORT_PLACEHOLDER#$DATABASE_PORT#g" $ENVIRONMENT_DIRECTORY/settings.local.php
  sed -i -e "s#DATABASE_DRIVER_PLACEHOLDER#$DATABASE_DRIVER#g" $ENVIRONMENT_DIRECTORY/settings.local.php
  sed -i -e "s#DATABASE_PREFIX_PLACEHOLDER#$DATABASE_PREFIX#g" $ENVIRONMENT_DIRECTORY/settings.local.php

  # Generate a random string to use as hash salt in the settings.local.php.
  RANDOM_STRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
  sed -i -e "s#RANDOM_STRING_PLACEHOLDER#$RANDOM_STRING#g" $ENVIRONMENT_DIRECTORY/settings.local.php
fi



# Theme configuration.
( cd $LOCAL_DOCROOT && drush -y en glacier )
( cd $LOCAL_DOCROOT && drush cc all )
( cd $LOCAL_DOCROOT && drush -y glacier $PROJECT_MACHINE_NAME )
mkdir -p $LOCAL_WORKSPACE/all/themes/custom
mv $LOCAL_WORKSPACE/all/themes/external/$PROJECT_MACHINE_NAME $LOCAL_WORKSPACE/all/themes/custom
( cd $LOCAL_DOCROOT && drush -y en $PROJECT_MACHINE_NAME )
( cd $LOCAL_DOCROOT && drush -y vset theme_default $PROJECT_MACHINE_NAME )
( cd $LOCAL_DOCROOT && drush -y dis bartik )
# Create the admin sub theme.
ADMIN_SUB_THEME="${PROJECT_MACHINE_NAME}_admin"
ADMIN_SUB_THEME_PATH="$LOCAL_WORKSPACE/all/themes/custom/$ADMIN_SUB_THEME"
cp -R ADMIN_SUB_THEME $LOCAL_WORKSPACE/all/themes/custom
mv $LOCAL_WORKSPACE/all/themes/custom/ADMIN_SUB_THEME $ADMIN_SUB_THEME_PATH
sed -i -e "s#ADMIN_SUB_THEME#$ADMIN_SUB_THEME#g" $ADMIN_SUB_THEME_PATH/css/ADMIN_SUB_THEME.css
sed -i -e "s#ADMIN_SUB_THEME#$ADMIN_SUB_THEME#g" $ADMIN_SUB_THEME_PATH/js/ADMIN_SUB_THEME.js
sed -i -e "s#ADMIN_SUB_THEME#$ADMIN_SUB_THEME#g" $ADMIN_SUB_THEME_PATH/ADMIN_SUB_THEME.info
sed -i -e "s#ADMIN_BASE_THEME#$ADMIN_BASE_THEME#g" $ADMIN_SUB_THEME_PATH/ADMIN_SUB_THEME.info
sed -i -e "s#ADMIN_SUB_THEME#$ADMIN_SUB_THEME#g" $ADMIN_SUB_THEME_PATH/template.php
mv $ADMIN_SUB_THEME_PATH/css/ADMIN_SUB_THEME.css $ADMIN_SUB_THEME_PATH/css/$ADMIN_SUB_THEME.css
mv $ADMIN_SUB_THEME_PATH/js/ADMIN_SUB_THEME.js $ADMIN_SUB_THEME_PATH/js/$ADMIN_SUB_THEME.js
mv $ADMIN_SUB_THEME_PATH/ADMIN_SUB_THEME.info $ADMIN_SUB_THEME_PATH/$ADMIN_SUB_THEME.info
( cd $LOCAL_DOCROOT && drush -y vset admin_theme $ADMIN_SUB_THEME )



# TODO: create deployment helper module (PROJECT_NAME_deploy?) inside sites/all/modules/custom
# TODO: install modules (via deployment dependencies or update / install hook)
# TODO: settings (via deployment module update / install)
# TODO: create a snapshot of the fresh install (do not delete this)
