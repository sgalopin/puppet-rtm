class rtm::mapserv {

    $enhancers = [ 'cgi-mapserver', 'mapserver-bin', 'gdal-bin', 'mapserver-doc', 'libapache2-mod-fcgid' ]
    package { $enhancers: ensure => 'installed' }

    file { "${rtm::conf_directory}/mapserver":
      ensure => 'directory',
      recurse => true,
      source => "${rtm::git_clone_directory}/mapserver",
      group => 'www-data',
    }->
    file_line { 'vrtm-onf.ifn.fr':
      ensure => present,
      path   => "${rtm::conf_directory}/mapserver/rtm.map",
      match  => '(.*)http://vrtm-onf.ifn.fr(.*)',
      line   => "\1https://${rtm::vhost_servername}\2",
    }->
    file_line { '/vagrant/ogam/website/htdocs/logs':
      ensure => present,
      path   => "${rtm::conf_directory}/mapserver/rtm.map",
      match  => '(.*)/vagrant/ogam/website/htdocs/logs(.*)',
      line   => "\1${rtm::log_directory}\2",
    }->
    file_line { '/vagrant/ogam/mapserver':
      ensure => present,
      path   => "${rtm::conf_directory}/mapserver/rtm.map",
      match  => '(.*)/vagrant/ogam/mapserver(.*)',
      line   => "\1${rtm::conf_directory}/mapserver\2",
    }

    # mapserv is a fcgi compatible, use default config sethandler with .fcgi
    file { '/usr/lib/cgi-bin/mapserv.fcgi':
        ensure => link,
        target => '/usr/lib/cgi-bin/mapserv',
    }
}