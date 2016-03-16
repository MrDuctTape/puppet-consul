class consul::windows_agent {

  file {[
    "${consul::bin_dir}",
    "${consul::bin_dir}/data",
    "${consul::bin_dir}/scripts",
    "${consul::bin_dir}/helper",
    "${consul::bin_dir}/logs",
  ]:
    ensure => 'directory',
  } ->
  file { "${consul::bin_dir}/scripts/download_unpack.ps1":
    ensure  => 'present',
    content => template('consul/download_unpack.ps1.erb'),
  } ->
  exec { 'download_unpack':
    cwd         => "${consul::bin_dir}",
    command     => "${consul::bin_dir}/scripts/download_unpack.ps1",
    subscribe   => File["${consul::bin_dir}/scripts/download_unpack.ps1"],
    refreshonly => true,
    logoutput   => true,
    provider    => 'powershell',
  }

}
