#!/bin/bash
source config.cfg

if [ ! -f $LOCAL_MAKE_FILE ]
then
  mkdir -p $LOCAL_DIRECTORY
  cp glacier.make.example $LOCAL_MAKE_FILE
fi

drush -y make $LOCAL_MAKE_FILE $LOCAL_DOCROOT/tmp
# mv $LOCAL_DOCROOT/tmp/{.,}* $LOCAL_DOCROOT
rsync -av $LOCAL_DOCROOT/tmp/ $LOCAL_DOCROOT
# (after checking)
rm -Rf $LOCAL_DOCROOT/tmp
