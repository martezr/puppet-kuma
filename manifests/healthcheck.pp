# kuma::healthcheck
define kuma::healthcheck (
  String[1]        $checkname    = $title,
  String[1]        $mesh         = 'default',
  Optional[Array]  $sources      = [],
  Optional[Array]  $destinations = [],
  Optional[Hash]   $conf         = {},
) {
  include kuma

  $healthcheck_yaml = {'type'  => 'HealthCheck',
                'name'         => $checkname,
                'mesh'         => $mesh,
                'sources'      => $sources,
                'destinations' => $destinations,
                'conf'         => $conf,
                }

  file { "/opt/${checkname}-healthcheck.yaml":
    ensure  => file,
    owner   => $kuma::kuma_user,
    group   => $kuma::kuma_group,
    mode    => '0644',
    content => to_yaml($healthcheck_yaml),
    notify  => Exec["apply ${checkname} mesh"],
  }

  exec { "apply ${checkname} mesh":
    command     => "/opt/kuma-${kuma::version}/bin/kumactl apply -f /opt/${checkname}-healthcheck.yaml",
    refreshonly => true,
  }
}
