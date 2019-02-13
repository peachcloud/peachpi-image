#/bin/bash

set -e

TODAY=$(date --rfc-3339=date)

mkdir -p releases/${TODAY}

cp output/peachpi.img.xz releases/${TODAY}/peachpi.img.xz

cd releases/${TODAY}

npx dat create --title "PeachPi image ${TODAY}" --description "Debian image for a Raspberry Pi based PeachCloud"

npx dat share
