#!/bin/bash

if [ -z ${MVN_MASTERPW+x} ]; then
	echo "Skipping GPG initialization"
else
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	openssl enc -aes-256-cbc -a -d -in $DIR/cooperate.key.enc -out /tmp/cooperate.key -k $MVN_MASTERPW
	echo $MVN_MASTERPW | gpg --passphrase-fd 0 --batch --yes --import /tmp/cooperate.key
	rm /tmp/cooperate.key
fi