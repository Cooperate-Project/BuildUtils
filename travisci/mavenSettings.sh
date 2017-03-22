#/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp $DIR/../settings/settings.xml "$HOME/.m2/"
cp $DIR/../settings/settings-security.xml "$HOME/.m2/"
echo "<settingsSecurity><master>"$MVN_MASTERPW"</master></settingsSecurity>" > /tmp/settings-security.xml
echo "MAVEN_OPTS='-Xmx2g -XX:MaxPermSize=512m'" > ~/.mavenrc