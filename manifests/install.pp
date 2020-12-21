# @summary
#   This class installs kuma.
#
# @api private
#
class kuma::install {
  include archive

  user { $kuma::kuma_user:
    ensure  => 'present',
    comment => 'kuma service mesh system user',
    system  => true,
  }

  group { $kuma::kuma_group:
    ensure => 'present',
    system => true,
  }

  archive { "/opt/kuma-${kuma::version}.tar.gz":
    ensure       => present,
    extract      => true,
    extract_path => '/opt/',
    source       => "https://kong.bintray.com/kuma/kuma-${kuma::version}-centos-amd64.tar.gz",
    creates      => "/opt/kuma-${kuma::version}/bin",
    user         => $kuma::kuma_user,
    group        => $kuma::kuma_group,
  }
}
