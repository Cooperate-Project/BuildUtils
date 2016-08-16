#!/bin/bash

# Abort on every error
set -e

# Echo commands
set -v

# Determine version of tycho plugin
TYCHO_VERSION=$(mvn -q -Dexec.executable="echo" -Dexec.args='${tycho.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.5.0:exec)

# prepare release (remove qualifier, commit, tag)
mvn -Dtycho.mode=maven -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion} -DpushChanges=false -Dmessage="[release] set release version to \${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}" org.codehaus.mojo:build-helper-maven-plugin:1.12:parse-version org.eclipse.tycho:tycho-versions-plugin:$TYCHO_VERSION:update-pom org.eclipse.tycho:tycho-versions-plugin:$TYCHO_VERSION:set-version scm:checkin

# build and deploy
mavenBuild.sh

# create and push tag
mvn -Dtycho.mode=maven -DpushChanges=true -Dtag="releases/\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}" org.codehaus.mojo:build-helper-maven-plugin:1.12:parse-version scm:tag

# finalize release (increment version, add qualifier, commit)
mvn -Dtycho.mode=maven -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}.qualifier -DpushChanges=true -Dmessage="[release] set development version to \${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}.qualifier" org.codehaus.mojo:build-helper-maven-plugin:1.12:parse-version org.eclipse.tycho:tycho-versions-plugin:$TYCHO_VERSION:update-pom org.eclipse.tycho:tycho-versions-plugin:$TYCHO_VERSION:set-version scm:checkin