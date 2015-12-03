# glacier Deploy
glacier Deploy is a collection of shell scripts to support a `drush make`
based Drupal development workflow.

## Get started
Download or clone `glacier_deploy` and copy it to your desired directory. Create
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
changes to those files to meet the conditions of your development environment.
To do so, manually copie those files from `glacier_deploy/files` to your
`environment` directory (remove the `.example` ending) and change the files to
fulfill your needs.

```
.
├── docroot
├── environment
|   ├── config.cfg
|   └── settings.local.php
└── glacier_deploy
```

**The settings in the `config.cfg` file must match the specifications of your
development environment, incorrect settings can cause serious issues.**

## Usage
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
`./setup.sh --environment-directory=/path/to/envirnonment --project-machine-name=project --project-human-readable-name=Project --account-mail=mail@mail.com --account-name=admin --database=database --database-username=username --database-password=password --database-host=127.0.0.1`

### snapshot.sh
Create a backup of your code, files and database. The `snapshot.sh` script is a
wrapper around `drush archive-dump`. The script creates a tar.gz file in your
backup directory (specified in your `config.cfg` file) with the current date and
timestamp as file name. If you want to specify a custom file name, you can do so
with the `file-name` option (e.g. `./snapshot.sh --file-name=customfilename`).

### build.sh
Use the `build.sh` script to run all steps necessary to build your Drupal
system after you made changes to features or the make file. Running `./build.sh`
creates a snapshot of the current state (you can prevent this by adding the
`-no-snapshot` option), puts your site in maintenance mode (except on the dev
environment), builds the make file, updates the database (`drush updatedb`) and
reverts all features (`drush features-revert-all`).

### deploy_ftp.sh
If it is not possible to use Git for deployment (e.g. on cheap shared hosting),
you can use the `deploy_ftp.sh` script to deploy via a FTP connection. The
script uses the [LFTP](http://lftp.yar.ru/) commmand line tool to mirror the
complete docroot of your project to the FTP server spcified in your
`config.cfg`. Keep in mind that deploying to an FTP server takes much more time
than using Git. Furthermore you must run the commands from `build.sh` manually
after FTP deployment. Don't forget to bill you client the extra time.

## About
Github: https://github.com/drupalglacier/glacier_deploy

### Author
Markus Oberlehner  
Twitter: https://twitter.com/MaOberlehner

### License
GPL v2 (http://www.gnu.org/licenses/gpl-2.0.html)
