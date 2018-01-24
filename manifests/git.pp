class rtm::git (
    String $git_clone_directory = '/root/tmp/rtm/sources'
) {
    package { 'subversion': ensure => 'installed' }

    vcsrepo { $git_clone_directory:
        ensure   => present,
        provider => svn,
        source   => 'http://ifn-dev.ign.fr/svn/RTM/trunk',
        includes => [
          'Bases SQL/0 - Create harmonized_data schema.sql',
          'Bases SQL/0 - Create mapping schema.sql',
          'Bases SQL/0 - Create metadata schema.sql',
          'Bases SQL/0 - Create raw_data schema.sql',
          'Bases SQL/0 - Create website schema.sql',
          'Bases SQL/1 - Create user.sql',
          'Bases SQL/2 - Populate mapping schema.sql',
          'Bases SQL/2 - Populate metadata schema.sql',
          'Bases SQL/2 - Populate website schema.sql',
          'Bases SQL/3 - Right management.sql',
          'Bases SQL/Data/',
          'Bases SQL/Mapping/',
          'Bases SQL/Metadata/',
          'Bases SQL/__convert_latlon_dms2.sql',
          'mapserver/',
          'services_configs/',
          'website/',
        ],
        # the excludes parameters doesn't work with svn provider
    }
}