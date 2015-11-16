#!/bin/bash
# Load the bootstrap script.
source _bootstrap.sh



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



( cd $DOCROOT && drush -y cc all )
( cd $DOCROOT && drush -y ard --destination="$BACKUP_DIRECTORY/$FILE_NAME.tar.gz" )
