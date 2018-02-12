class rtm::tomcat {

    $enhancers = [ 'gradle', 'libgnumail-java' ]
    package { $enhancers: ensure => 'installed' }
    # Note: 'libpostgresql-jdbc-java' already installed with postgresql

    # Note: The tomcat8 user, the service and the default instance
    # are done via the installation of the package
    tomcat::install { $rtm::tomcat_directory:
        install_from_source => false,
        package_ensure => 'present',
        package_name => 'tomcat8',
    }->
    # https://tomcat.apache.org/tomcat-8.0-doc/logging.html#Considerations_for_production_usage
    exec { [  "sed -i 's|, java.util.logging.ConsoleHandler||' logging.properties",
              "sed -i 's|= FINE|= SEVERE|' logging.properties",
              "sed -i 's|= INFO|= SEVERE|' logging.properties" ]:
      path => '/usr/bin:/usr/sbin:/bin',
      cwd => '/etc/tomcat8',
    }->
    file { "${rtm::tomcat_directory}/lib":
        ensure  => directory,
        owner => 'tomcat8',
        group => 'tomcat8',
    }->
    file { "${rtm::tomcat_directory}/lib/javax.mail.jar":
        ensure  => link,
        target => '/usr/share/java/gnumail.jar',
        owner => 'tomcat8',
        group => 'tomcat8',
    }->
    file { "${rtm::tomcat_directory}/lib/postgresql-jdbc4.jar":
        ensure  => link,
        target => '/usr/share/java/postgresql-jdbc4.jar',
        owner => 'tomcat8',
        group => 'tomcat8',
    }

    # Example of deployment (Integration service)
    # exec { "gradle war":
    #   path => '/usr/bin:/usr/sbin:/bin',
    #   cwd  => "${rtm::git_clone_directory}/service_integration",
    # }->
    # file { "${rtm::tomcat_directory}/conf/Catalina/localhost/RTMIntegrationService.xml":
    #   ensure => 'file',
    #   source => "${rtm::git_clone_directory}/service_integration/config/RTMIntegrationService.xml",
    # }->
    # tomcat::war { 'RTMIntegrationService.war':
    #   catalina_base => $rtm::tomcat_directory,
    #   war_source    => "${rtm::git_clone_directory}/service_integration/build/libs/service_integration-4.0.0.war",
    # }
}
