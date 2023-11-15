#!/usr/bin/env bash 

## Set Variables
ISO_PATH=/var/lib/libvirt/iso/AlmaLinux-9-latest-x86_64-boot.iso
INSTALL_URL=https://nexus.home.jpconsulted.com/repository/almalinux/9/BaseOS/x86_64/os/

## Check if run as root
if [ "${UID}" != "0" ]
  then echo "This script must be run as root" && exit 1 
fi

## Cleanup old VM
virsh destroy pxe
virsh undefine --nvram --remove-all-storage pxe


## Create VM, 2 vCPUs, 4GB RAM, bridge networking, with a Kickstart file to automate install
virt-install --name pxe \
    --memory 4096 \
    --vcpus "sockets=1,cores=2,threads=1" \
    --location ${INSTALL_URL} \
    --extra-args 'console=tty0 console=ttyS0 nameserver=10.1.0.2 systemd.zram=0 ip=10.1.0.8::10.1.0.1:255.255.255.0:boot.home.jpconsulted.com:enp1s0:none inst.ks=http://10.1.0.2/pxe.ks' \
    --os-variant almalinux9 \
    --disk size=150 \
    --network bridge=br0 \
    --noreboot \
    --autoconsole text
