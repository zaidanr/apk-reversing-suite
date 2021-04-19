#!/usr/bin/env bash

files=*.apk
for f in $files
do
	echo "Processing $f"
	unzip $f -d $f-zipper
	rm -rf $f
	cd $f-zipper
	rm -rf ./META-INF/*.RSA ./META-INF/*.SF ./META-INF/*.MF
	zip -r ../$f ./*
	cd ../
	rm -rf $f-zipper
done
