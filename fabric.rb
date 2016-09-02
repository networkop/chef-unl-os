require 'chef/provisioning/ssh_driver'

with_chef_local_server({
  :chef_repo_path => "/tmp",
  :cookbook_path => ["#{File.dirname(__FILE__)}/cookbooks"],
})

with_driver 'ssh'

nodes = node['fabric']

nodes.each do |node_id,node_data|	
  node_ip = "#{node["pxe"]["pfx"]}.#{100+node_id.to_i}"
  machine "#{node_data['role']}-#{node_id}" do
    attributes :node_id => node_id, :node_data => node_data, :os_lab => node['os_lab']
    recipe 'fabric'
    machine_options :transport_options => {
        :host => node_ip,
        :username => 'cumulus',
        :ssh_options => {
          :use_agent => true,
          :keys => ['/root/.ssh/id_rsa']
        }
      }, :convergence_options => {
           :chef_version => "12.13.30"
      }
  end
end
