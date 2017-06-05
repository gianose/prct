#!/usr/bin/env bash
# @author: Gregory Rose
# @created: 20170602
# @name: Test sftp
# @path: test/test_sftp.sh
# Utilized in order to test that the sftp module is working as expected.

declare TST_SFTP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${TST_SFTP_DIR}/../lib/const.sh"
source "${NAMESPACE}lib/sftp.sh" 
source "${NAMESPACE}lib/unittest.sh"

declare TST_SFTP_TTL='Testing `lib/sftp.sh`'

declare -a TST_SFTP_ERROR=(
	"sftp::sftp.initialize - Attempt to initialize sftp with too many parameters;113;foo;bar"
	"sftp::sftp.initialize - Attempt to initialize sftp with a unreachable host;107;not.real.host.com"
	"sftp::sftp.list - Attempt to call sftp.list with no params;113"
	"sftp::sftp.list - Attempt to call sftp.list with more than two params;113;foo;bar;blah"
	"sftp::sftp.list - Attempt to call sftp.list with an unknown option;113;a;test/bsftp/arch"
	"sftp::sftp.list - Attempt to call sftp.list with a known and a unknown option;113;1x;test/bsftp/arch"
	"sftp::sftp.list - Attempt to call sftp.list to list the content of a nonexistant directory;113;1;not/real"
	"sftp::sftp.list - Attempt to call sftp.list when server is unreachable;107;1;"
)

#declare -a TST_SFTP_CORRECT(
#	""
#)
