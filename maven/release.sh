#!/bin/bash

function createPomsInternal {
	DIR=$1
	PACKAGING=$2

	#POM=$(cat "$DIR/pom.xml" | tr '\r' ' ' | tr '\n' ' ')
	#GROUPID=$(echo $POM | sed 's!.*<parent>.*<groupId>\(.*\)</groupId>.*</parent>.*!\1!')
	#PARENTID=$(echo $POM | sed 's!.*<parent>.*<artifactId>\(.*\)</artifactId>.*</parent>.*!\1!')
	PARENTID=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="artifactId"]/text()' "$DIR/pom.xml" 2> /dev/null || true)
	GROUPID=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="parent"]/*[local-name()="groupId"]/text()' "$DIR/pom.xml" 2> /dev/null || true)
	V1=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="parent"]/*[local-name()="version"]/text()' "$DIR/pom.xml" 2> /dev/null || true)
	V2=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' "$DIR/pom.xml" 2> /dev/null || true)
	VERSION=$(echo -e "$V1\n$V2" | grep -v '^$' | sort | uniq)
	
	if [ $(echo $VERSION | wc -l) -ne 1 ]; then
		echo "All POMs have to have the same version."
		exit 4
	fi

	for i in $(find "$DIR/" -maxdepth 1 -type d | grep "$DIR/[a-zA-Z]" | sed 's!'$DIR'/\(.*\)!\1!'); do
		TARGET="$DIR/$i/pom.xml"
	
		if [ ! -f $TARGET ]; then
			echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<project xmlns=\"http://maven.apache.org/POM/4.0.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
	xsi:schemaLocation=\"http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd\">

	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>$GROUPID</groupId>
		<artifactId>$PARENTID</artifactId>
		<version>$VERSION</version>
	</parent>
	<artifactId>$i</artifactId>
	<packaging>$PACKAGING</packaging>
	
</project>" > "$TARGET"
			echo "Created $TARGET"
		fi
	
	done
}

function createPoms {
	BASEDIR=$1

	if [ ! -d "$BASEDIR" ]; then
		echo "Wrong directory $BASEDIR given"
		exit 3
	fi

	if [ -d "$BASEDIR/bundles" ]; then
	  createPomsInternal "$BASEDIR/bundles" eclipse-plugin
	fi

	if [ -d "$BASEDIR/tests" ]; then
	  createPomsInternal "$BASEDIR/tests" eclipse-test-plugin
	fi

	if [ -d "$BASEDIR/features" ]; then
	  createPomsInternal "$BASEDIR/features" eclipse-feature
	fi
}


if [ $# -lt 3 ]; then
	echo "Not enough arguments given. We need the directory, release and next development version number."
	exit 1
fi

DIR=$1
RELEASE_VERSION=$2
DEV_VERSION=$3

set -e
cd $DIR
git branch -d "tmp/Release$RELEASE_VERSION" 2> /dev/null || true

if [ $(git status -s | wc -l) -ne 0 ]; then
	echo "You have to have a clean working copy."
	exit 2
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Operating on branch: $BRANCH"
echo "Release version:     $RELEASE_VERSION"
echo "Development version: $DEV_VERSION"

git checkout -b "tmp/Release$RELEASE_VERSION"
createPoms .
set -x
mvn org.eclipse.tycho:tycho-versions-plugin:update-pom -Dtycho.mode=maven
mvn org.eclipse.tycho:tycho-versions-plugin:set-version -Dtycho.mode=maven -DupdateVersionRangeMatchingBounds=true -DnewVersion=$RELEASE_VERSION
git commit -am "[Release Process] Set release version to $RELEASE_VERSION"
mvn clean verify
git tag "releases/$RELEASE_VERSION"
mvn org.eclipse.tycho:tycho-versions-plugin:set-version -Dtycho.mode=maven -DupdateVersionRangeMatchingBounds=true -DnewVersion=$DEV_VERSION
git commit -am "[Release Process] Set development version to $DEV_VERSION"
mvn clean verify
git checkout $BRANCH
git merge "tmp/Release$RELEASE_VERSION"
git branch -d "tmp/Release$RELEASE_VERSION"
git clean -f
set +x

echo "Changes have not been pushed or deployed yet but only have been verified.

In order to deploy the release use
  * git checkout releases/$RELEASE_VERSION
  * mvn clean deploy
  
In order to push the changes use
  * git checkout $BRANCH
  * git push
  * git push --tags
"