class rtm::sencha (
    String $local_scripts_directory = '/root/tmp/rtm/scripts',
    String $tmp_directory = '/var/tmp/rtm',
) {
    file { "${local_scripts_directory}/install_sencha.sh":
      ensure  => 'file',
      mode    => '0400',
      content => epp("${module_name}/install_sencha.epp", {
        tmp_directory => $tmp_directory
      }),
    }->
    exec { 'bash install_sencha.sh':
      path    => '/usr/bin:/usr/sbin:/bin',
      cwd     => $local_scripts_directory,
      unless  => 'test -f /root/bin/Sencha/Cmd/sencha',
    }
}
