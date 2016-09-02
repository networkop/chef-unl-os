
cookbook_file '/etc/apache2/sites-available/cumulus.conf' do
  source 'cumulus.conf'
end

link '/etc/apache2/sites-enabled/cumulus.conf' do
  to '/etc/apache2/sites-available/cumulus.conf'
end

service 'apache2' do
  action [:restart]
end

template '/var/lib/tftpboot/cumulus/ztp.sh' do
  source 'ztp.erb'
    variables ({
     :ssh_key     => node['ssh_key']
    })
end
