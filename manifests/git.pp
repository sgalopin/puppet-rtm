class rtm::git (
    String $git_clone_directory = '/root/tmp/rtm/sources'
) {
    package { 'subversion': ensure => 'installed' }

    vcsrepo { $git_clone_directory:
        ensure   => present,
        provider => svn,
        source   => 'http://ifn-dev.ign.fr/svn/RTM/trunk',
        /*includes => [
          'Bases SQL/',
          'mapserver/',
          'services_configs/',
          'website/',
        ],*/
        excludes => 'Bases SQL/donnees_fournies_par_RTM/'
    }
}