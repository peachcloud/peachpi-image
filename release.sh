#/bin/bash

set -e

TODAY=$(date --rfc-3339=date)

mkdir -p releases/${TODAY}

cp output/peachpi.img.xz releases/${TODAY}/peachpi.img.xz

cd releases/${TODAY}

npx dat create --title "PeachPi image ${TODAY}" --description "Debian image for a Raspberry Pi based PeachCloud"

# do a dat share loop because stalls after some time?
trap exit EXIT
while true
do
  timeout 360s npx dat share
  sleep 10
done
