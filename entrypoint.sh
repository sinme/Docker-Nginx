#!/bin/bash
#########################################################################
# File Name: entrypoint.sh
# Author: Tyson
# Email: longtaijun@msn.cn
# Website：www.svipc.com
# Version: 1.0.0
# Created Time: 2016-08-18 16:50:04
#########################################################################

set -e

if [ -n "$TIMEZONE" ]; then
	rm -rf /etc/localtime && \
	ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

[ "${1:0:1}" = '-' ] && set -- nginx "$@"


mkdir -p ${DATA_DIR}
[ ! -f "$DATA_DIR/index.html" ] && echo 'Hello here, Let us see the world.' > $DATA_DIR/index.html
chown -R www.www $DATA_DIR

if [ -d /etc/logrotate.d ]; then
	cat > /etc/logrotate.d/nginx <<-EOF
		$(dirname ${DATA_DIR})/wwwlogs/*.log {
			daily
			rotate 5
			missingok
			dateext
			compress
			notifempty
			sharedscripts
			postrotate
    		[ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
			endscript
		}
	EOF
fi

#if [ ! -f ${INSTALL_DIR}/conf/nginx.conf ]; then
if [[ ! "${SED_CHANGE}" =~ ^[nN][oO]$ ]]; then
	cp /nginx.conf ${INSTALL_DIR}/conf/nginx.conf
	sed -i "s@/home/wwwroot@$DATA_DIR@" ${INSTALL_DIR}/conf/nginx.conf
	if [[ "${PHP_FPM}" =~ ^[yY][eS][sS]$ ]]; then
		if [ -z "${PHP_FPM_SERVER}" ]; then
			echo >&2 'error:  missing PHP_FPM_SERVER'
			echo >&2 '  Did you forget to add -e PHP_FPM_SERVER=... ?'
			exit 127
		fi
		PHP_FPM_PORT=${PHP_FPM_PORT:-9000}
		sed -i "s/PHP_FPM_SERVER/${PHP_FPM_SERVER}/" ${INSTALL_DIR}/conf/nginx.conf
		sed -i "s/PORT/${PHP_FPM_PORT}/" ${INSTALL_DIR}/conf/nginx.conf
		[ -f ${DATA_DIR}/index.php ] || cat > ${DATA_DIR}/index.php <<< '<? phpinfo(); ?>'
	else
		sed -i '73,78d' ${INSTALL_DIR}/conf/nginx.conf
	fi
fi

exec "$@" -g "daemon off;"
