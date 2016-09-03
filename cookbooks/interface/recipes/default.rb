#
# Cookbook Name:: chef_os_intf
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

node_ip = node['fabric']['ip']
node_mask = node['fabric']['mask']
node_gw = node['fabric']['gw']
node_route = node['fabric']['route'] 
bond_name = node['default']['fabric_lacp']['name']

if File.exist?('/root/.ssh/id_rsa.pub') && node['role'] == 'controller'
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

template '/etc/sysconfig/network-scripts/ifcfg-eth1' do
  source 'ifcfg-eth1.erb'
  variables ({
   :bond_master => bond_name
  })
end

template "/etc/sysconfig/network-scripts/ifcfg-#{bond_name}" do
  source 'ifcfg-bond0.erb'
  variables ({
   :ip     => node_ip,
   :mask   => node_mask,
   :name   => bond_name
  })
end

template "/etc/sysconfig/network-scripts/route-#{bond_name}" do 
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
  command 'ifup eth1'
end

