#!/usr/bin/env bash

# @const:<string> CONST_DIR The directory of 'self'.
# @const:<string> NAMESPACE The working directory of the PRCT script. 
# @const:<string> FORMAT    The desired format of PRCT related date strings.
# @const:<string> LOG       The absolute path to the log directory.
# @const:<string> DB        The absolute path to the sqlite DB file.
declare CONST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare NAMESPACE="$( cd ${CONST_DIR}'/../' && pwd)"
declare FORMAT="%Y-%m-%d %H:%M:%S"
declare LOG="${NAMESPACE}/log"
declare DB="${NAMESPACE}/db/prct.db"
