#!/usr/bin/env bash
# Author: Gregory Rose
# Created On: 20170321
# Name: Test Exception 
# Utilized in order test all the methods included in lib/exception.sh.

declare TST_EXCP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${TST_EXCP_DIR}'/../lib/unittest.sh'
source ${TST_EXCP_DIR}'/../lib/excp.sh'
declare TST_EXCP_TTL='Testing `lib/excp.sh`'
declare -a TST_EXCP_EXAMS=(
	"exception::incite - Zero param|113|''"
	"exception::incite - One param|113|InvalidArgument"
	"exception::incite - Non valid exception|113|CheeseBurger|This is a test"
	"exception::incite - Third param neither 0 or 1|113|InvalidArgument|This is a test|2"
	"exception::incite - No third param|0|InvalidArgument|This is a test"
	"exception::incite - With third param == 1|0|InvalidArgument|This is a test|1"
	"exception::incite - With third param == 0|0|InvalidArgument|This is a test|0"
	"exception::throw - The var stack is null and zero args|113|''"
	"exception::throw - The var stack is null and one args|113|InvalidArgument"
	"exception::throw - The var stack is null and two args|113|InvalidArgument|This is a test"
)

# Utilized in order to test all the functions included in lib/exception.sh
test_excp_main() {
	printf "%s\n" "${TST_EXCP_TTL}"
	declare -a params
	for tsk in "${TST_EXCP_EXAMS[@]}"; do
		IFS='|' read -r -a params <<< ${tsk}
		_f=${params[0]%% - *}
		_f=${_f##*::}
		case ${#params[@]} in
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


test_excp_main
