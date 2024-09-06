#!/bin/bash
DIRNAME=`dirname $0`
PROGNAME=`basename $0`

list="BP CBRS LEM LUMC RN SC"
if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
  echo "stopAll.sh will run stopTomcat.sh and then stopJVMs.sh to stop event handlers and other servers for specifed products"
  echo "if no arguments are passed products are found that have an event handler"
 exit 1

fi
if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
fi
prods=$*
if [ $# -eq 0 ]
then
        prods="$(cd ~;find BP CBRS LEM LUMC RN SC -type d -exec test -e '{}'/valuesys/shell/ehStart.sh \; -print 2>/dev/null |tr -s '\n' '_' )"
fi
LOG_FILE=stop_${prods// /_}.txt.`date +%Y%m%d`

$DIRNAME/stopJVMs.sh $* >> $LOG_FILE

if [ "x$(ps -leaf |grep "$USER " |grep -i 'org.apache.catalina.startup.Bootstrap start' | grep -v grep|wc -l)" = "x1" ]
then
        echo "stopping Tomcat "

        $DIRNAME/stopTomcat.sh  >> $LOG_FILE

        sleep 15
fi
if [ "x$(ps -leaf |grep "$USER " |grep -i 'org.apache.catalina.startup.Bootstrap start' | grep -v grep|wc -l)" = "x1" ]
        then
                echo
                echo "Tomcat still running"
        else
                echo
                echo "Tomcat stopped"
fi
