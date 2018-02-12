class rtm::java {

    include java
    $java_home= $java::params::java['jdk']['java_home']
    file_line { 'env_java_home':
        ensure => present,
        path   => '/etc/environment',
        line   => "JAVA_HOME=\"${java_home}\"",
        match  => '^JAVA_HOME\=',
    }
}