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

@@@@@@
Let’s go through the startAll.sh script step by step. This script is designed to start a Tomcat server and several Java Virtual Machines (JVMs) for different products, including event handlers and other servers. It can either start specified products or automatically find products with event handlers.

1. Initialize Script Variables

DIRNAME=`dirname $0`
PROGNAME=`basename $0`

	•	DIRNAME: Stores the directory path where the script is located.
	•	PROGNAME: Stores the name of the script (startAll.sh).

2. Define the Product List

list="BP CBRS LEM LUMC RN SC"

	•	list: A variable containing a space-separated list of predefined products (BP, CBRS, LEM, LUMC, RN, SC).

3. Argument Check and Usage Information

if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
  echo "startAll.sh will run startTomcat.sh and then startJVMs.sh to start event handlers and other servers for specified products"
  echo "if no arguments are passed and the configuration looks viable tomcat is started without change"
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
    prods="$(cd ${PROD_BASE}; find BP CBRS LEM LUMC RN SC -type d -exec test -e '{}'/valuesys/shell/ehStart.sh \; -print | tr -s '\n' '_' 2>/dev/null)"
fi

	•	prods=$*: This assigns all arguments (products) to the prods variable.
	•	if [ $# -eq 0 ]: If no arguments are passed:
	•	find: Searches for directories in the PROD_BASE that correspond to the products (BP, CBRS, etc.).
	•	-exec test -e '{}'/valuesys/shell/ehStart.sh: Finds directories that contain the ehStart.sh script (indicating they have an event handler).
	•	tr -s '\n' '_': Converts newline characters (\n) to underscores (_) to format the product names.
	•	The result is assigned to the prods variable.
	•	Explanation: If no specific products are provided, the script automatically finds products with event handlers.

6. Create Log Directory and Set Log File

mkdir -p logs
LOG_FILE=start_${prods// /_}.txt.`date +%Y%m%d`

	•	mkdir -p logs: Creates a logs directory if it doesn’t exist, to store the log files.
	•	LOG_FILE=start_${prods// /_}.txt.date +%Y%m%d``: Defines the log file name based on the products being started. It replaces spaces with underscores and appends the current date (YYYYMMDD format).

7. Start Tomcat Server

echo "starting Tomcat $*"
$DIRNAME/startTomcat.sh $* >> $LOG_FILE

	•	$DIRNAME/startTomcat.sh $*: Calls the startTomcat.sh script, passing along any arguments ($*, which represents the products).
	•	The output of the startTomcat.sh script is appended to the log file ($LOG_FILE).
	•	Explanation: This starts the Tomcat server and logs the results to a file.

8. Wait for Tomcat to Start

sleep 20

	•	The script waits for 20 seconds to give Tomcat enough time to fully start.

9. Check if Tomcat is Running

if [ "x$(ps -leaf |grep "$USER " |grep -i 'org.apache.catalina.startup.Bootstrap start' | grep -v grep | wc -l)" = "x1" ]
then
    echo
    echo "Tomcat running"
else
    echo
    echo "Tomcat could not be started, please do it manually"
fi

	•	ps -leaf: This lists all processes.
	•	grep "$USER ": Filters the processes by the current user.
	•	grep -i 'org.apache.catalina.startup.Bootstrap start': Looks for the Tomcat startup process.
	•	grep -v grep: Excludes the grep process itself.
	•	wc -l: Counts the number of lines returned (i.e., how many Tomcat processes are found).
	•	If exactly one Tomcat process is found, the script prints “Tomcat running”. Otherwise, it warns that Tomcat could not be started and advises manual startup.

10. Start JVMs for Event Handlers and Servers

$DIRNAME/startJVMs.sh $* >> $LOG_FILE

	•	$DIRNAME/startJVMs.sh $*: Runs the startJVMs.sh script, passing the same arguments ($*, representing the products).
	•	The output is also appended to the log file ($LOG_FILE).
	•	Explanation: This starts the Java Virtual Machines (JVMs) for the event handlers and any other associated servers for the specified products.

Summary of Key Steps

	1.	Argument Handling: The script checks if specific products are provided. If no products are passed, it automatically discovers products with event handlers.
	2.	Logging: It logs all actions in a file named based on the products and the current date.
	3.	Tomcat Startup: The script starts the Tomcat server using startTomcat.sh and checks whether it successfully starts.
	4.	JVM Startup: After starting Tomcat, it calls startJVMs.sh to start the Java Virtual Machines for the products.
	5.	Fallback for Manual Intervention: If Tomcat cannot be started, it prompts the user to manually start it.

This script is designed to automate the startup of Tomcat and the necessary JVMs for different products, simplifying deployment and startup management for complex server setups.
@@@@@@
