# saiku

These files building a container-image of [saiku](https://github.com/OSBI/saiku) and starting it up.

## Features

* Env-Variable `$SAIKU_HOME` is set to
* mountable data-location for persistent data
  * Environment-Variable is called `INSTANCEDIR`
  * per default this is `/saiku/data`
* automatic license-upload on bootstrap
  * mount the license-File to `/saiku_license.lic`
  * updating a license is done through `http://container-url/upload.html`
* bootstrapping additional cube-configurations (files has to be mounted in `/additionalCubes`)
* executing bootstrap-shellscripts (files has to be mounted in `/additionalCubes`)

## Usage

1) generate an [license](https://licensing.meteorite.bi/login) and provide it to the docker-container
2) use the file [docker-compose.yml](docker-compose.yml) (Alternatively you could pull the image from [docker-hub](https://hub.docker.com/r/gaerfield/saiku/) `docker pull gaerfield/saiku`)

    ```yaml
    version: '2'
    services:
      saiku:
        build:
          context: https://github.com/gaerfield/saiku.git
        image: saiku
        ports:
          - 8080
        volumes:
          # mounts used only for bootstraping (containers first creation)
          - ./config/saiku_license.lic:/saiku_license.lic
          - ./config/cubes:/additionalCubes
          - ./config/bootstrapScripts:/docker-entrypoint-initdb.d
          # used for persistence (overwritten when bootstrapping!)
          - ./data/saiku:/saiku/data/
    ```

3) `docker-compose up -d` and you're done

## FAQ (or stuff I asked myself)

### Is it possible to use a different tomcat-image as base-image?

I don't know about a compatible way of doing that. The binary release of ships it's own version of tomcat, which is somewhat suspicious. Also custom startup-scripts are used. So for backwards-compatibility it's maybe best to use, what's shipped by saiku.

### Howto configure additional Java-Arguments?

Normally on could to that through the setenv.sh-file or additional Java-Arguments. For Saiku this is not the case. Saiku ships with a custom [startup-script](https://github.com/OSBI/saiku/blob/development/saiku-server/scripts/start-saiku.sh), which sets the java-arguments hardcoded. For a backwards-compatible approach, I would:

* *either*: copy Saiku's [startup-script](https://github.com/OSBI/saiku/blob/development/saiku-server/scripts/start-saiku.sh) and mount it into `$SAIKU_HOME/start-saiku.sh` (per default `/saiku/start-saiku.sh`)
* *or*: provide a shell-script within `docker-entrypoint-initdb.d` that does some [sed-magic](https://askubuntu.com/questions/20414/find-and-replace-text-within-a-file-using-commands) to replace the arguments within the startup-script (beware of the fact, that this script is only executed once)

### Why the `docker-entrypoint-initdb.d` - folder?

`sh`-Files within the folder get's executed in alphabetical order during bootstrap (the first time, the container starts up) **before** Saiku is started. Use it for example to download an additional library that is needed for running saiku (i.e. the mysql-connector-library gets downloaded by the example-script in [installMysqlLib.sh](config/bootstrapScripts/installMysqlLib.sh)).

## Links
* [Image](https://hub.docker.com/r/gaerfield/saiku/) from Docker-Hub
* Saiku:
  * [Github](https://github.com/OSBI/saiku)
  * [Homepage](https://community.meteorite.bi/)
  * [License](https://licensing.meteorite.bi/login)
