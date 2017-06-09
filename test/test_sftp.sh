#!/usr/bin/env bash
# @author: Gregory Rose
# @created: 20170602
# @name: Test sftp
# @path: test/test_sftp.sh
# Utilized in order to test that the sftp module is working as expected.
# NOTE: In order to test a fata error scenario, spool up a sftp server VM, and stop SSHD.

declare TST_SFTP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${TST_SFTP_DIR}/../lib/const.sh"
source "${NAMESPACE}lib/sftp.sh" 
source "${NAMESPACE}lib/unittest.sh"

declare TST_SFTP_TMP="${NAMESPACE}tmp"

declare TST_SFTP_LPRP="${TST_SFTP_TMP}/prp"
declare TST_SFTP_LSRC="${TST_SFTP_TMP}/src"
declare TST_SFTP_LDST="${TST_SFTP_TMP}/dst"

declare -a TST_SFTP_LFILES=( "${TST_SFTP_LSRC}/_20170607" "${TST_SFTP_LSRC}/_20170608" "${TST_SFTP_LDST}/_20170610" )
declare -a TST_SFTP_RFILES=( "${TST_SFTP_LPRP}/_20170606" "${TST_SFTP_LPRP}/_20170609" "${TST_SFTP_LPRP}/_20170610" )

declare TST_SFTP_RDIR="test/sftp"

declare TST_SFTP_RSRC="${TST_SFTP_RDIR}/src"
declare TST_SFTP_RDST="${TST_SFTP_RDIR}/dst"
declare TST_SFTP_RARC="${TST_SFTP_RDIR}/arc"
declare TST_SFTP_RMDR="${TST_SFTP_RARC}/$(date +%Y%m%d%I%M%S)"

declare TST_SFTP_TTL='Testing `lib/sftp.sh`'

declare -a TST_SFTP_ERROR=(
	"sftp::sftp_initialize - Exception: Attempt to initialize sftp with too many parameters;113;foo;bar"
	"sftp::sftp_initialize - Exception: Attempt to initialize sftp with a unreachable host;110;not.real.host.com"
	"sftp::sftp_list - Exception: Attempt to call sftp_list with no params;113"
	"sftp::sftp_list - Exception: Attempt to call sftp_list with more than two params;113;foo;bar;blah"
	"sftp::sftp_list - Exception: Attempt to call sftp_list with an unknown option;113;test/bsftp/arch;a"
	"sftp::sftp_list - Exception: Attempt to call sftp_list with a known and a unknown option;113;test/bsftp/arch;1x"
	"sftp::sftp_list - Exception: Attempt to call sftp_list to list the content of a nonexistant directory;105;not/real;1"
	"sftp::sftp_get - Exception: Attempt to call sftp_get with less than two params;113"
	"sftp::sftp_get - Exception: Attempt to call sftp_get with more than two params;113;foo;bar;blah"
	"sftp::sftp_get - Exception: Attempt to get a remote files that does not exist;105;foo;${TST_SFTP_LDST}"
	"sftp::sftp_get - Exception: Attempt to get a remote directory;105;test/sftp/src;${TST_SFTP_LDST}"
	"sftp::sftp_get - Exception: Attempt to get a remote file in a local directory that does not exist;105;${TST_SFTP_RSRC}/_20170606;/not/real/"
	"sftp::sftp_put - Exception: Attempt to call sftp_pull with less than two params;113"
	"sftp::sftp_put - Exception: Attempt to call sftp_pull with more than two params;113;foo;bar;blah"
	"sftp::sftp_put - Exception: Attempt to put a local file that does not exist;105;foo;${TST_SFTP_RDST}"
	"sftp::sftp_put - Exception: Attempt to put a local directory;105;${TST_SFTP_LSRC};${TST_SFTP_RDST}"
	"sftp::sftp_put - Exception: Attempt to put a local file in a remote destination that does not exist;105;${TST_SFTP_LSRC}/_20170607;not/real/"
	"sftp::sftp_pull - Exception: Attempt to call sftp_pull with less than two params;113"
	"sftp::sftp_pull - Exception: Attempt to call sftp_pull with more than two params;113;foo;bar;blah"
	"sftp::sftp_pull - Exception: Attempt to pull a remote directory that does not exist;105;foo;${TST_SFTP_LDST}"
	"sftp::sftp_pull - Exception: Attempt to pull a remote file;105;${TST_SFTP_RSRC}/_20170606;${TST_SFTP_LDST}"
	"sftp::sftp_pull - Exception: Attempt to pull a remote directory to a local destination that does not exist;105;${TST_SFTP_RSRC};/not/real/"
	"sftp::sftp_push - Exception: Attempt to call sftp_push with less than two params;113"
	"sftp::sftp_push - Exception: Attempt to call sftp_push with more than two params;113;foo;bar;blah"
	"sftp::sftp_push - Exception: Attempt to push a local directory that does not exist;105;foo;${TST_SFTP_RDST}"
	"sftp::sftp_push - Exception: Attempt to push a local file;105;${TST_SFTP_LSRC}/_20170607;${TST_SFTP_RSRC}"
	"sftp::sftp_push - Exception: Attempt to push a local directory in a remote destination that does not exist;105;${TST_SFTP_LSRC};not/real/"
	"sftp::sftp_move - Exception: Attempt to call sftp_move with less than two params;113"
	"sftp::sftp_move - Exception: Attempt to call sftp_move with more than two params;113;foo;bar;blah"
	"sftp::sftp_move - Exception: Attempt to move a file/directory that does not exist;105;${TST_SFTP_RSRC}/_20170611;${TST_SFTP_RSRC}/20170611"
	"sftp::sftp_move - Exception: Attempt to move a file/directory to a destination that does not exist;105;${TST_SFTP_RSRC}/_20170610;not/real/dst/20170610"
	"sftp::sftp_move - Exception: Attempt to move a file/directory to a destination that already exist;105;${TST_SFTP_RSRC}/_20170610;${TST_SFTP_RSRC}/_20170609"
	"sftp::sftp_mkdir - Exception: Attempt to call sftp_mkdir with less than ONE params;113"
	"sftp::sftp_mkdir - Exception: Attempt to call sftp_mkdir with more than TWO params;113;foo;bar;blah"
	"sftp::sftp_mkdir - Exception: Attempt to call sftp_mkdir with an invalied option;113;${TST_SFTP_RMDR};P"
	"sftp::sftp_mkdir - Exception: Attempt to create a directory in the root of the remote;105;foo"
	"sftp::sftp_mkdir - Exception: Attempt to create a directory non-recursively in non-existant parent;105;${TST_SFTP_RARC}/parent/child"
	"sftp::sftp_mkdir - Exception: Attempt to create a directory that already exist;105;${TST_SFTP_RDST}"
)

