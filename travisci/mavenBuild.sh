#!/bin/bash
set -e

if [ -z ${MAIN_BRANCH+x} ]; then export MAIN_BRANCH=master; fi

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
	echo mvn clean verify
	mvn clean verify
elif [ "$TRAVIS_BRANCH" = "$MAIN_BRANCH" ] || [ -n "$TRAVIS_TAG" ]; then
	echo clean deploy sonar:sonar
	mvn clean deploy sonar:sonar
else
	echo mvn clean verify sonar:sonar -Dsonar.branch="$TRAVIS_BRANCH"
	mvn clean verify sonar:sonar -Dsonar.branch="$TRAVIS_BRANCH"
fi