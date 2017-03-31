#!/usr/bin/env bash

# @const:<string> CONST_DIR       The directory of 'self'.
# @const:<string> NAMESPACE The working directory of the PRCT script. 
# @const:<string> EVENT     The absolute path of the event logs file.
# @const:<string> ERROR     The absolute path of the error logs file.
# @const:<string> FORMAT    The desired format of PRCT related date strings.
declare CONST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare NAMESPACE="$( cd ${CONST_DIR}'/../' && pwd)/"
declare EVENT=${NAMESPACE}'log/event.log'
declare ERROR=${NAMESPACE}'log/error.log'
declare FORMAT='%Y-%m-%d %H:%H:%S'
declare CONST_DB=${NAMESPACE}'db/prct.db'
