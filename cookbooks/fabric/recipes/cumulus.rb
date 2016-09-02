
#log Chef::JSONCompat.to_json_pretty(node.to_hash)

node_id = node['node_id']
node_data = node['node_data']

log Chef::JSONCompat.to_json_pretty(node.node_data.to_hash)

# Configure interfaces

file '/tmp/interfaces.erb' do
  content IO.read('/etc/network/interfaces')
  not_if do ::File.exists?('/tmp/interfaces.erb') end
end

ruby_block "insert interface partial" do
  block do
    file = Chef::Util::FileEdit.new("/tmp/interfaces.erb")
    file.insert_line_if_no_match("interfaces.erb", "<%= render \"interfaces.erb\", :variables => {:interfaces => @interfaces,
                                                                                                  :access => @access,
                                                                                                  :os_lab => @os_lab 
    } %>")
    file.write_file
  end
end

template '/etc/network/interfaces' do
  source '/tmp/interfaces.erb'
  local true
    variables ({
   :interfaces => node_data['isl'],
   :access => node_data['access'],
   :os_lab => node['os_lab']
  })
end


execute 'reload all interfaces' do
    command 'ifreload -a'
end

# Configure routing protocols

template '/etc/quagga/Quagga.conf' do
  source 'quagga.erb'
  variables ({
   :id => node['node_id']
  })
end

# Make sure routing daemons are enabled (redo with crudini)

execute 'enable zebra' do
  command 'sed -i s/zebra=no/zebra=yes/ /etc/quagga/daemons'
end

execute 'enable bgpd' do
  command 'sed -i s/bgpd=no/bgpd=yes/ /etc/quagga/daemons'
end

# Restart routing daemons

service 'quagga' do
  action [:restart]
end



