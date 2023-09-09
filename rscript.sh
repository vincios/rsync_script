#!/bin/bash
LOGFILE=rsync.log
TASKSFILE=tasks.txt

backup () {
  # This function takes 4 parametes: 
  #   $1 is the source path
  #   $2 is the dest path
  #   $3 is the rsync's exclude arguments as a single string
  #   $4 is the rsync's include arguments as a single string
  # We use xargs to trim spaces
  sourcedir=$(echo -e "${1}" | xargs)
  destdir=$(echo -e "${2}" | xargs)
  excluded=$(echo -e "${3}" | xargs)
  included=$(echo -e "${4}" | xargs)

  echo "Backup $sourcedir to $destdir"
  rsync ${DRYRUNARG:+"$DRYRUNARG"} -avzhP --delete --log-file=$LOGFILE $included $excluded $sourcedir $destdir
}


backupfolder=""
destfolder=""
exclude_opts=""
include_opts=""

while read -r line; do
  if [[ $line = "->"* ]]  # if line starts with -> it is a new backup task
  then
    # then we set the variables for the new task
    backupfolder=$(echo -e "${line:2}" | xargs)  # remove the leading '->' and trim spaces
    destfolder=""
    exclude_opts=""
    include_opts=""

    echo -e "\nNew Task: $backupfolder"
  elif [[ $line = @* ]]
  then
    destfolder=$(echo -e "${line:1}" | xargs)  # remove the leading '@' character and trim spaces
  elif [[ $line = -* ]]
  then
    path=$(echo -e "${line:1}" | xargs)  # remove the leading '-' character and trim spaces
    exclude_opts+=" --exclude=$path"
  elif [[ $line = +* ]]
  then
    path=$(echo -e "${line:1}" | xargs)  # remove the leading '+' character and trim spaces
    exclude_opts+=" --include=$path"
  elif [[ $line = "<-"* ]]  # task end line: start the backup
  then
    if [ -z "$backupfolder" ]; then
      echo "Source dir not defined for this task. Skipped!"
    elif [ -z "$destfolder" ]; then
      echo "Dest dir not defined for task $sourcedir. Skipped!"
    elif [ -n "$backupfolder" ] && [ -n "$destfolder" ]; then
      backup $backupfolder $destfolder "${exclude_opts[@]}" "${include_opts[@]}"
    fi
  fi

done <$TASKSFILE
