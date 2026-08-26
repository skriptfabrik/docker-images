if [ -f /etc/postfix/sasl_passwd.db ]; then
	postconf -e "smtp_sasl_auth_enable = yes"
	postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
	postconf -e "smtp_sasl_security_options = noanonymous"
	postconf -e "smtp_sasl_tls_security_options = noanonymous"
	postconf -e "smtp_sasl_mechanism_filter = AUTH LOGIN"
else
	echo "No /etc/postfix/sasl_passwd.db file found, skipping Postfix SASL configuration."
fi
