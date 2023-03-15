#!/bin/bash
#goldyck@vmware.com

#This script adds a given number of ESXi hosts to an existing cPOD.

# $1 : Name of cpod to modify
# $2 : Number of ESXi hosts to add
# $3 : Name of owner

# source helper functions
. ./env
source ./extra/functions.sh

#logging what is this?
LOGGING="FALSE"
if [ -z "$LOGGING" ]
then
    echo "enabling logging"
    export LOGGING="TRUE"
    /usr/bin/script /tmp/scripts/test-$$-log.txt /bin/bash -c "$0 $*"
    exit 0
fi

#start the timer
START=$( date +%s )



#input validation check
if [ $# -ne 3 ]; then
  echo "usage: $0 <name_of_cpod>  <#esx to add> <name_of_owner>"
  echo "usage example: $0 LAB01 4 vedw" 
  exit 1  
fi

if [ -z "$1" ] || [ -z "$2"  ] || [ -z "$3"  ];then 
  echo "usage: $0 <name_of_cpod>  <#esx to add> <name_of_owner>"
  echo "usage example: $0 LAB01 4 vedw" 
  exit 1
fi

if [[ "$2" -ge 1 && "$2" -le 20 ]]; then
    echo "$2 is between 1 and 20"
else
    echo "$2 is not between 1 and 20, don't be greedy"
    exit 1
fi

if [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; then
  echo "You are running in a tmux session. That is very wise of you !  :)"
else
  echo "You are not running in a tmux session. Maybe you want to run this in a tmux session?"
  echo "stopping script because you're not in a TMUX session."
  exit 1
fi

#main code

#TODO check_space

#build the inputs

CPODNAME_LOWER=$( echo "${HEADER}-${1}" | tr '[:upper:]' '[:lower:]' )
NAME_UPPER=$( echo "${1}" | tr '[:lower:]' '[:upper:]' )
LASTNUMESX=$(get_last_ip  "esx"  "${CPODNAME_LOWER}")
STARTNUMESX=$(($LASTNUMESX-20+1))
NUM_ESX="${2}"
OWNER="${3}"
SUBNET=$( ./${COMPUTE_DIR}/cpod_ip.sh ${1} )
NEXT_IP="${SUBNET}.${STARTNUMESX}"
PORTGROUP_NAME="${CPODNAME_LOWER}"
TRANSIT_IP=$( cat /etc/hosts | grep ${CPODNAME_LOWER} | awk '{print $1}' )

#check for duplicate IP's 
for ((i=1; i<=${NUM_ESX}; i++)); do
  OCTET=$(($LASTNUMESX+$i))
  IP="${SUBNET}.${OCTET}"
  echo "checking for duplicate ip on $IP..."
  STATUS=$( ping -c 1 ${IP} 2>&1 > /dev/null ; echo $? )
  STATUS=$(expr $STATUS)
  if [ ${STATUS} == 0 ]; then
          echo "Error: Something has the same IP."
          exit 1
  fi
done

# have the hosts created with respool_create
echo "Adding $NUM_ESX ESXi hosts to $NAME_UPPER owned by $OWNER on portgroup: $PORTGROUP_NAME in domain: $ROOT_DOMAIN starting at: $STARTNUMESX."
#"${COMPUTE_DIR}"/create_resourcepool.sh "${NAME_UPPER}" "${PORTGROUP_NAME}" "${TRANSIT_IP}" "${NUM_ESX}" "${ROOT_DOMAIN}" "${OWNER}" "${STARTNUMESX}"

#update DNS cpodrouter

#end the timer and wrapup
END=$( date +%s )
TIME=$( expr "${END}" - "${START}" )

echo
echo "============================="
echo "===  creation is finished ==="
echo "=== In ${TIME} Seconds ==="
echo "============================="

export LOGGING=""