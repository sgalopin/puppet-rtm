class rtm::apache (
    String $docroot_directory = '/var/www/rtm/web',
    String $log_directory = '/var/log/rtm',
    String $conf_directory = '/etc/rtm',
) {
    # APACHE
    class { 'apache': # contains package['httpd'] and service['httpd']
        default_vhost => false,
        mpm_module => 'prefork', # required per the php module
    }

    include apache::params # contains common config settings

    # PHP (mayflower/php)
    class { '::php':
        ensure       => latest,
        manage_repos => true, # The default is to have php::manage_repos enabled to add apt sources for Dotdeb on Debian and ppa:ondrej/php5 on Ubuntu with packages for the current stable PHP version closely tracking upstream.
        fpm          => false,
        dev          => false,
        composer     => false,
        pear         => false,
        phpunit      => true,
        extensions => {
            xml      => {}, # For phpunit via composer
            pgsql => {
                provider => 'apt',
            },
        },
        settings   => {
          'PHP/short_open_tag'  => 'On', # Doesn't work...
        },
    }

    # APACHE Modules
    include apache::mod::php
    include apache::mod::rewrite
    include apache::mod::expires
    include apache::mod::cgi
    include apache::mod::fcgid

    exec { 'sed -i "s|short_open_tag = .*|short_open_tag = On|" /etc/php/7.0/apache2/php.ini':
      path     	=> '/usr/bin:/usr/sbin:/bin',
    }

    # Parameters
    $vhost_dir= $apache::params::vhost_dir
    $user= $apache::params::user
    $group= $apache::params::group

    # Virtual host with apache
    apache::vhost { $fqdn:
        servername => 'example.com',
        serveraliases => [
          $fqdn,
        ],
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
          # Version < 2.3
          #order => 'Allow,Deny',
          #allow => 'from All',
          # Version >= 2.3
          require => 'all granted',
          options => ['-MultiViews'],
          rewrites => [
            {
              comment      => 'Redirection to custom',
              rewrite_cond => ['/var/www/rtm/custom/public/$1 -f'],
              rewrite_rule => ['^(.+) /custom/$1 [QSA,L]'],
            },{
              comment      => 'Redirection to php app',
              rewrite_cond => ['%{REQUEST_FILENAME} !-f'],
              rewrite_rule => ['^(.*)$ index.php [QSA,L]'],
            },
          ],
        },{
          path => '/var/www/rtm/custom/public',
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
                path  => '/var/www/rtm/custom/public',
            },{
                scriptalias => '/cgi-bin/mapserv.rtm',
                path  => "/usr/lib/cgi-bin/mapserv.fcgi",
            }
        ]
    }
}
