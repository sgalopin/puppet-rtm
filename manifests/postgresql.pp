class rtm::postgresql (
		String $git_clone_directory = '/root/tmp/rtm/sources',
		String $tmp_directory = '/var/tmp/rtm',
) {
    $user = 'postgres'
		$password = 'bAz5<b{dYBC]A#q['

    class { 'postgresql::globals':
        encoding => 'UTF-8',
        #manage_package_repo => true,
        version             => '9.5',
        postgis_version     => '2.2',
    }->
    class { 'postgresql::server':
        listen_addresses => "127.0.0.1,192.168.50.1,${ipaddress_eth1}",
        manage_pg_hba_conf => true,
        port => 5432,
        postgres_password => postgresql_password($user, $password),
    }

		# Installs the PostgreSQL postgis packages
		include postgresql::server::postgis

		# JDBC
		include postgresql::lib::java

		# Pg_hba_rule
		postgresql::server::pg_hba_rule { 'allow application network to access app database':
				description => "Open up PostgreSQL for access from 127.0.0.1/32",
				type        => 'host',
				database    => 'rtm',
				user        => 'rtm',
				address     => '192.168.50.13/32',
				auth_method => 'md5',
		}
		postgresql::server::pg_hba_rule { 'allow admin user to access app database':
        description => "Open up PostgreSQL for access from 192.168.50.1/32",
        type        => 'host',
        database    => 'all',
        user        => $user,
        address     => '192.168.50.1/32',
        auth_method => 'trust',
    }

		file { '/root/.pgpass':
	    ensure  => 'file',
	    content => "localhost:5432:rtm:${user}:${password}\nlocalhost:5432:template1:${user}:${password}",
	    mode    => '0600',
	  }
}