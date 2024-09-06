DIRNAME=`dirname $0`
PROGNAME=`basename $0`
if [ $# -gt 0 ];  then
  echo "stopTomcat.sh expects to find CATALINA_HOME ($CATALINA_HOME) and CATALINA_BASE ($CATALINA_BASE)"
  echo "if not setup CATALINA_BASE will be set to ${PROD_BASE} and if not that then $HOME"
  echo "if not setup CATALINA_HOME will be set by searching for apache-tomcat-9, first in $HOME and if not found in /usr_local"
  echo ""
  echo "The tomcat instance in CATALINA_BASE ($CATALINA_BASE) will be shutdown"
  exit 1
fi

if [ "x$CATALINA_BASE" = "x" ]; then
        if [ "x${PROD_BASE}" = "x" ]; then
                export PROD_BASE=$HOME
        fi
    export CATALINA_BASE=`cd ${PROD_BASE};pwd`
fi

if [ "x$CATALINA_HOME" = "x" ]; then
        export CATALINA_HOME=$(find $HOME -name 'apache-tomcat-9*')
fi
if [ "x$CATALINA_HOME" = "x" ]; then
       ln -s $(find /usr/local -name 'apache-tomcat-*' 2>/dev/null | head -1) $HOME
       export CATALINA_HOME=$(find $HOME -name 'apache-tomcat-9*')
fi
