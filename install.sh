#!/bin/sh

echo "=== Requires SSH agent and key. Suggest forwarding agent with 'ssh -A'"
echo "=== when connecting and using 'sudo -E -s' to keep agent connection alive."

# Set some useful variables
. /etc/os-release

# Get basic tools we need:
apt -y install git wget

# Try to get official puppet repository set up, if not already installed
[ -e /etc/apt/sources.list.d/puppet.list ] || (
    cd /tmp
    wget https://apt.puppetlabs.com/puppet-release-${VERSION_CODENAME}.deb
    dpkg -i puppet-release-${VERSION_CODENAME}.deb
)

# Update apt's ideas of available packages
apt update

# puppet-agent is current version from official Puppet repos;
# puppet is what's in debian's sources. So install one or the other
apt -y install puppet-agent || apt -y install puppet

# For Puppetfile to pull in modules
apt -y install r10k

# Optional, but nice to have
apt -y install pdk || true

# Optional, but nice to have
[ -e /opt/puppetlabs/puppet/bin/onceover ] || /opt/puppetlabs/puppet/bin/gem install onceover
ln -sf /opt/puppetlabs/puppet/bin/onceover /usr/local/bin/onceover

# Optional, but nice to have
/opt/puppetlabs/puppet/bin/gem install puppet-strings

# Get this repo into place
[ -d /etc/puppet-control ] || git clone git@github.com:freiheit/puppet-serverless-example.git /etc/puppet-control

/etc/puppet-control/puppet-run.sh
