FROM jasonrivers/nagios:4.5.12

RUN set -e \
  ; sed -i -e 's;^cfg_file='${NAGIOS_HOME}'/etc;#cfg_file='${NAGIOS_HOME}'/etc;g' "${NAGIOS_HOME}/etc/nagios.cfg" \
  ; sed -i -e '\;^cfg_dir='${NAGIOS_HOME}'/etc;d' "${NAGIOS_HOME}/etc/nagios.cfg" \
  ; sed -i -e '\;^use_timezone=;d' "${NAGIOS_HOME}/etc/nagios.cfg" \
  ; printf '\n\n\ncfg_dir=%s\n' "${NAGIOS_HOME}/etc/conf.d" >> "${NAGIOS_HOME}/etc/nagios.cfg" \
  ; printf '#use_timezone=%s\n' "${NAGIOS_TIMEZONE}" >> "${NAGIOS_HOME}/etc/nagios.cfg" \
  ; rm -Rf "${NAGIOS_HOME}/etc/monitor" "${NAGIOS_HOME}/etc/objects" \
  ; mkdir /docker-entrypoint.d

COPY docker-entrypoint.sh /
COPY docker-entrypoint.d /docker-entrypoint.d/

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "start_nagios" ]
