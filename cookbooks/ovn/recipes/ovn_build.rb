
for pkg in node.default['ovn']['req'] do
  yum_package pkg  
end

git '/tmp/ovs' do
  repository node.default['ovn']['git']
  :checkout
end

bash 'bootstrap' do
  cwd '/tmp/ovs'
  creates '/tmp/ovs/rpm/rpmbuild/RPMS/x86_64/'
  code <<-EOH
    ./boot.sh
    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
    make rpm-fedora RPMBUILD_OPT="--without check"
    EOH
end

execute 'copy no_arch rpms' do
  command 'cp /tmp/ovs/rpm/rpmbuild/RPMS/noarch/* /tmp'
end

execute 'copy x86 rpms' do
  command 'cp /tmp/ovs/rpm/rpmbuild/RPMS/x86_64/* /tmp'
end

for n in node['node_ips'] do
  execute 'scp rpms to all nodes' do
    command "scp -oStrictHostKeyChecking=no /tmp/*.rpm #{n}:/tmp"
  end
end
