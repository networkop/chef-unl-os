
if node['node_data']['role'] == 'controller'

  include_recipe "#{cookbook_name}::ovn_build"

  package 'python-networking-ovn.noarch'

  service 'neutron-l3-agent' do
    action [:disable, :stop]
  end

  service 'neutron-dhcp-agent' do
    action [:disable, :stop]
  end

end

package 'python-networking-ovn.noarch'

rpm_package 'upgrade ovs' do
  source "/tmp/openvswitch-#{node.default['ovn']['version']}.x86_64.rpm"
  action :upgrade
end

rpm_package 'upgrade ovs python' do
  source "/tmp/python-openvswitch-#{node.default['ovn']['version']}.noarch.rpm"
  action :upgrade
end

rpm_package 'ovn common' do
  source "/tmp/openvswitch-ovn-common-#{node.default['ovn']['version']}.x86_64.rpm"
end

if node['node_data']['role'] == 'controller'
  
  rpm_package 'ovn central' do
    source "/tmp/openvswitch-ovn-central-#{node.default['ovn']['version']}.x86_64.rpm"
  end

elsif node['node_data']['role'] == 'compute'

  rpm_package 'ovn host' do
    source "/tmp/openvswitch-ovn-host-#{node.default['ovn']['version']}.x86_64.rpm"
  end
end

service 'openvswitch' do
  action [:restart]
end

