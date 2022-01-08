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

yum -y install wget
yum -y install gcc gcc-c++
yum -y install pcre-devel openssl openssl-devel

# Nginx complie by source
if check_command nginx; then
    if [[ ! -d nginx ]]; then
        mkdir nginx
    fi
    if [[ ! -e "nginx-1.20.2.tar.gz" ]];then
        wget https://nginx.org/download/nginx-1.20.2.tar.gz
        tar -xvf nginx-1.20.2.tar.gz
    fi
    cd nginx-1.20.2
    ./configure --prefix=${root}/nginx
    make 
    make install
    cp -f nginx /ect/init.d/
    chmod 755 /ect/init.d/nginx
    chkconfig --add nginx
    systemctl enable nginx
    systemctl start nginx
    cd ..
fi

# CMake complie by source
if check_command cmake; then
    if [[ ! -e "cmake-3.3.2.tar.gz" ]];then
        wget https://cmake.org/files/v3.3/cmake-3.3.2.tar.gz
        tar -xvf cmake-3.3.2.tar.gz
    fi
    cd cmake-3.3.2
    ./configure
    make -j4
    make install
    cd ..
fi

# Redis install by yum source
if check_command redis-cli; then
    yum -y install epel-release
    yum -y update
    yum -y install redis
    systemctl start redis
    systemctl enable redis
fi

sudo rpm -v --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
sudo yum install ffmpeg ffmpeg-devel

# ZLMediaKit complie by source
git clone --depth 1 https://gitee.com/xia-chu/ZLMediaKit
cd ZLMediaKit
git submodule update --init

cd ZLMediaKit
mkdir build
cd build
cmake ..
make -j4

# wvp complie by source
yum -y install java git maven  
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
yum -y install nodejs    

git clone https://gitee.com/pan648540858/wvp-GB28181-pro.git
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


git clone https://github.com/648540858/wvp-pro-assist
cd wvp-pro-assist
mvn package

assistjar="target/wvp-pro-assist.jar"
if [[ -e  ${assistjar} ]];then
   rm -f ${assistjar}
fi
mv target/*.jar ${assistjar}


cd ..
cp -f wvp-pro.yml ${root}/wvp-GB28181-pro/target/application.yml
cp -f assist.yml ${root}/wvp-pro-assist/target/application.yml
cp -f zlm.ini  ${root}/ZLMediaKit/release/linux/Debug/config.ini
yes | cp -f nginx.conf ${root}/nginx/conf/
cp -f host-wvp-pro.conf ${root}/nginx/conf/vhost/

npm --registry=https://registry.npm.taobao.org install -g pm2
pm2 start wvp-pro.json




