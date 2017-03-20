#!/bin/bash
set -e

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
	echo mvn clean verify
	mvn clean verify
elif [ "$TRAVIS_BRANCH" = "master" ] || [ -n "$TRAVIS_TAG" ]; then
	echo mvn clean deploy \&\& mvn -Dtycho.mode=maven sonar:sonar
	mvn clean deploy && mvn -Dtycho.mode=maven sonar:sonar
else
	echo mvn clean install \&\& mvn -Dsonar.branch="$TRAVIS_BRANCH" -Dtycho.mode=maven sonar:sonar
	mvn clean install && mvn -Dsonar.branch="$TRAVIS_BRANCH" -Dtycho.mode=maven sonar:sonar
fi