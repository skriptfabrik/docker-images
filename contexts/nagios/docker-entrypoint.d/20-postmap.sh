#!/bin/sh

set -e

entrypoint_log() {
	if [ -z "${DOCKER_ENTRYPOINT_QUIET_LOGS:-}" ]; then
		echo "$@"
	fi
}

# Create a Postfix generic map rewriting the Nagios sender address if SMTP_SENDER is provided and the generic file does not exist
if [ ! -f /etc/postfix/generic ] && [ -n "${SMTP_SENDER}" ]; then
	entrypoint_log "$0: Configuring Postfix generic mapping for ${NAGIOS_USER} to ${SMTP_SENDER}"
	printf '%s %s\n' "${NAGIOS_USER}" "${SMTP_SENDER}" > /etc/postfix/generic
fi

# Apply the Postfix generic mapping if the generic file was created
if [ -f /etc/postfix/generic ]; then
	postmap /etc/postfix/generic
	rm -f /etc/postfix/generic 2>/dev/null || entrypoint_log "$0: Could not remove /etc/postfix/generic, keeping it"
else
	entrypoint_log "$0: No /etc/postfix/generic file found, skipping Postfix generic mapping"
fi

# Read the SMTP password from the specified file if it exists
if [ -f "${SMTP_PASS_FILE}" ]; then
	SMTP_PASS=$(cat "${SMTP_PASS_FILE}")
fi

# Configure Postfix SASL if SMTP credentials are provided and the sasl_passwd file does not exist
if [ ! -f /etc/postfix/sasl_passwd ] && [ -n "${SMTP_HOST}" ] && [ -n "${SMTP_USER}" ] && [ -n "${SMTP_PASS}" ]; then
	entrypoint_log "$0: Configuring Postfix SASL with SMTP credentials"
	printf '%s %s:%s' "${SMTP_HOST}" "${SMTP_USER}" "${SMTP_PASS}" > /etc/postfix/sasl_passwd
fi

# Apply the Postfix SASL configuration if the sasl_passwd file was created
if [ -f /etc/postfix/sasl_passwd ]; then
	postmap /etc/postfix/sasl_passwd
	rm -f /etc/postfix/sasl_passwd 2>/dev/null || entrypoint_log "$0: Could not remove /etc/postfix/sasl_passwd, keeping it"
else
	entrypoint_log "$0: No /etc/postfix/sasl_passwd file found, skipping Postfix SASL configuration"
fi
