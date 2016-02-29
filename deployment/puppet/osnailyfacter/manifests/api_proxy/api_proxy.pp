# Module api_proxy
# Moved into class for LCM plugin

class osnailyfacter::api_proxy::api_proxy {

  notice('MODULAR: api-proxy.pp')

  $max_header_size = hiera('max_header_size', '81900')

  # Listen directives with host required for ip_based vhosts
  class { 'osnailyfacter::apache':
    listen_ports => hiera_array('apache_ports', ['0.0.0.0:80', '0.0.0.0:8888']),
  }

  # API proxy vhost
  class {'osnailyfacter::apache_api_proxy':
    master_ip       => hiera('master_ip'),
    max_header_size => $max_header_size,
  }

}
