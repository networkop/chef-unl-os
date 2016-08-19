resource_name :cobbler_image

property :image_name, String, name_property: true

property :checksum, String
property :source, String
property :os_version, String
property :os_breed, String

load_current_value do
  cmd_str = "cobbler distro report --name=#{distro}"
  cmd = Mixlib::ShellOut.new(cmd_str)
  Chef::Log.debug "cobbler_distro_exists?: #{cmd_str}"
  cmd.run_command
  image_name = cmd.stdout
end

action :create do
 converge_by "Creating cobbler distro #{new_resource.name}" do
    if distro_exists?(new_resource.name)
      cmd_str = "cobbler import --name=#{new_resource.name} \
	  --path=/mnt --breed=#{new_resource.breed}"
      execute cmd_str do
        Chef::Log.debug "cobbler_distro-create: #{cmd_str}"
        Chef::Log.info "Create new cobler distro: #{new_resource.name}"
        new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.info "Cobbler distro already exists #{new_resource.name}"
    end
  end
end 

action :destroy do
  converge_by "Destroying cobbler distro #{new_resource.name}" do
    if  distro_exists?(new_resource.name)
      Chef::Log.info "No cobbler distro #{new_resource.name} nothing to do"
    else
      cmd_str = "cobbler distro remove --name #{new_resource.name}"
      execute cmd_str do
        Chef::Log.debug "cobbler_distro-destroy: #{cmd_str}"
        Chef::Log.info "Delete cobbler distro: #{new_resource.name}"
        new_resource.updated_by_last_action(true)
      end
    end
  end
end


def distro_exists?(distro)
  cmd_str = "cobbler distro report --name=#{distro}"
  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command
  Chef::Log.debug "cobbler_distro_exists?: #{cmd_str}"
  cmd.error? ? false : true
end