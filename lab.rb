require 'chef/provisioning/ssh_driver'

with_chef_local_server({
  :chef_repo_path => "/tmp",
  :cookbook_path => ["#{File.dirname(__FILE__)}/cookbooks"],
})

with_driver 'ssh'

nodes = node["os_lab"]
controllers = nodes.select{ |k,v| v['role'] == 'controller'}.keys.map{ |id| "#{node['pxe']['pfx']}.#{10+id.to_i}" }
compute_nodes = nodes.select{ |k,v| v['role'] == 'compute'}.keys.map{ |id| "#{node['pxe']['pfx']}.#{10+id.to_i}" }

nodes.each do |node_id,node_data|
  node_ip = "#{node["pxe"]["pfx"]}.#{10+node_id.to_i}"
  machine "#{node_data['role']}-#{node_id}" do
    attributes :node_data => node_data
    recipe 'interface'
    machine_options :transport_options => {
      :host => node_ip,
      :username => 'root',
      :ssh_options => {
        :use_agent => true,
        :keys => ['/root/.ssh/id_rsa']
      } 
    }, :convergence_options => {
         :chef_version => "12.13.30"
    }
  end
end


machine controllers[0] do
  node_ip = controllers[0]
  attributes :os_nodes => {
    :controllers => controllers,
    :compute_nodes => compute_nodes
  }
  recipe 'packstack'
  machine_options :transport_options => {
      :host => node_ip,
      :username => 'root',
      :ssh_options => {
        :use_agent => true,
        :keys => ['/root/.ssh/id_rsa']
      }
    }, :convergence_options => {
         :chef_version => "12.13.30"
    }
end
