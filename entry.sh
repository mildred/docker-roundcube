#!/bin/bash

set -e

if [[ -n $ROUNDCUBE_CONFIG_URL ]]; then
  curl -o /etc/roundcube/main.inc.php $ROUNDCUBE_CONFIG_URL
else
  : ${LANG:=en_US}
  cp /etc/roundcube/main.inc.default.php /etc/roundcube/main.inc.php
fi

if [[ -n $TZ ]]; then
  echo "date.timezone = $TZ" >/etc/php5/mods-available/timezone.ini
  php5enmod timezone
fi

if [[ -n $LANG ]]; then
  echo "\$rcmail_config['language'] = '$LANG';" >>/etc/roundcube/main.inc.php
fi

if [[ -n $MAIL_PORT_143_TCP ]]; then
  echo "\$rcmail_config['default_port'] = $MAIL_PORT_143_TCP_PORT;"           >>/etc/roundcube/main.inc.php
  echo "\$rcmail_config['default_host'] = \"tls://$MAIL_PORT_143_TCP_ADDR\";" >>/etc/roundcube/main.inc.php
fi

if [[ -n $MAIL_PORT_587_TCP ]]; then
  echo "\$rcmail_config['smtp_port']   = $MAIL_PORT_587_TCP_PORT;"           >>/etc/roundcube/main.inc.php
  echo "\$rcmail_config['smtp_server'] = \"tls://$MAIL_PORT_587_TCP_ADDR\";" >>/etc/roundcube/main.inc.php
fi

# Make docker stop work correctly by ensuring signals get to apache2
# process and avoid trying to change limits which produces errors under
# docker.
export APACHE_HTTPD="exec /usr/sbin/apache2" APACHE_ULIMIT_MAX_FILES=:
exec /usr/sbin/apache2ctl -D FOREGROUND

