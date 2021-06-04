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
echo
TIME z "|*******************************************|"
TIME g "|                                           |"
TIME r "|     本脚本仅适用于在Ubuntu环境下编译      |"
TIME g "|                                           |"
TIME y "|    首次编译,请输入Ubuntu密码继续下一步    |"
TIME g "|                                           |"
TIME g "|*******************************************|"
echo
echo
sleep 2s

sudo apt-get update
sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync

clear
echo
echo
TIME g "|*******************************************|"
TIME z "|                                           |"
TIME b "|                                           |"
TIME y "|           基本环境部署完成......          |"
TIME z "|                                           |"
TIME g "|                                           |"
TIME z "|*******************************************|"
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
if [[ "${Ubuntu_kj}" -lt "80" ]];then
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
rm -Rf openwrt

TIME g "1. Lede_source"
echo
TIME g "2. Lienol_source"
echo
TIME g "3. Project_source"
echo
TIME g "4. Spirit_source"
echo
TIME r "5. Exit"
echo
echo

while :; do

TIME && read -p "请选择源码？输入1-4选择然后回车,选择5回车为退出！ " CHOOSE

case $CHOOSE in
	1)
		firmware="Lede_source"
	break
	;;
	2)
		firmware="Lienol_source"
	break
	;;
	3)
		firmware="Project_source"
	break
	;;
	4)
		firmware="Spirit_source"
	break
	;;
	5)	exit 0
	;;

esac
done
echo
echo
TIME g "正在下载源码中,请耐心等候~~~"
echo
if [[ $firmware == "Lede_source" ]]; then
          git clone -b master --single-branch https://github.com/coolsnowwolf/lede openwrt
          git clone https://github.com/fw876/helloworld openwrt/package/luci-app-ssr-plus
          git clone https://github.com/xiaorouji/openwrt-passwall openwrt/package/luci-app-passwall
          ZZZ="package/lean/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
          REPO_BRANCH="master"
elif [[ $firmware == "Lienol_source" ]]; then
          git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrt
          git clone https://github.com/fw876/helloworld openwrt/package/luci-app-ssr-plus
          git clone https://github.com/xiaorouji/openwrt-passwall openwrt/package/luci-app-passwall
          ZZZ="package/default-settings/files/zzz-default-settings"
          OpenWrt_name="19.07"
          REPO_BRANCH="19.07"
elif [[ $firmware == "Project_source" ]]; then
          git clone -b openwrt-18.06 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
          ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
          REPO_BRANCH="openwrt-18.06"
elif [[ $firmware == "Spirit_source" ]]; then
          git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
          ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="21.02"
          REPO_BRANCH="openwrt-21.02"
fi
cp -Rf AutoBuild-OpenWrt/build openwrt/build
chmod -R +x openwrt/build/${firmware}

rm -rf AutoBuild-OpenWrt
echo
TIME g "正在加载自定义文件,请耐心等候~~~"
echo
cd openwrt
./scripts/feeds clean && ./scripts/feeds update -a
if [[ "${REPO_BRANCH}" == "master" ]]; then
          find . -name 'luci-app-netdata' -o -name 'luci-theme-argon' -o -name 'k3screenctrl' | xargs -i rm -rf {}
	  sed -i 's/iptables -t nat/# iptables -t nat/g' "${ZZZ}"
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
          find . -name 'luci-app-netdata' -o -name 'luci-theme-argon' | xargs -i rm -rf {}
elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
          find . -name 'luci-theme-argonv3' -o -name 'luci-app-argon-config' -o -name 'luci-theme-argon'  | xargs -i rm -rf {}
          find . -name 'luci-theme-argonv2' -o -name 'luci-app-timecontrol' | xargs -i rm -rf {}
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
          find . -name 'luci-app-argon-config' -o -name 'luci-theme-argon'  | xargs -i rm -rf {}
fi
git clone --depth 1 -b "${REPO_BRANCH}" https://github.com/281677160/openwrt-package
cp -Rf feeds/luci/applications/* ./package/lean/
cp -Rf feeds/luci/themes/* ./package/lean/
rm -rf feeds/luci
cp -Rf openwrt-package/* ./ && rm -rf openwrt-package
if [ -n "$(ls -A "build/$firmware/diy" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/diy/* ./
fi
if [ -n "$(ls -A "build/$firmware/files" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/files ./ && chmod -R +x files
fi
if [ -n "$(ls -A "build/$firmware/patches" 2>/dev/null)" ]; then
          find "build/$firmware/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward"
fi
echo
TIME g "正在加载源和安装源,请耐心等候~~~"
echo
source build/$firmware/diy-part.sh
./scripts/feeds update -a && ./scripts/feeds install -a
./scripts/feeds install -a
[ -e build/$firmware/.config ] && mv build/$firmware/.config .config
echo
echo
make menuconfig
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
make -j8 download V=s
make -j8 download
echo
TIME g "开始编译固件,时间有点长,请耐心等待..."
echo
make -j1 V=s

if [ "$?" == "0" ]; then
TIME y "
编译完成~~~
初始用户名密码: root  root
"
fi
