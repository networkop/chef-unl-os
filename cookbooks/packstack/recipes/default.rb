#
# Cookbook Name:: chef_unl_packstack
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.



if node.default['bleedingedge']

  remote_file '/etc/yum.repos.d/delorean-deps.repo' do
    source 'http://trunk.rdoproject.org/centos7/delorean-deps.repo'
  end

  remote_file '/etc/yum.repos.d/delorean.repo' do
    source 'https://trunk.rdoproject.org/centos7-master/current/delorean.repo'
  end

  for ip in node['os_nodes']['compute_nodes'] do
    execute 'copy repos to other nodes' do
      command "scp -oStrictHostKeyChecking=no /etc/yum.repos.d/delorean* #{ip}://etc/yum.repos.d/" 
    end
  end

else

  yum_package 'centos-release-openstack-newton'

end


execute 'yum -y update' do
  command 'yum -y update'
end

yum_package 'openstack-packstack'
yum_package 'crudini'

execute 'generate answer file' do
  creates '/root/packstack.answer'
  command 'packstack --gen-answer-file=/root/packstack.answer'
end

crudini 'CONFIG_CINDER_INSTALL' do
  value 'n'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_CEILOMETER_INSTALL' do
  value 'n'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_SWIFT_INSTALL' do
  value 'n'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_AODH_INSTALL' do
  value 'n'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_GNOCCHI_INSTALL' do
  value 'n'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_NAGIOS_INSTALL' do
  value 'n'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS' do
  value 'extnet:br-ex'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_NEUTRON_ML2_TYPE_DRIVERS' do
  value 'vxlan,flat'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_PROVISION_DEMO' do
  value 'n'
  config_file '/root/packstack.answer'
end
 
crudini 'CONFIG_NEUTRON_OVS_BRIDGE_IFACES' do
  value "br-ex:#{node.default['ext_intf']}"
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_CONTROLLER_HOST' do
  value node['os_nodes']['controllers'].join(',')
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_NETWORK_HOSTS' do
  value node['os_nodes']['controllers'].join(',')
  config_file '/root/packstack.answer'
end


crudini 'CONFIG_COMPUTE_HOSTS' do
  value node['os_nodes']['compute_nodes'].join(',')
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_KEYSTONE_ADMIN_PW' do
  value 'openstack'
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_NEUTRON_OVS_TUNNEL_IF' do
  value "#{node.default['tunnel_intf']}"
  config_file '/root/packstack.answer'
end

crudini 'CONFIG_USE_EPEL' do
  value 'y'
  config_file '/root/packstack.answer'
end


execute 'openstack installation' do
  command 'packstack --answer-file=/root/packstack.answer'
end
