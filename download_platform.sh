#!/bin/bash
DIRNAME=`dirname $0`
PROGNAME=`basename $0`

if [ $# -lt 2 ]
then
  echo "download.sh requires 2 and has 1 conditional and 1 optional arguments :"
  echo "        prod being one of BP CBRS LEM LUMC RN SC (ALL will download all products)"
  echo "        tag - the TAG or BRANCH for the build required"
  echo "        conf - the configuration to be used unless CONF is set externally"
  echo "        unzip - the unzip options can be set (combinations of -f -o -q)  overwriting UNZIP_OPTS "
  echo ""
  echo "The following environment settings are also used"
  echo "        proxy - needed for artifactory suggested value: proxy.fisdev.local:8080"
  echo "        CREDS - if provided will stop the script using logged in user and prompting for password,"
  echo "            needed by proxy and artifactory possible values:"
  echo "                <userid>  - password will be requested when needed"
  echo "                <userid>:<password>"
  echo "                svcacct-loyaltybuild:<service user password>"
  echo "        CONF can set a default value for conf argument (e.g. qa or uat)"
  echo "        UNZIP_OPTS can set a default value for unzip argument (e.g. -foq freshen-up,overwrite,quietly)"
  echo "        LOYALTY_PRODUCTS can set list of PRODUCTS for ALL if not the full LIST above"
 exit 1
fi
if [ $# -lt 3 ] && [ "x$CONF" = "x" ]
then
  echo "Warning no configuration has been selected"
  echo ""
fi
if [ "x$CREDS" = "x" ]
then
        mytty=$(tty)
        mytty=${mytty##*dev/}
        u=$(w | grep "$mytty "| cut -d" " -f1)
        echo "Enter password for $u :"
        read -s p
        export CREDS=$u:$p
fi
if [ "x${CREDS%:*}" = "x${CREDS}" ]
then
        echo "Enter password for $CREDS :"
        read -s p
        export CREDS=$CREDS:$p
fi
export PROD=$1
shift 1
if [ "x$PROD" = "xALL" ]
then
        if [ "x$LOYALTY_PRODUCTS" = "x" ]
        then
                LOYALTY_PRODUCTS="CBRS BP LEM LUMC RN SC"
        fi
        for prod in $LOYALTY_PRODUCTS
        do
          download.sh $prod $*
        done
        exit 1
fi
export TAG=$1
shift 1
if [ $# -gt 0 ]
then
        export CONF=$1
        shift 1
        if [ $# -gt 0 ]
        then
                export UNZIP_OPTS=$1
                shift 1
fi
fi
export DIR=..
if [ $# -gt 0 ]
then
        export DIR=$1
fi
echo $DIRNAME $PROGNAME $PROD $TAG
if [ "x${GIT_BASE}" = "x" ]; then
        export GIT_BASE=$HOME
fi
if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
fi
mkdir -p ${PROD_BASE}/$PROD
(
        cd ${PROD_BASE}/$PROD
        echo curl -u ${CREDS/:*/:***************} -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O
        curl -u $CREDS -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O
        rm -fr */lib webapps
        unzip $UNZIP_OPTS ${PROD}-$TAG.zip
        rm -fr sql
        unzip -o valuesys/lib/*-persistence-*.jar '*.sql'

        if [ "x$CONF" = "x" ]
        then
                exit 0
        fi
        if [ "x$CONF" = "xnone" ] || [ "x$CONF" = "xtest" ]
        then
                # link in the dummy configuration for the product
                ln -s ${GIT_BASE}/git/LTYconfig/${PROD}config .
        else
                echo curl -u ${CREDS/:*/:***************} -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/${PROD}config/${PROD}config.$CONF-$TAG.zip -L -O
                curl -u $CREDS -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/${PROD}config/${PROD}config.$CONF-$TAG.zip -L -O
                unzip $UNZIP_OPTS ${PROD}config.$CONF-$TAG.zip
        fi
        if [[ " production dr test " =~ .*\ $CONF\ .* ]]
        then
                for exclude in $(cat productionExclusions.txt); do
                        rm -f $exclude
                done;
        fi
)


@@@@

This script is designed to download and configure product builds from an artifactory using `curl` and process the downloaded files. Here's a brief explanation of the key sections and commands:

### 1. **Script Initialization**
- `#!/bin/bash`: Specifies the script is to be run using the Bash shell.
- `DIRNAME=$(dirname $0)` and `PROGNAME=$(basename $0)`: Get the directory and script filename, respectively.

### 2. **Argument Check**
- `if [ $# -lt 2 ]`: Checks if fewer than 2 arguments are provided. If so, the script displays usage instructions and exits.
  - Expected arguments:
    - `prod`: Product name (BP, CBRS, LEM, LUMC, RN, SC).
    - `tag`: Build tag or branch for the download.
    - Optional: `conf` (configuration) and `unzip` (unzip options).
- If fewer than 3 arguments and `CONF` is not set, a warning about missing configuration is shown.

### 3. **Handling Credentials**
- `if [ "x$CREDS" = "x" ]`: If `CREDS` is not set, the script prompts for a username and password and sets `CREDS` accordingly.
  - `mytty=$(tty)`: Gets the current terminal.
  - `u=$(w | grep "$mytty" | cut -d" " -f1)`: Extracts the current username.
  - `read -s p`: Reads the password securely without echoing it.
  - `export CREDS=$u:$p`: Exports `CREDS` with the username and password.

### 4. **Handling Multiple Products (`ALL`)**
- If `prod` is set to `ALL`, the script checks if `LOYALTY_PRODUCTS` is set, otherwise defaults to `CBRS BP LEM LUMC RN SC`.
- It loops through each product in `LOYALTY_PRODUCTS` and calls the script recursively for each product.

### 5. **Argument Parsing**
- The first argument is set as `PROD`, and subsequent arguments are used for `TAG`, `CONF`, and `UNZIP_OPTS`.
- If additional arguments exist, they are used to set `DIR`, which defaults to `..`.

### 6. **Download and Unzip Artifacts**
- `mkdir -p ${PROD_BASE}/$PROD`: Creates a directory for the product.
- `cd ${PROD_BASE}/$PROD`: Changes to the product's directory.
- `curl -u $CREDS -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O`: Uses `curl` to download the product zip file from the artifactory with:
  - `-u $CREDS`: Username and password for authentication.
  - `-x $proxy`: Proxy server configuration.
  - `-L`: Follows redirects.
  - `-O`: Saves the file with the same name as the remote file.
- `rm -fr */lib webapps`: Deletes specific directories (`lib`, `webapps`).
- `unzip $UNZIP_OPTS ${PROD}-$TAG.zip`: Unzips the downloaded product zip file with provided unzip options.

### 7. **Additional Unzip Operations**
- `rm -fr sql`: Removes the `sql` directory.
- `unzip -o valuesys/lib/*-persistence-*.jar '*.sql'`: Unzips `.sql` files from a JAR file inside the product directory.

### 8. **Configuration Download**
- If `CONF` is provided:
  - If `CONF` is set to `none` or `test`, it links to a dummy configuration (`ln -s ${GIT_BASE}/git/LTYconfig/${PROD}config`).
  - Otherwise, the configuration zip file is downloaded using `curl` from the artifactory and unzipped with the same logic as above.

### 9. **Exclusion Handling for Production**
- If `CONF` is set to `production`, `dr`, or `test`, the script removes files listed in `productionExclusions.txt` to exclude specific files from the final product.

### Key Commands Explanation:
- **`curl -u $CREDS`**: Downloads files from a URL with authentication and proxy support.
- **`unzip`**: Extracts the contents of a zip file. Options like `-o` (overwrite) or `-q` (quiet) can be set via `UNZIP_OPTS`.
- **`rm -fr`**: Removes files or directories forcefully (`-f`) and recursively (`-r`).
- **`ln -s`**: Creates symbolic links to the configuration directory.

### Summary:
This script automates the process of downloading product builds and their configurations, extracting the necessary files, and applying additional configurations based on the provided arguments and environment variables.
@@@@

