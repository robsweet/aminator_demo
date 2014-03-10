class web_server {

  yumrepo { 'amzn-updates' :
    mirrorlist            => 'http://repo.us-east-1.amazonaws.com/$releasever/updates/mirror.list',
    metadata_expire       => '300',
    priority              => '10',
    failovermethod        => 'priority',
    gpgcheck              => '1',
    gpgkey                => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-ga',
    enabled               => '1',
    timeout               => '10',
  }

  package { ['php55'] : ensure => latest }

  file { 'index.html' :
    ensure => absent,
    path   => '/var/www/html/index.html',
  }

  file { 'documentroot' :
    ensure  => directory,
    path    => '/var/www/html/',
    mode    => '0644',
    recurse => 'true',
    source  => 'puppet:///modules/web_server/html',
  }

  service { 'httpd':
    ensure => running,
    enable => true,
  }


  Yumrepo['amzn-updates'] -> Package['php55'] -> File['index.html', 'documentroot'] -> Service['httpd']  



  if $::launchconfig == 'true' {

    file { 'special_guest' :
      path    => '/var/www/html/special_guest.txt',
      mode    => '0644',
      content => $::special_guest,
      before  => Service['httpd'],
    }

  }

}