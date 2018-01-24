class rtm::tomcat (
    String $tmp_directory = '/var/tmp/rtm',
    String $git_clone_directory = '/root/tmp/rtm/sources',
    String $tomcat_directory = '/var/lib/tomcat8',
) {
    $enhancers = [ 'gradle', 'libgnumail-java' ]
    package { $enhancers: ensure => 'installed' }
    # Note: 'libpostgresql-jdbc-java' already installed with postgresql

    tomcat::install { $tomcat_directory:
        install_from_source => false,
        package_ensure => 'present',
        package_name => 'tomcat8',
        #source_url => 'https://www.apache.org/dist/tomcat/tomcat-8/v8.5.24/bin/apache-tomcat-8.5.24.tar.gz',
    }
    tomcat::instance { 'tomcat8':
        user => 'tomcat8',
        group => 'tomcat8',
        catalina_home => $tomcat_directory,
        manage_service => true,
    }

    file { "${tomcat_directory}/lib":
        ensure  => directory,
        owner => 'tomcat8',
        group => 'tomcat8',
    }->
    file { "${tomcat_directory}/lib/javax.mail.jar":
        ensure  => link,
        target => '/usr/share/java/gnumail.jar',
        owner => 'tomcat8',
        group => 'tomcat8',
    }->
    file { "${tomcat_directory}/lib/postgresql-jdbc4.jar":
        ensure  => link,
        target => '/usr/share/java/postgresql-jdbc4.jar',
        owner => 'tomcat8',
        group => 'tomcat8',
    }

    file { "${tmp_directory}/rtm_upload":
        ensure  => directory,
        owner => 'tomcat8',
        group => 'tomcat8',
        mode    => '774',
    }
    file { [ "${tmp_directory}/upload",
             "${tmp_directory}/upload/images", ]:
        ensure  => directory,
        owner => 'www-data',
        group => 'www-data',
        mode    => '774',
    }

    # Example of deployment (Integration service)
    # exec { "gradle war":
    #   path => '/usr/bin:/usr/sbin:/bin',
    #   cwd  => "${git_clone_directory}/service_integration",
    # }->
    # file { "${tomcat_directory}/conf/Catalina/localhost/RTMIntegrationService.xml":
    #   ensure => 'file',
    #   source => "${git_clone_directory}/service_integration/config/RTMIntegrationService.xml",
    # }->
    # tomcat::war { 'RTMIntegrationService.war':
    #   catalina_base => $tomcat_directory,
    #   war_source    => "${git_clone_directory}/service_integration/build/libs/service_integration-4.0.0.war",
    # }
}
