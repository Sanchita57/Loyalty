#!/bin/bash
DIRNAME=`dirname $0`
PROGNAME=`basename $0`

list="BP CBRS LEM LUMC RN SC"
if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
  echo "startAll.sh will run startTomcat.sh and then startJVMs.sh to start event handlers and other servers for specifed products"
  echo "if no arguments are passed and the configuration looks viable tomcat is started without change"
  echo "if no arguments are passed products are found that have an event handler"
 exit 1

fi
if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
fi
prods=$*
if [ $# -eq 0 ]
then
        prods="$(cd ${PROD_BASE};find BP CBRS LEM LUMC RN SC -type d -exec test -e '{}'/valuesys/shell/ehStart.sh \; -print|tr -s '\n' '_' 2>/dev/null)"
fi
mkdir -p logs
LOG_FILE=start_${prods// /_}.txt.`date +%Y%m%d`
echo "starting Tomcat $*"

        $DIRNAME/startTomcat.sh $* >> $LOG_FILE

sleep 20

if [ "x$(ps -leaf |grep "$USER "  |grep -i 'org.apache.catalina.startup.Bootstrap start' | grep -v grep|wc -l)" = "x1" ]
        then
                echo
                echo "Tomcat running"
        else
                echo
                echo "Tomcat  could not be started, please do it manually"
fi
$DIRNAME/startJVMs.sh $* >> $LOG_FILE
