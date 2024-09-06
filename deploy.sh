#!/bin/sh
DIRNAME=`dirname $0`
PROGNAME=`basename $0`

if [ $# -lt 2 ]
then
  echo "deploy.sh requires 2 and has 1 conditional and 1 optional arguments :"
  echo "	prod being one of BP CBRS LEM LUMC RN SC (ALL will download all products)"
  echo "	tag - the TAG or BRANCH for the build required"
  echo "	conf - the configuration to be used unless CONF is set externally"
  echo "	unzip - the unzip options can be set (combinations of -f -o -q)  overwriting UNZIP_OPTS "
  echo ""
  echo "The following environment settings are also used"
  echo "	CONF can set a default value for conf argument (e.g. qa or uat)"
  echo "	UNZIP_OPTS can set a default value for unzip argument (e.g. -foq freshen-up,overwrite,quietly)"
  echo "	LOYALTY_PRODUCTS can set list of PRODUCTS for ALL if not the full LIST above"
 exit 1
fi 
if [ $# -lt 3 ] && [ "x$CONF" = "x" ]
then
  echo "deploy.sh requires 2 and has 1 conditional and 1 optional arguments :"
  echo "	prod being one of BP CBRS LEM LUMC RN SC (ALL will download all products)"
  echo "	tag - the TAG or BRANCH for the build required"
  echo "	conf - the configuration to be used unless CONF is set externally"
  echo "	unzip - the unzip options can be set (combinations of -f -o -q)  overwriting UNZIP_OPTS "
  exit 1
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
	  deploy.sh $prod $*
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
	unzip $UNZIP_OPTS ${GIT_BASE}/git/$PROD/target/${PROD}-$TAG.zip
	if [ "x$CONF" = "xnone" ]
	then
		# link in the dummy configuration for the product
		ln -s ${GIT_BASE}/git/LTYconfig/${PROD}config .
	else
		unzip $UNZIP_OPTS ${GIT_BASE}/git/${PROD}config/target/${PROD}config.$CONF-$TAG.zip
	fi
)

@@@@@@@
Overview

This script, deploy.sh, is designed to deploy a product by unzipping a build (specified by a tag or branch) and optionally configuring it. It uses a combination of mandatory and optional arguments and environment variables. Let’s break it down step-by-step.

1. Initialize Script Variables

DIRNAME=`dirname $0`
PROGNAME=`basename $0`

	•	DIRNAME: Stores the directory name of where the script is located.
	•	PROGNAME: Stores the name of the script itself (in this case, deploy.sh).

2. Check for Minimum Argument Count

if [ $# -lt 2 ]
then
  echo "deploy.sh requires 2 and has 1 conditional and 1 optional arguments :"
  # Explanation of required arguments
  exit 1
fi

	•	$#: This checks how many arguments were passed to the script.
	•	If fewer than 2 arguments are passed, it displays an error message and exits.
	•	Explanation: The script requires at least two arguments (product and tag), so this ensures the user provides the required input.

3. Handle Conditional Argument Requirement

if [ $# -lt 3 ] && [ "x$CONF" = "x" ]
then
  # Similar error message if less than 3 arguments and CONF is not set
  exit 1
fi

	•	If fewer than 3 arguments are passed and the CONF environment variable is not set, the script exits.
	•	Explanation: The conf argument is optional if the CONF environment variable is already set. This block checks that either the third argument or the CONF variable is present.

4. Set Product and Shift Arguments

export PROD=$1
shift 1

	•	export PROD=$1: Assigns the first argument (the product) to the PROD variable.
	•	shift 1: Shifts the arguments by 1, so that $1 now refers to the second argument (the tag).

5. Handle the Case of “ALL” Products

if [ "x$PROD" = "xALL" ]
then
  if [ "x$LOYALTY_PRODUCTS" = "x" ]
  then
    LOYALTY_PRODUCTS="CBRS BP LEM LUMC RN SC"
  fi
  for prod in $LOYALTY_PRODUCTS
  do
    deploy.sh $prod $*
  done
  exit 1
fi

	•	If the PROD variable is set to “ALL”, the script:
	•	Checks if the LOYALTY_PRODUCTS environment variable is set. If not, it defaults to a predefined list (CBRS BP LEM LUMC RN SC).
	•	Loops over each product in the list and runs the deploy.sh script for each one (recursively).
	•	After handling all products, the script exits.
	•	Explanation: This allows for batch deployment of all products if “ALL” is passed as the product argument.

6. Set the Tag and Optional Arguments

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

	•	export TAG=$1: Assigns the second argument (the tag or branch) to the TAG variable.
	•	Optional arguments:
	•	If there are remaining arguments, the third argument is stored in CONF (the configuration).
	•	If a fourth argument is present, it’s stored in UNZIP_OPTS (unzip options like -f, -o, or -q).
	•	Explanation: This allows for optional configuration and unzip behavior to be defined if provided.

7. Set the Working Directory

export DIR=..
if [ $# -gt 0 ]
then
  export DIR=$1
fi

	•	DIR=..: Sets the default working directory to the parent directory (..).
	•	If there is an additional argument, it’s used to overwrite the default DIR.

8. Print Status Information

echo $DIRNAME $PROGNAME $PROD $TAG

	•	This prints the current script name, the product being deployed, and the tag/branch being used.

9. Set GIT_BASE and PROD_BASE if Not Already Set

if [ "x${GIT_BASE}" = "x" ]; then
  export GIT_BASE=$HOME
fi

if [ "x${PROD_BASE}" = "x" ]; then
  export PROD_BASE=$HOME
fi

	•	GIT_BASE and PROD_BASE: These variables define where the code is located and where the product will be deployed. If they are not already set, they default to the home directory ($HOME).

10. Create the Product Directory

mkdir -p ${PROD_BASE}/$PROD

	•	Creates the directory for the product (if it doesn’t exist) under PROD_BASE.

11. Deploy the Product

(
  cd ${PROD_BASE}/$PROD
  unzip $UNZIP_OPTS ${GIT_BASE}/git/$PROD/target/${PROD}-$TAG.zip
  if [ "x$CONF" = "xnone" ]
  then
    ln -s ${GIT_BASE}/git/LTYconfig/${PROD}config .
  else
    unzip $UNZIP_OPTS ${GIT_BASE}/git/${PROD}config/target/${PROD}config.$CONF-$TAG.zip
  fi
)

	•	This section is responsible for actually deploying the product:
	•	cd ${PROD_BASE}/$PROD: Change into the product directory.
	•	unzip: Extracts the product’s build archive (specified by PROD and TAG) from the GIT_BASE into the product directory, using the UNZIP_OPTS if provided.
	•	Configuration Handling:
	•	If the CONF variable is set to “none”, it creates a symbolic link to a dummy configuration (LTYconfig).
	•	Otherwise, it unzips the configuration for the product using the specified CONF and TAG.
	•	Explanation: The script unzips the product build and either sets up a dummy configuration or the appropriate configuration for the environment (e.g., QA, UAT).

Summary of Key Steps

	1.	Argument Parsing: Checks for the minimum required arguments and sets up environment variables.
	2.	Product Selection: Handles either individual products or all products in bulk (“ALL”).
	3.	Deployment: Unzips the product’s build and sets up the configuration, handling optional unzip options and configurations.
	4.	Environment Variables: Uses or defaults key variables like GIT_BASE, PROD_BASE, CONF, and UNZIP_OPTS to streamline deployment.

This script is designed to be flexible, handling deployments for different environments, products, and configurations easily.
@@@@@@@
