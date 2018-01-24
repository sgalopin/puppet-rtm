class rtm::tasks (
    String $docroot_directory = '/var/www/rtm/web',
    String $git_clone_directory = '/root/tmp/rtm/sources',
    String $local_scripts_directory = '/root/tmp/rtm/scripts',
    String $tmp_directory = '/var/tmp/rtm',
    String $tomcat_directory = '/var/lib/tomcat8',
) {

  file { "${local_scripts_directory}/build_db.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_db.epp", {
      tmp_directory => $tmp_directory,
      git_clone_directory => $git_clone_directory
    }),
  }
  file { "${local_scripts_directory}/build_ogamserver.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_ogamserver.epp", {
      docroot_directory => $docroot_directory,
      tmp_directory => $tmp_directory,
      git_clone_directory => $git_clone_directory
    }),
  }
  file { "${local_scripts_directory}/build_ogamdesktop.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_ogamdesktop.epp", {
      docroot_directory => $docroot_directory,
      git_clone_directory => $git_clone_directory
    }),
  }
  file { "${local_scripts_directory}/build_ogamservices.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_ogamservices.epp", {
      git_clone_directory => $git_clone_directory,
      tomcat_directory => $tomcat_directory,
    }),
  }
}