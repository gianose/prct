#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170405
# Name: Log
# Relative Working Directory: ${NAMESPACE}/lib/log.sh

LOG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${LOG_DIR}'/const.sh'
source ${LOG_DIR}'/excp.sh'

declare log_event
declare log_error
declare log_on=false

# @private
# @static
log_private() {
	$(echo ${FUNCNAME[2]} | grep -P -i -q '^log_\w+') || throw "IllegalAccessError" "${FUNCNAME[0]} has been declared private."	
}

# Initializes the actual error and event log files, if they exist and are not empty
# zero out the file.
# @public
# @args:<array>:opt - List of absolute paths for the event and error logs. 
log_init(){
	[[ ( ${#@} -gt 2 ) ]] && throw 'InvalidArgument' 'Invalid number of arguments provided'
	
	if [ ${#@} -eq 0 ]; then
		log_error=${ERROR}
		log_event=${EVENT}
	fi
	
	[ ${1} ] && { log_make ${1} && log_error=${1}; }
	
	[ ${2} ] && { log_make ${2} && log_event=${2}; }

	[[ ${log_error} && ! -f ${log_error} ]] && touch ${log_error}
	[[ ${log_event} && ! -f ${log_event} ]] && touch ${log_event}
	
	[[ ${log_error} && -s ${log_error} ]] && truncate -s 0 ${log_error}
	[[ ${log_error} && -s ${log_event} ]] && truncate -s 0 ${log_event}

	return 0
}

# Ensures that the provided log directory exists.
# @private
# @args:<string> - The absolute path of the event or error log.
log_make(){
	log_private

	local dir="${1%/*}"
	
	[ -d ${dir%/*} ] || throw "InitalizationError" "The provided directory does not exist: ${dir%/*}"

	[ ! -d ${dir} ] && mkdir ${dir}
	
	${log_on} || log_on=true

	return 0	
}


# Writes the provided error, and corresponding stack trace to the error log.
# @arg:<string> - Pipe delimited string containing the exception and the corresponding stack trace.
log_error(){
	log_chk_arg ${@}
	declare -a _s=("${!1}")
	#IFS='|' read -r -a _s <<< ${1}
	local _p=`log_fore`

	printf "${_p} %15s\n" "${_s[0]%\|*}" >> ${log_error}
	unset -v _s[0]

	for s in "${_s[@]}"; do
		printf "%10s%s\n" "" "${s%\|*}" >> ${log_error}
	done
}

# Write the provided message to the event log.
# @arg:<string> - The message to be written to the event log.
log_event(){
	log_chk_arg ${@}

	local _m=${1}
	local _p=`log_fore`
	 
	printf "${_p} %15s\n" "${_m}" >> "${log_event}"

	return 0
}

# Check to ensure that the correct number of args were provided to the caller.
# @private
# @args:<array> - All args provided to the caller.
log_chk_arg(){
	log_private
	[[ ( ${#@} -gt 1 ) || ( ${#@} -lt 1 ) ]] && throw "InvalidArgument" "Invalid number of arguments provided"
}

# Returns to the caller a formatted string containing the current date and time, and the
# name of the script that called logger the corresponding line number and function.
# @private
# @static
log_fore(){
	log_private

	local _d=$(date +"${FORMAT}")
	local _f=${BASH_SOURCE[2]}
	local _l=${BASH_LINENO[1]}
	local _m=${FUNCNAME[2]}

	local msg=""
	
	printf "${_d} %15s:%s:%s:" "${_f}" "${_l}" "${_m}"	
}

#log_init $@

#log_init
#log_init "${NAMESPACE}tmp/role/error.log"
#log_init "${NAMESPACE}tmp/role/error.log" "${NAMESPACE}tmp/role/event.log"
#log_init foo bar ham
#log_init "${NAMESPACE}not/real/dir/event.log"
#echo ${log_on}
#echo ${log_error}
#echo ${log_event}

