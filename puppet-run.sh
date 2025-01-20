#!/bin/sh
cd /etc/puppet-control

chmod 0600 /etc/puppet-control/puppet-control-readonly.key

# Get PATH and whatnot variables if needed
[ -e /etc/profile.d/puppet-agent.sh ] && . /etc/profile.d/puppet-agent.sh

# Make sure remote is the correct current one
git remote set-url origin git@github.com:freiheit/puppet-serverless-example.git

# Get latest copy of code and discard the "Already up to date" message
GIT_SSH_COMMAND='ssh -i /etc/puppet-control/puppet-control-readonly.key' git pull > /dev/null

# Grab correct version of modules from forge, based on Puppetfile
r10k puppetfile install

# Actually apply the stuff
puppet apply --logdest syslog --modulepath=/etc/puppet-control/modules:/etc/puppet-control/site-modules --write-catalog-summary /etc/puppet-control/manifests/site.pp
