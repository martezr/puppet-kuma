# Class: kuma::dataplane
#
#
class kuma::dataplane (
  String      $dp_token_cert,
  String      $dp_token_key,
  String      $controlplane_url,
  String      $entry_name,
  Hash        $networking         = {},
  String      $tokenfile_path     = '/opt/kuma/dptoken',
  String      $bootstrap_server   = 'https://kumacp.grt.local:5678/',
  String      $mesh               = 'default',
)
  {

  include kuma
  include kuma::install

  $dp_yaml = {'type' => 'Dataplane', 'mesh' => $mesh,
              'name' => $entry_name, 'networking' => $networking}

  file { "/opt/${entry_name}.yaml":
    ensure  => file,
    owner   => $kuma::kuma_user,
    group   => $kuma::kuma_group,
    mode    => '0644',
    content => to_yaml($dp_yaml),
    notify  => Service['kuma-dp'],
  }

  kuma_token { $entry_name :
    ensure        => present,
    path          => $tokenfile_path,
    mesh          => $mesh,
    client_cert   => $dp_token_cert,
    client_key    => $dp_token_key,
    control_plane => 'https://kumacp.grt.local:5682',
  }

  file { 'kuma data plane service environment file':
    ensure  => present,
    path    => '/etc/systemd/system/kuma-dp.env',
    content => epp('kuma/kuma-dp.env.epp'),
    owner   => $kuma::kuma_user,
    group   => $kuma::kuma_group,
    notify  => Service['kuma-dp']
  }

  file { 'kuma data plane service':
    ensure  => present,
    path    => '/etc/systemd/system/kuma-dp.service',
    content => epp('kuma/kuma-dp.service.epp'),
    owner   => $kuma::kuma_user,
    group   => $kuma::kuma_group,
    notify  => Service['kuma-dp']
  }

  service { 'kuma-dp':
    ensure   => 'running',
    name     => 'kuma-dp',
    enable   => true,
    provider => 'systemd',
  }
}
