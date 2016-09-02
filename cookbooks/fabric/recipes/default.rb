#
# Cookbook Name:: fabric
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


if node['packages']['cumulus-platform-info']
  include_recipe "#{cookbook_name}::cumulus"
else
   Chef::Log 'ELSE BRANCH'  
end
