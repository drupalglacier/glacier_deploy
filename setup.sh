#!/bin/bash
# Load the bootstrap script.
source _bootstrap.sh



# Default variables.
PROJECT_MACHINE_NAME="project"
PROJECT_HUMAN_READABLE_NAME="Project"
ACCOUNT_MAIL=""
ACCOUNT_NAME="admin"
DATABASE=""
DATABASE_USERNAME=""
DATABASE_PASSWORD=""
DATABASE_HOST="127.0.0.1"
DATABASE_PORT=""
DATABASE_DRIVER="mysql"
DATABASE_PREFIX=""
ADMIN_BASE_THEME="shiny"



# Get settings from the script call.
# e.g. ./setup.sh --project-machine-name=project --project-human-readable-name=Project --account-mail=mail --account-name=admin --database=database --database-username=username --database-password=password --database-host=127.0.0.1 --admin-base-theme=shiny
for i in "$@"
do
case $i in
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
if [ ! -d "$ENVIRONMENT_DIRECTORY" ]
then
  mkdir -p "$ENVIRONMENT_DIRECTORY"
fi

if [ ! -f "$ENVIRONMENT_DIRECTORY/config.cfg" ]
then
  cp files/config.cfg.example "$ENVIRONMENT_DIRECTORY/config.cfg"

  # Replace project machine name placeholder string.
  sed -i -e "s#PROJECT_MACHINE_NAME_PLACEHOLDER#$PROJECT_MACHINE_NAME#g" "$ENVIRONMENT_DIRECTORY/config.cfg"
fi

source "$ENVIRONMENT_DIRECTORY/config.cfg"



# Check if all required variables, that don't have a default value, are set.
if [ -z "$ACCOUNT_MAIL" ]
then
  printf "${RED}Variable ACCOUNT_MAIL not set${NC}\n"
  exit 3
fi

if [ -z "$DATABASE" ]
then
  printf "${RED}Variable DATABASE not set${NC}\n"
  exit 3
fi

if [ -z "$DATABASE_USERNAME" ]
then
  printf "${RED}Variable DATABASE_USERNAME not set${NC}\n"
  exit 3
fi

if [ -z "$DATABASE_PASSWORD" ]
then
  printf "${RED}Variable DATABASE_PASSWORD not set${NC}\n"
  exit 3
fi



# Build the make file.
if [ ! -f "$MAKE_FILE" ]
then
  mkdir -p "$WORKSPACE/all"
  cp files/glacier.make.example "$MAKE_FILE"
fi

drush -y make "$MAKE_FILE" "$DOCROOT/tmp"
rsync -av "$DOCROOT/tmp/" "$DOCROOT"
rm -Rf "$DOCROOT/tmp"

if [ ! -f "$MAKE_FILE_FEATURES" ]
then
  cp files/glacier.features.make.example "$MAKE_FILE_FEATURES"
fi

( cd $DOCROOT && drush -y make $MAKE_FILE_FEATURES ./ --no-core )



# Install Drupal.
( cd "$DOCROOT" && drush -y site-install minimal --account-mail="$ACCOUNT_MAIL" --account-name="$ACCOUNT_NAME" --db-url="$DATABASE_DRIVER://$DATABASE_USERNAME:$DATABASE_PASSWORD@$DATABASE_HOST/$DATABASE" --site-name="$PROJECT_HUMAN_READABLE_NAME" )



# Replace the settings.php generated by the install process
# with a modified version.
chmod 755 "$WORKSPACE/default"
chmod 777 "$WORKSPACE/default/settings.php"
rm -f "$WORKSPACE/default/settings.php"
cp files/settings.php.example "$WORKSPACE/default/settings.php"

# Replace placeholder strings in the main settings file.
sed -i -e "s#PATH_TO_LOCAL_SETTINGS_PLACEHOLDER#$ENVIRONMENT_DIRECTORY/settings.local.php#g" "$WORKSPACE/default/settings.php"

if [ ! -f "$ENVIRONMENT_DIRECTORY/settings.local.php" ]
then
  cp files/settings.local.php.example "$ENVIRONMENT_DIRECTORY/settings.local.php"

  # Replace database credentials placeholder strings.
  sed -i -e "s#DATABASE_PLACEHOLDER#$DATABASE#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"
  sed -i -e "s#DATABASE_USERNAME_PLACEHOLDER#$DATABASE_USERNAME#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"
  sed -i -e "s#DATABASE_PASSWORD_PLACEHOLDER#$DATABASE_PASSWORD#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"
  sed -i -e "s#DATABASE_HOST_PLACEHOLDER#$DATABASE_HOST#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"
  sed -i -e "s#DATABASE_PORT_PLACEHOLDER#$DATABASE_PORT#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"
  sed -i -e "s#DATABASE_DRIVER_PLACEHOLDER#$DATABASE_DRIVER#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"
  sed -i -e "s#DATABASE_PREFIX_PLACEHOLDER#$DATABASE_PREFIX#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"

  # Generate a random string to use as hash salt in the settings.local.php.
  RANDOM_STRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
  sed -i -e "s#RANDOM_STRING_PLACEHOLDER#$RANDOM_STRING#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"

  # Replace environment setting placeholder string.
  sed -i -e "s#ENVIRONMENT_PLACEHOLDER#$ENVIRONMENT#g" "$ENVIRONMENT_DIRECTORY/settings.local.php"
fi



