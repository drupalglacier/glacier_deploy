#!/bin/bash
# Commands which fail will cause the shell script to exit immediately.
set -e

# Make bash include filenames beginning with a '.'
# in the results of pathname expansion.
shopt -s dotglob



# Get the path to the glacier deploy base directory.
SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")



# Text color variables.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'



# Set the path to the environment directory and
# load the config file if available.
ENVIRONMENT_DIRECTORY="$(dirname "$BASEDIR")/environment"
if [ -f "$ENVIRONMENT_DIRECTORY/config.cfg" ]
then
  source "$ENVIRONMENT_DIRECTORY/config.cfg"
fi
