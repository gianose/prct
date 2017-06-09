#!/usr/bin/env bash
# Author: Gregory Rose
# Created on: 20170405
# When source, provides means of throwing and catching custom exceptions.

declare EXCP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare -a EXCP_INV_ARG=(
	"InvalidArgument"
	"Invalid number of arguments provided"
	", is not a valid exception"
	"Expecting either 0 or 1"
)

declare excp_code # The corresponding exit code for the desired exception.
declare -a excp_stack # Array used in order to store the corresponding stack trace.

# Sets the excp_code variable to the exit code that corresponds with desired exception.
# If the exception is not defined and error is thrown.
# @private
# @static
# @arg:<string> - The desired exception.
excp_set_code() {
	$(echo ${FUNCNAME[1]} | grep -P -i -q '(incite|throw)') || throw "IllegalAccessError" "${FUNCNAME[0]} has been declared private."  
	case "${1}" in
		'InvalidArgument') 
			excp_code="113"
			;;
		'UnexpectedFormat') 
			excp_code="112"
			;;
		'IOError') 
			excp_code="111"
			;;
		'InitalizationError') 
			excp_code="110"
			;;
		'DatabaseException') 
			excp_code="109"
			;;
		'IllegalAccessError')
			excp_code="108"
			;;
		'FatalError')
			excp_code="107"
			;;
		'InvalidConfiguration')
			excp_code="106"
			;;
		'AccessFailed')
			excp_code="105"
			;;
		*) 
			throw "${EXCP_INV_ARG[0]}" "${1}${EXCP_INV_ARG[2]}"
	esac

	return 0
}

# Sets the `excp_stack` variable to the exception and the corresponding stack trace.
# If called with a third param of `1` it will return the excp_stack trace back to the caller.
# @public
# @arg:<string> - The exception
# @arg:<string> - The corresponding message
# @arg:<integer> - Either zero or one in order to indicate true or false 
incite() {
	[[ ${3} && ( "${3}" -ne 0 ) && ( "${3}" -ne 1 ) ]] && throw "${EXCP_INV_ARG[0]}" "${EXCP_INV_ARG[3]}"
	
	[[ ( ${#@} -gt 3 ) || ( ${#@} -le 1 ) ]] && throw "${EXCP_INV_ARG[0]}" "${EXCP_INV_ARG[1]}"

	excp_set_code ${1} || throw "${EXCP_INV_ARG[0]}" "${1}${EXCP_INV_ARG[2]}"
	
	excp_stack+="${1}: ${2} |"
	
	local frame=0

	while excp_stack+=("$(caller ${frame}) |"); do ((frame++)); done

	[[ ${3} -eq 1 ]] && echo "${excp_stack[@]}" || return 0

}

# If provided with the corresponding exception and message will output the exception and message to
# standard error. If not and if `incite` was called before hand will output the content of the `excp_stack`
# to stanard error.
# @public
# @args:<string>:optional - The exception
# @args:<string>:optional - The corresponding message.
# @args:<function>:optional
throw() {
	[[ ! ${excp_stack} && ( ${#@} -lt 2 ) ]] && throw "${EXCP_INV_ARG[0]}" "${EXCP_INV_ARG[1]}"
	[[ ${1} && ${2} && !${excp_stack} ]] && incite "${1}" "${2}"
	[[ ${3} ]] && $3

	(>&2 printf "%s\n" "${excp_stack[0]%\|*}")

	unset -v excp_stack[0]

	for s in "${excp_stack[@]}"; do
		(>&2 printf "%$((${#s}+5))s\n" "${s%\|*}")
	done
	exit ${excp_code}
}
