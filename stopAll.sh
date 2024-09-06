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


@@@@
Let’s go through the stopAll.sh script step by step. This script is designed to stop a running Tomcat server and several Java Virtual Machines (JVMs) for different products, including event handlers and other servers. Similar to the startAll.sh script, it either stops the specified products or automatically finds and stops products that have event handlers.

1. Initialize Script Variables

DIRNAME=`dirname $0`
PROGNAME=`basename $0`

	•	DIRNAME: Stores the directory path where the script is located.
	•	PROGNAME: Stores the name of the script (stopAll.sh).

2. Define the Product List

list="BP CBRS LEM LUMC RN SC"

	•	list: A variable containing a space-separated list of predefined products (BP, CBRS, LEM, LUMC, RN, SC).

3. Argument Check and Usage Information

if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
  echo "stopAll.sh will run stopTomcat.sh and then stopJVMs.sh to stop event handlers and other servers for specified products"
  echo "if no arguments are passed products are found that have an event handler"
 exit 1
fi

	•	$#: This checks how many arguments are passed to the script.
	•	If arguments are passed and the first argument is not in the predefined product list ($list), an error message is printed and the script exits.
	•	Explanation: This ensures that any specified product is one of the recognized products or none at all (for automatic discovery of products with event handlers).

4. Check and Set the PROD_BASE Directory

if [ "x${PROD_BASE}" = "x" ]; then
    export PROD_BASE=$HOME
fi

	•	PROD_BASE: This environment variable points to the base directory where the products are located.
	•	If PROD_BASE is not set, it defaults to the user’s home directory ($HOME).
	•	Explanation: This ensures that a valid base directory is defined where the product configurations and scripts reside.

5. Determine Products to Process

prods=$*
if [ $# -eq 0 ]
then
    prods="$(cd ~; find BP CBRS LEM LUMC RN SC -type d -exec test -e '{}'/valuesys/shell/ehStart.sh \; -print 2>/dev/null | tr -s '\n' '_')"
fi

	•	prods=$*: This assigns all arguments (products) to the prods variable.
	•	if [ $# -eq 0 ]: If no arguments are passed:
	•	find: Searches for directories in the home directory (~) that correspond to the products (BP, CBRS, etc.).
	•	-exec test -e '{}'/valuesys/shell/ehStart.sh: Finds directories that contain the ehStart.sh script (indicating they have an event handler).
	•	tr -s '\n' '_': Converts newline characters (\n) to underscores (_) to format the product names.
	•	The result is assigned to the prods variable.
	•	Explanation: If no specific products are provided, the script automatically finds products with event handlers.

6. Set Log File

LOG_FILE=stop_${prods// /_}.txt.`date +%Y%m%d`

	•	LOG_FILE: Defines the log file name based on the products being stopped. It replaces spaces with underscores and appends the current date (YYYYMMDD format).

7. Stop JVMs for Event Handlers and Servers

$DIRNAME/stopJVMs.sh $* >> $LOG_FILE

	•	$DIRNAME/stopJVMs.sh $*: Calls the stopJVMs.sh script, passing along any arguments ($*, which represents the products).
	•	The output of the stopJVMs.sh script is appended to the log file ($LOG_FILE).
	•	Explanation: This stops the Java Virtual Machines (JVMs) for the event handlers and any other associated servers for the specified products.

8. Check if Tomcat is Running

if [ "x$(ps -leaf |grep "$USER " |grep -i 'org.apache.catalina.start
@@@@
