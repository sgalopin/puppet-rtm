class rtm::gradle (
    String $docroot_directory = '/var/www/rtm/web',
    String $git_clone_directory = '/root/tmp/rtm/sources',
    String $local_scripts_directory = '/root/tmp/rtm/scripts',
) {
    file { "${local_scripts_directory}/install_gradle.sh":
      ensure  => 'file',
      content => epp("${module_name}/install_gradle.epp"),
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
    }
    ->
    exec { 'bash install_sencha.sh':
      path    => '/usr/bin:/usr/sbin:/bin',
      user    => 'root',
      cwd     => $local_scripts_directory,
      unless   	=> 'sencha which',
    }
}