FROM certbot/dns-ovh:latest
ENV CRTDIR=/crts
ENV INTERVAL=7d

RUN apk add bash curl
ADD autorenew.sh /autorenew.sh
ADD upload-to-minio.sh /upload-to-minio.sh
RUN chmod a+x /autorenew.sh ; chmod a+x /upload-to-minio.sh
RUN mkdir /crts

WORKDIR /
ENTRYPOINT ["/bin/sh","-c"]
CMD ["/autorenew.sh"]

