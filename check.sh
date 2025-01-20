#!/bin/sh
cd /etc/puppet-control

# Get PATH and whatnot variables if needed
[ -e /etc/profile.d/puppet-agent.sh ] && . /etc/profile.d/puppet-agent.sh



echo; echo; echo === Showing current state of the Control repo
onceover show repo
echo; echo; echo === Showing current state of the Puppetfile
onceover show puppetfile
echo; echo; echo "=== Running overall tests (if these pass, nothing else is important)"
onceover run spec
