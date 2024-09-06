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
