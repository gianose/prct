#!/usr/bin/env bash
# Auther: Gregory Rose
# Created On: 20170320
# Name: Unit Test
# When sourced, provides a set of methods that can be utilized in order to unit test a script.

declare UNT_TST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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


output() {
	local out=""
	local form="%s\n"

	out="${1}: ${2}"
	from="%$((${#out}+4))s\n"

	printf "${from}" "${out}"
}
