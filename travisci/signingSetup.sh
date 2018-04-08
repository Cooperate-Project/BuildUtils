#!/bin/bash

if [ -z ${MVN_MASTERPW+x} ]; then
	echo "Skipping GPG initialization"
else
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo $MVN_MASTERPW | gpg --passphrase-fd 0 -o /tmp/cooperate.key $DIR/cooperate.key.asc
	echo $MVN_MASTERPW | gpg --passphrase-fd 0 --batch --yes --import /tmp/cooperate.key
	rm /tmp/cooperate.key
fi