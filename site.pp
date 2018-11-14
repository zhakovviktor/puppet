class pw_hash {
        notify { 'In pw_hash': }
}


node default {
  notify { 'this node did not match any of the listed definitions': }
}

node 'host-106.162.serverel.net' {

        user {'test' :
                ensure => 'present',
                comment => 'local test user',
                uid => '123456',
                gid => '27',
                password => pw_hash('password', 'SHA-512', 'mysalt'),
                home => '/home/test',
                shell => '/bin/bash',
        }

        exec {'apt-get update':
                command => '/usr/bin/apt-get update',
                provider => shell,
        }

        class { 'nodejs': }

        class { 'midnight_commander':
                distribute_global_mc_ini     => false,
        }

        include sysadmin

        apt::key {'EA312927':
                ensure => present,
                server => "hkp://keyserver.ubuntu.com:80",
                id => 'EA312927',
        }

        exec {'source.list':
                unless => 'echo "deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list',
                provider => shell,
        }

        package { 'mongodb-org':
                ensure  => "installed",
                require => Exec['apt-get update'],
                install_options => ['--allow-unauthenticated', '-f'],
        }
        service { 'mongod':
                ensure => running,
                enable => true,
        }

        package { 'memcached':
                ensure  => "installed",
                require => Exec['apt-get update'],
        }
        package { 'php-memcached':
                ensure  => "installed",
                require => Exec['apt-get update']
        }

        package { 'htop':
                ensure  => "installed",
                require => Exec['apt-get update'],
        }

        wget::fetch {"zabbix deb":
                source => 'http://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2%2Bxenial_all.deb',
                destination => '/home/viktor/',
                timeout     => 0,
                verbose     => false,
                unless      => "test $(ls -A /home/viktor/zabbix-release_4.0-2%2Bxenial_all.deb 2>/dev/null)"
        }
        #exec { 'wget zabbix repo':
        #       unless => 'cd ~ | wget http://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2%2Bxenial_all.deb',
        #       provider => shell,
        #}
        package { 'zabbix-release':
                ensure => latest,
                source => "/home/viktor/zabbix-release_4.0-2%2Bxenial_all.deb",
                provider => dpkg,
        }
        package { 'zabbix-agent':
                ensure  => "installed",
                require => Exec['apt-get update'],
        }
}
