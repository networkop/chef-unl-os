#
# Cookbook Name:: neutron
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'crudini'

include_recipe "#{cookbook_name}::l2_population"

include_recipe "#{cookbook_name}::dvr"

