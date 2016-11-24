
# Setting up br-ex on all compute nodes

phy_int = node.network.default_interface
int_gw = node.network.default_gateway
int_ip = node.network.interfaces[phy_int]['addresses'].select{ |k,v| v['family'] == 'inet'}.keys.first
int_pfx = node.network.interfaces[phy_int]['addresses'][int_ip]['prefixlen']

template "/etc/sysconfig/network-scripts/ifcfg-#{node.default['ext_int']}" do
  source 'ifcfg-ext_int.erb'
  variables ({
    :intf_name=> node.default['ext_int']
  })
end

template "/etc/sysconfig/network-scripts/ifcfg-br-ex" do
  source 'ifcfg-ext_br.erb'
  variables ({
    :intf_ip => int_ip,
    :intf_pfx => int_pfx,
    :intf_gw => int_gw
  })
end

service 'network' do
  action [:restart]
end
