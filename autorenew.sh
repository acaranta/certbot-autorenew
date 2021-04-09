#!/bin/sh

echo "Starting Certbot Auto-renew"
while true 
do
	if certbot renew
	then
		for cert in  $( cd /etc/letsencrypt/live ; find * -type d)
		do 
			cat /etc/letsencrypt/live/${cert}/privkey.pem >/tmp/certbot_${cert}.crt
			cat /etc/letsencrypt/live/${cert}/fullchain.pem >> /tmp/certbot_${cert}.crt
			cp /tmp/certbot_${cert}.crt ${CRTDIR}
		done
	fi
	echo "Waiting ${INTERVAL}"
	sleep ${INTERVAL} 
done
