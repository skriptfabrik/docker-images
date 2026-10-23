#!/bin/sh

set -e

entrypoint_log() {
	if [ -z "${DOCKER_ENTRYPOINT_QUIET_LOGS:-}" ]; then
		echo "$@"
	fi
}

# Configure Postfix generic mapping if the generic.db file exists
if [ -f /etc/postfix/generic.db ]; then
	postconf -e "smtp_generic_maps = hash:/etc/postfix/generic"
else
	entrypoint_log "$0: No /etc/postfix/generic.db file found, skipping Postfix generic mapping"
fi

# Configure Postfix SASL if the sasl_passwd.db file exists
if [ -f /etc/postfix/sasl_passwd.db ]; then
	postconf -e "smtp_sasl_auth_enable = yes"
	postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
	postconf -e "smtp_sasl_security_options = noanonymous"
	postconf -e "smtp_sasl_tls_security_options = noanonymous"
	postconf -e "smtp_sasl_mechanism_filter = AUTH LOGIN"
else
	entrypoint_log "$0: No /etc/postfix/sasl_passwd.db file found, skipping Postfix SASL configuration"
fi
