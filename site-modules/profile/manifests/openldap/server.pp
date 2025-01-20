# @summary Configure an openldap server
#
# This uses https://forge.puppet.com/camptocamp/openldap to install
# and configure openldap server (slapd).
# 
# Configures schemas, sets a password, etc...
#
# @example
#   include profile::openldap::server
class profile::openldap::server {

  # This pulls in the basic package install, service running, etc stuff
  class { 'openldap::server': }

  # Base of our tree for everything:
  $basedn = 'dc=example,dc=com'

  # Sets up the main database for our basedn and an admin user
  openldap::server::database { $basedn:
    ensure => present,
    rootdn => "cn=admin,${basedn}",
    rootpw => '{SSHA}passwordhere',
  }

  # Load schemas:
  openldap::server::schema {
    # Inherits from organizationalperson which inherits from person;
    # together provide us:
    # - userPassword
    # - description
    # - displayName
    # - givenName
    # - initials
    # - mail
    # - uid
    # and various other attributes we're less likely to use
    'inetorgperson':
      ensure => present,
      path   => '/etc/ldap/schema/inetorgperson.ldif';
    # Gives us posixAccount and posixGroup. Unlikely to use the rest
    # posixAccount adds:
    # - cn
    # - uidNumber
    # - gidNumber
    # - gecos
    # - homeDirectory
    # - loginShell
    # posixGroup lists simple uids;
    # - cn
    # - gidnumber
    # - memberUid (multivalued)
    # - description
    'nis':
      ensure  => present,
      path    => '/etc/ldap/schema/nis.ldif',
      require => Openldap::Server::Schema['inetorgperson'];
    # This sets up stuff for the ppolicy overlay's usage:
    # Gives us pwdPolicy and pwdPolicyChecker
    'ppolicy':
      ensure => present,
      path   => '/etc/ldap/schema/ppolicy.ldif';
  }

  # This adds an overlay that syncs membership in a group
  # into a "memberOf" attribute on the user  
  # See slapo-memberof(5)
  openldap::server::module { 'memberof':
    ensure => present,
  }
  -> openldap::server::overlay { "memberof on ${basedn}":
    ensure  => present,
    options => {
      'olcMemberOfRefInt' => 'TRUE',
    },
  }

  ## Too finicky for now, and we're already enforcing this in keycloak layer...
  # This adds an overlay that will enforce uniqueness constraints
  # See slapo-unique(5)
  #openldap::server::module { 'unique':
  #  ensure => present,
  #}
  #-> openldap::server::overlay { "unique on ${basedn}":
  #  ensure  => present,
  #  options => [
  #    # keep cn and gidNumber unique for posixGroups:
  #    'olcUniqueURI "ldap:///?cn,gidNumber?sub?(objectClass=posixGroup)"',
  #    # keep cn unique for groupOfNames:
  #    'olcUniqueURI "ldap:///?cn?sub?(objectClass=groupOfNames)"',
  #    # keep uid unique on inetOrgPerson:
  #    'olcUniqueURI "ldap:///?uid?sub?(objectClass=inetOrgPerson)"',
  #    # keep uidNumber unique on posixAccount:
  #    'olcUniqueURI "ldap:///?uidNumber?sub?(objectClass=posixAccount)"',
  #  ]
  #}

  # This overlay records last bind (last login) timestamp:
  # FIXME: Configure to 1-day precision
  # See slapo-lastbind(5)
  openldap::server::module { 'lastbind':
    ensure => present,
  }
  -> openldap::server::overlay { "lastbind on ${basedn}":
    ensure => present,
    #options => {
    #  'olcLastBindPrecision' => '86400',
    #},
  }

  # This overlay enforces some password policies
  # See the cn=default,ou=Policies entry in the DB for main interesting config
  # See slapo-ppolicy(5)
  openldap::server::module { 'ppolicy':
    ensure => present,
  }
  -> openldap::server::overlay { "ppolicy on ${basedn}":
    ensure  => present,
    options => {
      'olcPPolicyDefault'       => "cn=default,ou=Policies,${basedn}",
      'olcPPolicyHashCleartext' => 'TRUE',
    }
  }

  # Set up indexes so that searches are fast
  openldap::server::dbindex {
    ## Index types are: eq, sub, and presence
    # eq is the most basic index type that only allows checks for exact matches
    ['objectClass','mail','uid','gidNumber','uidNumber', 'createTimestamp', 'modifyTimestamp']:
      suffix  => $basedn,
      indices => 'eq';
    # presence/non-presence and equality searches; don't use presence for fields that are in most records
    # presencs is weird and not super-common
    ['member','uniqueMember', 'memberUid', 'homeDirectory','loginShell']:
      suffix  => $basedn,
      indices => 'pres,eq';
    ## substring and equality searches:
    # sub is for various kinds of substring matches, like "frei*"
    # Note that substring can be more explicitly specified as subinitial, subany, or subfinal
    ['name','cn','sn','givenName','displayName','description']:
      suffix  => $basedn,
      indices => 'sub,eq';
    # presence is rarely used, so presence+sub+eq unlikely
    # []:
    #   indices => 'sub,pres,eq':
  }

  # Backup data daily via slapcat, to be sure other backups have solid source to use
  file { '/etc/cron.daily/openldap-backup':
    content => template('profile/openldap-backup.erb'),
    mode    => '0700',
  }

}
