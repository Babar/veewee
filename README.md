**VeeWee:** the tool to easily build vagrant base boxes
Vagrant is a great tool to test new things or changes in a virtual machine(Virtualbox) using either chef or puppet.
The first step is to download an existing 'base box'. I believe this scares a lot of people as they don't know who or how this box was build. Therefore lots of people end up first building their own base box to use with vagrant.

Veewee tries to automate this and to share the knowledge and sources you need to create a basebox. Instead of creating custom ISO's from your favorite distribution, it leverages the 'keyboardputscancode' command of Virtualbox so send the actual 'boot prompt' keysequence to boot an existing iso.

Before we can actually build the boxes, we need to take care of the minimal things to install:
- Have Virtualbox 4.x installed -> download it from http://download.virtualbox.org/virtualbox/


People have reported good experiences, why don't you give it a try?

## Installation: 
__as a gem__
<pre>
$ gem install veewee 
</pre>

__from source__
<pre>
$ git clone https://github.com/jedi4ever/veewee.git
$ cd veewee
$ gem install bundler
$ bundle install

If you don't use rvm, be sure to execute vagrant through bundle exec
$ alias vagrant="bundle exec vagrant"
</pre>


## List all templates
<pre>
$ vagrant basebox templates
The following templates are available:
The following templates are available:
vagrant basebox define '<boxname>' 'Archlinux-latest'
vagrant basebox define '<boxname>' 'CentOS-4.8-i386'
vagrant basebox define '<boxname>' 'CentOS-5.5-i386'
vagrant basebox define '<boxname>' 'CentOS-5.5-i386-netboot'
vagrant basebox define '<boxname>' 'Debian-6.0-amd64-netboot'
vagrant basebox define '<boxname>' 'Debian-6.0-i386-netboot'
vagrant basebox define '<boxname>' 'Fedora-14-amd64'
vagrant basebox define '<boxname>' 'Fedora-14-amd64-netboot'
vagrant basebox define '<boxname>' 'Fedora-14-i386'
vagrant basebox define '<boxname>' 'Fedora-14-i386-netboot'
vagrant basebox define '<boxname>' 'freebsd-8.2-experimental'
vagrant basebox define '<boxname>' 'freebsd-8.2-pcbsd-i386'
vagrant basebox define '<boxname>' 'freebsd-8.2-pcbsd-i386-netboot'
vagrant basebox define '<boxname>' 'solaris-11-express-i386'
vagrant basebox define '<boxname>' 'Sysrescuecd-2.0.0-experimental'
vagrant basebox define '<boxname>' 'ubuntu-10.04.2-server-amd64'
vagrant basebox define '<boxname>' 'ubuntu-10.04.2-server-i386'
vagrant basebox define '<boxname>' 'ubuntu-10.10-server-amd64'
vagrant basebox define '<boxname>' 'ubuntu-10.10-server-amd64-netboot'
vagrant basebox define '<boxname>' 'ubuntu-10.10-server-i386'
vagrant basebox define '<boxname>' 'ubuntu-10.10-server-i386-netboot'


</pre>
## Define a new box 
Let's define a  Ubuntu 10.10 server i386 basebox called myunbuntubox
this is essentially making a copy based on the  templates provided above.
<pre>$ vagrant basebox define 'myubuntubox' 'ubuntu-10.10-server-i386'</pre>
template successfully copied

-> This copies over the templates/ubuntu-10.10-server-i386 to definition/myubuntubox

<pre>$ ls definitions/myubuntubox
definition.rb	postinstall.sh	postinstall2.sh	preseed.cfg
</pre>

## Optionally modify the definition.rb , postinstall.sh or preseed.cfg

<pre>
Veewee::Session.declare( {
  :cpu_count => '1', :memory_size=> '256', 
  :disk_size => '10140', :disk_format => 'VDI',
  :os_type_id => 'Ubuntu',
  :iso_file => "ubuntu-10.10-server-i386.iso", 
  :iso_src => "http://releases.ubuntu.com/maverick/ubuntu-10.10-server-i386.iso",
  :iso_md5 => "ce1cee108de737d7492e37069eed538e",
  :iso_download_timeout => "1000",
  :boot_wait => "10",
  :boot_cmd_sequence => [ 
      '<Esc><Esc><Enter>',
      '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
      'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
      'hostname=%NAME% ',
      'fb=false debconf/frontend=noninteractive ',
      'console-setup/ask_detect=false console-setup/modelcode=pc105 console-setup/layoutcode=us ',
      'initrd=/install/initrd.gz -- <Enter>' 
    ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",:kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",:ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
  :ssh_host_port => "2222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -H",
  :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => "10000"
   }
)
</pre>

If you need to change values in the templates, be sure to run the rake undefine, the rake define again to copy the changes across.

## Getting the cdrom file in place
Put your isofile inside the 'currentdir'/iso directory or if you don't run
<pre>$ vagrant basebox build 'myubuntubox'</pre>

- the build assumes your iso files are in 'currentdir'/iso
- if it can not find it will suggest to download the iso for you
- use '--force' to overwrite an existing install

## Build the new box:
<pre>
$ vagrant basebox build 'myubuntubox'</pre>

- This will create a machine + disk according to the definition.rb
- Note: :os_type_id = The internal Name Virtualbox uses for that Distribution
- Mount the ISO File :iso_file
- Boot up the machine and wait for :boot_time
- Send the keystrokes in :boot_cmd_sequence
- Startup a webserver on :kickstart_port to wait for a request for the :kickstart_file
- Wait for ssh login to work with :ssh_user , :ssh_password
- Sudo execute the :postinstall_files

## Validate the vm 
<pre>$ vagrant basebox validate 'myubuntubox' </pre>

this will run some cucumber test against the box to see if it has the necessary bits and pieces for vagrant to work

## Export the vm to a .box file
<pre>$ vagrant basebox export 'myubuntubox' </pre>

this is actually calling - vagrant package --base 'myubuntubox' --output 'boxes/myubuntubox.box'

this will result in a myubuntubox.box

## Add the box as one of your boxes
To import it into vagrant type:

<pre>$ vagrant box add 'myubuntubox' 'myubuntubox.box'
</pre>
## Use it in vagrant

To use it:
<pre>
$ vagrant init 'myubuntubox'
$ vagrant up
$ vagrant ssh
</pre>

## How to add a new OS/installation (needs some love)

- I suggest the easiest way is to get an account on github
- fork of the veewee repository

<pre>
$ git clone https://github.com/*your account*/veewee.git
$ cd veewee
$ gem install bundler
$ bundle install
</pre>

If you don't use rvm, be sure to execute vagrant through bundle exec
<pre>
$ alias vagrant="bundle exec vagrant"
</pre>

Start of an existing one
<pre>
$ vagrant basebox define 'mynewos' 'ubuntu...'
</pre>

- Do changes in the currentdir/definitions/mynewos
- When it builds ok, move the definition/mynewos to a sensible directory under templates
- commit the changes (git commit -a)
- push the changes to github (git push)
- go to the github gui and issue a pull request for it

## If you have a setup working, share your 'definition' with me. That would be fun! 

IDEAS:

- Now you integrate this with your CI build to create a daily basebox

FUTURE IDEAS:

- export to AMI too
- provide for more failsafe execution, testing parameters
- Do the same for Vmware Fusion
