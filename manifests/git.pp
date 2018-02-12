class rtm::git {

    vcsrepo { $rtm::git_clone_directory:
        ensure   => latest,
        provider => git,
        source   => 'http://gitlab.dockerforge.ign.fr/sgalopin/rtm.git',
        revision => 'master',
    }
    exec { "sudo sed -i '$ a 172.28.99.2 gitlab.dockerforge.ign.fr' /etc/hosts":
      path    => '/usr/bin:/usr/sbin:/bin',
      unless  => 'cat /etc/hosts | grep gitlab.dockerforge.ign.fr',
    }

    # Working example for svn
    # package { 'subversion':
    #   ensure => 'installed'
    # }->
    # exec { "svn co http://ifn-dev.ign.fr/svn/RTM/trunk ${rtm::git_clone_directory}":
    #   path    => '/usr/bin:/usr/sbin:/bin',
    #   unless  => "test -f ${rtm::git_clone_directory}/README.txt",
    # }
    # exec { "sudo sed -i '$ a 172.27.5.200 ifn-dev' /etc/hosts":
    #   path    => '/usr/bin:/usr/sbin:/bin',
    #   unless  => 'cat /etc/hosts | grep ifn-dev.ign.fr',
    # }

    # The excludes parameters doesn't work with svn provider
    # The includes parameters use 'svn update' command and so doesn't checkout the externals
    # The 'svn co' done (when there are no inludes or excludes parameters)
    # with that module throws an encoding error on the dir 'Bases SQL/donnees_fournies_par_RTM/'
    # vcsrepo { $rtm::git_clone_directory:
    #     ensure   => present,
    #     provider => svn,
    #     source   => 'http://ifn-dev.ign.fr/svn/RTM/trunk',
    # }
}