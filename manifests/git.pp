class rtm::git (
    String $git_clone_directory = '/root/tmp/rtm/sources'
) {
    vcsrepo { $git_clone_directory:
        ensure   => present,
        provider => svn,
        source   => 'svn://ifn-dev/svn/RTM/trunk',
    }
}