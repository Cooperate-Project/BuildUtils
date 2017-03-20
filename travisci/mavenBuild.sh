#!/bin/bash
set -e

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
	echo mvn clean verify
	mvn clean verify
elif [ "$TRAVIS_BRANCH" = "master" ] || [ -n "$TRAVIS_TAG" ]; then
	echo mvn clean deploy \&\& mvn sonar:sonar
	mvn clean deploy && mvn sonar:sonar
else
	echo mvn clean verify \&\& mvn -Dsonar.branch="$TRAVIS_BRANCH" sonar:sonar
	mvn clean verify && mvn -Dsonar.branch="$TRAVIS_BRANCH" sonar:sonar
fi