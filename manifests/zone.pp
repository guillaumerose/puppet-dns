define dns::zone(
  $soa = "${::fqdn}.",
  $soa_email = "root.${::fqdn}.",
  $zone_serial = inline_template("<%= Time.now.to_i %>"),
  $zone_ttl = '604800',
  $zone_refresh = '604800',
  $zone_retry = '86400',
  $zone_expire = '2419200',
  $zone_minimum = '604800',
  $nameservers = ["${::fqdn}"],
  $reverse = false,
  $zone_type = 'master',
  $zone_notify = false,
  $ensure = present
) {
  $zone = $reverse ? {
    true    => "${name}.in-addr.arpa",
    default => $name,
  }

  $zone_file = "/etc/bind/db.${name}"

  if $ensure == absent {
    file { $zone_file:
      ensure => absent,
    }
  } else {
    concat { $zone_file:
      owner   => 'bind',
      group   => 'bind',
      mode    => 0644,
      require => [ Class['concat::setup'], Package['bind9'] ],
      notify  => Service['bind9'],
    }
    concat::fragment { "db.${name}.soa":
       target  => $zone_file,
       order   => 1,
       content => template("${module_name}/zone_file.erb"),
    }
  }

  concat::fragment { "named.conf.local.${name}.include":
     target  => '/etc/bind/named.conf.local',
     order   => 2,
     ensure  => $ensure,
     content => template("${module_name}/zone.erb"),
  }
}
