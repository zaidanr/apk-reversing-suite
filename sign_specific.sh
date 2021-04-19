#!/bin/bash

keystore=/path/to/keystore
keystore_alias=alias

if [ ! -e $keystore ]
then
	echo -e "Keystore not exist, please check your path"
else
	if [ ! -e $1 ] 
	then
		echo -e "Usage: ./sign-specific.sh <apk_file>"
	else
		echo -e "Signing $1"
		jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $keystore $1 $keystore_alias
	fi
fi
