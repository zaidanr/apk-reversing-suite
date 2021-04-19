#!/bin/bash

# TODO: make it POSIX-compliant

keystore=/path/to/keystore
keystore_alias=alias

files=*.apk

if [ ! -e $keystore ]
then
	echo -e "Keystore doesn't exist, please check your path."
else
	echo -n "Please enter your keystore password: "
	read -s keystore_password
	echo ''
	echo -n "Please enter your key password: "
	read -s key_password
	echo ''
	for f in $files
	do
		echo -e "Signing $f"
		jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -storepass $keystore_password -keypass $key_password -keystore $keystore $f $keystore_alias
	
		if [ $? -ne 0 ]
		then
			break
		fi
	done
fi	