#!/bin/bash
set -e

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
	echo mvn clean verify
	mvn clean verify
elif [ "$TRAVIS_BRANCH" = "master" ] || [ -n "$TRAVIS_TAG" ]; then
	echo mvn clean deploy sonar:sonar
	mvn clean deploy sonar:sonar
else
	echo mvn -Dsonar.branch="$TRAVIS_BRANCH" clean verify sonar:sonar
	mvn -Dsonar.branch="$TRAVIS_BRANCH" clean verify sonar:sonar
fi