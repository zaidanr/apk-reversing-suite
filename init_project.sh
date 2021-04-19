#!/bin/bash

# Function definition
unzip_apks () {
	unzip $1 -d ./apks/default
	unzip $1 -d ./apks/mod
}

create_apktool_dir () {
	if [ ! -e ./apktool ]; then
		mkdir ./apktool
		echo "$APKTOOL_README" >> ./apktool/README
	else
		echo "apktool directory already exists."
	fi	
}

create_source_dir () {
	if [ ! -e ./source ]; then
		mkdir ./source
		echo "$SOURCE_README" >> ./source/README
	else
		echo "source directory already exists."
	fi
}

create_repack_dir () {
	if [ ! -e ./repack ]; then
		mkdir ./repack
		echo "$REPACK_README" >> ./repack/README
	else
		echo "repack directory already exists."
	fi
}

create_apks_directory () {
	if [ ! -e ./apks ]; then
		mkdir ./apks
		echo "$APKS_README" >> ./apks/README
	else
		echo "apks directory already exists."
	fi
}

# README content
APKS_README="./default = Just use this directory as the backup of the original file when you messed something up in ./mod directory
./mod = Main directory where you perform APKS repacking & resigning stuff. Export your apks directory to ../repack/. (zip -r *.apk -d ../repack/v1.apks) "

APKTOOL_README="./default = apktool d base.apk
./nores = apktool d -r base.apk
./nosrc = apktool d -s base.apk"

SOURCE_README="./java = Decompiled Java codes from MobSF
./res = Resource files from ../apktool/default/res"

REPACK_README="Main directory of your repackaged .apk or signed .apks releases"

# Main script
echo "Project type: "
echo "APK  [0]"
echo "APKS [1]"
read -p "Select project type: " proj_type

if [ $proj_type -eq 0 ]; then
	echo "Creating APK project structure.."
	create_apktool_dir
	create_source_dir
	create_repack_dir
	echo "Project structure creation finished"
elif [ $proj_type -eq 1 ]; then
	echo "Creating APKS project structure.."
	read -p "Do you already have the APKS file? (Y/n): " ans
	ans="${ans:=YES}"
	if [[ $ans =~ Y|y ]]; then
		create_apks_directory
		apks=$(ls *.apks)
		if [ $? -ne 0 ]; then
			read -p "Can't find any .apks file. Please enter it manually: " apks
			if [ -e $apks ]; then	
				unzip_apks $apks
				if [ $? -ne 0 ]; then
					exit 1 
				fi
			else
				echo "File does not exist ¯\_(ツ)_/¯"
			fi
		else
			apks=$(echo $apks | awk '{print $1}')
			read -p "Is it $apks? (Y/n)" ans
			ans="${ans:=YES}"
			if [[ $ans =~ Y|y ]]; then
				unzip_apks $apks
				if [ $? -ne 0 ]; then
					exit 1 
				fi
			else
				read -p "What is it then? Please enter your apks filename: " apks
				if [ -e $apks ]; then	
					unzip_apks $apks
					if [ $? -ne 0 ]; then
						exit 1 
					fi
				else
					echo "File does not exist ¯\_(ツ)_/¯"
				fi	
			fi
		fi
	else
		echo "Please download the apks first from apkdl.in/apkdl.net/apkmirror.com."
		exit 1
	fi

	create_apktool_dir

	create_source_dir

	create_repack_dir

	echo "Project structure creation finished"
else
	echo "Option not supported"; exit 1
fi
