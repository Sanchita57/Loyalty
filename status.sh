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






@@@@@@@@@
Let's go step by step through this `bash` script to explain each part of it. This script appears to check for the status of Tomcat servers and event handlers for specified products and directories.

### 1. **Initial product list**
```bash
list="BP CBRS LEM LUMC RN SC"
```
- A variable `list` is created that contains a space-separated list of product names (`BP`, `CBRS`, `LEM`, `LUMC`, `RN`, `SC`).

### 2. **Check for arguments and validate them**
```bash
if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
    echo "status.sh will report on event handlers and other servers for specified products"
    echo "if no arguments are passed, products are found that have an event handler"
    exit 1
fi
```
- **`$#`**: This checks how many arguments were passed to the script.
  - If arguments are passed (`$# -gt 0`), the script checks if the first argument `$1` is in the product list `list`. 
  - If the argument is not in the `list`, it prints a usage message and exits (`exit 1`).
- **Explanation**: This ensures that the script is only run for recognized products from the `list`, or no arguments are passed.

### 3. **Check if Tomcat is running**
```bash
ps="$(ps -leaf |grep "$USER " |grep -i 'org.apache.catalina.startup.Bootstrap start' | grep -v grep)"
if [ ! -z "$ps" ]
then
    echo "Tomcat running : ${ps%%-classpath*}"
fi
```
- **`ps -leaf`**: This lists the processes currently running with detailed information.
- **`grep "$USER "`**: Filters the processes by the current user.
- **`grep -i 'org.apache.catalina.startup.Bootstrap start'`**: Filters the processes related to Tomcat startup (`Bootstrap`).
- **`grep -v grep`**: Excludes the `grep` command itself from the results.
- **`if [ ! -z "$ps" ]`**: Checks if the `ps` command found any Tomcat processes. If so, it prints that Tomcat is running.

### 4. **Set `PROD_BASE` environment variable**
```bash
if [ "x${PROD_BASE}" = "x" ]; then
    export PROD_BASE=$HOME
fi
```
- This checks if the `PROD_BASE` environment variable is set. If not, it assigns it to the current user's home directory (`$HOME`).
- **Explanation**: `PROD_BASE` is likely the base directory where products are located, so this ensures it is defined.

### 5. **Check for products if none are passed as arguments**
```bash
prods=$*
if [ $# -eq 0 ]
then
    prods=$(cd ${PROD_BASE};find BP CBRS LEM LUMC RN SC -type d -exec test -e '{}'/valuesys/shell/ehStart.sh \; -print 2>/dev/null)
fi
```
- **`prods=$*`**: This assigns all script arguments (products) to the `prods` variable.
- **`if [ $# -eq 0 ]`**: If no arguments are passed, the script:
  - Navigates to the `PROD_BASE` directory.
  - Uses `find` to search through the product directories (e.g., `BP`, `CBRS`, etc.) and look for directories that have a script file `ehStart.sh` (an event handler script).
  - The result is stored in `prods`.
  - **Explanation**: If no specific product is provided, the script automatically searches for products with an event handler script.

### 6. **Loop over products and check for event handler**
```bash
for prod in $prods; do
    ps="$(ps -leaf | grep "$USER " | grep "${prod##*/}/valuesys/lib" | grep 'appName=event-handler' | grep -v grep)"
    if [ ! -z "$ps" ]
    then
        echo "$prod event handler running : ${ps%%-classpath*}"
    fi
```
- This loops through each product in `prods`:
  - **`ps`**: Runs a process search (`ps -leaf`) for each product, filtering for processes involving the `valuesys/lib` directory and event handlers (`appName=event-handler`).
  - If an event handler is found, the script prints the event handler information.
- **Explanation**: This checks if the event handler for each product is running.

### 7. **Check for other servers for the product**
```bash
    for app in $(ls -d ${PROD_BASE}/$prod/*/); do
        if [ -f ${app}shell/server.sh ]
        then
            ps="$(ps -leaf | grep "$USER " | grep "${app}lib" | grep -v 'appName=event-handler' | grep -v grep)"
            if [ ! -z "$ps" ]
            then
                echo "$app server running : ${ps%%-classpath*}"
            fi
        fi
    done
done
```
- This nested loop checks for other servers related to the current product:
  - **`ls -d ${PROD_BASE}/$prod/*/`**: Lists all directories under each product.
  - **`if [ -f ${app}shell/server.sh ]`**: Checks if there is a `server.sh` script in each subdirectory (`app`).
  - **`ps`**: Searches for any running servers related to that product’s subdirectory, excluding event handlers.
  - If a server is found, it prints information about the running server.

### **Summary**
- The script checks for running processes related to Tomcat, event handlers, and other servers for a set of products.
- It can be run with or without product arguments. Without arguments, it will search for products with an event handler script.
- The script uses `ps`, `grep`, and `find` commands extensively to search for and report the status of these services.


@@@@@@@@@
