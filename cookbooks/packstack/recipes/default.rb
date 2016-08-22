#
# Cookbook Name:: chef_unl_packstack
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

remote_file '/tmp/rdo.rpm' do
  source 'https://www.rdoproject.org/repos/rdo-release.rpm'
end

rpm_package '/tmp/rdo.rpm'

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

crudini 'CONFIG_NEUTRON_OVS_BRIDGE_IFACES' do
  value 'br-ex:eth1'
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
  value 'br-ex:eth0'
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

execute 'openstack installation' do
  command 'packstack --answer-file=/root/packstack.answer'
end
