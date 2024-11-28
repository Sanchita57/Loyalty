#!/bin/bash

echo "Starting script..."
pwd
su - olmperfacct -c '
echo "home:  /tmp"
echo "backup: /tmp/backup"

# Create a variable for the current date in the format YYYY-MM-DD
current_date=$(date +%Y-%m-%d)
echo "Current date: ${current_date}"

# Define the backup directory
backup_dir="/tmp/backup/${current_date}/SC"
to_delete_dir="/tmp/backup/${current_date}"
echo "Backup directory: ${backup_dir}"
echo "To delete directory: ${to_delete_dir}"

# Define the working directory
working_dir="/tmp/SC"
echo "Working directory: ${working_dir}"
echo "hi"

# Check if the working directory exists
echo "Checking if working directory exists..."
if [ -d "${working_dir}" ]; then
  # Delete the working directory before rollback
  echo "Deleting working directory..."
  rm -rf "${working_dir}"
  echo "Directory ${working_dir} has been deleted."
else
  echo "Directory ${working_dir} does not exist. Nothing to delete."
fi

# Step 3: Check if the backup directory for the current date exists, otherwise use the latest backup directory
echo "Checking if backup directory exists..."
source_dir="${backup_dir}"
if [ ! -d "${backup_dir}" ]; then
  echo "Backup directory ${backup_dir} does not exist. Finding the latest backup directory..."
  latest_backup_dir=$(ls -td /tmp/backup/*/SC | head -1)
  if [ -d "${latest_backup_dir}" ]; then
    echo "Using latest backup directory: ${latest_backup_dir}"
    source_dir="${latest_backup_dir}"
  else
    echo "No backup directories found. Rollback failed."
    exit 1
  fi
fi

# Ensure the working directory exists before copying
mkdir -p "${working_dir}"

# Restore the contents of the backup directory to the working directory
cp -R ${source_dir}/* ${working_dir}/

# Check if the copy command was successful
if [ $? -eq 0 ]; then
  # Print a success message
  echo "Rollback of ${working_dir} completed from ${source_dir}"
  
  unzip -o ${working_dir}/*.zip -d ${working_dir}
  echo "Unzip completed !!"

  # Delete the backup directory if it is the current date's backup
  if [ "${source_dir}" == "${backup_dir}" ]; then
    rm -rf "${to_delete_dir}"
    echo "Backup directory ${to_delete_dir} has been deleted."
  fi
else
  # Print an error message if the copy command failed
  echo "Rollback not done. Copy command failed."
fi
'
echo "Script finished."




#

#!/bin/bash

echo "Starting script..."
pwd

su - olmperfacct -c '
echo "home: /tmp"
echo "backup: /tmp/backup"

# Create a variable for the current date in the format YYYY-MM-DD
current_date=$(date +%Y-%m-%d)
echo "Current date: ${current_date}"

# Define the backup directory
backup_dir="/tmp/backup/${current_date}/SC"
to_delete_dir="/tmp/backup/${current_date}"
echo "Backup directory: ${backup_dir}"
echo "To delete directory: ${to_delete_dir}"

# Define the working directory
working_dir="/tmp/SC"
echo "Working directory: ${working_dir}"
echo "hi"

# Check if the working directory exists
echo "Checking if working directory exists..."
if [ -d "${working_dir}" ]; then
  echo "Deleting working directory..."
  rm -rf "${working_dir}"
  echo "Directory ${working_dir} has been deleted."
else
  echo "Directory ${working_dir} does not exist. Nothing to delete."
fi

# Check if the backup directory for the current date exists
echo "Checking if backup directory exists..."
source_dir="${backup_dir}"
if [ ! -d "${backup_dir}" ]; then
  echo "Backup directory ${backup_dir} does not exist. Finding the latest backup directory..."
  latest_backup_dir=$(ls -td /tmp/backup/*/SC 2>/dev/null | head -1)

  # Ensure the latest backup directory exists and is not empty
  if [ -n "${latest_backup_dir}" ] && [ -d "${latest_backup_dir}" ] && [ "$(ls -A "${latest_backup_dir}")" ]; then
    echo "Using latest backup directory: ${latest_backup_dir}"
    source_dir="${latest_backup_dir}"
  else
    echo "No valid backup directories found. Rollback failed."
    exit 1
  fi
