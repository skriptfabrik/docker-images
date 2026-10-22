# Read the SMTP password from the specified file if it exists
if [ -f "${SMTP_PASS_FILE}" ]; then
	SMTP_PASS=$(cat "${SMTP_PASS_FILE}")
fi

# Configure Postfix SASL if SMTP credentials are provided and the sasl_passwd file does not exist
if [ ! -f /etc/postfix/sasl_passwd ] && [ -n "${SMTP_HOST}" ] && [ -n "${SMTP_USER}" ] && [ -n "${SMTP_PASS}" ]; then
	echo "Configuring Postfix SASL with SMTP credentials."
	printf '%s %s:%s' "${SMTP_HOST}" "${SMTP_USER}" "${SMTP_PASS}" > /etc/postfix/sasl_passwd
fi

# Apply the Postfix SASL configuration if the sasl_passwd file was created
if [ -f /etc/postfix/sasl_passwd ]; then
	postmap /etc/postfix/sasl_passwd
	rm -f /etc/postfix/sasl_passwd
else
	echo "No /etc/postfix/sasl_passwd file found, skipping Postfix SASL configuration."
fi
