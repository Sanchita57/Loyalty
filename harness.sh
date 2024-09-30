#!/bin/bash
DIRNAME=`dirname $0`
PROGNAME=`basename $0`

if [ $# -lt 2 ]
then
  echo "download.sh requires 2 and has 1 conditional and 1 optional arguments :"
  echo "        prod being one of BP CBRS LEM LUMC RN SC (ALL will download all products)"
  echo "        tag - the TAG or BRANCH for the build required"
  echo "        conf - the configuration to be used unless CONF is set externally"
  echo "        unzip - the unzip options can be set (combinations of -f -o -q)  overwriting UNZIP_OPTS "
  echo ""
  echo "The following environment settings are also used"
  echo "        proxy - needed for artifactory suggested value: proxy.fisdev.local:8080"
  echo "        CREDS - if provided will stop the script using logged in user and prompting for password,"
  echo "            needed by proxy and artifactory possible values:"
  echo "                <userid>  - password will be requested when needed"
  echo "                <userid>:<password>"
  echo "                svcacct-loyaltybuild:<service user password>"
  echo "        CONF can set a default value for conf argument (e.g. qa or uat)"
  echo "        UNZIP_OPTS can set a default value for unzip argument (e.g. -foq freshen-up,overwrite,quietly)"
  echo "        LOYALTY_PRODUCTS can set list of PRODUCTS for ALL if not the full LIST above"
exit 1
fi
if [ $# -lt 3 ] && [ "x$CONF" = "x" ]
then
  echo "Warning no configuration has been selected"
  echo ""
fi
#if [ "x$CREDS" = "x" ]
#then
#       mytty=$(tty)
#       mytty=${mytty##*dev/}
#       u=$(w | grep "$mytty "| cut -d" " -f1)
#       echo "Enter password for $u :"
#       read -s p
#       export CREDS=$u:$p
#fi
#if [ "x${CREDS%:*}" = "x${CREDS}" ]
#then
#       echo "Enter password for $CREDS :"
#       read -s p
#       export CREDS=$CREDS:$p
#fi
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
export Username=$1
shift 1
export Password=$1
shift 1

echo $DIRNAME $PROGNAME $PROD $TAG
if [ "x${GIT_BASE}" = "x" ]; then
        export GIT_BASE=$HOME
fi
if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
fi
mkdir -p /tmp/$PROD
(
        cd /tmp/$PROD
echo "$Username"
echo "$Password"
        echo curl -u ${CREDS/:*/:***************} -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O
        curl -v -u svcacct-san:san123 --retry 20 --retry-delay 60 -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O --connect-timeout 300 --max-time 7200
)
