#!/bin/bash
# Commands which fail will cause the shell script to exit immediately.
set -e

CURRENT_DIRECTORY=$(pwd)
ENVIRONMENT_DIRECTORY="$(dirname "$CURRENT_DIRECTORY")/environment"
DATE_STRING=$(date +"%Y-%m-%d")
TIMESTAMP=$(date +%s)
FILE_NAME="${DATE_STRING}_${TIMESTAMP}"

# Get settings from the script call.
# e.g. ./snapshot.sh --file-name=freshinstall
for i in "$@"
do
case $i in
    -fn=*|--file-name=*)
    FILE_NAME="${i#*=}"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
done

source $ENVIRONMENT_DIRECTORY/config.cfg

( cd $LOCAL_DOCROOT && drush -y ard --destination="$LOCAL_BACKUP_DIRECTORY/$FILE_NAME.tar.gz" )
