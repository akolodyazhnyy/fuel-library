#    Copyright 2013 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
#
# 
# This class is intended to make cobbler profile centos63_x86_64.
#
# [distro] The name of cobbler distro to bind profile to.
#
# [ks_repo] Repository definitions (array of hashes with name and url keys)
# where RPM packages are available which are not available in the main
# kickstart url.
#
# [ks_system_timezone] System timezone on installed system.
#
# [ks_encrypted_root_password] Hash of the root password on installed system.
#  default password is 'r00tme'
#

class cobbler::profile::centos63_x86_64(

  $distro                     = 'centos63_x86_64',
  $ks_repo                    = [
#    {
#      'name' => 'Puppet',
#      'url'  => 'http://yum.puppetlabs.com/el/6/products/x86_64',
#    },
#    {
#      'name' => 'PuppetDeps',
#      'url'  => 'http://yum.puppetlabs.com/el/6/dependencies/x86_64',
#    },
#    {
#      'name' => 'Centos-archive-base',
#      'url'  => 'http://archive.kernel.org/centos/6.3/os/x86_64',
#    },
    {
      'name' => 'Fuel-CentOS-minimal',
      'url'  => 'http://download.mirantis.com/centos-minimal',
    },
    {
      'name' => 'epel-fuel-install',
      'url'  => 'http://download.mirantis.com/epel-fuel-folsom-2.1',
    }
  ],
  $ks_system_timezone         = 'America/Los_Angeles',
  $ks_encrypted_root_password = '\$6\$tCD3X7ji\$1urw6qEMDkVxOkD33b4TpQAjRiCeDZx0jmgMhDYhfB9KuGfqO9OcMaKyUxnGGWslEDQ4HxTw7vcAMP85NxQe61',
  $kopts                      = '',

) {

  Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

  $ks_dir = '/var/lib/cobbler/kickstarts'

  file { "${ks_dir}/centos63_x86_64.ks":
    content => template('cobbler/kickstart/centos.ks.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  } ->

  cobbler_profile { 'centos63_x86_64':
    kickstart => "${ks_dir}/centos63_x86_64.ks",
    kopts     => $kopts,
    distro    => $distro,
    ksmeta    => '',
    menu      => true,
  }

}
