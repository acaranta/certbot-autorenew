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
			cp ${CRTDIR}/certbot_${cert}.crt ${CRTDIR}/certbot_${cert}.crt.old
			cp /tmp/certbot_${cert}.crt ${CRTDIR}
			if [ -n "${MINIO_URL}" ]; then
				./upload-to-minio.sh ${MINIO_URL} ${MINIO_USER} ${MINIO_PASS} ${MINIO_BUCKET} ${MINIO_PATH}/certbot_${cert}.crt /tmp/certbot_${cert}.crt
			fi
		done
	fi
	echo "Waiting ${INTERVAL}"
	sleep ${INTERVAL} 
done
