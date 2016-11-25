yum_package 'python-networking-ovn'

if node['node_data']['role'] == 'controller'

  service 'openvswitch' do
    action [:start, :enable]
  end

  service 'ovn-northd' do
    action [:start, :enable]
  end

  crudini 'core_plugin' do
    value 'neutron.plugins.ml2.plugin.Ml2Plugin'
    config_file '/etc/neutron/neutron.conf'
    section 'DEFAULT'
  end

  crudini 'service_plugins' do
    value 'networking_ovn.l3.l3_ovn.OVNL3RouterPlugin'
    config_file '/etc/neutron/neutron.conf'
    section 'DEFAULT'
  end

  crudini 'mechanism_drivers' do
    value 'ovn'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ml2'
  end

  crudini 'type_drivers' do
    value 'local,flat,vlan,geneve'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ml2'
  end

  crudini 'tenant_network_types' do
    value 'geneve'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ml2'
  end

  crudini 'extension_drivers' do
    value 'port_security'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ml2'
  end

  crudini 'vni_ranges' do
    value '1:65535'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ml2_type_geneve'
  end

  crudini 'max_header_size' do
    value '38'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ml2_type_geneve'
  end


  crudini 'enable_security_group' do
    value 'true'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'securitygroup'
  end

  crudini 'ovn_nb_connection' do
    value "tcp:#{node['controllers'][0]}:6641"
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ovn'
  end

  crudini 'ovn_sb_connection' do
    value "tcp:#{node['controllers'][0]}:6642"
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ovn'
  end

  crudini 'ovn_l3_mode' do
    value 'true'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ovn'
  end

  crudini 'ovn_l3_scheduler' do
    value 'leastloaded'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ovn'
  end


  crudini 'ovn_native_dhcp' do
    value 'true'
    config_file '/etc/neutron/plugins/ml2/ml2_conf.ini'
    section 'ovn'
  end

  service 'neutron-server' do
    action :restart
  end

  service 'ovn-northd' do
    action :restart
  end

elsif node['node_data']['role'] == 'compute'
  
  service 'openvswitch' do
    action :start
  end

  execute 'point OVS to sbdb' do
    command "ovs-vsctl set open . external-ids:ovn-remote=tcp:#{node['controllers'][0]}:6642"
  end

  execute 'enable overlay protocols' do
    command "ovs-vsctl set open . external-ids:ovn-encap-type=geneve,vxlan"
  end

  execute 'configure overlay IP address' do
    command "ovs-vsctl set open . external-ids:ovn-encap-ip=#{node['node_data']['fabric']['ip']}"
  end

  execute 'configure external bridge mapping' do
    command 'ovs-vsctl set Open_vSwitch . external-ids:ovn-bridge-mappings=extnet:br-ex'
  end

  service 'ovn-controller' do
    action [:start, :enable]
  end
  
  service 'network' do
    action :restart
  end

end

