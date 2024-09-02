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
