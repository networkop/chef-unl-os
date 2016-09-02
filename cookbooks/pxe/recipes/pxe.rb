#
# Cookbook Name:: pxe
# Recipe:: pxe
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'tftpd-hpa'
package 'isc-dhcp-server'
package 'iptables'


file '/tmp/interfaces.erb' do
  content IO.read('/etc/network/interfaces')
  not_if do ::File.exists?('/tmp/interfaces.erb') end
end

ruby_block "insert pxe interface partial" do
  block do
    file = Chef::Util::FileEdit.new("/tmp/interfaces.erb")
    file.insert_line_if_no_match("interfaces.erb", "<%= render \"interfaces.erb\" %>")
    file.write_file
  end
end

template '/etc/network/interfaces' do
  source '/tmp/interfaces.erb'
  local true
  variables ({
   :pxe_ip     => node['pxe']['gw'],
   :pxe_mask   => node['pxe']['mask']
  })
end

execute 'bring up the pxe interface' do
  command 'ifup pnet10'
end

execute 'enable ip forwarding' do
  command 'sysctl -w net.ipv4.ip_forward=1'
end

execute 'enable persistent ip forwarding' do
  command "sudo sed -ri 's/.*(net\.ipv4\.ip_forward).*$/\1=1/' /etc/sysctl.conf"
end

cookbook_file '/etc/default/tftpd-hpa' do
  source 'tftpd-hpa'
end

service 'tftpd-hpa' do
  action [:restart]
end

template '/etc/dhcp/dhcpd.conf' do
  source 'dhcpd.conf.erb'
  variables ({
   :pxe_net    => node['pxe']['net'],
   :pxe_ip     => node['pxe']['gw'],
   :pxe_mask   => node['pxe']['mask'],
   :pxe_prefix => node['pxe']['pfx']
  })
end


service 'isc-dhcp-server' do
  action [:restart]
end

directory '/var/lib/tftpboot/pxelinux.cfg' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/var/lib/tftpboot/ks' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/var/lib/tftpboot/centos7_x64' do
  owner 'root'
  group 'root'
  mode '0755'
  not_if { ::File.directory? '/var/lib/tftpboot/centos7_x64' }
end


['pxelinux.0', 'menu.c32'].each do |file|
  cookbook_file "/var/lib/tftpboot/#{file}" do
    source file
  end
end

template '/var/lib/tftpboot/pxelinux.cfg/default' do
  source 'pxe-menu_default.erb'
  variables ({
   :pxe_ip     => node['pxe']['gw']
  })
end

template '/var/lib/tftpboot/ks/kickstart-default.ks' do
  source 'kickstart-default.ks.erb'
  variables ({
   :pxe_ip     => node['pxe']['gw'],
   :root_pwd   => node['password'],
   :pxe_mask   => node['pxe']['mask'],
   :pxe_prefix => node['pxe']['pfx'],
   :ssh_key    => node['ssh_key']
  })
end

remote_file "/root/isofile" do
  source "#{node['centos_iso_http']}"
  checksum 'f90e4d28fa377669b2db16cbcb451fcb9a89d2460e3645993e30e137ac37d284'
end

mount '/var/lib/tftpboot/centos7_x64' do
  device "/root/isofile"
  fstype 'iso9660'
  action :mount
end

cookbook_file '/etc/apache2/sites-available/pxe.conf' do
  source 'pxe.conf'
end

link '/etc/apache2/sites-enabled/pxe.conf' do
  to '/etc/apache2/sites-available/pxe.conf'
end

service 'apache2' do
  action [:restart]
end
