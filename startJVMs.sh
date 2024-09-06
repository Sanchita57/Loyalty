#!/bin/bash
list="BP CBRS LEM LUMC RN SC"
if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
        echo "startJVMs.sh will start event handlers and other servers for specifed products"
        echo "if no arguments are passed products are found that have an event handler"
        exit 1
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
        if [ -f ${PROD_BASE}/$prod/valuesys/shell/ehStart.sh ]; then
                echo "starting $prod Event handler" 1>&2
                ${PROD_BASE}/$prod/valuesys/shell/ehStart.sh

                sleep 10

                if [ "x$(ps -leaf|grep "$USER " | grep "${prod}/valuesys/lib" | grep 'appName=event-handler' |grep -v grep|wc -l)" = "x1" ]
                        then
                                echo
                                echo "Event handler running" 1>&2
                        else
                                echo
                                echo "Event handler  could not be started, please do it manually" 1>&2
                fi
        fi
        for app in $(ls -d ${PROD_BASE}/$prod/*/ -1 )
        do
                if [ -f ${app}shell/server.sh ]; then
                (
                        echo "starting $app" 1>&2
                        s=${app%/*}
                        mkdir -p ~/logs/${s##*/}
                        ${app}shell/server.sh start

                        sleep 10

                        if [ "x$(ps -leaf|grep "$USER " | grep "${app}lib" | grep -v 'appName=event-handler' |grep -v grep|wc -l)" = "x1" ]
                        then
                                echo
                                echo "$app running" 1>&2
                        else
                                echo
                                echo "$app could not be started, please do it manually" 1>&2
                        fi
                )
                fi
        done
done
