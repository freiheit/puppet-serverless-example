# @summary Sets up standard logcheck setup
#
# This class:
# - Uses logcheck module to make sure logcheck is installed
# - Sets up a mail alias for "logcheck" that goes to primary admins
# - Adds custom logcheck rules
#
# @example
#   include profile::logcheck
class profile::logcheck {

  # logcheck email goes to admins:
  # TODO: migrate admin list to something pulled into here, so only in one place
  mailalias { 'logcheck':
    ensure    => present,
    recipient => [
      'admins@example.org',
    ],
  }


  $logcheck_ignore_rules_array = [
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ puppet-user\[[0-9]+\]: Applied catalog in [.0-9]+ seconds$',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ puppet-user\[[0-9]+\]: /etc/puppet-control/modules/openldap/data/common.yaml: file does not contain a valid yaml hash$',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ puppet-user\[[0-9]+\]:.*A reboot is required to fully enable the crashkernel',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ unattended-upgrade: Checking if system is running on battery is skipped. Please install powermgmt-base package to check power status and skip installing updates when the system is running on battery\.',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ snap\[[0-9]+\]: Ignoring `snap refresh` from the systemd timer$',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Start(ing|ed) Daily man-db regeneration\.+$',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ rsyslogd: +\[origin software="rsyslogd" swVersion="[0-9a-z.]+" x-pid="[0-9]+" x-info="https://www.rsyslog.com"] rsyslogd was HUPed$',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: (logrotate|man-db|apt-daily|snapd|certbot|snap-core-?[0-9]+|phpsessionclean|systemd-tmpfiles-clean|etckeeper|apt-daily-upgrade|apache2)\.(service|mount): Succeeded\.$',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Mount(ing|ed) Mount unit for core, revision [0-9]+\.+$',

    # Scan that's not even managing to try to authenticate
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ sshd\[[0-9]+\]: Bad protocol version identification.*$',

    # Scan that's not even managing to try to authenticate
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ dovecot: (pop3|imap)-login: (Disconnected(: Too many (bad|invalid) commands)?|Aborted login) \(no auth attempts in [0-9]+ secs\).+$',

    # More scan that didn't get anywhere
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ dovecot: auth:n Warning: auth client .* disconnected with .* pending requests: EOF$',

    # Normal routine authentication
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ postfix/smtpd?\[[0-9]+\]: Anonymous TLS connection established to .+$',

    # Scan that's not even managing to try to authenticate
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ postfix/smtpd?\[[0-9]+\]: warning:.* Invalid authentication mechanism$',

    # Scan? Doesn't look at all worth investigation.
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ postfix/smtpd?\[[0-9]+\]: improper command pipelining after EHLO',

    # If they can't even make an SSL/TLS connection, they're not managing to do anything interesting
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ postfix/smtpd?\[[0-9]+\]: SSL_accept error',

    # Pretty sure this is a scan that tried too old a TLS version and got rejected with no actual auth attempts
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ postfix/smtpd?\[[0-9]+\]: warning:.*error:1420918C.*$',

    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ postgrey\[[0-9]+\]: whitelisted: .*$',

    # Firewall dropping things isn't worth reporting
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ kernel: .*Shorewall:logflags:DROP:IN.*$',

    ## Successful logins:
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd-logind\[[0-9]+\]: New session.*$',
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Created slice.*$',
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd: .*session opened for user.*$',
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: (Starting|Listening on) D-Bus User Message Bus Socket.$',
    '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: .*: Succeeded.$',

  ]

  $logcheck_ignore_rules_string = $logcheck_ignore_rules_array.join("\n")

  class { '::logcheck':
    email => 'logcheck',
    rules => "${$logcheck_ignore_rules_string}\n",
  }
}
