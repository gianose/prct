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
	"logger::log_event - Zero param,255,"
	"logger::log_event - More than one param,255,This is a test event,blah"
	"logger::log_error - Zero param,255,"
	"logger::log_error - More than one param,255,$(incite "InvalidArgument" "This is a test" 1),blah"
)

declare -a TST_LOG_COR=()
declare -a TST_LOG_REGEX=(
	"^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] ${BASH_SOURCE[0]}:[0-9][0-9]:${FUNCNAME[0]}: InvalidArgument: ${TST_LOG_RND}$"
	"^[0-9][0-9] ${FUNCNAME[0]} ${BASH_SOURCE[0]}"
	"^[0-9][0-9] ${FUNCNAME[1]} ${BASH_SOURCE[1]}"
	"^[0-9][0-9] ${FUNCNAME[3]} ${BASH_SOURCE[3]}"
)

tst_log_main() {
	printf "%s\n" "${TST_LOG_TTL}"
	tst_log_err
	tst_log_cor
}

tst_log_err() {
	printf "%8s\n" "ERRORS"
	runMultiInput TST_LOG_ERR[@]
}

tst_log_cor() {
	printf "%9s\n" "CORRECT"

	declare -a err_log

	log_error "$(incite "InvalidArgument" "${TST_LOG_RND}" 1)"

	IFS='|' read -r -a err_log <<< $(echo "$(cat ${ERROR})" | tr -s '\n' '|')
	
	( 
		for i in "${!err_log[@]}"; do
			[[ ${err_log[${i}]} =~ ${TST_LOG_REGEX[${i}]} ]] ||    
		done

		exit 0
	 )

	 wait 
	
}

tst_log_main
