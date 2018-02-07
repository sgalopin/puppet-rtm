class rtm::apache (
    String $www_directory = '/var/www/rtm',
    String $docroot_directory = '/var/www/rtm/web',
    String $log_directory = '/var/log/rtm',
    String $conf_directory = '/etc/rtm',
    String $vhost_servername = 'agent.example.com',
) {
    # APACHE Install
    class { 'apache': # contains package['httpd'] and service['httpd']
        default_vhost => false,
        mpm_module => 'prefork', # required per the php module
    }

    # APACHE Modules
    # 'libapache2-mod-php7.0' package required on debian (stretch) to avoid a bug... (but not on ubuntu-16.04)
    package { [ 'libapache2-mod-php7.0', 'php-xml', 'php-pgsql' ]:
      ensure => 'installed'
    }->
    class { 'apache::mod::php': }->
    exec { 'sed -i "s|short_open_tag = .*|short_open_tag = On|" /etc/php/7.0/apache2/php.ini':
      path => '/usr/bin:/usr/sbin:/bin',
    }
    include apache::mod::rewrite
    include apache::mod::expires
    include apache::mod::cgi
    include apache::mod::fcgid

    # APACHE Parameters
    # include apache::params # contains common config settings
    # $vhost_dir= $apache::params::vhost_dir
    # $user= $apache::params::user
    # $group= $apache::params::group

    # APACHE Virtual host
    apache::vhost { $vhost_servername:
        servername => $vhost_servername,
        port    => '80',
        docroot => $docroot_directory,
        manage_docroot => false,
        docroot_owner => 'www-data',
        docroot_group => 'www-data',
        options => ['Indexes','FollowSymLinks','MultiViews'],
        directoryindex => 'index.php',
        php_values => {
            'post_max_size' => '200M',
            'upload_max_filesize' => '200M',
            'opcache.revalidate_freq' => '3',
            'xdebug.default_enable' => 'false',
        },
        php_admin_values => {
            'realpath_cache_size' => '64k',
            'opcache.interned_strings_buffer' => '8M',
            'opcache.max_accelerated_files' => '4000',
            'opcache.memory_consumption' => '128M',
            'opcache.fast_shutdown' => '1',
        },
        directories => [{
          path => $docroot_directory,
          override => 'None',
          require => 'all granted',
          options => ['-MultiViews'],
          rewrites => [
            {
              comment      => 'Redirection to custom',
              rewrite_cond => ["${www_directory}/custom/public/\$1 -f"],
              rewrite_rule => ['^(.+) /custom/$1 [QSA,L]'],
            },{
              comment      => 'Redirection to php app',
              rewrite_cond => ['%{REQUEST_FILENAME} !-f'],
              rewrite_rule => ['^(.*)$ index.php [QSA,L]'],
            },
          ],
        },{
          path => "${www_directory}/custom/public",
          provider => 'location',
        },{
          path => "/cgi-bin/mapserv.rtm",
          provider => 'location',
          custom_fragment => "
SetEnv MS_MAPFILE \"${conf_directory}/mapserver/rtm.map\"
SetEnv MS_ERRORFILE \"${log_directory}/mapserver_rtm.log\"
SetEnv MS_DEBUGLEVEL 5",
        }],
        aliases => [{
                alias => '/custom',
                path  => "${www_directory}/custom/public",
            },{
                scriptalias => '/cgi-bin/mapserv.rtm',
                path  => "/usr/lib/cgi-bin/mapserv.fcgi",
            }
        ]
    }
}
