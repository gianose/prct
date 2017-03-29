#!/usr/bin/env bash

# Author: Gregory Rose
# Created: 20170324
# Name: db
# Relative Working Directory: ${NAMESPACE}/lib/
# Utilized in order to provide simplified access to the DB.

declare DB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DB_DIR}'/../lib/exception.sh'
source ${DB_DIR}'/../lib/constants.sh'

declare DB 

declare -A DML=(
	[SELECT]='^select\s+(\w|\*)+(,\s+\w+)*\s+from\s(?!where).+$'
	[INSERT]='^insert\s+into\s+\w+\s+(\((\w+,\s+)*\w+\)\s+)?(values\s+\((\w+,\s+)*\w+\)|select.*from.*)'
	[UPDATE]='^update\s+\w+\s+set(\s+\w+\s+=\s+\w+,?)+(\s+where.*)?$'
	[DELETE]='^delete\s+from\s+(?!where)\w+(\s+where.*)?'
)

declare -a db_rows
declare -a db_headers

# Verifies that the db (the db provided via the param, or the one defined in contants.sh) file exists.
# If the existants of the db files is verified then the `DB` variable is set, else an error is thrown.
# @arg:<string>:opt - The absolute path to desired sqlite3 db file.
db_init() {
	local _db=${CONST_DB}
	[ ${1} ] && _db=${1}
	
	[ -e ${_db} ] || throw "IOError" "No such file or directory: '${_db}'"

	[[ ( -s ${_db} ) && ( -r ${_db} ) && ( -w ${_db} ) ]] || throw "IOError" "The db file is inaccessible: '${_db}'"

	DB=${_db}
}

# Executes the provided select statement against the DB.
# @arg:<string> - The 'SELECT' statement to be executed.
db_do_query() {
	db_do_chk "${@}"
	
	local rslt

	#[[ $( echo ${1} | perl -e 'print <STDIN> =~ @ARGV ? 0 : 1' ${db_select_regex} ) -eq 1 ]] && throw "InvalidArgument" "The provided query is improperly formated: ${1}"
	
	local qry=$(echo ${1} | grep -P -i -o '^select') || throw "InvalidArgument" "The provided query is not supported by the 'prct.db' module: ${1}"

	$( echo ${1} | grep -P -i -q "${DML[${qry}]}" ) || throw "InvalidArgument" "The provided query is improperly formated: ${1}"

	rslt=$(sqlite3 -separator ',' ${DB} "${1}" 2>&1) || throw "DatabaseException" "Query (${1}) failed with the following error: ${rslt}" 	
	
	[ "${rslt}" ] && db_set_rows "${rslt}" 

	[ "${rslt}" ] && db_set_headers "${1}"

	return 0
}

# Executes the provided dml statement againt the DB.
# @arg:<string> - The 'DML' statement to be executed.
db_do_dml() {
	db_do_chk "${@}"

	local rslt 
	local dml=$(echo ${1} | grep -P -i -o '^(insert|update|delete)')
	
	[[ (${dml}) && (${DML[${dml}]}) ]] || throw "InvalidArgument" "The provided dml is not supported by the 'prct.db' module: ${1}"

	$(echo ${1} | grep -P -i -q "${DML[${dml}]}") || throw "InvalidArgument" "The provided dml is improperly formated: ${1}"
	
	rslt=$(sqlite3 ${DB} "${1}" 2>&1) || throw "DatabaseException" "DML (${1}) failed with the following error: ${rslt}"
	
	return 0
}

# Check to ensure that the variable DB is set and the correct number of args
# have been passed to the calling function.
# @private
# @arg:<array> - The parameters passed to the calling function.
db_do_chk() {
	[[ ( ${#@} -gt 1 ) || ( ${#@} -lt 1 ) ]] && throw "InvalidArgument" "Invalid number of arguments provided"
	
	[ ${DB} ] || throw "InitalizationError" "The module DB was not initalized run db_init"
}

# Set the variable db_rows the results produced by the db_do_query function.
# @private
# @static
# @arg:<string> - A semicolon delimited string
db_set_rows() {
	local rslt=$(echo "${1}" | tr -s '\n\r' ';') 
	
	IFS=';' read -r -a db_rows <<< ${rslt}
}

# Set the variable db_headers to the headers 
# @private
# @arg:<string> - The 'SELECT' statement to be parsed.
db_set_headers() {
	if $(echo "${1}" | grep -P -q -i 'select\s+\*\s+from\s(?!where)'); then
		local tbl=$(db_get_table "${1}")
		db_headers=( $(sqlite3 -separator ',' ${DB} "PRAGMA table_info(${tbl})" | awk -F "," '{print $2}') )
	else
		local val=$(echo ${1} | perl -e 'print <STDIN> =~ /select(.*?)from/i')
		IFS=',' read -r -a db_headers <<< ${val}
	fi
}

# Returns to the caller the contents of db_rows
# @public
# return:<string> - Space delimited string.
db_get_rows() {
	echo ${db_rows[@]}
}

# Returns to the caller the content of db_headers
# @public
# return:<string> - Space delimited string
db_get_headers() {
	echo ${db_headers[@]}
}

# Parsed from the provided 'SELECT' query the table that is being queried.
# @private
# @static
# @arg:<string> - The 'SELECT' statement in which the table name needs to b parsed from.
# @return:<string> - The name of the table included in the select statment.
db_get_table() {
	echo $(echo ${1} | grep -P -i -o 'from.+' | awk '{print $2}')
}

db_init ${DB_DIR}'/../db/prct.db'
#db_init ${DB_DIR}'/../db/fake.db'
#db_get_table "SELECT * FROM table"
#db_get_table "SELECT * FROM table WHERE x=y"
#db_do_query "SELECT a, b, c FROM table WHERE x=y"
#db_do_query 'SELECT * FROM datasets WHERE dataset_id IN (1, 2)'
#db_do_query 'SELECT dataset_id, dataset_name, dataset_string FROM datasets WHERE dataset_id IN (1,2)'
#db_do_dml 'INSERT INTO TABLE_NAME VALUES (value1, value2, value3, value3)' 'blah'
#db_do_dml 'PUT INTO TABLE_NAME VALUES (value1, value2, value3, value3)'
#db_do_dml 'INSERT INTO TABLE_NAME (value1, value2, value3, value3)'
#db_do_dml 'INSERT INTO TABLE_NAME VALUES (value1, value2, value3, value3)'
