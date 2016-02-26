# glacier Deploy
glacier Deploy is a collection of shell scripts to support a `drush make`
based Drupal development workflow.

## Requirements
- Bash Shell
- Python
- Webserver (PHP, MySQL,..)
- [Drush](https://www.drupal.org/project/drush)
- [Git](https://git-scm.com/)

## Quick start
1. Download or clone glacier Deploy
2. Move `glacier_deploy` to your project directory
3. Create a directory named `environment` in the same directory as
`glacier_deploy`
4. Copy the `config.cfg.example` file from `glacier_deploy/files` to your
environment directory (remove the `.example` ending)
5. Make changes to the `config.cfg` file (most notably the `DOCROOT` setting)
6. Run `./setup.sh` (with all required parameters) inside the `glacier_deploy`
directory
7. Add the `post-receive.example` Git hook to your Git repository configuration
on your live server(s) (remove the `.example` ending)
8. Change the settings in the `post-receive` Git hook according to your setup
9. Push the `staging` or `production` branch to the live server

## Usage
### Basic configuration
Download or clone glacier Deploy and move it to your desired directory. Create
a directory structure like this:

```
.
├── docroot
|   └── your_website_data
├── environment
└── glacier_deploy
```

You can define the path to your docroot in the config.cfg. It is required that
the `glacier_deploy` and `environment` directory are on the same level.
Furthermore it is highly recommended that both the `glacier_deploy` and the
`environment` directory are not accessible from the web.

By default the `setup.sh` script copies the example configuration files
(`config.cfg.example` and `settings.local.php.example`) to your `environment`
directory and uses those for the setup process. But usually you want to make
changes to the `config.cfg` file to meet the conditions of your development
environment. To do so, manually copy the file from `glacier_deploy/files` to
your `environment` directory (remove the `.example` ending) and change the
settings to fulfill your needs.

```
.
├── docroot
├── environment
|   └── config.cfg
└── glacier_deploy
```

**The settings in the `config.cfg` file must match the specifications of your
development environment, incorrect settings can cause serious issues.**

If you want to make changes to the `settings.local.php` file, it is recommended
to let the `setup.sh` script create the file and make changes to it after the
installation is complete.

### Makefiles
There are two Makefiles which are used to build the Drupal base system.
Usually it is fine to use the default files. The `setup.sh` script will create
a copy of the example Makefiles (`glacier.make.example` and
`glacier.features.make.example`) in your `sites` directory and install the
Drupal base system accordingly. You will use the default Makefile `glacier.make`
to install new modules, themes, libraries and patches during your project
workflow. The `build.sh` script will use this Makefile to implement your changes
across your environments. The features Makefile `glacier.features.make` will
only be used during the setup process. This is because it is expected, that you
make changes to your features and those changes are tracked via Git. Defining
your features in the default Makefile would result in overwriting them when
running `build.sh`. If you do not make changes to certain features and you want
to update them from a global repository, you should add those to the default
Makefile and add them to `.gitignore`. If you want to make changes to the
Makefiles before the initial setup, create a copy of the example Makefiles in
`glacier_deploy/files` (remove the `.example` ending) and move them to a new
directory `sites` in the docroot of your project.

## Scripts
Open the terminal (your shell prompt) and type the command e.g. `./snapshot.sh`.
[Read more about shell scripts on Wikipedia.](https://en.wikipedia.org/wiki/Shell_script)

### setup.sh
Using the setup script it is possible to create a Drupal installation based on
your own or the predefined `.make` script in a few minutes. To perform an
installation using the predefined default settings, it is sufficient to execute
the setup script and pass the database login informations as parameters.
Before starting the setup script you must check whether the data in the
`config.cfg.example` file are compatible with your development environment.

Once everything is configured correctly, you can start the setup by running:
`./setup.sh --project-machine-name=project --project-human-readable-name=Project --account-mail=mail@mail.com --account-name=admin --database=database --database-username=username --database-password=password --database-host=127.0.0.1`

### snapshot.sh
Create a backup of your code, files and database. The `snapshot.sh` script is a
wrapper around `drush archive-dump`. The script creates a tar.gz file in your
backup directory (specified in your `config.cfg` file) with the current date and
timestamp as file name. If you want to specify a custom file name, you can do so
with the `file-name` option (e.g. `./snapshot.sh --file-name=customfilename`).

### rollback.sh
Restore snapshots created with `snapshot.sh`. The `rollback.sh` script is a
wrapper around `drush archive-restore`. By default the script restores the
latest snapshot. If you want to restore a specific snapshot, you can do so
with the `file-name` option (e.g. `./rollback.sh --file-name=customfilename`) or
by providing the timestamp of the snapshot you want to restore
(e.g. `./rollback.sh --snapshot-timestamp=1447516767`). To prevent data loss
`rollback.sh` creates a snapshot with the name "beforerollback" in your backup
directory (you can prevent this by adding the `-no-snapshot` option).

### build.sh
Use the `build.sh` script to run all steps necessary to build your Drupal
system after you made changes to features or the Makefile. Running `./build.sh`
creates a snapshot of the current state (you can prevent this by adding the
`-no-snapshot` option), puts your site in maintenance mode (except on the dev
environment), builds the Makefile, updates the database (`drush updatedb`) and
reverts all features (`drush features-revert-all`).

### deploy_ftp.sh
If it is not possible to use Git for deployment (e.g. on cheap shared hosting),
you can use the `deploy_ftp.sh` script to deploy via a FTP connection. The
script uses the [LFTP](http://lftp.yar.ru/) command line tool to mirror the
complete docroot of your project to the FTP server specified in your
`config.cfg`. Keep in mind that deploying to an FTP server takes much more time
than using Git. Furthermore you must run the commands from `build.sh` manually
after FTP deployment. Don't forget to bill you client the extra time.

## Drupal workflow
### Subfolder structure
According to best practices, glacier Deploy uses separate sub folders for
contrib modules, custom modules and features. Additionally there is a `external`
directory for modules and themes which are third party code but not from
drupal.org. Usually modules and themes in `external` are managed by a version
control system (e.g. on GitHub). To keep your codebase clean, external modules
and themes are not tracked in your projects Git repository.

```
.
├── contrib
├── custom
├── external
└── features
```

## About
Github: https://github.com/drupalglacier/glacier_deploy

### Author
Markus Oberlehner  
Twitter: https://twitter.com/MaOberlehner

### License
GPL v2 (http://www.gnu.org/licenses/gpl-2.0.html)
