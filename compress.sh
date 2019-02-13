#!/bin/bash
# Copies output/peachpi.img into output/compr.img, resulting in many consecutive zero bytes
# which are nicely compressible.

set -e

qemu-img create -f raw output/compr.img 1100M

# copy partition table from raspi3.img
sfdisk --quiet --dump output/peachpi.img | sfdisk --quiet output/compr.img

readarray rmappings < <(sudo kpartx -asv output/peachpi.img)
readarray cmappings < <(sudo kpartx -asv output/compr.img)

# copy the vfat boot partition as-is
set -- ${rmappings[0]}
rboot="$3"
set -- ${cmappings[0]}
cboot="$3"
sudo dd if=/dev/mapper/${rboot?} of=/dev/mapper/${cboot?} bs=5M status=none

# copy the ext4 root partition in a space-saving way
set -- ${rmappings[1]}
rroot="$3"
set -- ${cmappings[1]}
croot="$3"
sudo e2fsck -y -f /dev/mapper/${rroot?}
sudo resize2fs /dev/mapper/${rroot?} 800M
sudo e2image -rap /dev/mapper/${rroot?} /dev/mapper/${croot?}

sudo kpartx -ds output/peachpi.img
sudo kpartx -ds output/compr.img

xz -8 -f output/compr.img

mv output/compr.img.xz output/peachpi.img.xz
