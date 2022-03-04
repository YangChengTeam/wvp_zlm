#! /bin/sh

#======================================================================#
#  System Required:  CentOS 7 or Higher                                #
#  GB28181+ZLMediaKit服务 升级脚本                                      #          
#  Author：zhangkai <mzpbvsig@gmail.com>                               #
#======================================================================#

root=/home/wvp

cd ${root}/ZLMediaKit
git pull
git submodule update --init
cd build
cmake ..
make -j4

pm2 restart zlm


