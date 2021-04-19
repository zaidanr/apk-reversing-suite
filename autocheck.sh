#!/usr/bin/env bash

ctrl_c () {
  echo "\nCtrl+C Detected. Exiting.."
  exit 1
}

#COLOR VARIABLES
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

YES=Y

APK=$1
checklist=./.autocheck.list

## RUN TEST ##
# run_test PACKAGENAME
# $1 = PACKAGENAME

run_test () {
	BUILD_RESULT=$(cat $checklist | grep -i build_$1 | cut -d ':' -f 2)
	if [ BUILD_RESULT = 1 ];then
		adb install ./repack/$1.apk
		if [ $? -ne 0 ];then                        
			"Installing $1 package failed."                                                
			sed -i "s|^DEPLOY_${1^^}:.\$|DEPLOY_${1^^}:0|g" $checklist
			return 1
		else
			sed -i "s|^DEPLOY_${1^^}:.\$|DEPLOY_${1^^}:1|g" $checklist
		fi
	fi
}

## APKTOOL WRAPPER ##
# apktool_wrapper build default (--use-aapt2)
# apktool_wrapper decode default 
# $1 = apktool mode (decode/build)
# $2 = package name/type
# $3 = optional --use-aapt2

apktool_wrapper () { 
	case $2 in
		default)
			PACKAGE=default
			PARAM=''
			;;

		nores)
			PACKAGE=nores
			PARAM='-r'
			;;

		nosrc)
			PACKAGE=nosrc
			PARAM='-s'
			;;		
	esac

	if [ $1 = 'build' ]; then
		echo -e "${CYAN}Building ${PACKAGE} package.. (${3})${NC}"
		apktool b ./apktool/$PACKAGE -o ./repack/$PACKAGE.apk $3
		if [ $? -ne 0 ];then                        
			echo -e "${RED}Building $PACKAGE package failed. (${3})${NC}"                                                
			sed -i "s|^BUILD_${PACKAGE^^}:.\$|BUILD_${PACKAGE^^}:0|g" $checklist
			return 1
		else
			if [ ! -z $3 ]; then
				sed -i "s|^BUILD_${PACKAGE^^}:.\$|BUILD_${PACKAGE^^}:1:AAPT2|g" $checklist
			else
				sed -i "s|^BUILD_${PACKAGE^^}:.\$|BUILD_${PACKAGE^^}:1|g" $checklist	
			fi
		fi
	elif [ $1 = 'decode' ]; then
		BUILD_RESULT=$(cat $checklist | grep -i build_$1 | cut -d ':' -f 2)
		if [ $BUILD_RESULT  = 1 ] || [ -e ./apktool/$PACKAGE ]; then
			read -p "${RED}./apktool/${PACKAGE} already exists, do you want to overwrite it?" confirm
			confirm="${confirm:=YES}"
			if [[ $confirm =~ Y|y ]]; then
				rm -rf ./apktool/$PACKAGE
				sed -i "s|^DECODE_${PACKAGE^^}:.\$|DECODE_${PACKAGE^^}:0|g" $checklist
				apktool wrapper decode $PACKAGE
			else
				return 0
			fi
		else
			echo -e "${CYAN}Decompiling ${PACKAGE} package.. (${3})${NC}"
			apktool d $PARAM $APK -o ./apktool/$PACKAGE
			if [ $? -ne 0 ];then                        
				echo -e "${RED}Decompile $PACKAGE package failed.${NC}"                                                
				sed -i "s|^DECODE_${PACKAGE^^}:.\$|DECODE_${PACKAGE^^}:0|g" $checklist
				return 1
			else
				sed -i "s|^DECODE_${PACKAGE^^}:.\$|DECODE_${PACKAGE^^}:1|g" $checklist	
			fi
		fi
	fi
}

## MAIN ## 

if [ -z $1 ]; then
	echo -e "${CYAN}Usage: ./autocheck.sh <file_name>.apk${NC}"
	exit 1
fi

if [ ! -e $checklist ];then
	touch $checklist
	echo -e "DECODE_DEFAULT:0\nDECODE_NORES:0\nDECODE_NOSRC:0\nBUILD_DEFAULT:0\nBUILD_NORES:0\nBUILD_NOSRC:0\nDEPLOY_DEFAULT:0\nDEPLOY_NORES:0\nDEPLOY_NOSRC:0" > $checklist
fi

if [ ! -e $1 ]; then
	echo -e "${RED}Can't find APK. Please check your path.${NC}"
	exit 1
fi	

if [ ! -e ./apktool ]; then
	echo -e "${RED}Can't find apktool directory, have you run init_project.sh?${NC}"
	exit 1
fi

if [ ! -e ./repack ]; then
	echo -e "${RED}Can't find repack directory, have you run init_project.sh?${NC}"
	exit 1
fi

apktool_wrapper decode default
apktool_wrapper decode nores
apktool_wrapper decode nosrc
apktool_wrapper build default
if [ $? -ne 0 ]; then
	echo "Building with aapt"
	apktool_wrapper build default --use-aapt2
fi
apktool_wrapper build nores
if [ $? -ne 0 ]; then
	echo "Building with aapt"
	apktool_wrapper build nores --use-aapt2
fi
apktool_wrapper build nosrc
if [ $? -ne 0 ]; then
	echo "Building with aapt"
	apktool_wrapper build nosrc --use-aapt2
fi

# INTERRUPT TRAP
# trap ctrl-c and call ctrl_c()
# trap ctrl_c INT