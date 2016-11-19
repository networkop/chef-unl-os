if node['node_data']['role'] == 'controller'

  crudini 'mechanism_drivers' do
    value node.default['mechanism_drivers'].join(',')
    section 'ml2'
    config_file '/etc/neutron/plugin.ini'
  end

  service 'neutron-server' do
    action [:restart]
  end

end

# Execute on ALL nodes

crudini 'l2_population' do
  value 'true'
  section 'agent'
  config_file '/etc/neutron/plugins/ml2/openvswitch_agent.ini'
end

execute "Safely uncomment setting" do
  command "sed -ri 's/^#(arp_responder.*$)/\\1/' /etc/neutron/plugins/ml2/openvswitch_agent.ini"
  not_if 'grep -E "^arp_responder" /etc/neutron/plugins/ml2/openvswitch_agent.ini'
end


crudini 'arp_responder' do
  value 'true'
  section 'agent'
  config_file '/etc/neutron/plugins/ml2/openvswitch_agent.ini'
end


service 'neutron-openvswitch-agent' do
  action [:restart]
end
