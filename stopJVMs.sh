#!/bin/bash
list="BP CBRS LEM LUMC RN SC"
if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
        echo "stopJVMs.sh will stop event handlers and other servers for specifed products"
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
        for app in $(ls -d ${PROD_BASE}/$prod/*/ -r -1);        do
                if [ -f ${app}shell/server.sh ]; then
                        ps="$(ps -leaf|grep "$USER " | grep "${app}lib" | grep -v 'appName=event-handler' |grep -v grep|wc -l)"
                        if [ $ps == 0 ]
                        then
                                echo "$app already stopped"     1>&2
                        else
                                echo "stoping $app" 1>&2

                                if [ -f ${app}shell/sasKill.sh ]; then
                                        ${app}shell/sasKill.sh
                                else
                                        ${app}shell/server.sh stop
                                fi

                                sleep 5

                                if [ "x$(ps -leaf|grep "$USER " | grep "${app}lib" | grep -v 'appName=event-handler' |grep -v grep|wc -l)" = "x1" ]
                                then
                                        echo "$app still running" 1>&2
                                else
                                        echo "$app stopped" 1>&2
                                fi
                        fi
                fi
        done
        if [ -f ${PROD_BASE}/$prod/valuesys/shell/ehKill.sh ]; then
                ps="$(ps -leaf|grep "$USER " | grep "${prod}/valuesys/lib" | grep 'appName=event-handler' |grep -v grep)"
                if [ -z "$ps" ]
                then
                        echo "$prod Event handler already stopped"      1>&2
                else
                        pid=${ps##*pid=}
                        pid=${pid%% *}
                        echo "killing $prod Event handler - $pid" 1>&2
                        kill -9 $pid
                        sleep 1

                        if [ "x$(ps -leaf|grep "$USER " | grep "${prod}/valuesys/lib" | grep 'appName=event-handler' |grep -v grep|wc -l)" = "x1" ]
                        then
                                echo
                                echo "Event handler still running" 1>&2
                        else
                                echo
                                echo "Event handler killed " 1>&2
                        fi
                fi
        fi
done
