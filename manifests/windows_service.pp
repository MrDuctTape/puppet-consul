class consul::windows_service(
  $nssm_version = '2.24',
  $nssm_download_url = undef,
  $nssm_download_url_base = 'https://nssm.cc/release',
) {

  $real_download_url = pick($nssm_download_url, "${nssm_download_url_base}/nssm-${nssm_version}.zip")

  $install_path = $::consul_downloaddir

  case $::architecture {
    'x32': {
      $nssm_exec = "${install_path}/nssm-${nssm_version}/win32/nssm.exe"
    }
    'x64': {
      $nssm_exec = "${install_path}/nssm-${nssm_version}/win64/nssm.exe"
    }
    default: {
      fail("Unknown architecture for windows - ${::architecture}")
    }
  }

  include '::archive'
  archive { "${install_path}/nssm-${nssm_version}.zip":
    ensure       => present,
    source       => $real_download_url,
    extract      => true,
    extract_path => $install_path,
    creates      => [
      "${install_path}/nssm-${nssm_version}/win32/nssm.exe",
      "${install_path}/nssm-${nssm_version}/win64/nssm.exe",
    ],
  }->
  file { "${consul::bin_dir}/install_service.ps1":
    ensure  => 'present',
    content => template('consul/make_service.ps1.erb'),
  } ->
  exec { 'consul_service_install':
    cwd       => $consul::bin_dir,
    command   => "${consul::bin_dir}/install_service.ps1",
    unless    => 'get-service -name consul',
    logoutput => true,
    provider  => 'powershell',
  }

}
