#!/bin/bash
ENVIRONMENT_DIRECTORY="../environment"

# Override the environemnt directory setting.
# e.g. ./setup.sh --environment-directory=/env/directory/enviroment
for i in "$@"
do
case $i in
    -ed=*|--environment-directory=*)
    ENVIRONMENT_DIRECTORY="${i#*=}"
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
  mkdir -p $LOCAL_DIRECTORY
  cp glacier.make.example $LOCAL_MAKE_FILE
fi

drush -y make $LOCAL_MAKE_FILE $LOCAL_DOCROOT/tmp
rsync -av $LOCAL_DOCROOT/tmp/ $LOCAL_DOCROOT
rm -Rf $LOCAL_DOCROOT/tmp



# TODO: Create settings.local.php for the current environemnt and include it in the regular settings.php
# TODO: Install Drupal
# TODO: Install Modules
# TODO: create sub theme, admin sub theme and deployment helper module
# TODO: settings
