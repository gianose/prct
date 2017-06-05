#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170406
# Name: form.sh
# Relative Working Directory: ${NAMESPACE}/lib/form.sh
# Description: 
# 	When sources and passed a properly formated array, form.sh will output a formated
# form document to the user of the script that sourced usage.s.sh.

FORM_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${FORM_DIR}/const.sh"
source "${FORM_DIR}/excp.sh"

# @private
# @static
form_private() {
		$(echo ${FUNCNAME[2]} | grep -P -i -q '^form(_\w+)?') || throw "IllegalAccessError" "${FUNCNAME[0]} has been declared private."	
}

# Will utilizied in order to output the usage information for the script sourcing the form module.
# The input for this function should be an array formated as follows:
#  (
#    "title;semicolon delimited list"
#	 "head;semicolon delimited list"
#	 "body;semicolon delimies list"
#  )
# @public
# @args:<array> - An array containing the usage information to output to the screen:
form() {
	[[ (${#@} -lt 1) || (${#@} -gt 1) ]] && throw 'InvalidArgument' 'Invalid number of arguments provided'
	
	declare -a _form=("${!1}")
	declare -a _line
	
	for _frm in "${_form[@]}"; do
		IFS=';' read -r -a _line <<< ${_frm}
		echo ${_line[0]} | grep -P -i -q '(title|head|body)' || form_throw "${_frm}" 1

		printf "\n"

		case ${_line[0]} in
			'title')
				unset _line[0]
				[[ (${#_line[@]} -gt 2) || (${#_line[@]} -lt 1) ]] && form_throw "${_frm}" 2
				form_title _line[@]				
				;;
			'head')
				[[ (${#_line[@]} -gt 2) || (${#_line[@]} -lt 2) ]] && form_throw "${_frm}" 3
				printf "\n%s\n" "${_line[1]^^}"	
				;;
			'body')
				unset _line[0]
				form_body _line[@]
				;;
			*)
				echo "What am I doing down here"
				;;
		esac
	done
		
	printf "\n"
}

# Utilized in order to throw errors related to the form module.
# @private
# @args:<string>
form_throw() {
	form_private

	case ${2} in 
		1)
			throw "InvalidArgument" "Improperly formatted input string, input string should be lead with either title, head, or body: ${1}"
			;;
		2)
			throw "InvalidArgument" "Improperly formatted input string, the title should consist of a minimum of one string and no more than two delimited by commas: ${1}"
			;;
		3) 
			throw "InvalidArgument" "Improperly formatted input string, the head should consist of only one string: ${1}" 
	esac
}

# Utilized in order to output the title.
# @private
# @args:<array>
form_title() {
	form_private

	declare -a _title=("${!1}")

	case ${#_title[@]} in
		1)
			printf "%s\n" "${_title[0]^^}"		;;
		2) 
			printf "%-30s%s\n" "${_title[0]^^}" "${_title[1]}"
			;;
	esac
}

# Utilized in order to output the body.
# @private
# @args:<array>
form_body() {
	form_private

	local -a _body=("${!1}")

	for _bdy in "${_body[@]}"; do
		printf "%$((${#_bdy}+4))s\n" "${_bdy}"
	done
}
