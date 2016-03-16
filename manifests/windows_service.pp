class consul::windows_service(
  $service_name   = $consul::params::service_name,
  $nssm_source    = "puppet:///modules/${module_name}/nssm64/nssm.exe"
) {
  file { "${consul::bin_dir}/scripts/do_windows_path.ps1":
    ensure  => 'present',
    content => template('consul/do_windows_path.ps1.erb'),
  } ->
  file { "${consul::bin_dir}/scripts/make_service.ps1":
    ensure  => 'present',
    content => template('consul/make_service.ps1.erb'),
  } ->
  file { "${consul::bin_dir}/helper/nssm.exe":
    ensure             => 'present',
    source             => ${nssm_source},
    source_permissions => 'ignore',
  } ->
# we must run path mods separately, because Windows shells do not self-update:
  exec { 'do_path':
    cwd         => "${consul::bin_dir}/scripts",
    command     => "${consul::bin_dir}/scripts/do_windows_path.ps1",
    subscribe   => File["${consul::bin_dir}/scripts/do_windows_path.ps1"],
    refreshonly => true,
    provider    => 'powershell',
  }->
  exec { 'make_service':
    cwd         => "${consul::bin_dir}/scripts",
    command     => "${consul::bin_dir}/scripts/make_service.ps1",
    unless      => "get-service -name ${service_name}",
    subscribe   => File["${consul::bin_dir}/scripts/make_service.ps1"],
    refreshonly => true,
    provider    => 'powershell',
  }->
  service { $service_name:
    ensure => "running",
  }

}
