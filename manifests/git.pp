class rtm::git (
    String $git_clone_directory = '/root/tmp/rtm/sources'
) {
    package { 'subversion': ensure => 'installed' }

    vcsrepo { $git_clone_directory:
        ensure   => present,
        provider => svn,
        source   => 'http://ifn-dev.ign.fr/svn/RTM/trunk',
        excludes => [
          'documentation/',
          'Vagrantfile',
          '.buildpath',
          '.project',
          'README.txt',
        ]
    }
}