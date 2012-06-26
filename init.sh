#!/sbin/busybox sh

export PATH=/sbin

mkdir /dev
mknod /dev/null c 1 3
mknod /dev/zero c 1 5
mknod /dev/urandom c 1 9
mkdir /dev/block
mkdir /dev/input
mknod /dev/input/event0 c 13 64

# TODO : Fix LEDS and vibrator

# trigger blue LED
echo '255' > /sys/devices/i2c-3/3-0040/leds/blue/brightness
# trigger vibration
echo '200' > /sys/class/timed_output/vibrator/enable
# trigger button-backlight
echo '255' > /sys/class/leds/button-backlight/brightness
cat /dev/input/event0 > /dev/keycheck&
sleep 3

# trigger blue LED
echo '0' > /sys/devices/i2c-3/3-0040/leds/blue/brightness
# trigger button-backlight
echo '0' > /sys/class/leds/button-backlight/brightness

if [ -s /dev/keycheck ]
then
	mkdir /etc
	
	# We avoid to have an etc folder directly in the ramdisk because
	# of the symlink /system/etc -> /etc with Sony's init.rc
	cp recovery.fstab /etc/recovery.fstab
	
	ln -s ../init_gb /sbin/ueventd
	rm /init.rc
	rm /init.semc.rc
	rm /init.usbmode.sh
	mv /recovery.rc /init.rc
	
	# GB init for recovery
	/init_gb
else
	ln -s ../init_ics /sbin/ueventd
	
	# Boot stock ICS
	/init_ics
fi