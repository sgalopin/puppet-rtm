class rtm::postgresql {

    class { 'postgresql::globals':
        encoding => 'UTF-8',
        #manage_package_repo => true, # Sets up official PostgreSQL repositories on your host if set to true.
        #version             => '9.5',
        #postgis_version     => '2.2',
    }->
    class { 'postgresql::server':
        listen_addresses => "127.0.0.1,${rtm::admin_ip_address},${rtm::host_ip_address}",
        manage_pg_hba_conf => true,
        port => 5432,
        postgres_password => postgresql_password($rtm::pg_user, $rtm::pg_password),
    }->
		exec { [ 'sed -i "s|#*client_min_messages = .*|client_min_messages = error|" postgresql.conf',
						 'sed -i "s|#*log_min_messages = .*|log_min_messages = error|" postgresql.conf',
						 'sed -i "s|#*log_min_error_statement = .*|log_min_error_statement = error|" postgresql.conf' ]:
			path => '/usr/bin:/usr/sbin:/bin',
			cwd => '/etc/postgresql/9.6/main',
		}

		# Installs the PostgreSQL postgis packages
		include postgresql::server::postgis

		# JDBC
		include postgresql::lib::java

		# Pg_hba_rule
		postgresql::server::pg_hba_rule { 'allow application network to access app database':
				description => "Open up PostgreSQL for access from ${rtm::host_ip_address}/32",
				type        => 'host',
				database    => 'bdrtm',
				user        => 'rtm',
				address     => "${rtm::host_ip_address}/32",
				auth_method => 'md5',
		}
		postgresql::server::pg_hba_rule { 'allow admin user to access app database':
        description => "Open up PostgreSQL for access from ${rtm::admin_ip_address}/32",
        type        => 'host',
        database    => 'all',
        user        => $rtm::pg_user,
        address     => "${rtm::admin_ip_address}/32",
        auth_method => 'md5',
    }

		file { '/root/.pgpass':
	    ensure  => 'file',
	    content => "localhost:5432:bdrtm:${rtm::pg_user}:${rtm::pg_password}\nlocalhost:5432:template1:${rtm::pg_user}:${rtm::pg_password}",
	    mode    => '0600',
	  }
}