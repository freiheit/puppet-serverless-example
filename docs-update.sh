#!/bin/sh
cd /etc/puppet-control

git pull

/opt/puppetlabs/puppet/bin/gem install puppet-strings

[ -e /etc/profile.d/puppet-agent.sh ] && . /etc/profile.d/puppet-agent.sh

(
  cd site-modules/role
  puppet strings generate --format markdown --out REFERENCE.md
)

(
  cd site-modules/profile
  puppet strings generate --format markdown --out REFERENCE.md
)

puppet strings generate --format markdown --out REFERENCE.md

git add site-modules/role/REFERENCE.md site-modules/profile/REFERENCE.md REFERENCE.md
git commit -m "docs-update.sh ran" site-modules/role/REFERENCE.md site-modules/profile/REFERENCE.md REFERENCE.md
git push