declare -a TST_SFTP_CORRECT=(
	"sftp::sftp_list - List content of directory;0;${TST_SFTP_RSRC}"
	"sftp::sftp_list - List content of direcotry, utilizing supported option;0;${TST_SFTP_RSRC};l"
	""
)

tst_sftp_main(){
	printf "%s\n" "${TST_SFTP_TTL}"
	tst_sftp_error
	#tst_sftp_prepLocal
	#tst_sftp_prepRemote
}

# Test a majority of the possible scenarios which would cause sftp.sh to throw an error.
tst_sftp_error() {
	printf "%8s\n" "ERRORS"
	runMultiInput TST_SFTP_ERROR[@] '' 1
}

tst_sftp_prepLocal() {
	declare -a _l=("${TST_SFTP_LSRC}" "${TST_SFTP_LDST}" "${TST_SFTP_LPRP}")

	tst_sftp_print

	tst_sftp_prepLocalDir _l[@]
	tst_sftp_prepLocalFiles TST_SFTP_RFILES[@]
	tst_sftp_prepLocalFiles TST_SFTP_LFILES[@]	
}

# Preps and calls the necessary variables and functions in or to prepare the remote test envirnment.
# @public
tst_sftp_prepRemote() {
	declare -a _r=("${TST_SFTP_RARC}" "${TST_SFTP_RDST}" "${TST_SFTP_RSRC}")
	
	tst_sftp_print

	tst_sftp_prepRemoteDir _r[@]
	tst_sftp_cleanRemote _r[@]
	tst_sftp_prepRemoteFiles
}

tst_sftp_prepLocalDir() {
	declare -a _lcl_dirs=("${!1}")
	for lcl_dir in "${_lcl_dirs[@]}"; do
		if [ ! -d ${lcl_dir} ]; then 
			$(mkdir ${lcl_dir}) && tst_sftp_print 0 0 "${lcl_dir}"
		else
			tst_sftp_print 0 1 "${lcl_dir}"
		fi 
	done
	for lcl_dir in "${_lcl_dirs[@]}"; do
		if [[ $(ls -1 ${lcl_dir}) ]]; then
			for cnt in $(find ${lcl_dir} -maxdepth 1 ! -path ${lcl_dir}); do
				if [ -f ${cnt} ]; then
					$(rm ${cnt}) && tst_sftp_print 0 2 "${lcl_dir}" 
				fi
				if [ -d ${cnt} ]; then
					$(rm -rf ${cnt}) && tst_sftp_print 0 2 "${lcl_dir}"
				fi
			done
		fi
	done
}

