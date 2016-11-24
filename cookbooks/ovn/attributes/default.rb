default['ext_int'] = 'ens3'
default['ovn']['req'] = ['rpm-build', 'autoconf', 'automake', \
                         'libtool', 'systemd-units', 'openssl', \
                         'openssl-devel', 'python', 'python-twisted-core', \
                         'python-zope-interface', 'python-six', \
                         'desktop-file-utils', 'groff', 'graphviz', \
                         'procps-ng', 'libcap-ng', 'libcap-ng-devel']
default['ovn']['extra'] = ['selinux-policy-devel', 'git', 'kernel-devel']
default['ovn']['common'] = 'openvswitch-ovn-common'
default['ovn']['version'] = '2.6.90-1.el7.centos'
default['ovn']['git'] = 'https://github.com/openvswitch/ovs.git'
