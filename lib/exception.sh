#!/usr/bin/env bash
# Author: Gregory Rose
# Created on: 20170321
# When source, provides means of throwing and catching custom exceptions.

declare EXCP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${EXCP_DIR}'/constants.sh'

declare -a INV_ARG=(
	"InvalidArgument"
	"Invalid number of arguments provided"
	", is not a valid exception"
	"Expecting either 0 or 1"
)

declare -A EXCEPTION=(
	[InvalidArgument]="255"
	[UnexpectedFormat]="254"
)

declare -a stack

# Sets the `stack` variable to the exception and the corresponding stack trace.
# If called with a third param of `1` it will return the stack trace back to the caller.
# @arg:<string> - The exception
# @arg:<string> - The corresponding message
# @arg:<integer> - Either zero or one in order to indicate true or false 
incite() {
	[[ ${3} && ( "${3}" -ne 0 ) && ( "${3}" -ne 1 ) ]] && throw "${INV_ARG[0]}" "${INV_ARG[3]}"
	
	[[ ( ${#@} -gt 3 ) || ( ${#@} -le 1 ) ]] && throw "${INV_ARG[0]}" "${INV_ARG[1]}"

	[ ${EXCEPTION[${1}]} ] || throw "${INV_ARG[0]}" "${1}${INV_ARG[2]}"
	
	stack+="${1}: ${2} |"
	
	local frame=0

	while stack+=("$(caller ${frame}) |"); do ((frame++)); done

	[[ ${3} -eq 1 ]] && echo "${stack[@]}" || return 0
}

# If provided with the corresponding exception and message will output the exception and message to
# standard error. If not and if `incite` was called before hand will output the content of the `stack`
# to stanard error.
# @args:<string>:optional - The exception
# @args:<string>:optional - The corresponding message.
throw() {
	[[ !${stack} && ( ${#@} -lt 2 ) ]] && throw "${INV_ARG[0]}" "${INV_ARG[1]}"
	[[ ${1} && ${2} && !${stack} ]] && incite "${1}" "${2}"

	(>&2 printf "%s\n" "${stack[0]%\|*}")

	unset -v stack[0]

	for s in "${stack[@]}"; do
		(>&2 printf "%$((${#s}+5))s\n" "${s%\|*}")
	done
	
	exit ${EXCEPTION[${1}]}
}
