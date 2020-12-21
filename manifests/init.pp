# kuma
#
# @param service_enable
#   Whether to enable the kuma service at boot. Default value: true.
#
# @param service_ensure
#   Whether the kuma service should be running. Default value: 'running'.
#
# @param service_manage
#   Whether to manage the kuma service.  Default value: true.
#
# @param service_name
#   The kuma service to manage. Default value: varies by operating system.
#
# @param service_provider
#   Which service provider to use for kuma. Default value: 'undef'.
#
# @param service_hasstatus
#   Whether service has a functional status command. Default value: true.
#
# @param service_hasrestart
#   Whether service has a restart command. Default value: true.
#
# @param version
#   The version of kuma to install. Default value: .

class kuma (
  String                     $kuma_group        = 'kuma',
  String                     $kuma_user         = 'kuma',
  String                     $version           = '1.0.3',
)
{}
