# Certbot Autorenew for HAProxy + OVH DNS
Docker image of certbot, using ovh DNS automation, aimed at updating Haproxy Certificates.
This container is designed to update certificates for HAProxy using inotify reload as designed in : [acaranta/lbdocker](https://github.com/acaranta/lbdocker)
## Container Usage
In order to use this container, there are 2 steps :
* First use it to generate/create the LetsEncrypt Certificates (manually)
* Run it to allow for auto Renew
### Common parameters
Common parameters wether in certificate creation or autorenew are Certbot mount paths for certificates storage and OVH API:
```
/etc/letsencrypt
/var/lib/letsencrypt
/etc/ovh
```

### Certificates Creation
To request/create a Certificate, using OVH DNS API, first create `ovh.ini` as specified [here](https://certbot-dns-ovh.readthedocs.io/en/stable/)

Then Run your container with the command line :
```
docker run -it --rm --name certbot \ 
          -v "/volumespath/certbot/etc:/etc/letsencrypt" \ 
          -v "/volumespath/certbot/var/lib:/var/lib/letsencrypt" \ 
          -v /volumespath/certbot/ovh:/etc/ovh \ 
          certbot/dns-ovh certonly \ 
          --dns-ovh --dns-ovh-credentials /etc/ovh/ovh.ini \  
          --dns-ovh-propagation-seconds 60 \ 
          -d <YOURDOMAINCERT2GENERATE>
```

This will request and generate a certificate for `YOURDOMAINCERT2GENERATE` and will sotre its configuration in the volumes specified.

### Run the autorenew Mode
Once your certificates are generated you can run the container using this docker-compose configuration :
```
  certbot:
    image: acaranta/certbot-autorenew:latest
    environment:
      - "CERTDIR=/crts"
      - "INTERVAL=7d"
      - MINIO_URL=s3.myminio.net
      - MINIO_USER=<ACCESS KEY>
      - MINIO_PASS=<ACCESS SECRET>
      - MINIO_BUCKET=mybucket
      - MINIO_PATH=lbcerts
    volumes:
      - /volumespath/certbot/etc:/etc/letsencrypt
      - /volumespath/certbot/var/lib:/var/lib/letsencrypt
      - /volumespath/certbot/ovh:/etc/ovh
      - /volumespath/lbdocker/conf/certs:/crts
    restart: always
```

Where the Environment Variables passed are :
* CERTDIR : is the path to where the haproxy certificates will be placed/overwritten once the renew will be done
* INTERVAL : Interval between renewal attempts by certbot (Default 7D = 7 Days)
* MINIO_URL : if set (to your minio S3 storage host) this will try to send the certificates to S3
* MINIO_USER : Access key
* MINIO_PASS : Secret Key
* MINIO_BUCKET : S3 Bucket
* MINIO_PATH : path in the bucket to store the certificates

This will run certbot every INTERVAL, and will try to renew every Certificates found within the letsencrypt cerbot volumes.