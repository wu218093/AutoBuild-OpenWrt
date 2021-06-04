#!/bin/bash
if [ -z "$(ls -A "./openwrt/compile" 2>/dev/null)" ]; then
	source AutoBuild-OpenWrt/compile.sh
else
	source AutoBuild-OpenWrt/webluci.sh
fi
