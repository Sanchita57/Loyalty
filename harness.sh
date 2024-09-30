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
#if [ "x$CREDS" = "x" ]
#then
#       mytty=$(tty)
#       mytty=${mytty##*dev/}
#       u=$(w | grep "$mytty "| cut -d" " -f1)
#       echo "Enter password for $u :"
#       read -s p
#       export CREDS=$u:$p
#fi
#if [ "x${CREDS%:*}" = "x${CREDS}" ]
#then
#       echo "Enter password for $CREDS :"
#       read -s p
#       export CREDS=$CREDS:$p
#fi
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
export Username=$1
shift 1
export Password=$1
shift 1

echo $DIRNAME $PROGNAME $PROD $TAG
if [ "x${GIT_BASE}" = "x" ]; then
        export GIT_BASE=$HOME
fi
if [ "x${PROD_BASE}" = "x" ]; then
        export PROD_BASE=$HOME
fi
mkdir -p /tmp/$PROD
(
        cd /tmp/$PROD
echo "$Username"
echo "$Password"
        echo curl -u ${CREDS/:*/:***************} -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O
        curl -v -u svcacct-san:san123 --retry 20 --retry-delay 60 -x $proxy https://artifactory.fis.dev/artifactory/lty-generic-dev/$PROD/$PROD-$TAG.zip -L -O --connect-timeout 300 --max-time 7200
)


&&&&&&
This Bash script is designed to **download files** (likely product build artifacts) from an artifactory using `curl`. Here's a concise breakdown of its structure and commands:

### 1. **Script Initialization**
   - `#!/bin/bash`: Defines the script interpreter.
   - `DIRNAME=$(dirname $0)`, `PROGNAME=$(basename $0)`: Capture the directory and filename of the running script.
   
### 2. **Argument Check**
   - The script checks if there are at least 2 arguments (`prod` and `tag`). If not, it exits with instructions on usage.
   - `prod`: Specifies the product to download.
   - `tag`: Specifies the build version (TAG or BRANCH).
   - `conf` and `unzip`: Optional arguments for configuration and unzip options.
   - Environmental variables (`proxy`, `CREDS`, `CONF`, `UNZIP_OPTS`, etc.) can also be used for customization.

### 3. **Missing Configuration
Here's the remainder of the explanation:

### 3. **Missing Configuration Warning**
   - If no `conf` argument is passed and `CONF` is not set externally, a warning is printed indicating that no configuration has been selected.

### 4. **Handling Credentials (Commented Out)**
   - The script contains commented-out sections related to handling credentials (`CREDS`). If not provided, the script would ask the user for credentials and set them. This part is disabled by default.

### 5. **Handling `ALL` Products**
   - If `prod` is set to "ALL", it checks the `LOYALTY_PRODUCTS` variable. If not set, it defaults to "CBRS BP LEM LUMC RN SC".
   - It loops through each product in the list and recursively calls `download.sh` for each product with the same arguments.

### 6. **Handling Arguments**
   - If arguments for `tag`, `conf`, and `unzip` options are provided, they are assigned to environment variables.
   - The default download directory is set to `DIR=..`, but this can be overridden by additional arguments.

### 7. **Download Logic**
   - The script creates a directory under `/tmp/$PROD` for the product.
   - It uses `curl` to download a `.zip` file from the specified artifactory using the provided credentials (`CREDS`), `proxy`, and `tag`.
   - The command runs with options such as retry attempts, delay, and timeouts to ensure reliability during the download.

### 8. **Key Commands**
   - `curl -u ${CREDS/:*/:***************}`: Uses `CREDS` to download the file while masking the password in the output.
   - `--retry 20 --retry-delay 60`: Retry the download up to 20 times with a 60-second delay between retries.
   - `--connect-timeout 300 --max-time 7200`: Sets timeouts to handle long-running downloads.

### 9. **Environment Variables**
   - `PROD`, `TAG`, `CONF`, `UNZIP_OPTS`, `DIR`, `Username`, `Password`: The script heavily relies on these variables, which can be set through arguments or defaults.

### Summary:
This script downloads product build artifacts from an artifactory using `curl`, handling authentication and proxy settings. It supports multiple products, configuration options, and retries to ensure
&&&&&&
