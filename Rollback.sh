#!/bin/bash

echo "home:  <+exportedVariables.getValue("pipeline.alias.home")>"
echo "backup: <+exportedVariables.getValue("pipeline.alias.backup")>"

su - <+stage.variables.env_user> -c pwd

# Get the current date and set the backup directory path
current_date=$(date +%Y-%m-%d)

# Define the backup directory path (most recent backup date folder)
backup_dir="<+exportedVariables.getValue("pipeline.alias.backup")>"

# Find the latest backup directory
LATEST_BACKUP=$(ls -1d ${backup_dir}/*/ | sort -r | head -n 1)
if [ -z "$LATEST_BACKUP" ]; then
    echo "Error: No backup folders found in $backup_dir."
    exit 1
fi

echo "Found the latest backup directory: $LATEST_BACKUP"

# Extract the product folder (e.g., CBRS) from the backup directory
PRODUCT_BACKUP_DIR="${LATEST_BACKUP}/<+stage.variables.appname>"
if [ ! -d "$PRODUCT_BACKUP_DIR" ]; then
    echo "Error: No backup found for product: <+stage.variables.appname> under $PRODUCT_BACKUP_DIR."
    exit 1
fi

echo "Found backup directory for product: <+stage.variables.appname> at $PRODUCT_BACKUP_DIR"

# Clean the deployment directory (e.g., /apps/)
DEPLOY_DIR=<+exportedVariables.getValue("pipeline.alias.home")>/<+stage.variables.appname>
echo "Cleaning up deployment directory: $DEPLOY_DIR"
su - <+stage.variables.env_user> -c "rm -rf ${DEPLOY_DIR}/*"

# Copy the entire product folder from the latest backup to the deployment directory
echo "Restoring product folder from $PRODUCT_BACKUP_DIR to $DEPLOY_DIR"
su - <+stage.variables.env_user> -c "cp -r ${PRODUCT_BACKUP_DIR}/* ${DEPLOY_DIR}/"

# Check for tar files and extract if found
echo "Checking for tar files in the deployment directory..."

TAR_FOUND=false
for TAR_FILE in *.tar *.tar.gz *.tgz; do
    if [ -f "$TAR_FILE" ]; then
        TAR_FOUND=true
        echo "Untaring $TAR_FILE"
        su - <+stage.variables.env_user> -c "tar -xvzf $TAR_FILE"
    fi
done

# If no tar files were found, print a message
if [ "$TAR_FOUND" = false ]; then
    echo "No tar files found in the deployment directory."
fi

echo "Rollback completed for <+stage.variables.appname>. All artifacts have been restored and untarred if applicable."

#++++++++++++next to pick latest folder+++++++++++

#!/bin/bash
pwd
su - <+stage.variables.env_user> -c '
echo "home:  <+exportedVariables.getValue(\"pipeline.alias.home\")>"
echo "backup: <+exportedVariables.getValue(\"pipeline.alias.backup\")>"

# Create a variable for the current date in the format YYYY-MM-DD
current_date=$(date +%Y-%m-%d)

# Define the backup directory
backup_dir="<+exportedVariables.getValue(\"pipeline.alias.backup\")>/${current_date}/<+stage.variables.appname>"
to_delete_dir="<+exportedVariables.getValue(\"pipeline.alias.backup\")>/${current_date}"

# Define the working directory
working_dir="<+exportedVariables.getValue(\"pipeline.alias.home\")>/<+stage.variables.appname>"
echo "hi"

# Check if the backup directory exists
if [ -d "${backup_dir}" ]; then
  echo "Backup directory ${backup_dir} exists. Latest folder is not required."
else
  echo "Backup directory ${backup_dir} does not exist. Proceeding with rollback."

  # Check if the directory to be deleted exists
  if [ -d "<+exportedVariables.getValue(\"pipeline.alias.home\")>/<+stage.variables.appname>" ]; then
    # Delete the /apps/cbrs folder before rollback
    rm -rf <+exportedVariables.getValue(\"pipeline.alias.home\")>/<+stage.variables.appname>
    echo "Directory <+exportedVariables.getValue(\"pipeline.alias.home\")>/<+stage.variables.appname> has been deleted."
  else
    echo "Directory <+exportedVariables.getValue(\"pipeline.alias.home\")>/<+stage.variables.appname> does not exist. Nothing to delete."
  fi

  # Find the latest backup directory if today's backup is not found
  latest_backup_dir=$(ls -td <+exportedVariables.getValue(\"pipeline.alias.backup\")>/*/<+stage.variables.appname> | head -1)
  
  if [ -d "${latest_backup_dir}" ]; then
    echo "Using latest backup directory: ${latest_backup_dir}"
    cp -R ${latest_backup_dir}/* ${working_dir}/
    
    if [ $? -eq 0 ]; then
      echo "Rollback of ${working_dir} completed from ${latest_backup_dir}"
      echo "Unzipping .zip files ... "
      unzip -o ${working_dir}/*.zip -d ${working_dir}
      echo "Unzip completed !!"
    else
      echo "Rollback not done. Copy command failed."
    fi
  else
    echo "No backup directories found. Rollback failed."
  fi
fi
'
