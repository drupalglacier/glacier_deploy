#!/bin/bash
# Commands which fail will cause the shell script to exit immediately.
set -e

CURRENT_DIRECTORY=$(pwd)
ENVIRONMENT_DIRECTORY="$(dirname "$CURRENT_DIRECTORY")/environment"

source $ENVIRONMENT_DIRECTORY/config.cfg

# Create a snaphsot of the current state.
./snapshot.sh



FTP_URL="ftp://$FTP_USER:$FTP_PASS@$FTP_HOST"
lftp -c "set ftp:list-options -a;
open '$FTP_URL';
lcd $LOCAL_DOCROOT;
cd $FTP_DOCROOT;
mirror --reverse \
       --verbose \
       $FTP_DELETE \
       $FTP_EXCLUDE \
       --exclude sites/default/files/ \
       --exclude node_modules/ \
       --exclude .git/ \
       --exclude .DS_Store \
       --exclude .htaccess \
       --exclude settings.local.php"
