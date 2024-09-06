#!/bin/bash
list="BP CBRS LEM LUMC RN SC"
if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
        echo "status.sh will report on event handlers and other servers for specifed products"
        echo "if no arguments are passed products are found that have an event handler"
        exit 1
fi
ps="$(ps -leaf |grep "$USER " |grep -i 'org.apache.catalina.startup.Bootstrap start' | grep -v grep)"
if [ ! -z "$ps" ]
then
        echo "Tomcat running : ${ps%%-classpath*}"
fi
if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
fi
prods=$*
if [ $# -eq 0 ]
then
        prods=$(cd ${PROD_BASE};find BP CBRS LEM LUMC RN SC -type d -exec test -e '{}'/valuesys/shell/ehStart.sh \; -print 2>/dev/null)
fi
for prod in $prods; do
        ps="$(ps -leaf|grep "$USER " | grep "${prod##*/}/valuesys/lib" | grep 'appName=event-handler' |grep -v grep)"
        if [ ! -z "$ps" ]
        then
                echo "$prod event handler running : ${ps%%-classpath*}"
        fi

        for app in $(ls -d ${PROD_BASE}/$prod/*/); do
                if [ -f ${app}shell/server.sh ]
                then
                        ps="$(ps -leaf|grep "$USER " | grep "${app}lib" | grep -v 'appName=event-handler' |grep -v grep)"
                        if [ ! -z "$ps" ]
                        then
                                echo "$app server running : ${ps%%-classpath*}"
                        fi
                fi
        done
done
