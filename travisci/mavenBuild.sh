#!/bin/bash
set -e

if [[ "$TRAVIS_BRANCH" = "master" && "$TRAVIS_PULL_REQUEST" = "false" ]]; then
	echo mvn clean deploy sonar:sonar
	mvn clean deploy sonar:sonar
elif [[ "$TRAVIS_PULL_REQUEST" = "false" ]]; then
	echo mvn -Dsonar.branch="$TRAVIS_BRANCH" clean verify sonar:sonar
	mvn -Dsonar.branch="$TRAVIS_BRANCH" clean verify sonar:sonar
else
	echo mvn clean verify
	mvn clean verify
fi