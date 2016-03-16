class consul::windows_agent {

  file {[
    "${consul::bin_dir}",
    "${consul::bin_dir}/scripts",
    "${consul::bin_dir}/helper",
    "${consul::bin_dir}/logs",
  ]:
    ensure => 'directory',
  }

}
