resource_name :crudini

default_action :update

property :param, String, name_property: true

property :value, String
property :config_file, String
property :section, String, default: 'general'


load_current_value do |crudini|
  loaded_value = key_exists?(crudini.config_file,crudini.section, crudini.param)
  current_value_does_not_exist! unless loaded_value
  value loaded_value
  Chef::Log.debug "Loaded value is: #{value}"
end

action :update do
  if key_exists?(config_file, section, param)
    converge_if_changed :value do
      cmd_str = "crudini --set --existing #{config_file} \
          #{section} #{param} \"#{value}\""
      execute cmd_str do
        Chef::Log.debug "Update INI value: #{cmd_str}"
      end
    end
  else
    Chef::Log.debug "Updated key does not exist: #{param}"
  end
end

def key_exists?(config_file, section, param)
  cmd_str = "crudini --get #{config_file} #{section} #{param}"
  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command
  cmd.error? ? false : cmd.stdout.chomp
end
