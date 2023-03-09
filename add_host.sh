#!/bin/bash
#goldyck@vmware.com

#This script adds a given number of ESXi hosts to an existing cPOD.

# $1 : Name of cpod to modify
# $2 : Number of ESXi hosts to add
# $3 : Name of owner

#logging
if [ -z "$LOGGING" ]
then
    echo "enabling logging"
    export LOGGING="TRUE"
    /usr/bin/script /tmp/scripts/test-$$-log.txt /bin/bash -c "$0 $*"
    exit 0
fi

#start the timer
START=$( date +%s )

#sanity check
[ "$1" == "" -o "$2" == ""  -o "$3" == ""  ] && echo "usage: $0 <name_of_cpod>  <#esx> <name_of_owner>"  && echo "usage example: $0 LAB01 4 vedw" && exit 1

if [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; then
  echo "You are running in a tmux session. That is very wise of you !  :)"
else
  echo "You are not running in a tmux session. Maybe you want to run this in a tmux session?"
  echo "stopping script because you're not in a TMUX session."
  exit
fi

#main code

#TODO function - exit gate?
check_space ${1} ${3}

#build the inputs
#COMPUTE_DIR=""
NAME_UPPER=$( echo ${1} | tr '[:lower:]' '[:upper:]' )
NEXT_IP="" #this will  be fun
NUM_ESX="${2}"
#ROOT_DOMAIN=""
OWNER="$3"
STARTNUMESX="" #this will also be fun

# have the hosts created with respool_create
# how are other var's filled in create_resourcepool.ps1???
${COMPUTE_DIR}/create_resourcepool.sh ${NAME_UPPER} ${PORTGROUP_NAME} ${NEXT_IP} ${NUM_ESX} ${ROOT_DOMAIN} ${OWNER} ${STARTNUMESX}

#update DNS cpodrouter

#end the timer and wrapup
END=$( date +%s )
TIME=$( expr ${END} - ${START} )

echo
echo "============================="
echo "===  creation is finished ==="
echo "=== In ${TIME} Seconds ==="
echo "============================="

export LOGGING=""