fi

# Ensure the working directory exists before copying
mkdir -p "${working_dir}"

# Restore the contents of the backup directory to the working directory
echo "Restoring files from ${source_dir} to ${working_dir}..."
cp -R "${source_dir}/"* "${working_dir}/"

if [ $? -eq 0 ]; then
  echo "Rollback of ${working_dir} completed from ${source_dir}"
  
  # Unzip any zip files in the working directory
  unzip -o "${working_dir}"/*.zip -d "${working_dir}"
  echo "Unzip completed."

  # Delete the backup directory if it is the current date's backup
  if [ "${source_dir}" == "${backup_dir}" ]; then
    echo "Deleting current date's backup directory: ${to_delete_dir}..."
    rm -rf "${to_delete_dir}"
    echo "Backup directory ${to_delete_dir} has been deleted."
  fi
else
  echo "Rollback not done. Copy command failed."
fi
'
echo "Script finished."

))))))))

#!/bin/bash

echo "Starting script..."
pwd

su - olmperfacct -c '
echo "home: /tmp"
echo "backup: /tmp/backup"

# Create a variable for the current date in the format YYYY-MM-DD
current_date=$(date +%Y-%m-%d)
echo "Current date: ${current_date}"

# Define the backup directory
backup_dir="/tmp/backup/${current_date}/SC"
to_delete_dir="/tmp/backup/${current_date}/SC"
echo "Backup directory: ${backup_dir}"
echo "To delete directory: ${to_delete_dir}"

# Define the working directory
working_dir="/tmp/SC"
echo "Working directory: ${working_dir}"

# Check if the working directory exists
echo "Checking if working directory exists..."
if [ -d "${working_dir}" ]; then
  echo "Deleting working directory..."
  rm -rf "${working_dir}"
  echo "Directory ${working_dir} has been deleted."
else
  echo "Directory ${working_dir} does not exist. Nothing to delete."
fi

# Check if the backup directory for the current date exists
echo "Checking if backup directory exists..."
source_dir="${backup_dir}"
if [ ! -d "${backup_dir}" ]; then
  echo "Backup directory ${backup_dir} does not exist. Finding the latest backup directory..."
  latest_backup_dir=$(ls -td /tmp/backup/*/SC 2>/dev/null | head -1)

  # Ensure the latest backup directory exists and is not empty
  if [ -n "${latest_backup_dir}" ] && [ -d "${latest_backup_dir}" ] && [ "$(ls -A "${latest_backup_dir}")" ]; then
    echo "Using latest backup directory: ${latest_backup_dir}"
    source_dir="${latest_backup_dir}"
    to_delete_dir="${latest_backup_dir}"
  else
    echo "No valid backup directories found. Rollback failed."
    exit 1
  fi
fi

# Ensure the working directory exists before copying
mkdir -p "${working_dir}"

# Restore the contents of the backup directory to the working directory
echo "Restoring files from ${source_dir} to ${working_dir}..."
cp -R "${source_dir}/"* "${working_dir}/"

if [ $? -eq 0 ]; then
  echo "Rollback of ${working_dir} completed from ${source_dir}"

  # Unzip any zip files in the working directory
  echo "Checking for zip files to unzip..."
  if ls "${working_dir}"/*.zip 1> /dev/null 2>&1; then
    unzip -o "${working_dir}"/*.zip -d "${working_dir}"
    echo "Unzip completed."
  else
    echo "No zip files found to unzip."
  fi

  # Delete only the folder used for rollback (not the entire backup directory)
  echo "Deleting backup folder used for rollback: ${to_delete_dir}..."
  rm -rf "${to_delete_dir}"
  if [ $? -eq 0 ]; then
    echo "Backup folder ${to_delete_dir} has been deleted."
  else
    echo "Failed to delete backup folder ${to_delete_dir}. Please check permissions."
  fi
else
  echo "Rollback not done. Copy command failed."
fi
'
echo "Script finished."





