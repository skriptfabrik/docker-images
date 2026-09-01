# Set the Nagios admin user
sed -i -e "s/nagiosadmin/${NAGIOSADMIN_USER}/g" "${NAGIOS_HOME}/etc/cgi.cfg"

# Set the Nagios admin password
htpasswd -cbs "${NAGIOS_HOME}/etc/htpasswd.users" "${NAGIOSADMIN_USER}" "${NAGIOSADMIN_PASS}"
chown ${NAGIOS_USER}:${NAGIOS_GROUP} "${NAGIOS_HOME}/etc/htpasswd.users"

# Set the Nagios timezone
sed -i -e 's;^#use_timezone=.*;use_timezone='${NAGIOS_TIMEZONE}';' "${NAGIOS_HOME}/etc/nagios.cfg"
