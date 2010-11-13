       Veewee::Session.declare( {
        :cpu_count => '1', :memory_size=> '384', 
        :disk_size => '10140', :disk_format => 'VDI',:disk_size => '10240' ,
        :os_type_id => 'RedHat',
        :iso_file => "CentOS-4.8-i386-bin-DVD.iso", :iso_src => "", :iso_md5 => "", :iso_download_timeout => 1000,
        :boot_wait => "10",:boot_cmd_sequence => [ 
          		          'linux text ks=http://%IP%:%PORT%/ks.cfg<Enter>' 				  
          ],
        :kickstart_port => "7122", :kickstart_timeout => 10000,:kickstart_file => "ks.cfg",
        :ssh_login_timeout => "100",:ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
        :ssh_host_port => "2222", :ssh_guest_port => "22",
        :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => 10000
         }
      )