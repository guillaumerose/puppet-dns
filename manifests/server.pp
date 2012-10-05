class dns::server ($forwarders = []) {
  package { 'bind9':
    ensure => latest,
  }

  service { 'bind9':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Package['bind9'],
  }

  file { '/etc/bind/named.conf':
    ensure  => present,
    owner   => 'bind',
    group   => 'bind',
    mode    => 0644,
    require => Package['bind9'],
    notify  => Service["bind9"],
  }

  file { '/etc/bind/named.conf.options':
    ensure  => present,
    owner   => 'bind',
    group   => 'bind',
    mode    => 0644,
    content => template('dns/named.conf.options.erb'),
    require => Package['bind9'],
    notify  => Service["bind9"],
  }

  concat { '/etc/bind/named.conf.local':
    owner   => 'bind',
    group   => 'bind',
    mode    => 0644,
    require => [ Class['concat::setup'], Package['bind9'] ],
    notify  => Service["bind9"],
  }

  concat::fragment { 'named.conf.local.header':
     target  => '/etc/bind/named.conf.local',
     order   => 1,
     ensure  => present,
     content => "// File managed by Puppet.\n",
  }
}