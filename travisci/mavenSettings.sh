#/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp $DIR/../common/settings.xml "$HOME/.m2/"
cp $DIR/../common/settings-security.xml "$HOME/.m2/"
echo "<settingsSecurity><master>"$MVN_MASTERPW"</master></settingsSecurity>" > /tmp/settings-security.xml
