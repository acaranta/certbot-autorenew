FROM certbot/dns-ovh:latest
ENV CRTDIR=/crts
ENV INTERVAL=7d

ADD autorenew.sh /autorenew.sh
RUN chmod a+x /autorenew.sh
RUN mkdir /crts

WORKDIR /
ENTRYPOINT ["/bin/sh","-c"]
CMD ["/autorenew.sh"]

