class aminator {

  package { ['python-pip', 'git'] :
    ensure => latest
  }

  exec { 'upgrade_pip':
    cwd     => '/root',
    command => '/usr/bin/pip install --upgrade pip',
    creates => '/usr/lib/python2.6/site-packages/pip-1.5.4-py2.6.egg-info',
  }

  exec {'install_aminator':
    cwd     => '/root',
    command => '/usr/bin/pip install git+https://github.com/Netflix/aminator.git@2.0.221-dev#egg=aminator',
    creates => '/usr/lib/python2.6/site-packages/aminator',
  }

  exec { 'install_aminator_puppet_plugin':
    command => '/usr/bin/aminator-plugin install puppet',
    creates => '/usr/lib/python2.6/site-packages/puppet_provisioner-0.1-py2.6.egg',
  }

  file { 'aminator_configs':
    ensure  => 'directory',
    path    => '/etc/aminator',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => true,
    recurse => true,
    source  => 'puppet:///modules/aminator/etc/aminator',
  }

  Package['python-pip', 'git'] -> Exec['upgrade_pip'] ->  Exec['install_aminator'] -> Exec['install_aminator_puppet_plugin']
                                                          Exec['install_aminator'] -> File['aminator_configs']
}
