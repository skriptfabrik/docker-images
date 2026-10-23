#!/bin/sh

set -e

entrypoint_log() {
	if [ -z "${DOCKER_ENTRYPOINT_QUIET_LOGS:-}" ]; then
		echo "$@"
	fi
}

# Set the Nagios admin user
entrypoint_log "$0: Setting Nagios admin user to ${NAGIOSADMIN_USER}"
sed -i -e "s/nagiosadmin/${NAGIOSADMIN_USER}/g" "${NAGIOS_HOME}/etc/cgi.cfg"

# Read the Nagios admin password from the specified file if it exists
if [ -f "${NAGIOSADMIN_PASS_FILE}" ]; then
	NAGIOSADMIN_PASS=$(cat "${NAGIOSADMIN_PASS_FILE}")
fi

# Set the Nagios admin password
entrypoint_log "$0: Setting Nagios admin password for user ${NAGIOSADMIN_USER}"
printf '%s' "${NAGIOSADMIN_PASS}" | htpasswd -cis "${NAGIOS_HOME}/etc/htpasswd.users" "${NAGIOSADMIN_USER}"
chown ${NAGIOS_USER}:${NAGIOS_GROUP} "${NAGIOS_HOME}/etc/htpasswd.users"

# Set the Nagios timezone
entrypoint_log "$0: Setting Nagios timezone to ${NAGIOS_TIMEZONE}"
sed -i -e 's;^#use_timezone=.*;use_timezone='${NAGIOS_TIMEZONE}';' "${NAGIOS_HOME}/etc/nagios.cfg"
