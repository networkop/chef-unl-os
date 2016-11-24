
include_recipe "#{cookbook_name}::ext_bridge_clear"

execute 'delete ovs db' do
  command 'rm -rf /etc/openvswitch/*'
end

package 'openstack-neutron-openvswitch' do
    action :remove
end

service 'openvswitch' do
  action :restart
end

service 'network' do
  action :restart
end

if node['node_data']['role'] == 'compute'
  include_recipe "#{cookbook_name}::ext_bridge_create"
end
