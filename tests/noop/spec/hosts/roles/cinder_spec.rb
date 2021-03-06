require 'spec_helper'
require 'shared-examples'
manifest = 'roles/cinder.pp'

describe manifest do
  shared_examples 'catalog' do

  storage_hash = Noop.hiera 'storage_hash'
  ceilometer_hash = Noop.hiera 'ceilometer_hash', { 'enabled' => false }
  use_ceph = Noop.hiera 'use_ceph'
  volume_backend_name = storage_hash['volume_backend_names']

  database_vip = Noop.hiera('database_vip')
  cinder_db_password = Noop.hiera_structure 'cinder/db_password', 'cinder'
  cinder_db_user = Noop.hiera_structure 'cinder/db_user', 'cinder'
  cinder_db_name = Noop.hiera_structure 'cinder/db_name', 'cinder'

  it 'should configure the database connection string' do
    if facts[:os_package_type] == 'debian'
      extra_params = '?charset=utf8&read_timeout=60'
    else
      extra_params = '?charset=utf8'
    end
    should contain_class('openstack::cinder').with(
      :sql_connection => "mysql://#{cinder_db_user}:#{cinder_db_password}@#{database_vip}/#{cinder_db_name}#{extra_params}"
    )
  end

  if use_ceph and !(storage_hash['volumes_lvm']) and !(member($roles, 'cinder-vmware'))
      it { should contain_class('ceph') }
  end

  it { should contain_package('python-amqp') }

  if Noop.hiera_structure('use_ssl')
    glance_protocol = 'https'
    glance_internal_address = Noop.hiera_structure('use_ssl/glance_internal_hostname')
  else
    glance_protocol = 'http'
    glance_internal_address = Noop.hiera('management_vip')
  end
  glance_api_servers = "#{glance_protocol}://#{glance_internal_address}:9292"

  it 'should contain correct glance api servers addresses' do
    should contain_class('openstack::cinder').with(
      'glance_api_servers' => glance_api_servers
    )
  end

  it 'should disable use_stderr option' do
    should contain_cinder_config('DEFAULT/use_stderr').with(:value => 'false')
  end

  if storage_hash['volumes_block_device']
    disks_metadata = Noop.hiera('node_volumes')

    let (:disks_list) do
      disks_list = Noop.puppet_function('get_disks_list_by_role', disks_metadata, 'cinder-block-device')
    end

    let (:iscsi_bind_host) do
      iscsi_bind_host = Noop.puppet_function('get_network_role_property', 'cinder/iscsi', 'ipaddr')
    end

    it 'should contain disks list for cinder block device role' do
      should contain_class('openstack::cinder').with(
        :physical_volume => disks_list,
        :manage_volumes  => 'fake',
      )
    end

    it 'should contain proper config file for cinder' do
      should contain_cinder_config('DEFAULT/iscsi_helper').with(:value => 'fake')
      should contain_cinder_config('DEFAULT/iscsi_protocol').with(:value => 'iscsi')
      should contain_cinder_config('DEFAULT/volume_backend_name').with(:value => 'DEFAULT')
      should contain_cinder_config('DEFAULT/volume_driver').with(:value => 'cinder.volume.drivers.block_device.BlockDeviceDriver')
      should contain_cinder_config('DEFAULT/iscsi_ip_address').with(:value => iscsi_bind_host)
      should contain_cinder_config('DEFAULT/volume_group').with(:value => 'cinder')
      should contain_cinder_config('DEFAULT/volume_dir').with(:value => '/var/lib/cinder/volumes')
      should contain_cinder_config('DEFAULT/volume_clear').with(:value => 'zero')
      should contain_cinder_config('DEFAULT/available_devices').with(:value => disks_list)
    end
  end

  it 'ensures that cinder have proper volume_backend_name' do
    if use_ceph
      should contain_class('openstack::cinder').with(
        'volume_backend_name' => volume_backend_name['volumes_ceph']
      )
    end

    if storage_hash['volumes_lvm']
      should contain_class('openstack::cinder').with(
        'volume_backend_name' => volume_backend_name['volumes_lvm']
      )
    end

    if storage_hash['volumes_block_device']
      should contain_class('openstack::cinder').with(
        'volume_backend_name' => volume_backend_name['volumes_block_device']
      )
    end
  end

  let :ceilometer_hash do
    Noop.hiera 'ceilometer_hash', { 'enabled' => false }
  end

  if ceilometer_hash['enabled']
    it 'should contain notification_driver option' do
      should contain_cinder_config('DEFAULT/notification_driver').with(:value => ceilometer_hash['notification_driver'])
    end
  end

  end
  test_ubuntu_and_centos manifest
end

