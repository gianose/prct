#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170406
# Name: Test Form
# Relative Working Directory: ${NAMESPACE}/test/test_form.sh
# Description: Utilized in order to test that the form module is working as expected.

declare TST_FORM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${TST_FORM_DIR}/../lib/const.sh"
source "${NAMESPACE}/lib/form.sh"
source "${NAMESPACE}/lib/unittest.sh"

declare TST_FORM_TTL='Testing `lib/form.sh`'
declare TST_FORM_MD5='4958112c677a75d03e27d778a070956f'
declare TST_FORM_OUT="${NAMESPACE}/tmp/form.out"
declare -a TST_FORM_ERR=(
	"form::form_throw - Attempt to call private function 'from_throw';108"
	"form::form_title - Attempt to call private function 'from_title';108"
	"form::form_body - Attempt to call private function 'from_body';108"
	"form::form - Zero params;113"
	"form::form - Array that contains err formated input string;113;('foo%bar%bam')"
	"form::form - Title input string contains more than two strings;113;('title%foo%bar%bam')"
	"form::form - Head input string contains more than one string;113;('head%foo%bar')"
)

declare -a TST_FORM_COR=(
	"form::form - Creating a form;0;('title%foo%bar' 'head%foo' 'body%bar')"
)

tst_form() {
	printf "%s\n" "${TST_FORM_TTL}"
	tst_form_neg
	tst_form_pos

	[ -f ${TST_FORM_OUT} ] && rm ${TST_FORM_OUT}
}


# Test all conceived possible scenarios which would cause form.sh to react negatively.
tst_form_neg() {
	printf "%8s\n" "ERRORS"
	runCustom TST_FORM_ERR[@] tst_form_neg_wrk
}

tst_form_pos() {
	printf "%8s\n" "CORRECT"
	runCustom TST_FORM_COR[@] tst_form_pos_wrk
}

tst_form_pos_wrk() {
	declare -a params=("${!1}")
	
	local _f=${params[0]%% - *}; _f=${_f##*::}

	declare -a _ary=${params[2]//\%/\;}

	$_f _ary[@] > ${TST_FORM_OUT} 2> /dev/null  || return $?
	
	local _md5=$(md5sum ${TST_FORM_OUT} | awk '{print $1}')

	[ ${_md5} == ${TST_FORM_MD5} ] && return $?  
}

tst_form_neg_wrk() {
	declare -a params=("${!1}")

	local _f=${params[0]%% - *}; _f=${_f##*::}

	if [ "${_f}" != 'form' ]; then
		$($_f &> /dev/null)
	else
		declare -a _ary=${params[2]//\%/\;}
		
		$($_f _ary[@] &> /dev/null)
	fi

	return $?
}

tst_form
