#!/bin/bash
DIRNAME=`dirname $0`
PROGNAME=`basename $0`

if [ $# -lt 2 ]
then
  echo "download.sh requires 2 and has 1 conditional and 1 optional arguments :"
  echo "	prod being one of BP CBRS LEM LUMC RN SC (ALL will download all products)"
  echo "	tag - the TAG or BRANCH for the build required"
  echo "	conf - the configuration to be used unless CONF is set externally"
  echo "	unzip - the unzip options can be set (combinations of -f -o -q)  overwriting UNZIP_OPTS "
  echo ""
  echo "The following environment settings are also used"
  echo "	proxy - needed for artifactory suggested value: proxy.fisdev.local:8080"
  echo "	CREDS - if provided will stop the script using logged in user and prompting for password,"
  echo "            needed by proxy and artifactory possible values:"
  echo "		<userid>  - password will be requested when needed"
  echo "		<userid>:<password>"
  echo "		svcacct-loyaltybuild:<service user password>"
  echo "	CONF can set a default value for conf argument (e.g. qa or uat)"
  echo "	UNZIP_OPTS can set a default value for unzip argument (e.g. -foq freshen-up,overwrite,quietly)"
  echo "	LOYALTY_PRODUCTS can set list of PRODUCTS for ALL if not the full LIST above"
 exit 1
fi 
if [ $# -lt 3 ] && [ "x$CONF" = "x" ]
then
  echo "Warning no configuration has been selected"
  echo ""
fi
if [ "x$CREDS" = "x" ]
then
	mytty=$(tty)
	mytty=${mytty##*dev/}
	u=$(w | grep "$mytty "| cut -d" " -f1)
	echo "Enter password for $u :"
	read -s p
	export CREDS=$u:$p
fi
if [ "x${CREDS%:*}" = "x${CREDS}" ]
then
	echo "Enter password for $CREDS :"
	read -s p
	export CREDS=$CREDS:$p
fi
export PROD=$1
shift 1
if [ "x$PROD" = "xALL" ]
then
	if [ "x$LOYALTY_PRODUCTS" = "x" ]
	then
		LOYALTY_PRODUCTS="CBRS BP LEM LUMC RN SC"
	fi
	for prod in $LOYALTY_PRODUCTS
	do
	  download.sh $prod $*
	done
	exit 1
fi 
export TAG=$1
shift 1
if [ $# -gt 0 ]
then
	export CONF=$1
	shift 1
	if [ $# -gt 0 ]
	then
		export UNZIP_OPTS=$1
		shift 1
fi
fi
export DIR=..
if [ $# -gt 0 ]
then
	export DIR=$1
fi
echo $DIRNAME $PROGNAME $PROD $TAG
if [ "x${GIT_BASE}" = "x" ]; then
	export GIT_BASE=$HOME
fi
if [ "x${PROD_BASE}" = "x" ]; then
	export PROD_BASE=$HOME
fi
mkdir -p ${PROD_BASE}/$PROD
(
	cd ${PROD_BASE}/$PROD
	echo curl -u ${CREDS/:*/:***************} -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O 
	curl -u $CREDS -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O 
	rm -fr */lib webapps
	unzip $UNZIP_OPTS ${PROD}-$TAG.zip
	rm -fr sql
	unzip -o valuesys/lib/*-persistence-*.jar '*.sql'
	
	if [ "x$CONF" = "x" ]
	then
		exit 0
	fi
	if [ "x$CONF" = "xnone" ] || [ "x$CONF" = "xtest" ]
	then
		# link in the dummy configuration for the product
		ln -s ${GIT_BASE}/git/LTYconfig/${PROD}config .
	else
		echo curl -u ${CREDS/:*/:***************} -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/${PROD}config/${PROD}config.$CONF-$TAG.zip -L -O
		curl -u $CREDS -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/${PROD}config/${PROD}config.$CONF-$TAG.zip -L -O
		unzip $UNZIP_OPTS ${PROD}config.$CONF-$TAG.zip
	fi
	if [[ " production dr test " =~ .*\ $CONF\ .* ]] 
	then
		for exclude in $(sed 's|\r||' productionExclusions.txt); do
			rm -f $exclude
		done;
	fi
)


This Bash script is designed to automate the process of downloading, configuring, and setting up build environments for specific products. Here’s a clear explanation of each part of the script, focusing on where variables are passed and used:

1. Shebang and Initial Setup

#!/bin/bash
DIRNAME=`dirname $0`
PROGNAME=`basename $0`

	•	#!/bin/bash: This tells the system to use the Bash shell to interpret the script.
	•	DIRNAME: Stores the directory path where the script is located.
	•	PROGNAME: Stores the name of the script itself.

2. Argument Check and Usage Information

if [ $# -lt 2 ]; then
  echo "download.sh requires 2 and has 1 conditional and 1 optional arguments:"
  ...
  exit 1
fi

	•	if [ $# -lt 2 ]: This checks if fewer than two arguments are provided when the script is run.
	•	If true, it displays usage information, detailing the expected arguments and environment variables.

3. Handling Optional Arguments

if [ $# -lt 3 ] && [ "x$CONF" = "x" ]; then
  echo "Warning no configuration has been selected"
fi

	•	This checks if fewer than three arguments are provided and whether the CONF variable (used to specify configuration) is set. If not, a warning is issued.

4. Handling Credentials

if [ "x$CREDS" = "x" ]; then
  ...
  export CREDS=$u:$p
fi
if [ "x${CREDS%:*}" = "x${CREDS}" ]; then
  echo "Enter password for $CREDS :"
  read -s p
  export CREDS=$CREDS:$p
fi

	•	CREDS: This environment variable is used for authentication (e.g., with a proxy or Artifactory).
	•	If CREDS isn’t set, the script prompts the user to enter a username and password, then exports CREDS as username:password.
	•	If only a username is provided in CREDS, the script prompts for a password and completes the CREDS variable.

5. Product Handling

export PROD=$1
shift 1
if [ "x$PROD" = "xALL" ]; then
  ...
  exit 1
fi

	•	PROD: The first argument passed to the script is stored in the PROD variable, representing the product to be downloaded.
	•	shift 1: This shifts the argument list to the left, so the next argument can be accessed as $1.
	•	If PROD is set to “ALL”, the script loops through a predefined list of products and downloads them all.

6. Tag, Configuration, and Unzip Options

export TAG=$1
shift 1
if [ $# -gt 0 ]; then
  export CONF=$1
  shift 1
  if [ $# -gt 0 ]; then
    export UNZIP_OPTS=$1
    shift 1
  fi
fi

	•	TAG: The next argument (after PROD) is stored in the TAG variable, representing the version or branch to download.
	•	CONF: The next argument (after TAG) is optionally stored in CONF, which determines the configuration to be used.
	•	UNZIP_OPTS: The following argument, if provided, is stored in UNZIP_OPTS to define options for unzipping files.
	•	shift 1: After each argument is processed, shift removes it from the list, allowing the script to access the next argument as $1.

7. Directory Setup

export DIR=..
if [ $# -gt 0 ]; then
  export DIR=$1
fi

	•	DIR: Sets the default directory to .. (the parent directory). If another argument is provided, it overrides DIR.

8. Download and Unzip Process

mkdir -p ${PROD_BASE}/$PROD
(
  cd ${PROD_BASE}/$PROD
  ...
  curl -u $CREDS -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O
  rm -fr */lib webapps
  unzip $UNZIP_OPTS ${PROD}-$TAG.zip
  ...
)

	•	PROD_BASE: The base directory where the product will be downloaded. This is typically set to the user’s home directory but can be changed.
	•	mkdir -p ${PROD_BASE}/$PROD: Creates a directory for the product if it doesn’t exist.
	•	cd ${PROD_BASE}/$PROD: Navigates to the product’s directory.
	•	curl -u $CREDS -x $proxy: Uses curl to download the product from the specified URL, with credentials (CREDS) and proxy (proxy) options.
	•	unzip $UNZIP_OPTS ${PROD}-$TAG.zip: Unzips the downloaded file using the options specified in UNZIP_OPTS.

9. Handling Configurations

if [ "x$CONF" = "x" ]; then
  exit 0
fi
if [ "x$CONF" = "xnone" ] || [ "x$CONF" = "xtest" ]; then
  ln -s ${GIT_BASE}/git/LTYconfig/${PROD}config .
else
  ...
  curl -u $CREDS -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/${PROD}config/${PROD}config.$CONF-$TAG.zip -L -O
  unzip $UNZIP_OPTS ${PROD}config.$CONF-$TAG.zip
fi

	•	If CONF is not set, the script exits.
	•	If CONF is set to “none” or “test”, it creates a symbolic link to a dummy configuration.
	•	Otherwise, it downloads and unzips the configuration file specific to the product and configuration (CONF).

10. Exclusions Handling

if [[ " production dr test " =~ .*\ $CONF\ .* ]]; then
  for exclude in $(sed 's|\r||' productionExclusions.txt); do
    rm -f $exclude
  done;
fi

	•	If CONF matches specific conditions (e.g., “production”, “dr”, “test”), the script reads a list of files from productionExclusions.txt and removes them from the product directory.

Summary of Variable Usage

	•	Passed as Arguments:
	•	PROD: First argument, specifying the product.
	•	TAG: Second argument, specifying the version or branch.
	•	CONF: Third argument (optional), specifying the configuration.
	•	UNZIP_OPTS: Fourth argument (optional), specifying unzip options.
	•	DIR: Fifth argument (optional), specifying the directory to use.
	•	Used in the Script:
	•	CREDS: Used for authentication with curl.
	•	proxy: Used for proxy settings in curl.
	•	PROD_BASE, GIT_BASE: Used to define paths where products and configurations are stored.
	•	DIRNAME, PROGNAME: Used for logging or identifying the script and its location.

The script carefully checks the presence of each variable, provides defaults, and uses them in commands to automate downloading, configuring, and setting up a build environment.
