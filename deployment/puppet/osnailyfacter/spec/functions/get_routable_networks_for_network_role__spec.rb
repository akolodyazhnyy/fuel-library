require 'spec_helper'
require 'yaml'


describe 'get_routable_networks_for_network_role for network_scheme with routes' do

let(:network_scheme) do
"""
---
  version: '1.1'
  provider: lnx
  transformations:
  - action: add-br
    name: section_not_used_in_this_trst
  roles:
    management: br-mgmt
    mgmt/database: br-mgmt
    neutron/mesh: br-mesh
    storage: br-storage
    ex: br-ex
    neutron/floating: br-floating
    fw-admin: br-fw-admin
  interfaces:
    eth1: {}
  endpoints:
    br-fw-admin:
      routes:
      - net: 10.145.0.0/24
        via: 10.144.0.5
      - net: 10.146.0.0/24
        via: 10.144.0.5
      IP:
      - 10.144.0.13/24
    br-mesh:
      routes:
      - net: 10.145.4.0/24
        via: 10.144.4.5
      - net: 10.146.4.0/24
        via: 10.144.4.5
      IP:
      - 10.144.4.2/24
    br-floating:
      IP: none
    br-storage:
      routes:
      - net: 10.145.3.0/24
        via: 10.144.3.5
      - net: 10.146.3.0/24
        via: 10.144.3.5
      IP:
      - 10.144.3.2/24
      vendor_specific:
        phy_interfaces:
        - eth4
    br-mgmt:
      routes:
      - net: 10.145.2.0/24
        via: 10.144.2.5
      - net: 10.146.2.0/24
        via: 10.144.2.5
      IP:
      - 10.144.2.4/24
      vendor_specific:
        phy_interfaces:
        - eth2
    br-ex:
      routes:
      - net: 10.146.1.0/24
        via: 10.144.1.1
      - net: 10.145.1.0/24
        via: 10.144.1.1
      IP:
      - 10.144.1.4/24
      vendor_specific:
        phy_interfaces:
        - eth1
      gateway: 10.144.1.1
"""
end

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  before(:each) do
    puppet_debug_override()
  end

  subject do
    function_name = Puppet::Parser::Functions.function('get_routable_networks_for_network_role')
    scope.method(function_name)
  end

  it 'should exist' do
    expect(subject).to eq scope.method('function_get_routable_networks_for_network_role')
  end

  it 'should return ordered subnets list as list' do
    expect(scope.function_get_routable_networks_for_network_role([YAML.load(network_scheme), 'mgmt/database'])).to eq ['10.144.2.0/24','10.145.2.0/24','10.146.2.0/24']
  end

  it 'should return ordered subnets list as string' do
    expect(scope.function_get_routable_networks_for_network_role([YAML.load(network_scheme), 'mgmt/database', ':'])).to eq '10.144.2.0/24:10.145.2.0/24:10.146.2.0/24'
  end

end


describe 'get_routable_networks_for_network_role for network_scheme without routes' do

let(:network_scheme) do
"""
---
  version: '1.1'
  provider: lnx
  transformations:
  - action: add-br
    name: section_not_used_in_this_trst
  roles:
    management: br-mgmt
    mgmt/database: br-mgmt
    neutron/mesh: br-mesh
    storage: br-storage
    ex: br-ex
    neutron/floating: br-floating
    fw-admin: br-fw-admin
  interfaces:
    eth1: {}
  endpoints:
    br-fw-admin:
      IP:
      - 10.144.0.13/24
    br-mesh:
      IP:
      - 10.144.4.2/24
    br-floating:
      IP: none
    br-storage:
      IP:
      - 10.144.3.2/24
    br-mgmt:
      IP:
      - 10.144.2.4/24
    br-ex:
      IP:
      - 10.144.1.4/24
      gateway: 10.144.1.1
"""
end

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  before(:each) do
    puppet_debug_override()
  end

  subject do
    function_name = Puppet::Parser::Functions.function('get_routable_networks_for_network_role')
    scope.method(function_name)
  end

  it 'should exist' do
    expect(subject).to eq scope.method('function_get_routable_networks_for_network_role')
  end

  it 'should return ordered subnets list as list' do
    expect(scope.function_get_routable_networks_for_network_role([YAML.load(network_scheme), 'mgmt/database'])).to eq ['10.144.2.0/24']
  end

  it 'should return ordered subnets list as string' do
    expect(scope.function_get_routable_networks_for_network_role([YAML.load(network_scheme), 'mgmt/database', ':'])).to eq '10.144.2.0/24'
  end

end

describe 'get_routable_networks_for_network_role for network_scheme without public IP' do

let(:network_scheme) do
"""
---
  version: '1.1'
  provider: lnx
  transformations:
  - action: add-br
    name: section_not_used_in_this_trst
  roles:
    management: br-mgmt
    mgmt/database: br-mgmt
    neutron/mesh: br-mesh
    storage: br-storage
    ex: br-ex
    neutron/floating: br-floating
    fw-admin: br-fw-admin
  interfaces:
    eth1: {}
  endpoints:
    br-fw-admin:
      IP:
      - 10.144.0.13/24
    br-mesh:
      IP:
      - 10.144.4.2/24
    br-floating:
      IP: none
    br-storage:
      IP:
      - 10.144.3.2/24
    br-mgmt:
      IP:
      - 10.144.2.4/24
    br-ex:
      IP: none
"""
end

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  before(:each) do
    puppet_debug_override()
  end

  subject do
    function_name = Puppet::Parser::Functions.function('get_routable_networks_for_network_role')
    scope.method(function_name)
  end

  it 'should exist' do
    expect(subject).to eq scope.method('function_get_routable_networks_for_network_role')
  end

  it 'should return empty list for public network' do
    expect(scope.function_get_routable_networks_for_network_role([YAML.load(network_scheme), 'ex'])).to eq []
  end

end

