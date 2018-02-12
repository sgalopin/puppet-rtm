class rtm::mapserv {

    $enhancers = [ 'cgi-mapserver', 'mapserver-bin', 'gdal-bin', 'mapserver-doc', 'libapache2-mod-fcgid' ]
    package { $enhancers: ensure => 'installed' }

    file { "${rtm::conf_directory}/mapserver":
      ensure => 'directory',
      recurse => true,
      source => "${rtm::git_clone_directory}/mapserver",
      group => 'www-data',
    }->
    exec { [  "sed -i 's|http://vrtm-onf.ifn.fr|https://${rtm::vhost_servername}|' rtm.map",
              "sed -i 's|/vagrant/ogam/website/htdocs/logs|${rtm::log_directory}|' rtm.map",
              "sed -i 's|/vagrant/ogam/mapserver|${rtm::conf_directory}/mapserver|' rtm.map" ]:
      path => '/usr/bin:/usr/sbin:/bin',
      cwd => "${rtm::conf_directory}/mapserver",
    }

    # mapserv is a fcgi compatible, use default config sethandler with .fcgi
    file { '/usr/lib/cgi-bin/mapserv.fcgi':
        ensure => link,
        target => '/usr/lib/cgi-bin/mapserv',
    }
}