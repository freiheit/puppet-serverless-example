# @summary Makes snapd stuff happen
#
# @example
#   include profile::snap
class profile::snap {
  # This class doesn't seem to work right?
  # class { 'snapd': }

  package { 'snapd':
    ensure => present;
  }

  exec { '/usr/bin/snap install --edge core':
    refreshonly => true,
    subscribe   => Package['snapd'],
    before      => Service['snapd'],
  }

  exec { '/usr/bin/snap refresh --edge core':
    refreshonly => true,
    subscribe   => Package['snapd'],
    before      => Service['snapd'],
  }

  service { 'snapd':
    ensure  => running,
    enable  => true,
    require => Package['snapd']
  }
}
