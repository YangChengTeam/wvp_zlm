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

yum -y wget
yum -y install gcc gcc-c++
yum -y install pcre-devel openssl openssl-devel

# Nginx complie by source
if check_command cmake; then
    if [[ ! -d nginx ]]; then
        mkdir nginx
    fi
    wget https://nginx.org/download/nginx-1.20.2.tar.gz
    tar -xvf nginx-1.20.2.tar.gz
    cd nginx-1.20.2
    ./configure --prefix=${root}/nginx
    make 
    make install
    cd ..
fi

# CMake complie by source
if check_command cmake; then
    wget https://cmake.org/files/v3.3/cmake-3.3.2.tar.gz
    tar -xvf cmake-3.3.2.tar.gz
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
 else

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
yum -y install java git maven nodejs 

git clone https://gitee.com/pan648540858/wvp-GB28181-pro.git
cd wvp-GB28181-pro/web_src/
npm --registry=https://registry.npm.taobao.org install
npm run build

cd ..
mvn package

ls ${root}/wvp-GB28181-pro/target/*.jar > jar.txt
jarfile='jar.txt'
while read name; do
    if [[ $name != "wvp-pro-2.0.jar" ]]; then
       yes | cp -f $name "wvp-pro-2.0.jar"
    fi
done < $jarfile


git clone https://gitee.com/18010473990/wvp-pro-assist.git
cd wvp-pro-assist
mvn package
ls ${root}/wvp-pro-assist/target/*.jar > jar.txt
jarfile='jar.txt'
while read name; do
    if [[ $name != "wvp-pro-assist.jar" ]]; then
       yes | cp -f $name "wvp-pro-assist.jar"
    fi
done < $jarfile


rm -f $jarfile

cd ..
cp -f wvp-pro.yml ${root}/wvp-GB28181-pro/target/application.yml
cp -f assist.yml ${root}/wvp-pro-assist/target/application.yml
cp -f config.ini  ${root}/ZLMediaKit/release/linux/Debug/config.ini
cp -f host-wvp-pro.conf ${root}/nginx/conf/vhost/

npm --registry=https://registry.npm.taobao.org install -g pm2
pm2 stop wvp-pro.json
pm2 start wvp-pro.json
systemctl stop nginx
systemctl start nginx