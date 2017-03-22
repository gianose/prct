#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 

source ${DIR}'/../lib/logger.sh'
v(){
	w
}
w(){
	x
}

x(){
	y
}

y(){
	z
}

z(){
	_l=${#FUNCNAME[@]}
	echo ${FUNCNAME[1]}
}

v
