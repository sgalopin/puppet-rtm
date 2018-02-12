class rtm::tasks {

  file { "${local_scripts_directory}/build_db.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_db.epp"),
  }
  file { "${local_scripts_directory}/build_ogamserver.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_ogamserver.epp"}),
  }
  file { "${local_scripts_directory}/build_ogamservices.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_ogamservices.epp"),
  }
}