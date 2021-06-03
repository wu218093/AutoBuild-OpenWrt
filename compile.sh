#/bin/bash
echo
echo
echo "本脚本仅适用于在Ubuntu环境下编译"
echo
echo
sleep 2s
sudo apt-get update
sudo apt-get upgrade

sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs gcc-multilib g++-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler ccache xsltproc rename antlr3 gperf curl screen upx



clear 
echo
echo 
echo 
echo "|*******************************************|"
echo "|                                           |"
echo "|                                           |"
echo "|           基本环境部署完成......          |"
echo "|                                           |"
echo "|                                           |"
echo "|*******************************************|"
echo
echo


if [ "$USER" == "root" ]; then
	echo
	echo
	echo "请勿使用root用户编译，换一个普通用户吧~~"
	sleep 3s
	exit 0
fi





rm -Rf openwrt

echo "
1. Lede_source
2. Lienol_source
3. Project_source
4. Spirit_source
5. Exit
"

while :; do

read -p "你想要编译哪个源码,请选择1-4回车,选择5回车为退出？ " CHOOSE

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
	9)	exit 0
	;;

esac
done

read -p "请输入您的github地址: " Github
Github=${Github:-"https://github.com/coolsnowwolf/lede"}
echo "您的后台地址为: $ip"
Apidz="${Github##*com/}"
Author="${Apidz%/*}"
Cangku="${Github##*${Author}/}"

if [[ $firmware == "Lede_source" ]]; then
    git clone -b master --single-branch https://github.com/coolsnowwolf/lede openwrt
    
elif [[ $firmware == "Lienol_source" ]]; then
    git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrt
    
elif [[ $firmware == "Project_source" ]]; then
    git clone -b openwrt-18.06 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
    
elif [[ $firmware == "Spirit_source" ]]; then
    git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
fi
cp -Rf AutoBuild-OpenWrt/build openwrt/build
git clone --depth 1 -b main https://github.com/281677160/common openwrt/build/common
chmod -R +x openwrt/build/common
chmod -R +x openwrt/build/${firmware}
source openwrt/build/${firmware}/settings.ini

Home="$PWD/openwrt"
PATH1="$PWD/openwrt/build/${firmware}"

rm -rf AutoBuild-OpenWrt
mv -f openwrt/build/common/Convert.sh openwrt
mv -f openwrt/build/common/*.sh openwrt/build/${firmware}
cd openwrt
./scripts/feeds clean && ./scripts/feeds update -a
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
source build/${firmware}/common.sh && Diy_all
bash build/${firmware}/$DIY_PART_SH
if [ -n "$(ls -A build/${firmware}/diy" 2>/dev/null)" ]; then
    cp -Rf build/${firmware}/diy/* ./
fi
if [ -n "$(ls -A build/${firmware}/files 2>/dev/null)" ]; then
    cp -Rf build/${firmware}/files ./ && chmod -R +x files
fi
if [ -n "$(ls -A build/${firmware}/patches 2>/dev/null)" ]; then
    find build/${firmware}/patches -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward --no-backup-if-mismatch"
fi
if [[ "${REPO_BRANCH}" =~ (21.02|openwrt-21.02) ]]; then
    /bin/bash ./Convert.sh
fi
./scripts/feeds update -a && ./scripts/feeds install -a
[ -e build/${firmware}/$CONFIG_FILE ] && mv build/${firmware}/$CONFIG_FILE .config
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    echo "Compile_Date=$(date +%Y%m%d%H%M)" > $GITHUB_WORKSPACE/Openwrt.info
    source build/${firmware}/upgrade.sh && Diy_Part1
fi
make menuconfig
make defconfig
if [ `grep -c "CONFIG_TARGET_x86_64=y" .config` -eq '1' ]; then
    echo "x86-64" > DEVICE_NAME
[ -s DEVICE_NAME ] && echo "TARGET_PROFILE=$(cat DEVICE_NAME)"
elif [ `grep -c "CONFIG_TARGET.*DEVICE.*=y" .config` -eq '1' ]; then
    grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
    [ -s DEVICE_NAME ] && echo "TARGET_PROFILE=$(cat DEVICE_NAME)"
else
    echo "TARGET_PROFILE=armvirt"
fi
source build/${firmware}/common.sh && Diy_chuli
if [ "${REGULAR_UPDATE}" == "true" ]; then
    source build/${firmware}/upgrade.sh && Diy_Part2
fi
echo
echo
echo
echo "                      *****5秒后开始编译*****
1.你可以随时按Ctrl+C停止编译
3.大陆用户编译前请准备好梯子,使用大陆白名单或全局模式"
echo
echo
echo
sleep 3s

make -j$(($(nproc)+1)) download -j$(($(nproc)+1)) &
make -j$(($(nproc)+1)) || make -j1 V=s

if [ "$?" == "0" ]; then
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source build/${firmware}/upgrade.sh && Diy_Part3
fi
echo "
编译完成~~~
初始用户名密码: root  root
"
fi
