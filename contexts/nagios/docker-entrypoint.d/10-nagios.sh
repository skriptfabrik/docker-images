# Set the Nagios admin user
sed -i -e "s/nagiosadmin/${NAGIOSADMIN_USER}/g" "${NAGIOS_HOME}/etc/cgi.cfg"

# Read the Nagios admin password from the specified file if it exists
if [ -f "${NAGIOSADMIN_PASS_FILE}" ]; then
	NAGIOSADMIN_PASS=$(cat "${NAGIOSADMIN_PASS_FILE}")
fi

# Set the Nagios admin password
printf '%s' "${NAGIOSADMIN_PASS}" | htpasswd -cis "${NAGIOS_HOME}/etc/htpasswd.users" "${NAGIOSADMIN_USER}"
chown ${NAGIOS_USER}:${NAGIOS_GROUP} "${NAGIOS_HOME}/etc/htpasswd.users"

# Set the Nagios timezone
sed -i -e 's;^#use_timezone=.*;use_timezone='${NAGIOS_TIMEZONE}';' "${NAGIOS_HOME}/etc/nagios.cfg"
