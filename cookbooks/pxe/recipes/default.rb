#
# Cookbook Name:: pxe
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute 'generate SSH key' do
  creates '/root/.ssh/id_rsa'
  command 'ssh-keygen -b 2048 -f /root/.ssh/id_rsa -t rsa -q -N ""'
end.run_action(:run)

node.default['ssh_key'] = ::File.read('/root/.ssh/id_rsa.pub').chomp

include_recipe "#{cookbook_name}::openstack"
include_recipe "#{cookbook_name}::pxe"

node['os_lab'].each do |node_id, node_data|
  node_mac = "50:%02d:%02d:%02d:00:00" % [node['unl']['tenant_id'],node_id.to_i / 512, node_id.to_i % 512]
  mac_string = node_mac.gsub(/:/,'-')
  Chef::Log.info("\nMAC ADDRESS: #{mac_string}\n")

  node_ip = "#{node['pxe']['pfx']}.#{10+node_id.to_i}"
  node_mask = "#{node['pxe']['mask']}"
  node_hostname = "#{node_data.role}-#{node_id}"

  template "/var/lib/tftpboot/pxelinux.cfg/01-#{mac_string}" do
    source 'pxe-menu.erb'
    variables ({
     :mac_addr   => mac_string,
     :pxe_ip     => node['pxe']['gw'],
     :hostname   => node_hostname
    })
  end

  template "/var/lib/tftpboot/ks/#{mac_string}.ks" do
    source 'kickstart.ks.erb'
    variables ({
     :mac_addr    => mac_string,
     :server_name => node_hostname,
     :pxe_ip      => node['pxe']['gw'],
     :root_pwd    => node['password'],
     :node_ip     => node_ip,
     :node_mask   => node_mask,
     :ssh_key     => node['ssh_key']
    })

  end
end

execute 'install ssh provisioner' do
  command 'chef gem install chef-provisioning-ssh'
  not_if 'chef gem list --local | grep chef-provisioning-ssh'
end
