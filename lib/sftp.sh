#!/usr/bin/env bash
# Author: Gregory Rose
# Created: 20170406
# Name: sftp_sh
# Relative Working Directory: ${NAMESPACE}/lib/sftp_sh
# Description:
#	Provides simplified means of access files and directories on a designated sftp_server.

SFTP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare CONFIG=/home/dataops/configs

source "${SFTP_DIR}/const.sh"
source "${SFTP_DIR}/excp.sh"
. ${CONFIG}/serverconfigs.lookup


# @var:<string>:static:RSRC - Variable containing the string 'remote source'
# @var:<string>:static:LSRC - Variable containing the string 'local source'
# @var:<string>:static:RDST - Variable containing the string 'remote destination'
# @var:<string>:static:LSDT - Variable containing the string 'local destination'
declare RSRC='remote source'
declare LSRC='local source'
declare RDST='remote destination'
declare LDST='local destination'

# @var:<string>:output - utililized in order to store any error string produced from the call to lftp
# @var:<string>:sftp_rmt_hst - Utilized in order to hold the verified remote host.
declare sftp_rmt_hst=''
declare output='' 

sftp() {

	sftp_initialize() {
		[[ (${#@} -gt 1) ]] && sftp_throw 1

		sftp_rmt_hst=${tapeload02b}; [ ${1} ] && sftp_rmt_hst=${1}

		$(ping -q -c 1 "${sftp_rmt_hst}" &> /dev/null) || throw "InitalizationError" "The remote host is unreachable: ${sftp_rmt_hst}"
	
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
	# @args:<string> - The remote directory
	# @args:<string>:optional - Nondelimited string containing a list of list options as described above.
	# @return:<string> - The result of the remote directory listing.
	# @usage: sftp_list [DIRECTORY]... [OPTION]...?
	# @example:
	#	sftp_list 'test'
	#	**return**
	#	test/bsftp_
	#
	#   sftp_list 'test/bsftp_src' '1s'
	#   **Returns**
	#    0 test/bsftp_src/_20161011
	#    0 test/bsftp_src/_20161016
	sftp_list() {
		local options='^(1|B|d|s|l|h|k|D|S)+$'

		declare -a cmd_lst=( 'cls' )

		[[ ((${#@} < 1 || ${#@} > 2)) ]] && sftp_throw 1 "1-2" "${#@}"

		local dir="${1};"

		[ ${2} ] && { [[ ${2} =~ ${options} ]] || sftp_throw 2 $(echo "${2}" | sed -e "s/\(1\|B\|d\|s\|l\|h\|k\|D\|S\)//"); } 

		cmd_lst+=( "-${2}" )

		sftp_checkRemoteExist ${dir} || sftp_throw 3 "${RDST}" ${dir} "${output}"

		cmd_lst+=("${dir}")

		sftp_work cmd_lst[@] || sftp_throw 0

		return 0
	}
	
	# Copies a file or files from the remote source to the provided destination.
	# @public
	# @args:<string> - The remote source files, or comma delimited list of source files.
	# @args:<string> - The local destination.
	# @usage: sftp_get [SOURCE || SRC1,SRC2,...SRCN]... [DESTINATION]...
	# @example:
	#	sftp_get 'rfile' 'local/dir'
	#	sftp_get 'rfile1,rfile2,rfilen' '/local/dir'
	sftp_get(){
		[[ ((${#@} != 2)) ]] && sftp_throw 1 2 ${#@}
		
		declare -a files
		declare -a cmd_lst=('mget')
	
		[[ ${1} =~ ',' ]] && { IFS=',' read -r -a files <<< "${1}"; } || { files=("${1}"); }
		
		for f in "${files[@]}"; do
			sftp_checkRemoteExist "${f}" || sftp_throw 3 "${RSRC}" ${f} "${output}"
			sftp_checkRemoteIsDir "${f}" && sftp_throw 4 "${RSRC}" ${f} 1 'pull'
		done
		
		cmd_lst+=("${files[@]}")
	
		sftp_checkLocalIsDir ${2} || sftp_throw 3 "${LDST}" ${2} 

		cmd_lst+=("-O ${2};")

		sftp_work cmd_lst[@] || sftp_throw 0

		return 0
	}

	# Copies a file or files from the local source to the a remote destination.
	# @public
	# @args:<string> - The local source file, or comma delimited list of local source files.
	# @args:<string> - The remote destination directory.
	# @usage: sftp_put [SOURCE || SRC1,SRC2,...SRCN]... [DESTINATION]...
	# @example:
	#	sftp_put 'lfile' 'remote/dir'	
	#	sftp_put 'lfile1,lfile2,lfilen' 'remote/dir'	
	sftp_put() {
		[[ ((${#@} != 2)) ]] && sftp_throw 1 2 ${#@}

		declare -a cmd_lst=('mput')
		declare -a files

		[[ ${1} =~ ',' ]] && { IFS=',' read -r -a files <<< "${1}"; } || { files=("${1}"); }

		for f in "${files[@]}"; do
			sftp_checkLocalExist ${1} || sftp_throw 3 "${LSRC}" ${1}
			sftp_checkLocalIsDir ${1} && sftp_throw 4 "${LSRC}" ${1} 1 'push'
		done

		cmd_lst+=("${files[@]}")

		sftp_checkRemoteIsDir ${2} || sftp_throw 3 "${RDST}" ${2}

		cmd_lst+=("-O ${2};")

		sftp_work cmd_lst[@] || sftp_throw 0

		return 0

	}

	# Mirrors the content of a remote directory to a local directory.
	# @public
	# @args:<string> - The remote source directory.
	# @args:<string> - The local destination directory.
	# @usage: sftp_pull [SRC_DIR]... [DST_DIR]....
	# @example:
	#	sftp_pull 'remote/dir' 'local/dir'
	sftp_pull() {
		[[ ((${#@} != 2)) ]] && sftp_throw 1 2 ${#@}

		declare -a cmd_lst=('mirror -rPc')
		
		sftp_checkRemoteExist "${1}" || sftp_throw 3 "${RSRC}" ${1} "${output}"
		sftp_checkRemoteIsDir "${1}" || sftp_throw 4 "${RSRC}" ${1} '0' 'get'

		cmd_lst+=("${1}")

		sftp_checkLocalIsDir ${2} || sftp_throw 3 "${LDST}" ${2}

		cmd_lst+=("${2};")

		sftp_work cmd_lst[@] || sftp_throw 0

		return 0
	}

	# Mirrors the content of a local directory to a remote directory.
	# @public
	# @args:<string> - The local source directory.
	# @args:<string> - The remote destination directory.
	# @usage: sftp_push [SRC_DIR]... [DST_DIR]....
	# @example
	#	sftp_push 'local/dir' 'remote/dir'
	sftp_push() {
		[[ ((${#@} != 2)) ]] && sftp_throw 1 2 ${#@}

		declare -a cmd_lst=('mirror -RrPc')

		sftp_checkLocalExist ${1} || sftp_throw 3 "${LSRC}" ${1} 
		sftp_checkLocalIsDir ${1} || sftp_throw 4 "${LSRC}" ${1} '0' 'put' 

		cmd_lst+=("${1}")

		sftp_checkRemoteIsDir ${2} || sftp_throw 3 "${RDST}" ${2} 

		cmd_lst+=("${2};")

		sftp_work cmd_lst[@] || sftp_throw 0

		return 0
	}

	# Renames/Moves a remote file or directory.
	# @public
	# @args:<string> - The remote source.
	# @args:<string> - The remote destination.
	# @usage: sftp_move [SOURCE]... [DESTINATION]...
	sftp_move() {
		[[ ((${#@} != 2)) ]] && sftp_throw 1 2 ${#@}

		local dst=${2}
		declare -a cmd_lst=('mv')

		sftp_checkRemoteExist ${1} || sftp_throw 3 "${RSRC}" ${1} "${output}"

		cmd_lst+=("${1}")

		sftp_checkRemoteExist ${dst} && { 
			sftp_checkRemoteIsDir ${dst} && {
				[[ "${dst:$((${#dst}-1)):${#dst}}" != '/' ]] && dst+='/'
			} || { 
				sftp_throw 5 "${RDST}" ${dst}
			}	
		} || { 
			[[ $(sftp_checkRemoteExist ${dst%/*}) && $(sftp_checkRemoteIsDir ${dst%/*}) ]] || sftp_throw 3 "remote parent directory" "${dst%/*}"
		}
			
		cmd_lst+=("${dst};")

		sftp_work cmd_lst[@] || sftp_throw 0

		return 0
	}
	
	
	# Create a remote directory
	# @public
	# @args:<string> - The remote directory
	# @usage: sftp_mkdir [REMOTE_DIR]...
	sftp_mkdir() {
		[[ ((${#@} < 1 || ${#@} > 2)) ]] && sftp_throw 1 "1-2" "${#@}"
		
		local dir=${1}
		local regex='^(\/)?\w+\/\w+(\/\w+)?{1,}(\/)?'
		declare -a cmd_lst=( "mkdir" )

		[[ ${dir} =~ ${regex} ]] || throw "AccessFailed" "The parent of the directory you are attempting to created is the root of the remote."
		
		[ ${2} ] && { [[ "${2}" == "p" ]] || sftp_throw 2 ${2}; cmd_lst+=("-${2}"); }
		
		[ ${2} ] || { 
			sftp_checkRemoteIsDir ${dir%/*} || sftp_throw 3 "remote parent directory" "${dir%/*}"
		}
			
		sftp_checkRemoteExist ${dir} && { 
			sftp_checkRemoteIsDir ${dir} && sftp_throw 5 "remote directory" "${dir}"
		}
	
		cmd_lst+=( "${1};" )

		sftp_work cmd_lst[@] || sftp_throw 0

		return 0
	}

	# Utilized in order to throw common errors that may occure in sftp_module.
	# @private
	# @args:<integer> - The index of the corresponding error to throw.
	# @args:<string> - Additional argument to pass to the call to throw.
	sftp_throw() {
		private

		local exp="InvalidArgument"
		local msg=''
		local x=''

		[[ ${1} =~ (3|4|5) ]] && exp="AccessFailed"

		case ${1} in
			0) exp="FatalError"; msg="${FUNCNAME[1]} failed to execute with the error: ${output}"
				;;
			1) msg="Invalid number of arguments provided; expected ${2} parameters recieved ${3}"
				;;
			2) msg="Currently not a support ${FUNCNAME[1]} option: ${2}"
				;;
			3) msg="The ${2}, '${3}', does not exist or is inaccessible"; [ "${4}" ] && msg+="; error: ${4}"
				;;
			4) [[ ((${4} == 1)) ]] && x='is' || x='is not'; msg="The ${2}, '${3}', ${x} a directory, use sftp_${5} instead."
				;;
			5) msg="The ${2}, '${3}, already exists"	
		esac

		throw "${exp}" "${msg}"		
	}

	# Utilized in order to check whether or not the remote file or directory exist.
	# @private 
	# @args:<string> - Remote file or directory to check 
	sftp_checkRemoteExist() {
		private
		declare -a fnd_cmd=("cls -1q ${1};")
		sftp_work fnd_cmd[@] &> /dev/null || {
			[[ "${output%:*}" == "Fatal error" ]] && sftp_throw 0 
			return 1
		}
		return 0	
	}

	# Utilized in order to determine if the remote file is a directory.
	# @private
	# @args:<string> - Remote file to check
	sftp_checkRemoteIsDir() {
		private
		sftp_list ${1} 'ld' 2> /dev/null | grep -P -i -o -q  '^d.{9}' && return 0
		return 1
	}
	
	# Utilized order to determine if the local file or directory exist.
	# @private
	# @args:<string> - Local file or directory to check
	sftp_checkLocalExist() {
		private
		[[ -r ${1} ]] && return 0

		return 1
	}

	# Check to see if the provided destination is a direactory, is accessable and is capable of being written to by the UID
	# of the current process.
	# @private
	# @args:<string> - The local directory that shall act as the destination.
	sftp_checkLocalIsDir() {
		private
		[[ (-d ${1}) && (-x ${1}) && (-w ${1}) ]] && return 0
		return 1
	}

	# Utilized in order to build the lftp command and executes it.
	# @private
	# @args:<array> - An array containing all the commands to pass to lftp.
	# @return:<boolean>
	sftp_work() {
		private
		declare -a cmd_lst=("${!1}")
		local out
		
		local cmd="set net:reconnect-interval-base 5; set net:max-retries 2; $(printf "%s " "${cmd_lst[@]}") bye"

		{ output=$(lftp -u "${ftpuser},${ftppasswd}" sftp://${sftp_rmt_hst} -e "${cmd}" 2>&1 1>&$out); } {out}>&1 && return 0
		#lftp -u "${ftpuser},${ftppasswd}" sftp://${sftp_rmt_hst} -e "${cmd}"

		return 1
	}

	sftp_initialize ${@}
}

# Utilized in order to  throw an error whenever there is an attempt to utilize a provide 
# function declared within the sftp_module.
# @private
private() {
	$(echo ${FUNCNAME[2]} | grep -P -i -q '^sftp_\w+?') || throw "IllegalAccessError" "Attempt to utilize private function: ${FUNCNAME[0]}."	
}

sftp ${@}
#(1|B|d|s|l|h|k|D|S)
#$(sftp_list 'test' '1z')
#sftp_list 'test' '1B'
#sftp_list 'test' 'lh'
#$(sftp_list 'test' 'lm')
#$(sftp_get > ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_get 'test1.txt,test2.txt,x.nope' '/home/rosegr01/lock' 'bar' >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_get 'test1.txt,test2.txt,x.nope' '/home/rosegr01/open' >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_get 'test1.txt,test2.txt' '/home/rosegr01/lock' >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_get 'test' '/home/rosegr01/open' >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_get 'test1.txt,test2.txt' '/home/rosegr01/open' &>> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_pull >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_pull 'nope' "${NAMESPACE}tmp/ldst" 'blah' >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_pull 'nope' "${NAMESPACE}tmp/ldst" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_pull 'test' "${NAMESPACE}tmp/nope" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_pull 'test1.txt' "${NAMESPACE}tmp/ldst" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_pull 'rsrc' "${NAMESPACE}tmp/ldst" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_put >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_put "${NAMESPACE}tmp/lsrc/nope" "rdst" "blah" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_put "${NAMESPACE}tmp/lsrc/nope" "rdst" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_put "${NAMESPACE}tmp/lsrc" "rdst" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_put "${NAMESPACE}tmp/lsrc/file1" "nope" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_put "${NAMESPACE}tmp/lsrc/file1" "test1.txt" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_put "${NAMESPACE}tmp/lsrc/file1" "test/bsftp/dst" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_push >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_push "${NAMESPACE}tmp/lsrc/file1" "test/bsftp/dst", "blah" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_push "${NAMESPACE}tmp/lsrc/nope" "test/bsftp/dst" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_push "${NAMESPACE}tmp/lsrc/file1" "test/bsftp/dst" >> ${NAMESPACE}tmp/lsrc/file1)
#$(sftp_push "${NAMESPACE}tmp/lsrc" "nope" >> ${NAMESPACE}tmp/lsrc/file1)
#sftp_move "test/sftp/src/_20170610" "not/real/destination/20170610"
