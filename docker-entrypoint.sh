#!/bin/bash
set -euo pipefail
shopt -s nullglob

LICENSE_FILE="${SAIKU_LICENSE:-/saiku_license.lic}"

function log_info {
  echo -e $(date '+%Y-%m-%d %T')"\e[1;32m $@\e[0m"
}

function log_error {
  echo -e >&2 $(date +"%Y-%m-%d %T")"\e[1;31m $@\e[0m"
}

function ensure_InstanceDir {
  log_info "bootstrapping instance data directory $INSTANCEDIR"
  cp -r $INSTANCEDIR_BOOTSTRAP/* $INSTANCEDIR
}

function copy_extraCubes {
  log_info "copying additional Cubes from $ADDITIONAL_CUBES to $INSTANCEDIR"
  cp -r $ADDITIONAL_CUBES/* $INSTANCEDIR
}

function process_init_file {
	local f="$1"; shift

	case "$f" in
		*.sh)     log_info "$0: running $f"; . "$f" ;;
		*)        echo "$0: ignoring $f" ;;
	esac
	echo done
}

function install_license {
  log_info "loading license from $LICENSE_FILE"

  SAIKU_PING_URL=http://admin:admin@localhost:8080/saiku/rest/saiku/admin/version/
  SAIKU_LICENSE_UPLOAD=http://admin:admin@localhost:8080/saiku/rest/saiku/api/license/

  log_info "Wating for saiku ..."
  until $(curl --output /dev/null --silent --head --fail $SAIKU_PING_URL); do
      log_info 'still waiting ...'
      sleep 1
  done

  log_info "uploading license"
  curl -X POST --header "Content-Type:application/x-java-serialized-object" --data-binary "@$LICENSE_FILE" $SAIKU_LICENSE_UPLOAD

  log_info "uploaded license"
  curl $SAIKU_LICENSE_UPLOAD
}

function server_start {
  log_info "starting server"
  /saiku/start-saiku.sh
  log_info "server is running"
}

function server_stop {
  log_info "shutting down"
  /saiku/stop-saiku.sh
  log_info "server is down"
  exit 0 # finally exit main handler script
}

## graceful shutdown
trap "server_stop"  SIGTERM

if [ -e /initialized ]; then
  # only start server
  server_start
else
  touch /initialized
  # bootstrap AND start server
  ensure_InstanceDir
  copy_extraCubes
  log_info "executing bootstrapping scripts"
  ls /docker-entrypoint-initdb.d/ > /dev/null
  for f in /docker-entrypoint-initdb.d/*; do
    process_init_file "$f"
  done
  server_start
  if [ -e $LICENSE_FILE ]; then
    install_license
  fi
fi

tail -F /saiku/tomcat/logs/catalina.out # keep the container running
