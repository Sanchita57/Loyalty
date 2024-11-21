#!/bin/bash
echo "home:  <+exportedVariables.getValue("pipeline.alias.home")>"
echo "backup: <+exportedVariables.getValue("pipeline.alias.backup")>"


su - <+stage.variables.env_user> -c pwd
# Create a variable for the current date in the format YYYY-MM-DD
current_date=$(date +%Y-%m-%d)

# Create the backup directory
working_dir=<+exportedVariables.getValue("pipeline.alias.home")>/<+stage.variables.appname>
backup_dir="<+exportedVariables.getValue("pipeline.alias.backup")>/${current_date}"
su - <+stage.variables.env_user> -c "mkdir -p ${backup_dir}"

# Copy the contents of /apps/ to the backup directory
su - <+stage.variables.env_user> -c "cp -R <+exportedVariables.getValue("pipeline.alias.home")>/<+stage.variables.appname> \"${backup_dir}/\""

# Print a success message
echo "Backup of <+exportedVariables.getValue("pipeline.alias.home")>/<+stage.variables.appname> completed and copied to ${backup_dir}"
