#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170405
# Name: Test Log
# Relative Working Directory: ${NAMESPACE}/test/test_log.sh
# Description: Utilized in order to test that the log script is function as expected.

declare TST_LOG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${TST_LOG_DIR}'/../lib/unittest.sh'
source ${TST_LOG_DIR}'/../lib/log.sh'
source ${TST_LOG_DIR}'/../lib/excp.sh'
source ${TST_LOG_DIR}'/../lib/const.sh'

declare TST_LOG_TTL='Testing `lib/log.sh`'
declare TST_LOG_RND="$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 24)"
declare -a TST_LOG_ERR=(
	"log::log_make - Attempt to call private function 'log_make';108;"
	"log::log_chk_arg - Attempt to call private function 'log_chk_arg';108;"
	"log::log_fore - Attempt to call private function 'log_fore';108;"
	"log::log_init - More than two params;113;foo;bar;ham"
	"log::log_init - Attempt to init with not real directory;110;${NAMESPACE}/not/real/dir/error.log"
	"log::log_event - Zero param;113;"
	"log::log_event - More than one param;113;This is a test event;blah"
	"log::log_error - Zero param;113;"
	"log::log_error - More than one param;113;$(incite "InvalidArgument" "This is a test" 1);blah"
)
 
declare -a TST_LOG_COR=(
	"log::log_init - Initializing log with one param;0;${NAMESPACE}/tmp/role/error.log"
	"log::log_init - Initializing log with two params;0;${NAMESPACE}/tmp/log/error.log;${NAMESPACE}/tmp/log/event.log"
	"log::log_event - Logging an event;0;This is a test event log entry"
	"log::log_error - Logging an error;0;This is a test error log entry"
)

# Executes the functions that test the negative and positive outcomes of the test logger unit test.
tst_log_main() {
	printf "%s\n" "${TST_LOG_TTL}"
	tst_log_neg
	tst_log_pos
	tst_log_clean
}

# Remove any directories or corresponding files created by test_log.sh
tst_log_clean() {
	[ -d "${NAMESPACE}/tmp/role" ] && rm -rf "${NAMESPACE}/tmp/role"
	[ -d "${NAMESPACE}/tmp/log" ] && rm -rf "${NAMESPACE}/tmp/log"
}

# Test all conceived possible scenarios which would cause log.sh to react negatively.
tst_log_neg() {
	printf "%8s\n" "ERRORS"
	runMultiInput TST_LOG_ERR[@]
}

# Test all conceived possible scenarios which would cause log.sh to react positively.
tst_log_pos() {
	printf "%9s\n" "CORRECT"
	runCustom TST_LOG_COR[@] tst_log_fmt_chk	
}

# Function utilized in order to verify that the logs produced by the log script are in
# the desired format.
# @arg:<array> - ...
tst_log_fmt_chk() {
	declare -a e_log
	declare -a params=("${!1}")
	declare -a tst_log_err=(
		"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} ${BASH_SOURCE[0]}:\d{2}:${FUNCNAME[0]}: InvalidArgument: ${TST_LOG_RND}$"
		"^\d{2} ${FUNCNAME[0]} ${BASH_SOURCE[0]}$"
		"^\d{2} ${FUNCNAME[1]} ${BASH_SOURCE[1]}$"
		"^\d{2} ${FUNCNAME[2]} ${BASH_SOURCE[2]}$"
		"^\d{2} ${FUNCNAME[3]} ${BASH_SOURCE[3]}$"
		"^\d{3} ${FUNCNAME[4]} ${BASH_SOURCE[4]}$"
	)
	declare -a tst_log_evnt=(
		"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} ${BASH_SOURCE[0]}:\d{2}:${FUNCNAME[0]}: ${TST_LOG_RND}$"	
	)

	local _f=${params[0]%% - *}; _f=${_f##*::}
	local _l=${_f#*_}; _l=${_l^^}
	local regex=''
	local _e
	
	if [[ "${_f}" == "log_event" || "${_f}" == "log_error" ]]; then
		if [[ ${_l} == "ERROR" ]]; then
			incite "InvalidArgument" "${TST_LOG_RND}"
			$_f excp_stack[@]
			regex=("${tst_log_err[@]}")
			_e=${log_error}
		else
			$_f "${TST_LOG_RND}"
			regex=("${tst_log_evnt[@]}")
			_e=${log_event}
		fi

		IFS='|' read -r -a e_log <<< $(echo "$(cat ${_e})" | tr -s '\n' '|')
		(	 
			for i in "${!e_log[@]}"; do
				$( echo ${e_log[${i}]} | sed -e 's/[ \t]*$//g' | grep -P -q "${regex[${i}]}" ) || throw "UnexpectedFormat" "The log was formated incorrectly see log/${_l}" &> /dev/null	
			done

			exit 0
		)
	
  		return ${?}

		wait
	else
		case ${#params[@]} in
			3) 
				$_f "${params[2]}" &> /dev/null || return $?
				[ -f ${params[2]} ] && return $? 
				;;
			4)
				$_f "${params[2]}" "${params[3]}" &> /dev/null || return $?
				[[ ( -f ${params[2]} ) && ( -f ${params[3]} ) ]] && return $?
				;;
		esac
		
	fi
}

tst_log_main
