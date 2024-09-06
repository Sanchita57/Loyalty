#!/bin/bash
if [ $# -lt 3 ]
then
  echo "executeDBscript.sh requires at least 3 arguments :"
  echo "  PRODUCT - Loyalty Product"
  echo "  COMMAND - flyway command to execute"
  echo "  ENV - Environment (qa/uat/prod)"
  echo "Exiting..."
  exit 1
fi

PRODUCT=$1
if [ $PRODUCT != 'CBRS' ] && [ $PRODUCT != 'BP' ] && [ $PRODUCT != 'LEM' ] && [ $PRODUCT != 'LUMC' ] && [ $PRODUCT != 'RN' ] &&  [ $PRODUCT != 'SC' ]
then
  echo "No matching loyalty product specified. Specify one of the below commands."
  echo "  CBRS BP LEM LUMC RN SC"
  echo "Exiting..."
  exit 1
fi

COMMAND=$2
if [ $COMMAND != 'baseline' ] && [ $COMMAND != 'migrate' ] && [ $COMMAND != 'repair' ] && [ $COMMAND != 'info' ] && [ $COMMAND != 'validate' ] && [ $COMMAND != 'undo' ]
then
  echo "No matching command specified. Specify one of the below commands."
  echo "  baseline - baseline an existing database"
  echo "  migrate - migrate database to the latest version"
  echo "  repair - repair schema history table"
  echo "  info - print status about all migrations"
  echo "  validate - validates applied migrations against available ones"
  echo "  undo - undoes the most recently applied versioned migration."
  echo "Exiting..."
  exit 1
fi

ENV=$3

if [ "x${PROD_BASE}" = "x" ]; then
  export PROD_BASE=$HOME
fi

cd /usr/local/loyalty/flyway-9.5.1
echo "Start executing DB scripts...$FLYWAY_USER"

if [ "x${FLYWAY_USER}" = "x" ] || [ "x${FLYWAY_PASSWORD}" = "x" ]; then
	./flyway $COMMAND -configFiles=$PROD_BASE/$PRODUCT/${PRODUCT}config/$ENV/cfg/flyway.conf
else
	./flyway $COMMAND -configFiles=$PROD_BASE/$PRODUCT/${PRODUCT}config/$ENV/cfg/flyway.conf -user=$FLYWAY_USER -password=$FLYWAY_PASSWORD
fi

echo "Done executing DB scripts."


@@@@@
Here’s a detailed breakdown of the executeDBscript.sh script, which is designed to execute Flyway database migration commands based on provided arguments.

1. Check Argument Count

if [ $# -lt 3 ]
then
  echo "executeDBscript.sh requires at least 3 arguments :"
  echo "  PRODUCT - Loyalty Product"
  echo "  COMMAND - flyway command to execute"
  echo "  ENV - Environment (qa/uat/prod)"
  echo "Exiting..."
  exit 1
fi

	•	Argument Check:
	•	Ensures that at least three arguments are provided.
	•	Arguments required:
	•	PRODUCT: Loyalty product name.
	•	COMMAND: Flyway command to execute.
	•	ENV: Environment (e.g., qa, uat, prod).
	•	If not enough arguments are provided, it prints an error message and exits.

2. Validate PRODUCT Argument

PRODUCT=$1
if [ $PRODUCT != 'CBRS' ] && [ $PRODUCT != 'BP' ] && [ $PRODUCT != 'LEM' ] && [ $PRODUCT != 'LUMC' ] && [ $PRODUCT != 'RN' ] &&  [ $PRODUCT != 'SC' ]
then
  echo "No matching loyalty product specified. Specify one of the below commands."
  echo "  CBRS BP LEM LUMC RN SC"
  echo "Exiting..."
  exit 1
fi

	•	Product Validation:
	•	Validates that the PRODUCT argument matches one of the predefined loyalty products.
	•	If the product is invalid, it prints valid options and exits.

3. Validate COMMAND Argument

COMMAND=$2
if [ $COMMAND != 'baseline' ] && [ $COMMAND != 'migrate' ] && [ $COMMAND != 'repair' ] && [ $COMMAND != 'info' ] && [ $COMMAND != 'validate' ] && [ $COMMAND != 'undo' ]
then
  echo "No matching command specified. Specify one of the below commands."
  echo "  baseline - baseline an existing database"
  echo "  migrate - migrate database to the latest version"
  echo "  repair - repair schema history table"
  echo "  info - print status about all migrations"
  echo "  validate - validates applied migrations against available ones"
  echo "  undo - undoes the most recently applied versioned migration."
  echo "Exiting..."
  exit 1
fi

	•	Command Validation:
	•	Checks that the COMMAND argument is one of the valid Flyway commands.
	•	If the command is invalid, it prints valid options and exits.

4. Set Environment Variable

ENV=$3

if [ "x${PROD_BASE}" = "x" ]; then
  export PROD_BASE=$HOME
fi

	•	Environment Variable:
	•	Sets the ENV variable from the third argument.
	•	If PROD_BASE is not set, defaults it to $HOME.

5. Execute Flyway Command

cd /usr/local/loyalty/flyway-9.5.1
echo "Start executing DB scripts...$FLYWAY_USER"

if [ "x${FLYWAY_USER}" = "x" ] || [ "x${FLYWAY_PASSWORD}" = "x" ]; then
	./flyway $COMMAND -configFiles=$PROD_BASE/$PRODUCT/${PRODUCT}config/$ENV/cfg/flyway.conf
else
	./flyway $COMMAND -configFiles=$PROD_BASE/$PRODUCT/${PRODUCT}config/$ENV/cfg/flyway.conf -user=$FLYWAY_USER -password=$FLYWAY_PASSWORD
fi

echo "Done executing DB scripts."

	•	Change Directory:
	•	Navigates to the Flyway installation directory.
	•	Print Start Message:
	•	Prints a message indicating that DB scripts execution is starting, showing the FLYWAY_USER if set.
	•	Run Flyway Command:
	•	Executes the Flyway command with the appropriate configuration file.
	•	If FLYWAY_USER and FLYWAY_PASSWORD are set, includes them in the command; otherwise, runs the command without authentication.
	•	Print Completion Message:
	•	Prints a message indicating that the DB scripts execution is complete.

In summary, this script checks the validity of the provided arguments, sets up necessary environment variables, and then executes a Flyway command based on the provided product, command, and environment settings.
@@@@@
