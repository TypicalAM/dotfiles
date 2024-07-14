#!/usr/bin/bash

command -v "supergfxd" >/dev/null 2>&1 || {
	echo ""
	exit 1
}

mode=$(supergfxctl --get)
[[ $mode == "Vfio" ]] && echo " " && exit
[[ $mode == "Hybrid" ]] && echo " " && exit
echo ""
