#!/bin/bash

## Icinga plugin to check for hosts missing from icinga configuration
## Thomas Widhalm (C) 2013. This script is released and distributed under the terms of the GNU General Public License.

# tr [:blank:] \\n | sort | uniq -u

### global variables ###

version=0.1

### functions ###

## show_version ##

# simply prints the version

show_version() {
  echo "Version: ${version}"
  exit 0
}

## show_help ##

# print help

show_help() {
  echo "

Usage:
  -s first 3 triples of subnet to scan (by now only 255.255.255.0 netmask is supported)
  -i path to icinga.cfg
  -h show this help
  -V print version information

"
exit 0
}


### reading arguments ###


OPTSTR=s:i:Vh

while getopts ${OPTSTR} SWITCHVAR
do
  case ${SWITCHVAR} in
    s) SUBNET_TO_SCAN=${OPTARG};;
    i) ICINGA_CONFIG=${OPTARG};;
    h) show_help;;
    V) show_version;;
  esac
done

#SUBNET_TO_SCAN=$1
IP_RANGE_TO_SCAN=${SUBNET_TO_SCAN}.1-254

### initializing other variables ###

OUTPUT=""

### intial checks ###

if [[ -z ${SUBNET_TO_SCAN} ]]
then
  echo "Please specify a subnet to scan with -s"
  exit 3
fi

if [[ -z ${ICINGA_CONFIG} ]]
then
  echo "Please specify a valid icinga.cfg file wiwth -i"
  exit 3
fi

OBJECTS_CACHE=$(grep object_cache_file ${ICINGA_CONFIG} | cut -d= -f2)

if [[ -z ${OBJECTS_CACHE} ]]
then
  echo "Please specify a valid icinga.cfg file wiwth -i"
  exit 3
fi

NMAP_TOOL=$(which nmap)
if [[ $? -gt 0 ]]
then
  echo "nmap is missing"
  exit 3
fi

### main ###

# scan for all hosts in given subnet
IPS_IN_SUBNET=$(${NMAP_TOOL} -sP ${IP_RANGE_TO_SCAN} | grep report | cut -d\( -f2 | cut -d\) -f1 | tr -d [:alpha:] | tr -d [:blank:] )

# scan objects.cache file for ip addresses in subnet that are already monitored
IPS_IN_ICINGA=$(grep address ${OBJECTS_CACHE} | grep ${SUBNET_TO_SCAN} | tr -d [:alpha:] | tr -d [:blank:])

# clean list of ip addresses in subnet from blanks and add newlines
for i in  $IPS_IN_ICINGA
do
  IPS_TEMP=$(echo  $IPS_IN_SUBNET | tr [:blank:] \\n | grep -v "^$i$")
  IPS_IN_SUBNET=$IPS_TEMP
done

# clean list of ips in subnet from blanks and add newlines and run loop over it
for i in $( echo $IPS_IN_SUBNET |  tr [:blank:] \\n | sort -n  )
do
  HOSTOUTPUT=$(host $i | cut -d' ' -f5)
  if [[ $? -gt 0 ]]
  then
    OUTPUT="${OUTPUT} IP $i can not be resolved"
  else
    OUTPUT="${OUTPUT} ${HOSTOUTPUT}"
  fi
done

if [[ -z ${HOSTOUTPUT} ]]
then
  echo "all hosts in range ${IP_RANGE_TO_SCAN} monitored by Icinga"
  exit 0
else
  echo "missing hosts: ${OUTPUT}"
  exit 1
fi
