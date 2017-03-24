#!/usr/bin/env bash
# Auther: Gregory Rose
# Created On: 20170320
# Name: Unit Test
# When sourced, provides a set of methods that can be utilized in order to unit test a script.

declare UNT_TST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run the provided function with a single input.
# @arg:<array> - An array of comma dilimited strings.
runSingleInput() {
	declare -a params
	declare -a tests=("${!1}")
	for tsk in "${tests[@]}"; do
		IFS=',' read -r -a params <<< ${tsk}
		local _f=${params[0]%% - *}; _f=${_f##*::}
		$($_f ${params[2]} 2> /dev/null)
		assertEquals "${params[0]}" ${params[1]} $?
	done
}

# Run the provided function with multiple arguments, up to three.
# @arg:<array> - An array of comma dilimited strings.
runMultiInput() {
	declare -a params
	declare -a tests=("${!1}")
	for tsk in "${tests[@]}"; do
		IFS=',' read -r -a params <<< ${tsk}
		local _f=${params[0]%% - *}; _f=${_f##*::}
		case ${#params[@]} in
			2) $($_f &> /dev/null)
				;;
			3) $($_f "${params[2]}" &> /dev/null)
				;;
			4) $($_f ${params[2]} "${params[3]}" &> /dev/null)
				;;
			5) $($_f "${params[2]}" "${params[3]}" "${params[4]}" &> /dev/null)
				;;
		esac
		assertEquals "${params[0]}" ${params[1]} $?
	done
}

# Run the provided function against the provided test funtion.
# @arg:<array> - An array of comma dilimited strings.
runCustom() {
	declare -a params
	declare -a tests=("${!1}")
	for tsk in "${tests[@]}"; do
		IFS=',' read -r -a params <<< ${tsk}
		assertEquals "${params[0]}" ${params[1]} $($2 params[@])
	done
}

# Determines if the expected out come matches the actual out come. 
# If the expected out come matches the expected then the function
# outputs the provided message and "passed". If they do not match, 
# the function then outputs the provided message and "failed"
# @arg:<string> - The desired message.
# @arg:<integer> - The expected outcome.
# @arg:<integer> - the actual outcome. 
assertEquals() {
	local msg=$1
	local exp=$2
	local act=$3

	if [ "${exp}" != "${act}" ]; then
		output "${msg}" "---->FAILER!?!: EXPECTED=${exp} ACTUAL=${act}<----"
		exit 1
	else
		output "${msg}" "PASSED"
	fi
}

# Formats and outputs the provided strings
# @arg:<string> - The message
# @arg:<string> - Test result
output() {
	local out=""
	local form="%s\n"

	out="${1}: ${2}"
	from="%$((${#out}+4))s\n"

	printf "${from}" "${out}"
}