# Theme configuration.
( cd "$DOCROOT" && drush -y en glacier )
( cd "$DOCROOT" && drush -y vset theme_default glacier )
( cd "$DOCROOT" && drush cc all )
( cd "$DOCROOT" && drush -y glacier "$PROJECT_MACHINE_NAME" )
mkdir -p "$WORKSPACE/all/themes/custom"
mv "$WORKSPACE/all/themes/external/$PROJECT_MACHINE_NAME" "$WORKSPACE/all/themes/custom"
( cd "$DOCROOT" && drush -y en "$PROJECT_MACHINE_NAME" )
( cd "$DOCROOT" && drush -y vset theme_default "$PROJECT_MACHINE_NAME" )
( cd "$DOCROOT" && drush -y dis bartik )
# Create the admin sub theme.
ADMIN_SUB_THEME="${PROJECT_MACHINE_NAME}_admin"
ADMIN_SUB_THEME_PATH="$WORKSPACE/all/themes/custom/$ADMIN_SUB_THEME"
cp -R files/ADMIN_SUB_THEME "$WORKSPACE/all/themes/custom"
mv "$WORKSPACE/all/themes/custom/ADMIN_SUB_THEME" "$ADMIN_SUB_THEME_PATH"
sed -i -e "s#ADMIN_SUB_THEME#$ADMIN_SUB_THEME#g" "$ADMIN_SUB_THEME_PATH/css/ADMIN_SUB_THEME.css"
sed -i -e "s#ADMIN_SUB_THEME#$ADMIN_SUB_THEME#g" "$ADMIN_SUB_THEME_PATH/js/ADMIN_SUB_THEME.js"
sed -i -e "s#ADMIN_SUB_THEME#$ADMIN_SUB_THEME#g" "$ADMIN_SUB_THEME_PATH/ADMIN_SUB_THEME.info"
sed -i -e "s#ADMIN_BASE_THEME#$ADMIN_BASE_THEME#g" "$ADMIN_SUB_THEME_PATH/ADMIN_SUB_THEME.info"
sed -i -e "s#ADMIN_SUB_THEME#$ADMIN_SUB_THEME#g" "$ADMIN_SUB_THEME_PATH/template.php"
mv "$ADMIN_SUB_THEME_PATH/css/ADMIN_SUB_THEME.css" "$ADMIN_SUB_THEME_PATH/css/$ADMIN_SUB_THEME.css"
mv "$ADMIN_SUB_THEME_PATH/js/ADMIN_SUB_THEME.js" "$ADMIN_SUB_THEME_PATH/js/$ADMIN_SUB_THEME.js"
mv "$ADMIN_SUB_THEME_PATH/ADMIN_SUB_THEME.info" "$ADMIN_SUB_THEME_PATH/$ADMIN_SUB_THEME.info"
( cd "$DOCROOT" && drush -y vset admin_theme "$ADMIN_SUB_THEME" )



# Create and enable deployment helper module.
DEPLOY_MODULE="${PROJECT_MACHINE_NAME}_deploy"
DEPLOY_MODULE_PATH="$WORKSPACE/all/modules/custom/$DEPLOY_MODULE"
mkdir -p "$WORKSPACE/all/modules/custom"
cp -R files/DEPLOY_MODULE "$WORKSPACE/all/modules/custom"
mv "$WORKSPACE/all/modules/custom/DEPLOY_MODULE" "$DEPLOY_MODULE_PATH"
sed -i -e "s#DEPLOY_MODULE#$DEPLOY_MODULE#g" "$DEPLOY_MODULE_PATH/DEPLOY_MODULE.info"
sed -i -e "s#DEPLOY_MODULE#$DEPLOY_MODULE#g" "$DEPLOY_MODULE_PATH/DEPLOY_MODULE.module"
sed -i -e "s#DEPLOY_MODULE#$DEPLOY_MODULE#g" "$DEPLOY_MODULE_PATH/DEPLOY_MODULE.install"
mv "$DEPLOY_MODULE_PATH/DEPLOY_MODULE.info" "$DEPLOY_MODULE_PATH/$DEPLOY_MODULE.info"
mv "$DEPLOY_MODULE_PATH/DEPLOY_MODULE.module" "$DEPLOY_MODULE_PATH/$DEPLOY_MODULE.module"
mv "$DEPLOY_MODULE_PATH/DEPLOY_MODULE.install" "$DEPLOY_MODULE_PATH/$DEPLOY_MODULE.install"
# Enabling the module with drush is not possible because of a problem with batch
# processing in hook_install(). We display a message that asks the user to
# manually enable the module at the end of the script.




# Setup git.
if [ ! -f "$WORKSPACE/.gitignore" ]
then
  # Add a .gitignore file to the workspace.
  cp files/.gitignore.example "$WORKSPACE/.gitignore"
fi

( cd "$WORKSPACE" && git init )
( cd "$WORKSPACE" && git add --all )
( cd "$WORKSPACE" && git commit -m "initial commit" )
( cd "$WORKSPACE" && git branch staging )
( cd "$WORKSPACE" && git branch production )
( cd "$WORKSPACE" && git checkout -b dev )
( cd "$WORKSPACE" && git branch -d master )
( cd "$WORKSPACE" && git remote add origin "$REPOSITORY" )



# Create a snapshot of the fresh installation.
./snapshot.sh --file-name=freshinstall



printf "${GREEN}Setup was successful!${NC}\n"
printf "${YELLOW}Please go to /admin/modules and manually enable $DEPLOY_MODULE ${RED}(do not use drush!)${NC}\n"
