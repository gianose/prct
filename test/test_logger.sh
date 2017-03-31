#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170322
# Name: Test Logger
# Relative Working Directory: ${NAMESPACE}/test/test_logger.sh
# Utilized in order to test that the logger script is function as expected.

declare TST_LOG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${TST_LOG_DIR}'/../lib/unittest.sh'
source ${TST_LOG_DIR}'/../lib/logger.sh'
source ${TST_LOG_DIR}'/../lib/exception.sh'
source ${TST_LOG_DIR}'/../lib/constants.sh'

declare TST_LOG_TTL='Testing `lib/logger.sh`'
declare TST_LOG_RND="$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 24)"
declare -a TST_LOG_ERR=(
	"logger::log_event - Zero param;113;"
	"logger::log_event - More than one param;113;This is a test event;blah"
	"logger::log_error - Zero param;113;"
	"logger::log_error - More than one param;113;$(incite "InvalidArgument" "This is a test" 1);blah"
)
 
declare -a TST_LOG_COR=(
	"logger::log_event - Logging an event;0;This is a test event log entry"
	"logger::log_error - Logging an error;0;This is a test error log entry"
)

# Executes the functions that test the negative and positive outcomes of the test logger unit test.
tst_log_main() {
	printf "%s\n" "${TST_LOG_TTL}"
	tst_log_neg
	tst_log_pos
}

# Test all conceived possible scenarios which would cause logger.sh to react negatively.
tst_log_neg() {
	printf "%8s\n" "ERRORS"
	runMultiInput TST_LOG_ERR[@]
}

# Test all conceived possible scenarios which would cause logger.sh to react positively.
tst_log_pos() {
	printf "%9s\n" "CORRECT"
	runCustom TST_LOG_COR[@] tst_log_fmt_chk	
}

# Function utilized in order to verify that the logs produced by the logger script are in
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
		"^\d{2} ${FUNCNAME[4]} ${BASH_SOURCE[4]}$"
	)
	declare -a tst_log_evnt=(
		"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} ${BASH_SOURCE[0]}:\d{2}:${FUNCNAME[0]}: ${TST_LOG_RND}$"	
	)

	local _f=${params[0]%% - *}; _f=${_f##*::}
	local _l=${_f#*_}; _l=${_l^^}
	local regex=''
	
	if [[ ${_l} == "ERROR" ]]; then
		$_f "$(incite "InvalidArgument" "${TST_LOG_RND}" 1)"
		regex=("${tst_log_err[@]}")
	else
		$_f "${TST_LOG_RND}"
		regex=("${tst_log_evnt[@]}")
	fi

	IFS='|' read -r -a e_log <<< $(echo "$(cat ${!_l})" | tr -s '\n' '|')
	( 
		for i in "${!e_log[@]}"; do
			$( echo ${e_log[${i}]} | sed -e 's/[ \t]*$//g' | grep -P -q "${regex[${i}]}" ) || throw "UnexpectedFormat" "The log was formated incorrectly see log/${_l}" &> /dev/null	
		done

		exit 0
	)
	
   return ${?}

	wait
}

tst_log_main
