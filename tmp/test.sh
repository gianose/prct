#!/usr/bin/env bash

f() {
	declare var='yes'

	f1() {
		echo "Inner function ${var}"
	}
}

f1

f

echo ${var}

f1
