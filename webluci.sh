#/bin/bash

TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
echo

if [ "$USER" == "root" ]; then
	echo
	echo
	TIME r "请勿使用root用户编译，换一个普通用户吧~~"
	echo
	sleep 3s
	exit 0
fi
echo
df -h
echo
Ubuntu_lv="$(df -h | grep "/dev/mapper/ubuntu--vg-ubuntu--lv" | awk '{print $4}' | awk 'NR==1')"
Ubuntu_kj="${Ubuntu_lv%?}"
echo
if [[ "${Ubuntu_kj}" -lt "80" ]];then
	TIME z "您当前系统可用空间为${Ubuntu_kj}G"
	echo ""
	TIME && read -p "可用空间小于[ 30G ]编译容易出错,是否继续? [y/N]: " YN
	case ${YN} in
		[Yy])
			echo ""
		;;
		[Nn]) 
			echo ""
			TIME r  "取消编译,请清理Ubuntu空间..."
			echo ""
			rm -rf AutoBuild-OpenWrt
			sleep 3s
			exit 0
		;;
	esac
fi
echo

if [[ -n "$(ls -A "openwrt/Lede_source" 2>/dev/null)" ]]; then
          firmware="Lede_source"
elif [[ -n "$(ls -A "openwrt/Lienol_source" 2>/dev/null)" ]]; then
          firmware="Lienol_source"
elif [[ -n "$(ls -A "openwrt/Project_source" 2>/dev/null)" ]]; then
          firmware="Project_source"
elif [[ -n "$(ls -A "openwrt/Spirit_source" 2>/dev/null)" ]]; then
          firmware="Spirit_source"
fi
if [[ `grep -c "CONFIG_TARGET_x86_64=y" openwrt/.config` -eq '1' ]]; then
          TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" openwrt/.config` -eq '1' ]]; then
          TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" openwrt/.config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
          TARGET_PROFILE="armvirt"
fi
echo
while :; do

TIME g "你正在使用[ ${firmware} ]编译[ ${TARGET_PROFILE} ]固件,是否需要更换源码?" && read -p " [Y/y确认，N/n否定]： " GHYM

case $GHYM in
	[Yy])
		git clone https://github.com/281677160/AutoBuild-OpenWrt && bash AutoBuild-OpenWrt/compile.sh
	break
	;;
	[Nn])
		TIME r  ""
	break
	;;
esac
done
echo
echo
while :; do

TIME g "是否把定时更新插件编译进固件,要定时更新得把固件上传在github的Releases?"  && read -p " [Y/y确认，N/n否定]： " RELE

case $RELE in
	[Yy])
		REG_UPDATE="true"
	break
	;;
	[Nn])
		REG_UPDATE="false"
		echo
		TIME r "您放弃了把定时更新插件编译进固件!"
	break
	;;
esac
done
echo
echo
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
TIME g "请输入Github地址[ 直接回车默认https://github.com/281677160/AutoBuild-OpenWrt ]"  && read -p " 请输入Github地址： " Github
Github=${Github:-"https://github.com/281677160/AutoBuild-OpenWrt"}
echo
echo
TIME y "您的Github地址为：$Github"
Apidz="${Github##*com/}"
Author="${Apidz%/*}"
CangKu="${Apidz##*/}"
fi
echo
echo
while :; do

TIME g "是否需要执行[make menuconfig]命令来增删插件?" && read -p " [Y/y确认，N/n否定]： " MENU

case $MENU in
	[Yy])
		Menuconfig="YES"
		echo
		TIME y "您选择了执行[make menuconfig]命令!"
	break
	;;
	[Nn])
		Menuconfig="NO"
		echo
		TIME r "您放弃执行[make menuconfig]命令!"
	break
	;;
esac
done
echo
Github="${https://github.com/281677160/AutoBuild-OpenWrt}"
Apidz="${Github##*com/}"
Author="${Apidz%/*}"
CangKu="${Apidz##*/}"
echo
if [[ $firmware == "Lede_source" ]]; then
	  ZZZ="package/lean/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
