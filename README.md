# Deploy
glacier Deploy is a collection of shell scripts to support a `drush make`
based Drupal development workflow.

## Usage
To run shell scripts open your command line interface and type `./snapshot.sh`.
[Read more about shell scripts on Wikipedia.](https://en.wikipedia.org/wiki/Shell_script)

### setup.sh
Using the setup script it is possible to create a Drupal installation based on
your own or the predefined `.make` script in a few minutes. To perform an
installation using the predefined default settings, it is sufficient to execute
the setup script and pass the database login informations as parameters.
Before starting the setup script you must check whether the data in the
`config.cfg.example` file are compatible with your development environment.

If you want to the make changes to the `config.cfg.example` or
`settings.local.php.example` files you need to create your own `environment`
directory. The `environment` directory must be located in the same directory as
`glacier_deploy` and must not be accessible from the web. Copy the desired
file(s) to the `environment` directory and remove the `.example` ending. Perform
the desired changes to the `config.cfg` and `settings.local.php` files.
The setup script will now use those files for the installation process.

**The settings in the `config.cfg` file must match the specifications of your
development environment, incorrect settings can cause serious issues.**

Once everything is configured correctly, you can start the setup by running:
`./setup.sh --environment-directory=/path/to/envirnonment --project-machine-name=project --project-human-readable-name=Project --account-mail=mail@mail.com --account-name=admin --database=database --database-username=username --database-password=password --database-host=127.0.0.1`

## About
Github: https://github.com/drupalglacier/glacier_deploy

### Author
Markus Oberlehner  
Twitter: https://twitter.com/MaOberlehner

### License
GPL v2 (http://www.gnu.org/licenses/gpl-2.0.html)
