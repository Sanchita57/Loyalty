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

@@@@
Let’s walk through the provided script step by step. This script is designed to start applications and event handlers for specific products. It ensures that the services are launched correctly and verifies that they are running after startup.

1. List of Products

list="BP CBRS LEM LUMC RN SC"

	•	A list of product names is defined: BP, CBRS, LEM, LUMC, RN, and SC. These are the products that the script will handle.

2. Argument Check

if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
        echo "startJVMs.sh will start event handlers and other servers for specified products"
        echo "if no arguments are passed products are found that have an event handler"
        exit 1
fi

	•	$# -gt 0: Checks if any arguments were passed to the script.
	•	If an argument is passed, the script checks if it is a valid product name from the list.
	•	If the argument is not in the list, the script prints usage information and exits.
	•	Explanation: This ensures that if an argument is provided, it must be one of the listed products. If no argument is given, the script will later automatically find products with event handlers to start.

3. Set PROD_BASE

if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
fi

	•	Check if PROD_BASE is set:
	•	If PROD_BASE is not set, it defaults to the user’s home directory ($HOME).
	•	Explanation: This ensures that the base directory for the products is defined. If not, it falls back to the user’s home directory.

4. Determine Products to Start

prods=$*
if [ $# -eq 0 ]
then
        prods=$(cd ${PROD_BASE};find BP CBRS LEM LUMC RN SC -type d -exec test -e '{}'/valuesys/shell/ehStart.sh \; -print 2>/dev/null)
fi

	•	prods=$*: If arguments were passed (i.e., specific products), the script stores them in the prods variable.
	•	If no arguments are passed ($# -eq 0):
	•	The script searches through the PROD_BASE directory to find product directories that have the ehStart.sh script in the valuesys/shell/ directory, which indicates an event handler is present.
	•	find ...: This command looks for product directories that meet the criteria and stores them in the prods variable.
	•	Explanation: This allows the script to automatically determine which products have event handlers to start if no specific products are provided.

5. Start Event Handlers

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
                                echo "Event handler could not be started, please do it manually" 1>&2
                fi
        fi

	•	Check for ehStart.sh: If the ehStart.sh script exists for the product, the script attempts to start the event handler.
	•	Run the event handler: It uses the ehStart.sh script to start the event handler.
	•	Wait for 10 seconds (sleep 10): The script waits to give the system time to start the handler.
	•	Check if the event handler is running: The ps command checks if the event handler is running by looking for processes related to the product’s event handler (appName=event-handler).
	•	If the event handler is running, it prints confirmation.
	•	If the event handler is not running, it prints a message asking the user to start it manually.
	•	Explanation: This section ensures that the event handler for the product is started and verifies that it is running. If the event handler fails to start, the script provides feedback to the user.

6. Start Applications

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

	•	Outer for loop: Iterates through each product in prods (either passed as an argument or found automatically).
	•	Inner for loop: Iterates through each application directory for the current product.
	•	Check if server.sh exists: If server.sh exists in the shell/ directory of the application, it is used to start the application.
	•	Run the application:
	•	Log directory: A log directory is created in ~/logs with the name of the application (${s##*/}).
	•	Start the app: The script runs the server.sh start command to start the application.
	•	Wait for 10 seconds (sleep 10): The script waits for the application to start.
	•	Check if the app is running: The ps command checks if the application is running (excluding event handlers).
	•	If the application is running, it prints confirmation.
	•	If the application is not running, it prints a message asking the user to start it manually.
	•	Explanation: This section ensures that each application for the specified products is started and verifies that it is running. It provides feedback if any application fails to start.

Summary

This script is designed to start both applications and event handlers for specific products. It can either take product names as arguments or automatically determine which products have event handlers. For each product, it loops through the applications and event handlers, starting them and verifying that they are running. The script provides feedback at each step to inform the user about the status of the startup process, and it creates logs for each application. If an application or event handler fails to start, the script asks the user to start it manually.
@@@@
