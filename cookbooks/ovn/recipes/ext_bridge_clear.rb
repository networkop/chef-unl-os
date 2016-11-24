
# Moving external interface from the br-ex

phy_int = node.network.default_interface
int_gw = node.network.default_gateway
int_ip = node.network.interfaces[phy_int]['addresses'].select{ |k,v| v['family'] == 'inet'}.keys.first
int_pfx = node.network.interfaces[phy_int]['addresses'][int_ip]['prefixlen']
fname_phy_int = "/etc/sysconfig/network-scripts/ifcfg-#{phy_int}"

template "/etc/sysconfig/network-scripts/ifcfg-#{node.default['ext_int']}" do
  source 'controller-ext_int.erb'
  variables ({
    :intf_ip => int_ip,
    :intf_pfx => int_pfx,
    :intf_gw => int_gw,
    :intf_name=> node.default['ext_int']
  })
end

template "/etc/sysconfig/network-scripts/ifcfg-br-ex" do
  source 'controller-br_ex.erb'
end

execute 'remove interface from ovsdb' do
  command "ovs-vsctl del-port br-ex #{node.default['ext_int']}"
  ignore_failure true
end

service 'network' do
  action [:restart]
end
