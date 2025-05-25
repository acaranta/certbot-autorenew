#!/usr/bin/env bash
#
# upload-to-minio.sh <endpoint> <accessKey> <secretKey> <bucket> <objectKey> <file>
#
if [ -z $1 ]; then
  echo "You have NOT specified a MINIO URL!"
  exit 1
fi

if [ -z $2 ]; then
  echo "You have NOT specified a USERNAME!"
  exit 1
fi

if [ -z $3 ]; then
  echo "You have NOT specified a PASSWORD!"
  exit 1
fi

if [ -z $4 ]; then
  echo "You have NOT specified a BUCKET!"
  exit 1
fi

if [ -z $5 ]; then
  echo "You have NOT specified a UPLOAD PATH!"
  exit 1
fi

if [ -z $6 ]; then
  echo "You have NOT specified a UPLOAD FILE!"
  exit 1
fi

set -euo pipefail

ENDPOINT="$1"     # e.g. play.min.io:9000  (do NOT include “https://”)
ACCESS_KEY="$2"
SECRET_KEY="$3"
BUCKET="$4"       # e.g. “mybucket”
OBJECT_KEY="$5"   # e.g. “subdir/foo.txt”
FILE="$6"         # local file to upload

# derive filename and resource path
FILENAME=$(basename "$FILE")
# If you want to embed FILENAME, do: OBJECT_KEY="subdir/${FILENAME}"

# Content‐Type
CONTENT_TYPE="application/octet-stream"

# Date in RFC1123 format, UTC (same as “Date” header in S3 V2)
DATE=$(date -R --utc)

# Canonical Resource: “/bucket/object”
CANONICAL_RESOURCE="/${BUCKET}/${OBJECT_KEY}"

# Build the StringToSign exactly as per AWS S3 V2 spec:
#
#   StringToSign = HTTP-Verb + "\n" +
#                  Content-MD5 + "\n" +
#                  Content-Type + "\n" +
#                  Date + "\n" +
#                  CanonicalizedAmzHeaders (none) +
#                  CanonicalizedResource
#
# We are not sending a Content-MD5 header, so that field is empty.
#
STRING_TO_SIGN=$(
  printf "PUT\n\n%s\n%s\n%s" \
    "$CONTENT_TYPE" \
    "$DATE" \
    "$CANONICAL_RESOURCE"
)

# HMAC‐SHA1 and base64‐encode
SIGNATURE=$(
  printf "%s" "$STRING_TO_SIGN" \
    | openssl sha1 -hmac "$SECRET_KEY" -binary \
    | base64
)

# Finally, upload with curl
curl -sS \
  -w "HTTP_CODE:%{http_code} - TIME_TOTAL:%{time_total}s - SIZE_UPLOAD:%{size_upload} bytes\n" \
  --request PUT \
  --data-binary @"$FILE" \
  "https://${ENDPOINT}${CANONICAL_RESOURCE}" \
  -H "Host: ${ENDPOINT}" \
  -H "Date: ${DATE}" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}"