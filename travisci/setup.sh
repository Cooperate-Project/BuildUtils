#!/bin/bash
# Sets up the build environment for Travis CI.
#
# Add this to your .travis.yml:
#
#	before_install:
#   - git clone --depth 1 https://github.com/Cooperate-Project/BuildUtils.git /tmp/BuildUtils
#	- . /tmp/BuildUtils/travisci/setup.sh
#	install: true
#	script:
#	- mavenBuild.sh
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/xvfb.sh
. $DIR/mavenSettings.sh
. $DIR/signingSetup.sh

export PATH=$DIR:$PATH