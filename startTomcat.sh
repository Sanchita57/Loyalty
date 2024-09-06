DIRNAME=`dirname $0`
PROGNAME=`basename $0`
list="BP CBRS LEM LUMC RN SC"
if [ $# -gt 0 ] && [[ ! " $list " =~ .*\ $1\ .* ]]
then
  echo "startTomcat.sh will verify the configuration expecting to find CATALINA_HOME ($CATALINA_HOME) and CATALINA_BASE ($CATALINA_BASE)"
  echo "if not setup CATALINA_BASE will be set to ${PROD_BASE} or if not set to$HOME"
  echo "if not setup CATALINA_HOME will be set by searching for apache-tomcat-9, first in $HOME and if not found in /usr_local"
  echo ""
  echo "if one or more <product> name arguments is passed webapps will be reconstructed"
  echo "        for a single product CATALINA_BASE/webapps will be linked to ~/<product>/webapps"
  echo "        for a multiple products each ~/<product>/webapps/*.war will be copied to CATALINA_BASE/webapps"
  echo "    the ROOT and manager folders from CATALINA_HOME/webapps are lined to linked CATALINA_BASE/webapps"
  echo "The following environment settings are also used"
  echo "        DEFAULT_APPS - a list of app locations to link in to webapps"
  echo "    could be used for the ROOT and manager folders from CATALINA_HOME/webapps"
  echo ""
  echo "if no arguments are passed and the configuration looks viable tomcat is started without change"
 exit 1

fi

if [ "x$CATALINA_BASE" = "x" ]; then
        if [ "x${PROD_BASE}" = "x" ]; then
                export PROD_BASE=$HOME
        fi
    export CATALINA_BASE=`cd ${PROD_BASE};pwd`
fi
echo $HOME $PROD_BASE $CATALINA_BASE $*
if [ "x$CATALINA_HOME" = "x" ]; then
        export CATALINA_HOME=$(find $HOME -name 'apache-tomcat-9*')
fi
if [ "x$CATALINA_HOME" = "x" ]; then
       ln -s $(find /usr/local -name 'apache-tomcat-*' 2>/dev/null | head -1) $HOME
       export CATALINA_HOME=$(find $HOME -name 'apache-tomcat-9*')
fi
if [ ! -f $CATALINA_BASE/conf/server.xml ] || [ ! -f $CATALINA_BASE/conf/catalina.properties ]; then
  echo "CATALINA_BASE - $CATALINA_BASE does not contain the required files in conf folder"
  echo "copy conf from $CATALINA_HOME to $CATALINA_BASE and edit files for this instance"
  echo "specifically add <product>config=<product>/<product>config/<configuration> for this instance"
  echo "        <product> is one of BP,CBRS,LEM,LUMC,RN or SC"
  echo "        <configuration> is one of production,dr,uat or qa (or similar)"
 exit 1
fi
if [ $# -gt 0 ]
then
  echo cleaning $CATALINA_BASE/webapps
  rm $CATALINA_BASE/webapps 2>/dev/null
  rm -fr $CATALINA_BASE/webapps $CATALINA_BASE/work 2>/dev/null
fi
if [ $# -eq 1 ]
then
        echo adding $1
        ln -s ${PROD_BASE}/$1/webapps $CATALINA_BASE
        if [ "$(grep ${1}config= $CATALINA_BASE/conf/catalina.properties | wc -l)" = "0" ]
        then
                echo "please add ${1}config=${PROD_BASE}/${1}/${1}config/<configuration> to $CATALINA_BASE/conf/catalina.properties"
        fi
fi

if [ $# -gt 1 ]
then
        echo linking $*
        mkdir $CATALINA_BASE/webapps
        for prod in $*
        do
                for app in $(ls ${PROD_BASE}/$prod/webapps/*.war)
                do
                        echo adding $app
                        cp -p $app $CATALINA_BASE/webapps
                done
                if [ "$(grep ${prod}config= $CATALINA_BASE/conf/catalina.properties | wc -l)" = "0" ]
                then
                        echo "please add ${prod}config=${PROD_BASE}/${prod}/${prod}config/<configuration> to $CATALINA_BASE/conf/catalina.properties"
                fi
        done
fi
if [ "x$DEFAULT_APPS" != "x" ]
then
        for app in $DEFAULT_APPS; do
                ln -s $APP $CATALINA_BASE/webapps
        done
fi
if [ $# -gt 0 ]
then
        echo "webapps contains : $(ls $CATALINA_BASE/webapps)"

fi
if [ $(grep 'config=' $CATALINA_BASE/conf/catalina.properties | wc -l) -eq 0 ]
then
        echo "please add config properties to $CATALINA_BASE/conf/catalina.properties"
        exit 1
fi
if [[ "x$(ls $CATALINA_BASE/lib 2>/dev/null)" = "x" ]]
then
        ln -s ${GIT_BASE}/git/LTYconfig/web/WEB-INF/lib $CATALINA_BASE
        ls $CATALINA_BASE/lib
fi
if [ "x$CATALINA_TMPDIR" = "x" ]
then
        export CATALINA_TMPDIR=/tmp
        echo set CATALINA_TMPDIR=$CATALINA_TMPDIR
fi
mkdir -p $CATALINA_BASE/logs

$CATALINA_HOME/bin/startup.sh
