# PeachPi image

Debian image for a [Raspberry Pi 3 B+](https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/) based PeachCloud

with help from [`Debian/raspi3-image-spec`](https://github.com/Debian/raspi3-image-spec)

## table of contents

- [download image](#download-image)
  - [using `dat`](#using-dat)
  - [using `wget`](#using-wget)
- [build image from source](#build-image-from-source)
  - [download image spec](#download-image-spec)
  - [build image](#build-image)
- [configure image](#configure-image)
  - [setup wireless](#setup-wireless)
- [write image to SD card](#write-image-to-SD-card)
- [connect to Pi](#connect-to-Pi)

## download image

our images are hosted on [hashbase](https://hashbase.io) as compressed `xz` files within a `dat` archive.

**pre-requisites**

- `xz`

### using [`dat`](https://github.com/datproject/dat)

**pre-requisites**

- [`dat`](https://github.com/datproject/dat#installing-the--dat-command-line-tool)

```shell
dat clone dat://peachpi-image-2019-02-13.hashbase.io peachpi-2019-02-13
cd peachpi-2019-02-13
unxz peachpi.img.xz
```

### using `wget`

```
mkdir peachpi-2019-02-13
cd peachpi-2019-02-13
wget https://peachpi-2019-02-13.hashbase.io/peachpi.img.xz
unxz peachpi.img.xz
```

## build image from source

**pre-requisites**

- Docker
- Node.js

### download image spec

clone down the image spec and install the scripts:

```
git clone https://github.com/peach-cloud/peachpi-image
cd peachpi-image
npm install
```

### build image

to build the Debian image using [`debian-image-builder`](https://github.com/ahdinosaur/debian-image-builder):

```
npm run build
```

## configure image

to mount the boot partition to `./mount`:

```shell
mkdir -p ./mount
sudo mount -o loop,offset=$((512 * 2048)) output/peachpi.img ./mount
```

to mount the root partition to `./mount`:

```shell
sudo mount -o loop,offset=$((512 * 614400)) output/peachpi.img ./mount
```

note: `offset = block size * start block`, found by using `fdisk -l output/peachpi.img`.

when you're done configuring, run

```shell
sudo umount ./mount
```

### setup wireless

if you're like @ahdinosaur and need to setup wireless before you boot the PeachPi (because you share internet with your neighbor and they have the router with Ethernet ports), you'll want to configure `wpa_supplicant`.

first get the name of your wireless device:

```shell
ifconfig
```

mine is `wlp4s0`.

then scan for the wireless networks available:

```shell
sudo iwlist <wireless_device> scan
```

you want to find the SSID of the network you want to setup, mine is `The ZigZag`.

now run:

```shell
wpa_passphrase "<ssid>"
```

and when prompted, type in your network password.

this should output something like:

```txt
network={
        ssid="The ZigZag"
        #psk="123456789"
        psk=f0c5a30de1be27b52ddb03d3be764d3cc483e085ba72b2e136588fab16f42624
}
```

now add this to your PeachPi image as `/etc/wpa_supplicant/wpa_supplicant.conf`:

```shell
sudo nano ./mount/etc/wpa_supplicant/wpa_supplicant.conf
```

also add the following at the start of the file:

```
country=nz
update_config=1
ctrl_interface=/run/wpa_supplicant
```

where the country code is an [ISO/IEC alpah2 code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements) specific to the country in which you are using your Pi.

now add a network entry for your wireless interface so it starts automatically:

```shell
sudo nano ./mount/etc/network/interfaces.d/wlan0
```

```txt
auto wlan0
iface wlan0 inet dhcp
        wpa-ssid "The ZigZag"
        wpa-psk f0c5a30de1be27b52ddb03d3be764d3cc483e085ba72b2e136588fab16f42624
```

## write image to SD card

to write your image to an SD card:

```shell
sudo dd if=output/peachpi.img of=/dev/sdX bs=64k oflag=dsync status=progress
```

where `/dev/sdX` is the device corresponding to your SD card.

if you're not sure, run `lsblk` or `sudo fdisk -l` to find the device.

## connect to Pi

once you're Pi is up and running, you should be able to find it on the network by the `peachcloud` hostname.

```shell
ssh root@peachcloud
```

the default password is `password`.

get amongst! :sunny:

## license

Copyright © 2019, Michael Williams, Michael Stapelberg and contributors

[AGPL-3.0](./LICENSE)
