#!/bin/sh

FreeSBIE=/usr/local/livefs

rm -rf /tmp/*
rm -rf /tmp/*.*

echo

umount /tmp 2>/dev/null
mdconfig -d -u 91 2>/dev/null

cd /home/sullrich

chflags -R noschg /tmp/
rm -rf /tmp/*

cp /home/sullrich/pfSense/boot/device.hints_wrap \
        /usr/local/livefs/boot/device.hints
cp /home/sullrich/pfSense/boot/loader.conf_wrap \
        /usr/local/livefs/boot/loader.conf
cp /home/sullrich/pfSense/etc/ttys_wrap \
	/usr/local/livefs/etc/

mkdir  $FreeSBIE/dev 2>/dev/null
rm -f $FreeSBIE/etc/rc.d/freesbie_1st 2>/dev/null
rm -f $FreeSBIE/usr/local/share/freesbie/files/000.freesbie_2nd.sh 2>/dev/null
rm -rf $FreeSBIE/cloop 2>/dev/null
rm -rf $FreeSBIE/dist 2>/dev/null
rm -f $FreeSBIE/etc/rc.local 2>/dev/null
rm $FreeSBIE/root/.tcshrc 2>/dev/null
rm $FreeSBIE/root/.message* 2>/dev/null
rm $FreeSBIE/etc/rc.conf 2>/dev/null
touch $FreeSBIE/etc/rc.conf 2>/dev/null

# Prevent the system from asking for these twice
touch $FreeSBIE/root/.part_mount 
touch $FreeSBIE/root/.first_time

echo > $FreeSBIE/etc/motd
echo /etc/rc.initial > $FreeSBIE/root/.shrc
echo exit >> $FreeSBIE/root/.shrc
rm -f $FreeSBIE/usr/local/bin/after_installation_routines.sh 2>/dev/null

cd /home/sullrich/tools
echo Calculating size of /usr/local/livefs...
du -H -d0 /usr/local/livefs
cd /home/sullrich/tools
echo Running DD
/bin/dd if=/dev/zero of=image.bin bs=1k count=111072
echo Running mdconfig
/sbin/mdconfig -a -t vnode -u91 -f image.bin
disklabel -BR md91 /home/sullrich/pfSense/boot/label.proto_wrap
echo Running newfs
newfs /dev/md91
newfs /dev/md91a
echo Mounting /tmp
mount /dev/md91a /tmp

echo Populating /tmp/
echo livefs
cd /usr/local/livefs/ && tar czPf /home/sullrich/livefs.tgz .
cd /tmp/ && tar xzPf /home/sullrich/livefs.tgz
echo pfSense
cd /home/sullrich/pfSense && tar czPf /home/sullrich/pfSense.tgz .
cd /tmp/ && tar xzPf /home/sullrich/pfSense.tgz

echo /dev/ad0		/		ufs	rw		1 \
	1 > /tmp/etc/fstab
echo /dev/ad0a /cf ufs ro 1 1 >> /tmp/etc/fstab

ls /tmp/cf/conf

cd /home/sullrich/tools && umount /tmp
/sbin/mdconfig -d -u 91

echo GZipping image.bin
gzip -9 image.bin
mv image.bin.gz pfSense-128-megs.bin.gz
ls -la pfSense-128-megs.bin.gz
echo Cleaning up /tmp/
rm -rf /tmp/*
rm -rf /tmp/*.*
