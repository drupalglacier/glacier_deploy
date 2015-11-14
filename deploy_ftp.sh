#!/bin/bash
# Load the bootstrap script.
source _bootstrap.sh

# Ask for ftp login data if they are not set in the config.
if [ -z "$FTP_USER" ]
then
  printf "Please enter the ftp user:\n"
  read FTP_USER
fi

if [ -z "$FTP_PASS" ]
then
  printf "Please enter the ftp password:\n"
  read -s FTP_PASS
fi

if [ -z "$FTP_HOST" ]
then
  printf "Please enter the ftp host:\n"
  read FTP_HOST
fi



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
