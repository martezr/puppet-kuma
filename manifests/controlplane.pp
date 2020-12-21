# Class: kuma::controlplane
#
#
class kuma::controlplane (
  String        $api_server_tls_cert          = '',
  String        $api_server_tls_key           = '',
  Array[String] $api_server_client_cert_dir   = ['/opt/kuma','/opt/kuma/ssl','/opt/kuma/ssl/client'],
  String        $postgres_host                = '127.0.0.1',
  String        $postgres_port                = '5432',
  String        $postgres_user                = 'kumauser',
  String        $postgres_password            = 'kumapassword',
  String        $postgres_root_password       = 'TPSrep0rt!',
  String        $postgres_database            = 'kumadb',
  Variant[String, Enum['global', 'standalone', 'remote']]        $controlplane_mode            = 'standalone',
  Variant[String, Enum['memory', 'postgres']]        $backend                      = 'postgres',
  String        $kuma_multizone_remote_zone   = '',
  String        $kuma_multizone_remote_global_address = '',
  Boolean       $manage_postgres              = false,
  String        $url                          = "http://${facts['networking']['fqdn']}",
  Boolean       $self_signed_certs            = true,
){

  include kuma
  include kuma::install

  $api_server_client_cert_dir.each | $kuma_dir | {
    file { $kuma_dir:
      ensure => directory,
      owner  => $kuma::kuma_user,
      group  => $kuma::kuma_group,
    }
  }

  file { 'kuma control plane config':
    ensure  => present,
    path    => '/opt/kuma/kuma-cp.conf.yaml',
    content => epp('kuma/kuma-cp.conf.yaml.epp'),
    owner   => $kuma::kuma_user,
    group   => $kuma::kuma_group,
    notify  => Service['kuma-cp'],
  }

  if $manage_postgres {
    class { 'postgresql::globals':
      manage_package_repo => true,
      version             => '12',
    }

    class { 'postgresql::server':
      postgres_password => $postgres_root_password,
    }

    postgresql::server::db { 'kumadb':
      user     => $postgres_user,
      password => postgresql::postgresql_password($postgres_user, $postgres_password),
    }

    exec { "/opt/kuma-${kuma::version}/bin/kuma-cp migrate up --config-file /opt/kuma/kuma-cp.conf.yaml":
      refreshonly => true,
      subscribe   => Postgresql::Server::Db['kumadb']
    }
  }

  if $self_signed_certs {
    include ::openssl

    openssl::certificate::x509 { 'kumacp':
      country      => 'OR',
      organization => 'Puppet',
      commonname   => $::fqdn,
      base_dir     => '/opt',
    }
  }

  file { 'kuma control plane service':
    ensure  => present,
    path    => '/etc/systemd/system/kuma-cp.service',
    content => epp('kuma/kuma-cp.service.epp'),
    owner   => $kuma::kuma_user,
    group   => $kuma::kuma_group,
  }

  service { 'kuma-cp':
    ensure   => 'running',
    name     => 'kuma-cp',
    enable   => true,
    provider => 'systemd',
  }
}
