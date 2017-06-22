#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170405
# Name: Log
# Relative Working Directory: ${NAMESPACE}/lib/log.sh

LOG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${LOG_DIR}'/const.sh'
source ${LOG_DIR}'/excp.sh'

declare log_event        # Utilized in order to store the absolute path for event log file. 
declare log_error        # Utilized in order to store the absolute path for error log file.
declare log_is_err=false # Utilized in order to indicate whether or not the previous log written was a error log.
declare log_on=false     # Utilized in order to indicate that the correponding instance of log has been initalized. 


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

	[[ ${#@} -eq 0 ]] && {
		log_make ${LOG}
		log_error="${LOG}/${BASH_SOURCE[2]%.*}.error.log"
		log_event="${LOG}/${BASH_SOURCE[2]%.*}.event.log"
	}
	
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
	local _p=`log_fore`

	printf "${_p} %15s\n" "${_s[0]%\|*}" >> ${log_error}
	unset -v _s[0]

	for s in "${_s[@]}"; do
		printf "%10s%s\n" "" "${s%\|*}" >> ${log_error}
	done

	log_is_err=true

	return 0
}

# Write the provided message to the event log.
# @arg:<string> - The message to be written to the event log.
log_event(){
	log_chk_arg ${@}

	local _m=${1}
	local _p=`log_fore`
	 
	printf "${_p} %15s\n" "${_m}" >> "${log_event}"

	log_is_err=false

	return 0
}

# Check to ensure that the correct number of args were provided to the caller.
# @private
# @args:<array> - All args provided to the caller.
log_chk_arg(){
	log_private
	[[ (( ${#@} != 1 )) ]] && throw "InvalidArgument" "Invalid number of arguments provided"
}

# Utilized in order to send the logged error or event via email to the contacts specified in BUILD_CONTACTS. 
# @public
# @args:<string> - The subject of the email to be sent.
log_send() {
	log_chk_arg ${@}
	
	local _e=''

	${log_is_err} && { _e=$(printf '%s\n\n%s\n' "$(cat ${log_error})" "${STEPS}"); } || { _e=$(cat ${log_event}); }
	
	log_mail "${1}" "${_e}"
	
	return 0
}

# Utilized in order to send the content of the event or error log via email.
# @private
# @args:<string> - The subject of the email to be sent.
# @args:<string> - The log file containing content to be included in email.
log_mail() {
	log_private
	#mailx -s "${BUILD_NAME}::$(date +"${FORMAT}")::${eclsourceip} ${1}" ${BUILD_CONTACTS} < "${2}"
	printf '%s\n' "${2}" | mailx -s "${BUILD_NAME}::$(date +"${FORMAT}")::${eclsourceip} ${1}" ${BUILD_CONTACTS}
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
	
	printf "${_d} %15s::%s::%s" "${_f}" "${_m}"	"${_l}"
}

log_init ${@}
