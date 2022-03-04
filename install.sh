#! /bin/sh

#======================================================================#
#  System Required:  CentOS 7 or Higher                                #
#  GB28181+ZLMediaKit服务 一键安装与启动脚本                             #          
#  Author：zhangkai <mzpbvsig@gmail.com>                               #
#======================================================================#

root=/home/wvp

# Check command is exist
check_command(){
    local command=$1 
    if hash $command 2> /dev/null; then
        return 1
    else
        return 0
    fi
}

if check_command wget; then
    yum -y install wget
fi

if check_command gcc; then
    yum -y install gcc gcc-c++
    yum -y install pcre-devel openssl openssl-devel
fi

# CMake complie by source
if check_command cmake; then
    if [[ ! -e "cmake-3.3.2.tar.gz" ]];then
        cd ${root}
        wget https://cmake.org/files/v3.3/cmake-3.3.2.tar.gz
        tar -xvf cmake-3.3.2.tar.gz
    fi
    cd cmake-3.3.2
    ./configure
    make -j4
    make install
fi

yum -y install epel-release
yum -y update

# Redis install by yum source
if check_command redis-cli; then
    yum -y install redis
    systemctl start redis
    systemctl enable redis
fi

if check_command ffmpeg; then
    sudo rpm -v --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
    sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
    sudo yum install ffmpeg ffmpeg-devel
fi

# ZLMediaKit complie by source
cd ${root}
git clone --depth 1 https://gitee.com/xia-chu/ZLMediaKit
if [[ -d ZLMediaKit ]];then
    cd ZLMediaKit
    git submodule update --init

    cd ZLMediaKit
    mkdir build
    cd build
    cmake ..
    make -j4
fi

# wvp complie by source
if check_command java; then
    yum -y install java
fi

if check_command git; then
    yum -y install git   
fi

if check_command maven; then
    yum -y install maven   
fi

if check_command node; then
    curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
    yum -y install nodejs 
    npm --registry=https://registry.npm.taobao.org install -g pm2
fi

cd ${root}
git clone https://gitee.com/pan648540858/wvp-GB28181-pro.git
if [[ -d wvp-GB28181-pro ]];then
    cd wvp-GB28181-pro/web_src/
    npm --registry=https://registry.npm.taobao.org install
    npm run build
    cd ..
    mvn package
    wvpjar="target/wvp-pro.jar"
    if [[ -e  ${wvpjar} ]];then
    rm -f ${wvpjar}
    fi
    mv target/*.jar ${wvpjar}

fi

cd ${root}
git clone https://github.com/648540858/wvp-pro-assist
if [[ -d wvp-pro-assist ]];then
    cd wvp-pro-assist
    mvn package

    assistjar="target/wvp-pro-assist.jar"
    if [[ -e  ${assistjar} ]];then
    rm -f ${assistjar}
    fi
    mv target/*.jar ${assistjar}
fi

cd ${root}
if [[ -d ZLMediaKit ]];then
    mkdir -p ${root}/ZLMediaKit/release/linux/Debug/www/record
    cp -f zlm.ini  ${root}/ZLMediaKit/release/linux/Debug/config.ini
    pm2 start zlm.sh
fi

if [[ -d wvp-GB28181-pro ]];then
    cp -f wvp-pro.yml ${root}/wvp-GB28181-pro/target/application.yml
    pm2 start wvp-pro.sh
fi


if [[ -d wvp-pro-assist ]];then
    cp -f assist.yml ${root}/wvp-pro-assist/target/application.yml
    pm2 start assist.sh
fi






