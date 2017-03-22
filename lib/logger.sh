#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170321
# Name: Logger
# Relative Working Directory: ${NAMESPACE}/lib/logger.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}'/constants.sh'
source ${DIR}'/exception.sh'

# Initializes the actual error and event log files, if they exist and are not empty
# zero out the file.
log_init(){
	[[ -s ${ERROR} ]] && truncate -s 0 ${ERROR}
	[[ -s ${EVENT} ]] && truncate -s 0 ${EVENT}
	return 0
}

# Writes the provided error, and corresponding stack trace to the error log.
# @arg:<string> - Pipe delimited string containing the exception and the corresponding stack trace.
log_error(){
	log_chk_arg "$@"
	declare -a _s
	IFS='|' read -r -a _s <<< ${1}
	local _p=`log_fore`

	printf "${_p} %15s\n" "${_s[0]%\|*}" >> ${ERROR}
	unset -v _s[0]

	for s in "${_s[@]}"; do
		printf "%10s%s\n" "" "${s%\|*}" >> ${ERROR}
	done

	return 0
}

# Write the provided message to the event log.
# @arg:<string> - The message to be written to the event log.
log_event(){
	log_chk_arg "$@"
	local _m=${1}
	local _p=`log_fore`
	 
	printf "${_p} %15s\n" "${_m}" >> ${EVENT}

	return 0
}

# Check to ensure that the correct number of args were provided to the caller.
# @args:<array> - All args provided to the caller.
log_chk_arg(){
	[[ ( ${#@} -gt 1 ) || ( ${#@} -lt 1 ) ]] && throw "InvalidArgument" "Invalid number of arguments provided"
}

# Returns to the caller a formatted string containing the current date and time, and the
# name of the script that called logger the corresponding line number and function.
# @static
log_fore(){
	local _d=$(date +"${FORMAT}")
	local _f=${BASH_SOURCE[2]}
	local _l=${BASH_LINENO[1]}
	local _m=${FUNCNAME[2]}

	local msg=""
	
	printf "${_d} %15s:%s:%s:" "${_f}" "${_l}" "${_m}"	
}

log_init
