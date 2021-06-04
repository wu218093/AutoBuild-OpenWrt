#!/bin/bash
if [ -z "$(ls -A "./openwrt/compile" 2>/dev/null)" ]; then
	source AutoBuild-OpenWrt/compile.sh
else
	source AutoBuild-OpenWrt/webluci.sh
fi
if [[ -n "$(ls -A "Lede_source" 2>/dev/null)" ]]; then
          firmware="Lede_source"
fi
if [[ -n "$(ls -A "Lienol_source" 2>/dev/null)" ]]; then
          firmware="Lienol_source"
fi
if [[ -n "$(ls -A "Project_source" 2>/dev/null)" ]]; then
          firmware="Project_source"
fi
if [[ -n "$(ls -A "Spirit_source" 2>/dev/null)" ]]; then
          firmware="Spirit_source
fi
