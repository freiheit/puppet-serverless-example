# Profile::base is the base applied to all systems
# 
# This class:
# - makes sure the puppet package sources (apt repo) are available
# - installs pdk (Puppet Development Kit)
# - ensures that /etc/puppet-control is a git repo with the proper source
# - sets up an hourly cronjob to pull the latest code and apply it
# - Does logcheck things in profile::logcheck
class profile::base {
  # Installs and sets up etckeeper; defaults to git on our systems
  include ::etckeeper

  include profile::adminusers
  include profile::weeklyreboot
  include profile::logcheck


  class { 'kdump':
    enable => true,
  }

  $debian_name = $facts['os']['distro']['codename']

  include apt
  apt::key {
    'reductive':
      server => 'keyserver.ubuntu.com',
      id     => '9C6C545246912EE700FB5682FFAC86588347A27F',
      source => 'https://apt.puppetlabs.com/DEB-GPG-KEY-reductive';
    'puppetlabs':
      server => 'keyserver.ubuntu.com',
      id     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      source => 'https://apt.puppetlabs.com/DEB-GPG-KEY-puppetlabs';
    'puppet':
      server => 'keyserver.ubuntu.com',
      id     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
      source => 'https://apt.puppetlabs.com/DEB-GPG-KEY-puppet';
  }

  -> apt::source { 'puppet':
    location => 'http://apt.puppetlabs.com',
    repos    => 'puppet',
  }

  service { 'puppet':
    ensure => stopped,
    enable => false;
  }

  package { 'pdk':
    ensure  => 'present',
    require => Apt::Source['puppet'];
  }

  # Some generic non-default packages to include:
  package { ['at']:
    ensure => 'present'
  }

  vcsrepo { '/etc/puppet-control':
    ensure             => present,
    provider           => git,
    source             => 'git@github.com:freiheit/puppet-serverless-example.git',
    revision           => 'production',
    keep_local_changes => true,
    identity           => '/etc/puppet-control/puppet-control-readonly.key';
  }

  file { '/etc/cron.hourly/puppet-run':
    ensure => link,
    target => '/etc/puppet-control/puppet-run.sh';
  }
}
