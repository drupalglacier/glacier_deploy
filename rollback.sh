#!/bin/bash
# Load the bootstrap script.
source _bootstrap.sh



# Use the latest snapshot file by default.
SNAPSHOT=$(cd "$BACKUP_DIRECTORY" && ls | head -1)



# Get settings from the script call.
# e.g. ./snapshot.sh --snapshot-timestamp=1447516767
for i in "$@"
do
case $i in
  -st=*|--snapshot-timestamp=*)
  TIMESTAMP=${i#*=}
  DATE_STRING=$(date +"%Y-%m-%d" -d @"$TIMESTAMP")
  SNAPSHOT="${DATE_STRING}_${TIMESTAMP}.tar.gz"
  shift
  ;;
  -fn=*|--file-name=*)
  SNAPSHOT="${i#*=}.tar.gz"
  shift
  ;;
  *)
  # unknown option
  ;;
esac
done



# Create a snaphsot of the current state (if the "-no-snapshot" option isn't set).
if [ "$1" != "-no-snapshot" ]
then
  ./snapshot.sh --file-name=beforerollback
fi



# Drop the database.
( cd "$DOCROOT" && drush -y sql-drop )
# Make default directory writable so it is possible to delete it.
chmod 755 "$WORKSPACE/default"
# Delete the Drupal installation.
rm -rf $DOCROOT
# Restore from snapshot.
( drush arr "$BACKUP_DIRECTORY/$SNAPSHOT" --destination="$DOCROOT" )
