#
# Cookbook Name:: ovn
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'crudini'

#log Chef::JSONCompat.to_json_pretty(node)

include_recipe "#{cookbook_name}::pre_ovn_cleanup"

ovn_installed = node['packages'].include? 'openvswitch-ovn-common'

include_recipe "#{cookbook_name}::ovn_install" unless ovn_installed

include_recipe "#{cookbook_name}::ovn_conf"

