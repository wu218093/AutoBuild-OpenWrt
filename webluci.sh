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
	TIME g "请勿使用root用户编译，换一个普通用户吧~~"
	sleep 3s
	exit 0
fi
echo
df -h
echo
echo
Ubuntu_lv="$(df -h | grep "/dev/mapper/ubuntu--vg-ubuntu--lv" | awk '{print $4}' | awk 'NR==1')"
Ubuntu_kj="${Ubuntu_lv%?}"
TIME z "您当前系统可用空间为${Ubuntu_kj}G"
echo
if [[ "${Ubuntu_kj}" -lt "30" ]];then
	TIME && read -p "可用空间小于 30G 编译容易出错,是否继续? [y/N]: " YN
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


echo
while :; do

TIME && read -p "请选择是否需要执行 make menuconfig 增删插件命令? [y/N]: " MENU

case $MENU in
	[Yy])
		Menuconfig="YES"
	break
	;;
	[Nn])
		Menuconfig="NO"
	break
	;;
esac
done
echo
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

chmod -R +x build/common
chmod -R +x build/${firmware}
source build/${firmware}/settings.ini

Home="$PWD/openwrt"
PATH1="$PWD/openwrt/build/${firmware}"

echo
TIME g "正在加载自定义文件,请耐心等候~~~"
echo
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
source build/$firmware/$DIY_PART_SH
./scripts/feeds update -a && ./scripts/feeds install -a
./scripts/feeds install -a
[ -e build/$firmware/$CONFIG_FILE ] && mv build/$firmware/$CONFIG_FILE .config
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
if [ `grep -c "CONFIG_TARGET_x86_64=y" .config` -eq '1' ]; then
          echo "x86-64" > DEVICE_NAME
          [ -s DEVICE_NAME ] && TARGET_PROFILE="$(cat DEVICE_NAME)"
	  rm -rf DEVICE_NAME
elif [ `grep -c "CONFIG_TARGET.*DEVICE.*=y" .config` -eq '1' ]; then
          grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
          [ -s DEVICE_NAME ] && TARGET_PROFILE="$(cat DEVICE_NAME)"
else
          TARGET_PROFILE="armvirt"
fi
if [ "${REGULAR_UPDATE}" == "true" ]; then
          source build/$firmware/upgrade.sh && Diy_Part2
fi
echo
echo
TIME y "*****10秒后开始编译*****"
echo
TIME g "你可以随时按Ctrl+C停止编译"
echo
TIME z "大陆用户编译前请准备好梯子,使用大陆白名单或全局模式"
echo
echo
sleep 8s
TIME g "正在下载插件包"
make -j8 download
echo
TIME g "开始编译固件,时间有点长,请耐心等待..."
echo
make -j$(($(nproc) + 1)) V=s

if [ "$?" == "0" ]; then
TIME y "
编译完成~~~
初始用户名密码: root  root
"
fi
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source build/${firmware}/upgrade.sh && Diy_Part3
fi
