class rtm::postgresql (
		String $git_clone_directory = '/root/tmp/rtm/sources',
		String $admin_ip_address = "192.168.50.1",
		String $host_ip_address = $ipaddress_eth1,
		String $pg_user = 'postgres',
		String $pg_password = 'postgres'
) {
    class { 'postgresql::globals':
        encoding => 'UTF-8',
        #manage_package_repo => true, # Sets up official PostgreSQL repositories on your host if set to true.
        #version             => '9.5',
        #postgis_version     => '2.2',
    }->
    class { 'postgresql::server':
        listen_addresses => "127.0.0.1,${admin_ip_address},${host_ip_address}",
        manage_pg_hba_conf => true,
        port => 5432,
        postgres_password => postgresql_password($pg_user, $pg_password),
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
				description => "Open up PostgreSQL for access from ${host_ip_address}/32",
				type        => 'host',
				database    => 'bdrtm',
				user        => 'rtm',
				address     => "${host_ip_address}/32",
				auth_method => 'md5',
		}
		postgresql::server::pg_hba_rule { 'allow admin user to access app database':
        description => "Open up PostgreSQL for access from ${admin_ip_address}/32",
        type        => 'host',
        database    => 'all',
        user        => $pg_user,
        address     => "${admin_ip_address}/32",
        auth_method => 'md5',
    }

		file { '/root/.pgpass':
	    ensure  => 'file',
	    content => "localhost:5432:bdrtm:${pg_user}:${pg_password}\nlocalhost:5432:template1:${pg_user}:${pg_password}",
	    mode    => '0600',
	  }
}