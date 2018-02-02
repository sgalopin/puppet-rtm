# Class: rtm
# ===========================
#
# Full description of class rtm here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'rtm':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2018 Your name here, unless otherwise noted.
#
class rtm  {

    package { 'unzip': ensure => 'installed' }

    # Directories paths
    $git_clone_directory      = '/root/tmp/rtm/sources'
    $local_scripts_directory  = '/root/tmp/rtm/scripts'
    $conf_directory           = '/etc/rtm'
    $docroot_directory        = '/var/www/rtm/ogam/public'
    $tilecache_directory      = '/var/www/tilecache'
    # If you set the server upload dir to a subdir into /var/tmp be aware of the apache service "PrivateTmp" parameter
    $server_upload_directory  = '/var/www/rtm/upload'
    $service_upload_directory = '/var/tmp/rtm/service_upload'
    $log_directory            = '/var/log/rtm'
    $tomcat_directory         = '/var/lib/tomcat8'

    # Defaults directories
    file { [ '/root/tmp',
             '/root/tmp/rtm',
              $git_clone_directory,
              $local_scripts_directory, ]:
        ensure  => directory,
        mode    => '0700',
    }
    file { $conf_directory:
        ensure  => directory,
        group => 'www-data',
        mode    => '0750',
    }
    file { [ '/var/www',
             '/var/www/rtm',
             '/var/www/rtm/ogam',
              $docroot_directory, ]:
        ensure => 'directory',
        group => 'www-data',
        mode => '0750'
    }
    file { [  $tilecache_directory,
              "${tilecache_directory}/cache", ]:
        ensure  => directory,
        group => 'www-data',
        mode    => '0770',
    }
    file { $log_directory:
        ensure  => directory,
        group => 'www-data',
        mode    => '0770',
    }
    file { [ '/var/tmp/rtm',
             $service_upload_directory ]:
        ensure  => directory,
        group => 'tomcat8',
        mode    => '770',
    }
    file { [ $server_upload_directory,
             "${server_upload_directory}/images", ]:
        ensure  => directory,
        group => 'www-data',
        mode    => '770',
    }

    # Class
    include rtm::java
    class {'rtm::git':
        git_clone_directory => $git_clone_directory
    }
    class {'rtm::postgresql':
        git_clone_directory => $git_clone_directory
    }
    class {'rtm::tomcat':
        git_clone_directory => $git_clone_directory,
    }
    class {'rtm::apache':
        docroot_directory => $docroot_directory,
        log_directory => $log_directory,
        conf_directory => $conf_directory,
    }
    class {'rtm::mapserv':
        git_clone_directory => $git_clone_directory,
        conf_directory => $conf_directory,
        log_directory => $log_directory,
    }
    class {'rtm::tasks':
        docroot_directory => $docroot_directory,
        git_clone_directory => $git_clone_directory,
        local_scripts_directory => $local_scripts_directory,
        server_upload_directory  => $server_upload_directory,
        service_upload_directory => $service_upload_directory,
        tomcat_directory => $tomcat_directory,
    }
}
