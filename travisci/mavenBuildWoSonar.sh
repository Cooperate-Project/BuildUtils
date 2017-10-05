#!/bin/bash
set -e

if [ -z ${MAIN_BRANCH+x} ]; then export MAIN_BRANCH=master; fi

if [ "$TRAVIS_BRANCH" = "$MAIN_BRANCH" ] || [ -n "$TRAVIS_TAG" ]; then
	echo clean deploy
	mvn clean deploy
else
	echo mvn clean verify
	mvn clean verify
fi