# @summary Reboot weekly on Saturday or Sunday between 5am and 6am
#
# Weekly reboot to ensure kernel and core library updates fully kick in.
# Between 5am and 6am on Saturday (or maybe Sunday).
#
# @example
#   include profile::weeklyreboot
class profile::weeklyreboot {
  cron { 'weekly reboot':
    command => '/usr/bin/apt-get -y upgrade && /sbin/reboot',
    user    => 'root',
    weekday => 'sat',
    hour    => 5,
    minute  => fqdn_rand(59),
  }
}
