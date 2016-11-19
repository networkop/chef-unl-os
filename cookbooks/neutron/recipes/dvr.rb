
if node['node_data']['role'] == 'controller'

  execute "Safely uncomment setting" do
    command "sed -ri 's/^#(router_distributed.*$)/\\1/' /etc/neutron/neutron.conf"
    not_if 'grep -E "^router_distributed" /etc/neutron/neutron.conf'
  end

  crudini 'router_distributed' do
    value 'true'
    section 'DEFAULT'
    config_file '/etc/neutron/neutron.conf'
  end

  execute "Safely uncomment setting" do
    command "sed -ri 's/^#(agent_mode.*$)/\\1/' /etc/neutron/l3_agent.ini"
    not_if 'grep -E "^agent_mode" /etc/neutron/l3_agent.ini'
  end

  crudini 'agent_mode' do
    value 'dvr_snat'
    section 'DEFAULT'
    config_file '/etc/neutron/l3_agent.ini'
  end

  service 'neutron-server' do
    action [:restart]
  end

elsif node['node_data']['role'] == 'compute'
  
  include_recipe "#{cookbook_name}::ext_bridge"

  execute "Safely uncomment setting" do
    command "sed -ri 's/^#(agent_mode.*$)/\\1/' /etc/neutron/l3_agent.ini"
    not_if 'grep -E "^agent_mode" /etc/neutron/l3_agent.ini'
  end

  crudini 'agent_mode' do
    value 'dvr'
    section 'DEFAULT'
    config_file '/etc/neutron/l3_agent.ini'
  end

  execute "Safely uncomment setting" do
    command "sed -ri 's/^#(interface_driver.*$)/\\1/' /etc/neutron/l3_agent.ini"
    not_if 'grep -E "^interface_driver" /etc/neutron/l3_agent.ini'
  end

  crudini 'interface_driver' do
    value 'neutron.agent.linux.interface.OVSInterfaceDriver'
    section 'DEFAULT'
    config_file '/etc/neutron/l3_agent.ini'
  end

  execute "Safely uncomment setting" do
    command "sed -ri 's/^#(bridge_mappings.*$)/\\1/' /etc/neutron/plugins/ml2/openvswitch_agent.ini"
    not_if 'grep -E "^bridge_mappings" /etc/neutron/plugins/ml2/openvswitch_agent.ini'
  end

  crudini 'bridge_mappings' do
    value 'extnet:br-ex'
    section 'ovs'
    config_file '/etc/neutron/plugins/ml2/openvswitch_agent.ini'
  end

  service 'neutron-l3-agent' do
    action [:enable]
  end

end

# Execute on ALL nodes

execute "Safely uncomment setting" do
  command "sed -ri 's/^#(enable_distributed_routing.*$)/\\1/' /etc/neutron/plugins/ml2/openvswitch_agent.ini"
  not_if 'grep -E "^enable_distributed_routing" /etc/neutron/plugins/ml2/openvswitch_agent.ini'
end

crudini 'enable_distributed_routing' do
  value 'true'
  section 'agent'
  config_file '/etc/neutron/plugins/ml2/openvswitch_agent.ini'
end

execute "Safely uncomment setting" do
  command "sed -ri 's/^#(nova_metadata_ip.*$)/\\1/' /etc/neutron/metadata_agent.ini"
  not_if 'grep -E "^nova_metadata_ip" /etc/neutron/metadata_agent.ini'
end

crudini 'nova_metadata_ip' do
  value "#{node.default['metadata']['ip']}"
  section 'DEFAULT'
  config_file '/etc/neutron/metadata_agent.ini'
end

execute "Safely uncomment setting" do
  command "sed -ri 's/^#(metadata_proxy_shared_secret.*$)/\\1/' /etc/neutron/metadata_agent.ini"
  not_if 'grep -E "^metadata_proxy_shared_secret" /etc/neutron/metadata_agent.ini'
end

crudini 'metadata_proxy_shared_secret' do
  value "#{node.default['metadata']['secret']}"
  section 'DEFAULT'
  config_file '/etc/neutron/metadata_agent.ini'
end


service 'neutron-l3-agent' do
  action [:restart]
end

service 'neutron-openvswitch-agent' do
  action [:restart]
end

service 'neutron-metadata-agent' do
  action [:restart, :enable]
end

