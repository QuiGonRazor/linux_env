#!/bin/bash

#VARS
# 0 = NOT_DEFINED, 1 = INSTALL AS SOURCE, 2 = INSTALL INSIDE /USR/LOCAL/BIN
INSTALL_MODE=0
OVERRIDE_CONFIGS=0
INSTALL_GIT_ALIASES=0
LINUX_FOLDER=$PWD/genuine_linux
WSL_FOLDER=$PWD/wsl_env
CONFIG_FILE="$HOME/.user_configs"
CONFIG_FILE_BAK="$HOME/.user_configs.bak"
CONFIG_FILE_TO_COPY=$LINUX_FOLDER/user_configs
BASHRC_PATH="$HOME/.bashrc"

USR=""
EMAIL=""

declare -A optsDesc

optsDesc=( ["-r"]="Add a source to aliases inside shell config file (e.g. $BASHRC_PATH) using a custom file '$CONFIG_FILE'"
	["-b"]="Install aliases inside /usr/local/bin" 
	["-c"]="Specify shell config file. Default: '$BASHRC_PATH'" 
	["-o"]="Override custom settings if file exists. File used '$CONFIG_FILE'" 
	["-g"]="Install git aliases" 
	["-u"]="Username used into git config" 
	["-e"]="Email used into git config" 
	["-h|--help"]="Show this message")

function printErrorAndExit()
{
	echo -ne "\nERROR: $1\n" >&2
	print_usage
	exit 1
}

function printWarn()
{
	echo -ne "\nWARN: $1\n"
}

function print_opts()
{
	for opt in "${!optsDesc[@]}"; do echo -ne "$opt\t\t\t${optsDesc[$opt]}\n"; done
}

function print_usage()
{
	echo -ne "\nUSAGE:\n\t$0 [OPTIONS]\n\n"
	print_opts
}

function parseargs()
{
	# if [ $# -lt 1  ] ; then
	# 	echo "Too few arguments."
	# 	print_usage
	# 	exit 99;
	# fi

	while (( "$#" )); do
		case "$1" in
			-r)
				INSTALL_MODE=1
				shift
				;;
			-b)
				INSTALL_MODE=2
				shift
				;;
			-c)
				BASHRC_PATH=$2
				shift 2
				;;
			-o)
				OVERRIDE_CONFIGS=1
				shift
				;;
			-g)
				INSTALL_GIT_ALIASES=1
				shift
				;;
			-u)
				USR=$2
				shift 2
				;;
			-e)
				EMAIL=$2
				shift 2
				;;
			-h|--help)
				print_usage
				exit 0
				;;
			-*|--*=)
				printErrorAndExit "Unsupported flag $1"
				;;
			*) # preserve positional arguments of remaining items
				PARAMS="$PARAMS $1"
				shift
				;;
		esac
	done

	# set positional arguments in their proper place
	eval set -- "$PARAMS"
}

function installTools()
{
	IS_WSL=0
	if [[ $(uname -a) == *"Microsoft"* ]]; then
		printInfo "WSL system FOUND. Installing related tools"
		IS_WSL=1
	fi

	if [[ $INSTALL_MODE -eq 1 ]]; then
		echo "" | sudo tee --append $CONFIG_FILE
		echo "#ADDING PATH TO NEW TOOLS" | sudo tee --append $CONFIG_FILE
		echo 'export PATH='$LINUX_FOLDER':$PATH' | sudo tee --append $CONFIG_FILE
		[[ IS_WSL -eq 1 ]] && echo 'export PATH='$WSL_FOLDER':$PATH' | sudo tee --append $CONFIG_FILE
		echo "" | sudo tee --append $CONFIG_FILE
	elif [[ $INSTALL_MODE -eq 2 ]]; then
		sudo cp $LINUX_FOLDER/* /usr/local/bin
		[[ IS_WSL -eq 1 ]] && sudo cp $WSL_FOLDER/* /usr/local/bin
	fi
}

function moveConfigFile()
{
	cp $CONFIG_FILE $CONFIG_FILE_BAK
	cp $CONFIG_FILE_TO_COPY $CONFIG_FILE
}

function installGitAliases()
{
	if [[ $USR == "" ]] || [[ $EMAIL == "" ]]; then
		printErrorAndExit "No USER/EMAIL specified for git aliases"
	fi

	$LINUX_FOLDER/setgitaliases -u $USR -e $EMAIL
}

function overrideConfig()
{
	[ $OVERRIDE_CONFIGS -eq 0 ] && printWarn "File exist. Override not requested" || moveConfigFile
}

function installUserConfigFile()
{
	[ -f $CONFIG_FILE ] && overrideConfig || moveConfigFile

	echo "" | sudo tee --append $BASHRC_PATH
	echo "#USER CONFIG FILE W/CUSTOM SETTINGS" | sudo tee --append $BASHRC_PATH
	echo "if [ -f $CONFIG_FILE ]; then" | sudo tee --append $BASHRC_PATH
	echo ". $CONFIG_FILE" | sudo tee --append $BASHRC_PATH
	echo "fi" | sudo tee --append $BASHRC_PATH
	echo "" | sudo tee --append $BASHRC_PATH
}

parseargs "$@"

if [[ $INSTALL_MODE -eq 0 ]]; then
	printErrorAndExit "No installation mode specified"	
fi

installUserConfigFile
installTools

if [[ $INSTALL_GIT_ALIASES -eq 1 ]]; then
	installGitAliases
fi