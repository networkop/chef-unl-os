#
# Cookbook Name:: pxe
# Recipe:: openstack
#


# 1. Add Openstack node definition to initialization file /opt/unetlab/html/includes/init.php.

template node['init_html_file'] do
  source 'init.erb'
end

#  2. Create a new Openstack node template based on existing linux node template.
#  3. Edit the template file replacing all occurences of ‘Linux’ with ‘Openstack’
#  4. Edit the template file to double the RAM and CPU and pass all host’s CPU instructions to Openstack nodes

cookbook_file node['openstack_temlpate'] do
  source 'openstack.php'
end

# 1. Create a new directory for Openstack image

directory node['os_image_dir'] do
  recursive true
end

# 3. Create a blank 6Gb disk image

execute "creating a virtual HDD" do
  command "/opt/qemu/bin/qemu-img create -f qcow2 -o preallocation=metadata #{node['os_image_dir']}/virtioa.qcow2 6G"
  not_if { ::File.exist? "#{node['os_image_dir']}/virtioa.qcow2" }
end
