class rtm::tasks (
    String $docroot_directory = '/var/www/rtm/web',
    String $git_clone_directory = '/root/tmp/rtm/sources',
    String $local_scripts_directory = '/root/tmp/rtm/scripts',
    String $www_directory = '/var/www/rtm',
    String $server_upload_directory = '/var/www/rtm/upload',
    String $service_upload_directory = '/var/tmp/rtm/service_upload',
    String $tomcat_directory = '/var/lib/tomcat8',
    String $domain = 'example.com',
) {

  file { "${local_scripts_directory}/build_db.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_db.epp", {
      server_upload_directory => $server_upload_directory,
      service_upload_directory => $service_upload_directory,
      git_clone_directory => $git_clone_directory
    }),
  }
  file { "${local_scripts_directory}/build_ogamserver.sh":
    ensure  => 'file',
    mode    => '0400',
    content => epp("${module_name}/build_ogamserver.epp", {
      docroot_directory => $docroot_directory,
      git_clone_directory => $git_clone_directory,
      www_directory => $www_directory,
      server_upload_directory => $server_upload_directory,
      domain => $domain,
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