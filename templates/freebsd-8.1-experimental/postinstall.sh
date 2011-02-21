#http://www.freebsd.org/doc/en_US.ISO8859-1/articles/remote-install/installation.html
dd if=/dev/zero of=/dev/ad4 count=2
#bsdlabel -wB /dev/ad4

sysctl kern.geom.debugflags=16


cat <<EOF >/install.cfg
# This is the installation configuration file for our rackmounted FreeBSD 
# cluster machines

# Turn on extra debugging.
debug=yes

#releaseName 8.0-RELEASE


################################
# My host specific data
#hostname=dragonfly
#domainname=cs.duke.edu
#nameserver=152.3.145.240
#defaultrouter=152.3.145.240
#ipaddr=152.3.145.64
#netmask=255.255.255.0
################################
tryDHCP=NO

################################
# Which installation device to use 
_ftpPath=ftp://ftp.freebsd.org/pub/FreeBSD/
netDev=em0
mediaSetFTP
################################

################################
# Select which distributions we want.
#dists= bin doc games manpages catpages proflibs dict info des compat1x compat20 compat21 X331bin X331cfg X331doc X331html X331lib X331lkit X331man X331prog X331ps X331set X331VG16 X331nest X331vfb X331fnts X331f100 X331fcyr X331fscl X331fnon sinclude
#distSetCustom
distSetMinimum
################################

################################
# Now set the parameters for the partition editor on ad4.  
disk=ad4
partition=all
#http://www.mail-archive.com/freebsd-questions@freebsd.org/msg212036.html
bootManager=standard
diskPartitionEditor
diskPartitionWrite

################################

################################
# All sizes are expressed in 512 byte blocks!
#
# A 960MB root partition, followed by a 0.5G swap partition, followed by
# a 1G /var, and a /usr using all the remaining space on the disk
#
ad4s1-1=ufs 1966080 /mnt
ad4s1-2=swap 1048576 none
ad4s1-3=ufs 2097152 /mnt/var
ad4s1-4=ufs 0 /mnt/usr
# Let's do it!


diskLabelEditor
diskLabelCommit

#http://unix.derkeiler.com/Mailing-Lists/FreeBSD/questions/2010-11/msg00420.html
installRoot=/mnt
#

# OK, everything is set.  Do it!
installCommit


# Install some packages at the end.
# package=LPRng-3.2.3
# packageAdd


# Install some packages at the end.

#
# this last package is special.  It is used to configure the machine.
# it installs several files (like /root/.rhosts) an its installation
# script tweaks several options in /etc/rc.conf
#
#package=ari-0.0
#packageAdd

EOF

exit
sysinstall configFile=/install.cfg loadConfig
