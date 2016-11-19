#
# Cookbook Name:: chef_os_intf
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

node_ip = node['node_data']['fabric']['ip']
node_mask = node['node_data']['fabric']['mask']
node_gw = node['node_data']['fabric']['gw']
node_route = node['node_data']['fabric']['route'] 
bond_intf = node.default['bond_intf']
fabric_intf = node.default['fabric_intf']

if File.exist?('/root/.ssh/id_rsa.pub') && node['node_data']['role'] == 'controller'
  log "SETTING SSH KEYS"
  node.normal['controller_ssh'] = ::File.read('/root/.ssh/id_rsa.pub').chomp
end

controller_nodes = search(:node, 'controller_ssh:*').push(node)
first_controller = controller_nodes.first
log controller_nodes.empty?

execute "Add Controller's key to authorized" do
  command "echo #{first_controller['controller_ssh']} >> ~/.ssh/authorized_keys"
  not_if 'grep controller ~/.ssh/authorized_keys'
end

template "/etc/sysconfig/network-scripts/ifcfg-#{node.default['fabric_intf']}" do
  source 'ifcfg-fabric.erb'
  variables ({
   :bond_master => bond_intf,
   :intf_name   => fabric_intf
  })
end

template "/etc/sysconfig/network-scripts/ifcfg-#{bond_intf}" do
  source 'ifcfg-bond0.erb'
  variables ({
   :ip     => node_ip,
   :mask   => node_mask,
   :name   => bond_intf
  })
end

template "/etc/sysconfig/network-scripts/route-#{bond_intf}" do 
  source 'route-bond0.erb'
  variables ({
   :gw => node_gw,
   :route => node_route
  })
end


template '/etc/hosts' do
  source 'hosts.erb'
  variables ({
    :host_1 => node['hostname'],
    :ip_1 => node['ipaddress'],
    :host_2 => "#{node['hostname']}-fabric",
    :ip_2 => node_ip
  })
end

execute 'bring up the fabric interface' do
  command "ifup #{fabric_intf}"
end

execute 'bring up the bond interface' do
  command "ifup #{bond_intf}"
end