elif [[ $firmware == "Lienol_source" ]]; then
	  ZZZ="package/default-settings/files/zzz-default-settings"
          OpenWrt_name="19.07"
elif [[ $firmware == "Project_source" ]]; then
	  ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
elif [[ $firmware == "Spirit_source" ]]; then
	  ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="21.02"
fi

chmod -R +x openwrt/build/common
chmod -R +x openwrt/build/${firmware}
source openwrt/build/${firmware}/settings.ini
REGULAR_UPDATE="REG_UPDATE"

Home="$PWD/openwrt"
PATH1="$PWD/openwrt/build/${firmware}"

echo
TIME g "正在加载自定义文件,请耐心等候~~~"
echo
cd openwrt
git pull
if [[ "${REPO_BRANCH}" == "master" ]]; then
          source build/${firmware}/common.sh && Diy_lede
          cp -Rf build/common/LEDE/files ./
          cp -Rf build/common/LEDE/diy/* ./
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
          source build/${firmware}/common.sh && Diy_lienol
          cp -Rf build/common/LIENOL/files ./
          cp -Rf build/common/LIENOL/diy/* ./
elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
          source build/${firmware}/common.sh && Diy_1806
          cp -Rf build/common/PROJECT/files ./
          cp -Rf build/common/PROJECT/diy/* ./
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
          source build/${firmware}/common.sh && Diy_2102
          cp -Rf build/common/SPIRIT/files ./
          cp -Rf build/common/SPIRIT/diy/* ./
fi
if [ -n "$(ls -A "build/$firmware/diy" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/diy/* ./
fi
if [ -n "$(ls -A "build/$firmware/files" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/files ./ && chmod -R +x files
fi
if [ -n "$(ls -A "build/$firmware/patches" 2>/dev/null)" ]; then
          find "build/$firmware/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward"
fi
if [[ "${REPO_BRANCH}" =~ (21.02|openwrt-21.02) ]]; then
          source Convert.sh
fi
echo
TIME g "正在加载源和安装源,请耐心等候~~~"
echo
./scripts/feeds update -a && ./scripts/feeds install -a
./scripts/feeds install -a
[ -e .config_bf ] && mv .config_bf .config
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
          echo "Compile_Date=$(date +%Y%m%d%H%M)" > Openwrt.info
	  source build/$firmware/upgrade.sh && Diy_Part1
fi
find . -name 'LICENSE' -o -name 'README' -o -name 'README.md' | xargs -i rm -rf {}
find . -name 'CONTRIBUTED.md' -o -name 'README_EN.md' | xargs -i rm -rf {}
if [ "${Menuconfig}" == "YES" ]; then
          make menuconfig
else
          TIME y ""
fi
make defconfig
if [[ `grep -c "CONFIG_TARGET_x86_64=y" openwrt/.config` -eq '1' ]]; then
          TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" openwrt/.config` -eq '1' ]]; then
          TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" openwrt/.config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
          TARGET_PROFILE="armvirt"
fi
if [ "${REGULAR_UPDATE}" == "true" ]; then
          source build/$firmware/upgrade.sh && Diy_Part2
fi
echo
echo
TIME y "*****5秒后开始下载DL文件*****"
echo
TIME g "你可以随时按Ctrl+C停止编译"
echo
TIME z "大陆用户编译前请准备好梯子,使用大陆白名单或全局模式"
echo
echo
sleep 3s
TIME g "正在下载插件包,请耐心等待..."
make -j8 download
echo
TIME g "3秒后开始编译固件,时间有点长,请耐心等待..."
sleep 2s
echo -e "$(($(nproc)+1)) thread compile"
make -j$(($(nproc)+1)) || make -j1 V=s

if [ "$?" == "0" ]; then
TIME y "
编译完成~~~
"
fi
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source build/${firmware}/upgrade.sh && Diy_Part3
fi