tst_sftp_prepLocalFiles() {
	declare -a _lcl_files=("${!1}")
	for file in "${_lcl_files[@]}"; do
		$(touch ${file}) && tst_sftp_print 0 1 "${file##*/}" "${file%/*}"
	done
}

# Create directories on the remote.
# @private
# @args:<array> - list of directories
tst_sftp_prepRemoteDir() {
	declare -a _rmt_dirs=("${!1}")
	for rmt_dir in "${_rmt_dirs[@]}"; do
		$(sftp_mkdir "${rmt_dir}" "p" &>/dev/null)
		case ${?} in
			105) tst_sftp_print 0 1 ${rmt_dir};;
			0) tst_sftp_print 0 0 ${rmt_dir};;
		esac
	done
}

# Puts the test files in the remote test envirnment.
# @private
tst_sftp_prepRemoteFiles() {
	for _lcl_file in "${TST_SFTP_RFILES[@]}"; do
		sftp_put ${_lcl_file} ${TST_SFTP_RSRC} 1> /dev/null
		[[ ${?} -eq 0 ]] && tst_sftp_print 0 1 ${_lcl_file##*/} ${TST_SFTP_RSRC}
	done	
}

# Clean the remote test envirnment.
# @private
# @args:<array> - list of directories
tst_sftp_cleanRemote() {
	local stamp=$(date +%Y%m%d%I%M%S)
	declare -a _rmt_cont
	declare -a _rmt_dirs=("${!1}")
	declare regex='^_[0-9]{8}.[0-9]{14}$'
	declare regex2='^(\w+.)?[0-9]{14}$'

	for rmt_dir in "${_rmt_dirs[@]}"; do
		_rmt_cont=($(sftp_list "${rmt_dir}" "1"))
		if [ ${#_rmt_cont[@]} -gt 0 ]; then
			if [ "${rmt_dir}" != "${TST_SFTP_RARC}" ]; then
				for cont in "${_rmt_cont[@]}"; do
					sftp_move "${cont}" "${TST_SFTP_RARC}" 1> /dev/null
					[[ ${?} -eq 0 ]] && tst_sftp_print 0 1 "${cont}" "${TST_SFTP_RARC}" 
				done
			else
				for cont in "${_rmt_cont[@]}"; do
					[[ ${cont##*/} =~ ${regex} || ${cont##*/} =~ ${regex2} ]] && continue
					sftp_move "${cont}" "${cont}.${stamp}" 1> /dev/null
					[[ ${?} -eq 0 ]] && tst_sftp_print 0 0 "${cont}" "${cont}.${stamp}"
				done
			fi
		fi
	done
}

tst_sftp_print() {
	local _out
	local _form="%s\n"
	declare -a _out_opts
	declare -A _output=(
		[tst_sftp_prepLocal]="Preparing local test ENV"
		[tst_sftp_prepLocalDir]="Local test DIR ${3} |already exist.|has been ceated.|has been cleaned"
		[tst_sftp_prepLocalFiles]="Local test file ${3} |has been created in ${4}"
		[tst_sftp_prepRemote]="Preparing remote test ENV"
		[tst_sftp_prepRemoteDir]="Remote test DIR ${3} |already exist.|has been created"
		[tst_sftp_cleanRemote]="Remote test file ${3} |has been archived in ${4}|has been renamed to ${4}"
		[tst_sftp_prepRemoteFiles]="Local test file ${3} |has been put in remote directory ${4}"
		[run_excp]="Performing exception tests"
		[run_proofs]="Performing proofs tests"
	)

	case ${1} in
		0)
			IFS='|' read -r -a _out_opts <<< ${_output[${FUNCNAME[1]}]}
		
			case ${2} in
				0) _out="${_out_opts[0]}${_out_opts[2]}";;
				1) _out="${_out_opts[0]}${_out_opts[1]}";;	
				2) _out="${_out_opts[0]}${_out_opts[3]}";;	
			esac
		
			_form="%$((${#_out}+4))s\n"
			;;
		1)
			_out="${2}: ${3}"
			_form="%$((${#_out}+4))s\n"
			;;
		*)
			_out="${_output[${FUNCNAME[1]}]^^}"
			;;
	esac

	printf "${_form}" "${_out}"
}

tst_sftp_main
