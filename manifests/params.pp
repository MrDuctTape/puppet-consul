# == Class consul::params
#
# This class is meant to be called from consul
# It sets variables according to platform
#
class consul::params {

  $install_method        = 'url'
  $package_name          = 'consul'
  $package_ensure        = 'latest'
  $download_url_base     = 'https://releases.hashicorp.com/consul/'
  $download_extension    = 'zip'
  $ui_package_name       = 'consul_ui'
  $ui_package_ensure     = 'latest'
  $ui_download_url_base  = 'https://releases.hashicorp.com/consul/'
  $ui_download_extension = 'zip'
  $version               = '0.5.2'
  $config_mode           = '0660'

# 0.6.0 introduced a 64-bit version, so we need to differentiate:
  if (versioncmp($::consul::version, '0.6.0') < 0) {
    $win_arch = '386'
  } else {
    $win_arch = 'amd64'
  }


  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64'   }
    'i386':            { $arch = '386'     }
# this part solves the 32/64-bit 0.6.0 conundrum (see above):
    'x64':             { $arch = $win_arch }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }

  $os = downcase($::kernel)

  case $::operatingsystem {
    'windows': {
      $config_dir = 'C:/Consul/config'
    }
    default: {
      $config_dir = '/etc/consul'
    }
  }

  if $::operatingsystem == 'Ubuntu' {
    if versioncmp($::operatingsystemrelease, '8.04') < 1 {
      $init_style = 'debian'
    } elsif versioncmp($::operatingsystemrelease, '15.04') < 0 {
      $init_style = 'upstart'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem =~ /Scientific|CentOS|RedHat|OracleLinux/ {
    if versioncmp($::operatingsystemrelease, '7.0') < 0 {
      $init_style = 'sysv'
    } else {
      $init_style  = 'systemd'
    }
  } elsif $::operatingsystem == 'Fedora' {
    if versioncmp($::operatingsystemrelease, '12') < 0 {
      $init_style = 'sysv'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Debian' {
    if versioncmp($::operatingsystemrelease, '8.0') < 0 {
      $init_style = 'debian'
    } else {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Archlinux' {
    $init_style = 'systemd'
  } elsif $::operatingsystem == 'SLES' {
    $init_style = 'sles'
  } elsif $::operatingsystem == 'Darwin' {
    $init_style = 'launchd'
  } elsif $::operatingsystem == 'Amazon' {
    $init_style = 'sysv'
  } elsif $::operatingsystem == 'windows' {
    $service_name = 'Consul'
    $init_style = 'windows'
  } else {
    $init_style = undef
  }
  if $init_style == undef {
    fail('Unsupported OS')
  }
}
