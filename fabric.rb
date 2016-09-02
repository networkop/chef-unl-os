require 'chef/provisioning/ssh_driver'

with_chef_local_server({
  :chef_repo_path => "/tmp",
  :cookbook_path => ["#{File.dirname(__FILE__)}/cookbooks"],
})

with_driver 'ssh'

nodes = node['fabric']

nodes.each do |node_id,node_ip|	
  machine node_ip do
    recipe 'leaf'
    attribute 'id', node_id
    machine_options :transport_options => {
        :host => node_ip,
        :username => 'cumulus',
        :ssh_options => {
          :use_agent => true,
          :keys => ['/root/.ssh/id_rsa']
        }
      }, :convergence_options => {
           :chef_version => "12.13.30",
           :install_sh_path => "/tmp/chef/chef-install.sh"
      }
  end
end
