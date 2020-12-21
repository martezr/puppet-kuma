define kuma::mesh (
  String[1]        $meshname = $title,
  Optional[Hash]   $mtls     = {},
  Optional[Hash]   $tracing  = {},
  Optional[Hash]   $logging  = {},
  Optional[Hash]   $metrics  = {},
) {
  include kuma

  $mesh_yaml = {'type' => 'Mesh',
                'name' => $meshname,
                'mtls' => $mtls,
                'tracing' => $tracing,
                'logging' => $logging,
                'metrics' => $metrics,
                }

  notify { 'mesh message':
    message => to_yaml($mesh_yaml),
  }

  file { "/opt/${meshname}-mesh.yaml":
    ensure  => file,
    owner   => $kuma::kuma_user,
    group   => $kuma::kuma_group,
    mode    => '0644',
    content => to_yaml($mesh_yaml),
    notify  => Exec["apply ${meshname} mesh"],
  }

  exec { "apply ${meshname} mesh":
    command     => "/opt/kuma-${kuma::version}/bin/kumactl apply -f /opt/${meshname}-mesh.yaml",
    refreshonly => true,
  }
}
