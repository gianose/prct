#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170406
# Name: sftp.sh
# Relative Working Directory: ${NAMESPACE}/lib/sftp.sh
# Description:
#	Provides simplified means of access files and directories on a designated SFTP server.

SFTP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare CONFIG=/home/dataops/configs

source "${SFTP_DIR}/const.sh"
source "${SFTP_DIR}/excp.sh"
. ${CONFIG}/serverconfigs.lookup

sftp() {
	# @var:<string>:output - utililized in order to store any error string produced from the call to lftp
	# @var:<string>:sftp_rmt_hst - Utilized in order to hold the verified remote host.
	declare output='' 
	declare sftp_rmt_hst=''
	
	sftp.initialize() {
		[[ (${#@} -gt 1) ]] && sftp.throw 1
			
		sftp_rmt_hst=${tapeload02b}; [ ${1} ] && sftp_rmt_hst=${1}

		$(ping -q -c 1 "${tapeload02b}" &> /dev/null) || throw "InitalizationError" "The remote host is unreachable: ${tapeload02b}"

		return 0
	}
	
	# List the content of the the provided directory utilizing the optional list option if provided.
	# 1 - single-column output
	# B - Basename
	# d - list directory entries instead of contents
	# s - print size of each file
	# l - use a long listing format
	# h - print sizes in human readable format
	# k - kilobytes
	# D - list directories first
	# S - sort by file size
	# @public
	# @args:<string>:optional - Nondelimited string containing a list of list options as described above.
	# @args:<string> - The remote directory
	# @return:<string> - The result of the remote directory listing.
	# @example
	#   sftp.ls '1s' '/test/bsftp/src'
	#   **Returns**
	#    0 test\bsftp\src/_20161011
	#    0 test\bsftp\src/_20161016
	sftp.list() {
		local options='1 B d s l h k D S'
		
		declare -a cmd_lst=( 'cls' )

		[[ (${#@} -lt 1) || (${#@} -gt 2) ]] && sftp.throw 1

		for (( i=0; i<${#1}; i++ )); do
			[[ ${options} =~ "${1:${i}:1}" ]] || sftp.throw 2 ${1:${i}:1}
		done

		cmd_lst+=("-${1}")
		
		sftp.checkRemote ${2} || sftp.throw 3 ${2}

		cmd_lst+=("${2}")
		
		sftp.work cmd_lst[@] || sftp.throw 0

		return 0
	}
	
	# Utilized in order to throw common errors that may occure in sftp module.
	# @private
	# @args:<integer> - The index of the corresponding error to throw.
	# @args:<string> - Additional argument to pass to the call to throw.
	sftp.throw() {
		private
		case ${1} in
			0) throw "FatalError" "${FUNCNAME[1]} failed to execute with the error: ${output}"
				;;
			1) throw "InvalidArgument" "Invalid number of arguments provided"
				;;
			2) throw "InvalidArgument" "Currently not a support ${FUNCNAME[1]} option: ${2}"
				;;
			3) throw "InvalidArgument" "The remote directory does not exist: ${2}"
		esac
	}

	# Utilized in order to check whether or not the remote file or directory exist.
	# @private 
	# @args:<string> - Remote file or directory to check 
	sftp.checkRemote() {
		private
		declare -a fnd_cmd=("cls -1q ${1}")
		sftp.work fnd_cmd[@] && return 0
		return 1	
	}

	# Utilized in order to build the lftp command and executes it.
	# @private
	# @args:<array> - An array containing all the commands to pass to lftp.
	# @return:<boolean>
	sftp.work() {
		private
		declare -a cmd_lst=("${!1}")
	
		local out
		local cmd="set net:reconnect-interval-base 5; set net:max-retries 2; $(printf "%s; " "${cmd_lst[@]}")bye"

		{ output=$(lftp -u "${ftpuser},${ftppasswd}" sftp://${sftp_rmt_hst} -e "${cmd}" 2>&1 1>&$out); } {out}>&1 && return 0

		return 1
	}
		
}


# Utilized in order to  throw an error whenever there is an attempt to utilize a provide 
# function declared within the sftp module.
# @private
private() {
	$(echo ${FUNCNAME[2]} | grep -P -i -q '^sftp(.\w+)?') || throw "IllegalAccessError" "Attempt to utilize private function: ${FUNCNAME[0]}."	
}

sftp ${@}
