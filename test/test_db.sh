#!/usr/bin/env bash

# Author: Gregory Rose
# Created: 20170329
# Name: test_db.sh
# Relative Working Directory: ${NAMESPACE}/test/
# Will be utilized in order to test all essential functions of the db script

declare TST_DB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare TST_LIB=${TST_DB_DIR}'/../lib/'
declare TST_DB=${TST_DB_DIR}'/../db/'

source ${TST_LIB}'unittest.sh'
source ${TST_LIB}'db.sh'
source ${TST_LIB}'excp.sh'

declare TST_DB_TTL='Testing `lib/db.sh`'

declare -A TST_DB_DML=(
	[INSERT]="INSERT INTO person (first_name, last_name, age) VALUES ('Joe', 'Hill', '34')"
	[UPDATE]="UPDATE person SET age=35 WHERE first_name = 'Joe'"
	[SEL_ALL]="SELECT * FROM person WHERE first_name ='Joe'"
	[SEL_SOME]="SELECT last_name, age FROM person WHERE first_name = 'Joe'"
	[DELETE]="DELETE FROM person WHERE first_name = 'Joe'"
)

declare -A TST_DB_REGEX=(
	[ALL_HEADERS]='^person_id\sfirst_name\slast_name\sage$'
	[ALL_ROWS]='^\d+,\w+,\w+,\d+$'
	[SOME_HEADERS]='^\w+\s+\w+$'
	[SOME_ROWS]='^\w+,\d+$'
)

declare -a TST_DB_ERR=(
	"db::db_init - Incorrect number of arguments;113;${TST_DB}fake.db;foo"
	"db::db_init - Initialize against nonexistent DB;111;${TST_DB}nonexistent.db"
	"db::db_init - Initialize against inaccessible DB;111;${TST_DB}fake.db"
	"db::db_do_query - Incorrect number of arguments;113;foo;bar"
	"db::db_do_query - Non supported query;113;OUTPUT ( $.Person(last_name = 'James') )"
	"db::db_do_query - Improperly formated query;113;SELECT first_name, last_name, FROM person"
	"db::db_do_query - Database related exception;109;SELECT ssn FROM person WHERE last_name = 'james'"
	"db::db_do_dml - Incorrect number of arguments;113;foo;bar"
	"db::db_do_dml - Non supported dml;113;EXPORT SetBureauCodes := SET($.Persons, bureaucode)"
	"db::db_do_dml - Improperly formated dml;113;INSERT INTO TABLE_NAME (value1, value2, value3, value3)"
	"db::db_do_dml - Database related exception;109;INSERT INTO TABLE_NAME VALUES (value1, value2, value3, value3)"
)

declare -a TST_DB_COR=(
	"db::db_init - Initialize against a accessible DB;0;${TST_DB}prct.db"
	"db::db_do_dml - Run valid INSERT dml against DB;0;${TST_DB_DML['INSERT']}"
	"db::db_do_dml - Run valid UPDATE dml against DB;0;${TST_DB_DML['UPDATE']}"
	"db::db_do_query - Run valid SELECT ALL query against DB;0;${TST_DB_DML['SEL_ALL']}"
	"db::db_get_headers - Get headers for the above SELECT ALL query;0;${TST_DB_REGEX['ALL_HEADERS']}"
	"db::db_get_rows - Get rows for the above SELECT ALL query;0;${TST_DB_REGEX['ALL_ROWS']}"
	"db::db_do_query - Run valid SELECT SOME query against DB;0;${TST_DB_DML['SEL_SOME']}"
	"db::db_get_headers - Get headers for the above SELECT SOME query;0;${TST_DB_REGEX['SOME_HEADERS']}"
	"db::db_get_rows - Get rows for the above SELECT SOME query;0;${TST_DB_REGEX['SOME_ROWS']}"
	"db::db_do_dml - Run valid DELETE dml against DB;0;${TST_DB_DML['DELETE']}"
)

# Executes the functions that test the negative and positive outcomes of the test db unit test. 
tst_db_main() {
	printf "%s\n" "${TST_DB_TTL}"
	tst_db_neg
	tst_db_pos
}

# Test all conceived possible scenarios which would cause db.sh to react negatively. 
tst_db_neg() {
	printf "%8s\n" "ERRORS"
	runMultiInput TST_DB_ERR[@]
}

# Test all conceived possible scenarios which would cause db.sh to react positively.
tst_db_pos() {
	printf "%9s\n" "CORRECT"
	runCustom TST_DB_COR[@] tst_db_wrk
}

# Function utilized in order to verify the outcome of successful dml (queries).
tst_db_wrk() {
	declare -a params=("${!1}")

	local _f=${params[0]%% - *}; _f=${_f##*::}
	case "${_f}" in
		'db_init'|'db_do_dml'|'db_do_query')
			$_f "${params[2]}" &> /dev/null
			return ${?}
			;;
		'db_get_headers'|'db_get_rows')
			$_f | grep -P -i -q "${params[2]}"
			return ${?}
			;;
		*)
			echo "How are we making it to the bottom"
			;;
	esac

	echo "I am down here"
}

tst_db_main
