DIRNAME=`dirname $0`
PROGNAME=`basename $0`
if [ $# -gt 0 ];  then
  echo "stopTomcat.sh expects to find CATALINA_HOME ($CATALINA_HOME) and CATALINA_BASE ($CATALINA_BASE)"
  echo "if not setup CATALINA_BASE will be set to ${PROD_BASE} and if not that then $HOME"
  echo "if not setup CATALINA_HOME will be set by searching for apache-tomcat-9, first in $HOME and if not found in /usr_local"
  echo ""
  echo "The tomcat instance in CATALINA_BASE ($CATALINA_BASE) will be shutdown"
  exit 1
fi

if [ "x$CATALINA_BASE" = "x" ]; then
        if [ "x${PROD_BASE}" = "x" ]; then
                export PROD_BASE=$HOME
        fi
    export CATALINA_BASE=`cd ${PROD_BASE};pwd`
fi

if [ "x$CATALINA_HOME" = "x" ]; then
        export CATALINA_HOME=$(find $HOME -name 'apache-tomcat-9*')
fi
if [ "x$CATALINA_HOME" = "x" ]; then
       ln -s $(find /usr/local -name 'apache-tomcat-*' 2>/dev/null | head -1) $HOME
       export CATALINA_HOME=$(find $HOME -name 'apache-tomcat-9*')
fi


@@@@
Let’s walk through the stopTomcat.sh script step by step. This script is designed to stop a running Tomcat server instance by ensuring that CATALINA_HOME and CATALINA_BASE are correctly set, either through existing environment variables or by determining appropriate paths.

1. Initialize Variables

DIRNAME=`dirname $0`
PROGNAME=`basename $0`

	•	DIRNAME: Stores the directory path where the script is located.
	•	PROGNAME: Stores the name of the script (stopTomcat.sh).

2. Check for Arguments and Provide Usage Information

if [ $# -gt 0 ]; then
  echo "stopTomcat.sh expects to find CATALINA_HOME ($CATALINA_HOME) and CATALINA_BASE ($CATALINA_BASE)"
  echo "if not setup CATALINA_BASE will be set to ${PROD_BASE} and if not that then $HOME"
  echo "if not setup CATALINA_HOME will be set by searching for apache-tomcat-9, first in $HOME and if not found in /usr_local"
  echo ""
  echo "The tomcat instance in CATALINA_BASE ($CATALINA_BASE) will be shutdown"
  exit 1
fi

	•	$# -gt 0: Checks if any arguments were passed to the script.
	•	If there are arguments, the script prints information about the required environment variables (CATALINA_HOME and CATALINA_BASE) and how they are set if not defined. The script then exits.
	•	Explanation: This ensures the user knows the expectations before proceeding and stops execution if unnecessary arguments are passed.

3. Set CATALINA_BASE if Not Already Defined

if [ "x$CATALINA_BASE" = "x" ]; then
    if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
    fi
    export CATALINA_BASE=`cd ${PROD_BASE};pwd`
fi

	•	Check if CATALINA_BASE is set:
	•	If CATALINA_BASE is not already defined, the script checks if PROD_BASE is set.
	•	If PROD_BASE is not set, it defaults to the user’s home directory ($HOME).
	•	CATALINA_BASE: It is set to the absolute path of PROD_BASE.
	•	Explanation: This ensures that CATALINA_BASE is defined, pointing to the base directory where the Tomcat instance resides. If neither CATALINA_BASE nor PROD_BASE is set, it defaults to $HOME.

4. Set CATALINA_HOME if Not Already Defined

if [ "x$CATALINA_HOME" = "x" ]; then
    export CATALINA_HOME=$(find $HOME -name 'apache-tomcat-9*')
fi

	•	Check if CATALINA_HOME is set:
	•	If CATALINA_HOME is not already defined, the script searches the user’s home directory ($HOME) for any directory named apache-tomcat-9* (Tomcat version 9).
	•	CATALINA_HOME: If a match is found, it is set to the directory path of Tomcat.
	•	Explanation: This attempts to automatically find the Tomcat installation in the user’s home directory.

5. Fallback Search for CATALINA_HOME

if [ "x$CATALINA_HOME" = "x" ]; then
    ln -s $(find /usr/local -name 'apache-tomcat-*' 2>/dev/null | head -1) $HOME
    export CATALINA_HOME=$(find $HOME -name 'apache-tomcat-9*')
fi

	•	Fallback search:
	•	If CATALINA_HOME is still not set, the script looks for apache-tomcat-* (any version) in /usr/local.
	•	ln -s: If found, it creates a symbolic link to the Tomcat directory in the user’s home directory.
	•	find $HOME: It then searches again in the user’s home directory for apache-tomcat-9* to set CATALINA_HOME.
	•	Explanation: This provides a fallback mechanism to locate a Tomcat installation if it wasn’t found in the user’s home directory. It searches in /usr/local, which is a common location for Tomcat installations, and creates a symbolic link in $HOME to simplify future access.

Summary

This script ensures that the environment is correctly set up for stopping a Tomcat server. It checks if CATALINA_HOME and CATALINA_BASE are defined and, if not, it sets them based on default paths or searches for existing Tomcat installations. This way, the script can reliably locate and stop the Tomcat instance, even if the environment variables are not pre-configured by the user.
@@@@
