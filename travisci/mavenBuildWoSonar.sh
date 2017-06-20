#!/bin/bash
set -e

if [ "$TRAVIS_BRANCH" = "master" ] || [ -n "$TRAVIS_TAG" ]; then
	echo clean deploy
	mvn clean deploy
else
	echo mvn clean verify
	mvn clean verify
fi