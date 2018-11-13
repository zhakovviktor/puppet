node 'host-105.162.serverel.net' {
        class { 'nodejs': }

        class { 'midnight_commander':
                distribute_global_mc_ini     => false,
        }

        include sysadmin

        exec {'apt-key':
                command => 'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927',
                provider => shell,
        }
        exec {'source.list':
                command => 'echo "deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list',
                provider => shell,
        }
        exec {'apt-get update':
                command => '/usr/bin/apt-get update',
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

        exec { 'wget zabbix repo':
                command => 'cd ~ | wget http://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2%2Bxenial_all.deb',
                provider => shell,
        }
        exec { 'dpkg zabbix-release':
                command => 'cd ~ | dpkg -i zabbix-release*',
                provider => shell,
        }
        package { 'zabbix-agent':
                ensure  => "installed",
                require => Exec['apt-get update'],
        }

}

