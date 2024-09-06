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

@@@@
Let’s break down the provided script step by step. This script is designed to stop various applications and event handlers for specific products. It ensures that these services are shut down properly by checking their running state and attempting to stop them if necessary.

1. List of Products

list="BP CBRS LEM LUMC RN SC"

	•	A list of product names is defined: BP, CBRS, LEM, LUMC, RN, and SC. These represent different applications or services the script manages.

2. Argument Check

if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
        echo "stopJVMs.sh will stop event handlers and other servers for specified products"
        echo "if no arguments are passed products are found that have an event handler"
        exit 1
fi

	•	$# -gt 0: Checks if any arguments were passed to the script.
	•	If an argument is passed, the script checks if the argument is a valid product name from the list.
	•	If the argument is not in the list, the script prints usage information and exits.
	•	Explanation: This ensures that if an argument is provided, it must be one of the products listed. If no argument is given, the script will determine the products automatically later.

3. Set PROD_BASE

if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
fi

	•	Check if PROD_BASE is set:
	•	If PROD_BASE is not set, it defaults to the user’s home directory ($HOME).
	•	Explanation: This ensures that the base directory for the products is defined. If not, it falls back to the user’s home directory.

4. Determine Products to Process

prods=$*
if [ $# -eq 0 ]
then
        prods=$(cd ${PROD_BASE};find BP CBRS LEM LUMC RN SC -type d -exec test -e '{}'/valuesys/shell/ehStart.sh \; -print 2>/dev/null)
fi

	•	prods=$*: If any arguments were passed (i.e., specific products), the script stores them in the prods variable.
	•	If no arguments are passed ($# -eq 0):
	•	The script searches through the PROD_BASE directory to find product directories that have the ehStart.sh script in the valuesys/shell/ directory, which indicates an event handler is present.
	•	find ...: This command looks for product directories that meet the criteria and stores them in the prods variable.
	•	Explanation: This allows the script to automatically determine which products have event handlers to stop if no specific products are provided.

5. Stop Applications

for prod in $prods; do
        for app in $(ls -d ${PROD_BASE}/$prod/*/ -r -1); do
                if [ -f ${app}shell/server.sh ]; then
                        ps="$(ps -leaf|grep "$USER " | grep "${app}lib" | grep -v 'appName=event-handler' |grep -v grep|wc -l)"
                        if [ $ps == 0 ]
                        then
                                echo "$app already stopped" 1>&2
                        else
                                echo "stopping $app" 1>&2

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

	•	Outer for loop: Iterates through each product in prods (either passed as an argument or found automatically).
	•	Inner for loop: Iterates through each application directory for the current product.
	•	Check if server.sh exists: If server.sh exists in the shell/ directory of the application, it is used to manage the app.
	•	Check if the app is running:
	•	Uses the ps command to check if any processes are running for the application (excluding event handlers). If no processes are found, it prints that the app is already stopped.
	•	Stopping the app:
	•	If the app is running, it tries to stop it by running either sasKill.sh (if available) or server.sh stop.
	•	Recheck if the app is stopped:
	•	After attempting to stop the app, it checks again if the app is still running. If it’s still running, it prints a warning; otherwise, it confirms the app has stopped.
	•	Explanation: This loop ensures that each application for the specified products is stopped. It handles different stopping mechanisms (sasKill.sh or server.sh) and verifies that the app is no longer running.

6. Stop Event Handlers

        if [ -f ${PROD_BASE}/$prod/valuesys/shell/ehKill.sh ]; then
                ps="$(ps -leaf|grep "$USER " | grep "${prod}/valuesys/lib" | grep 'appName=event-handler' |grep -v grep)"
                if [ -z "$ps" ]
                then
                        echo "$prod Event handler already stopped" 1>&2
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
                                echo "Event handler killed" 1>&2
                        fi
                fi
        fi
done

	•	Check for event handler kill script:
	•	If the ehKill.sh script exists for the product, it attempts to stop the event handler.
	•	Check if the event handler is running:
	•	The script uses ps to check if any processes related to the event handler are running for the current product.
	•	Killing the event handler:
	•	If an event handler process is found, the script extracts the process ID (pid) and uses kill -9 to forcefully terminate it.
	•	Recheck if the event handler is stopped:
	•	After attempting to kill the process, it checks again if the event handler is still running. If it is, it prints a warning; otherwise, it confirms the event handler has been successfully killed.
	•	Explanation: This ensures that the event handler for each product is stopped. If it’s running, the script forcefully kills it using the process ID.

Summary

This script is designed to stop both applications and event handlers for specific products. It can either take product names as arguments or automatically determine which products have event handlers. For each product, it loops through the applications and event handlers, checking their running state, stopping them if needed, and verifying that they have been successfully stopped. The script uses process checking and provides feedback at each step to inform the user about the status of the shutdown process.
@@@@
