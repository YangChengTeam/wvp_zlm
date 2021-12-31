#! /bin/sh

yum -y install gcc
yum -y install gcc-c++

# CMake complie by source
wget https://cmake.org/files/v3.3/cmake-3.3.2.tar.gz
tar -xvf cmake-3.3.2.tar.gz
cd cmake-3.3.2
./configure
make -j4
make install
cd ..

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
yum -y install java git maven nodejs npm
git clone https://gitee.com/pan648540858/wvp-GB28181-pro.git
cd wvp-GB28181-pro/web_src/
npm --registry=https://registry.npm.taobao.org install
npm run build

cd ..
mvn package

npm --registry=https://registry.npm.taobao.org install -g pm2

cd ..
root=/home/wvp
cp -f wvp-pro.yml ${root}/wvp-GB28181-pro/target/application.yml
cp -f assist.yml ${root}/wvp-pro-assist/target/application.yml
cp -f config.ini  ${root}/ZLMediaKit/release/linux/Debug/config.ini

pm2 stop wvp-pro.json
pm2 start wvp-pro.json