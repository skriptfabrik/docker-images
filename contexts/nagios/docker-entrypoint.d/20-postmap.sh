if [ ! -f /etc/postfix/sasl_passwd ] && [ -n "${SMTP_HOST}" ] && [ -n "${SMTP_USER}" ] && [ -n "${SMTP_PASS}" ]; then
	echo "Configuring Postfix SASL with SMTP credentials."
	printf '%s %s:%s' "${SMTP_HOST}" "${SMTP_USER}" "${SMTP_PASS}" > /etc/postfix/sasl_passwd
fi

if [ -f /etc/postfix/sasl_passwd ]; then
	postmap /etc/postfix/sasl_passwd
	rm -f /etc/postfix/sasl_passwd
else
	echo "No /etc/postfix/sasl_passwd file found, skipping Postfix SASL configuration."
fi
