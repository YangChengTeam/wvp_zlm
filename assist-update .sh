#! /bin/sh

#======================================================================#
#  System Required:  CentOS 7 or Higher                                #
#  GB28181+ZLMediaKit服务 升级脚本                                      #          
#  Author：zhangkai <mzpbvsig@gmail.com>                               #
#======================================================================#

root=/home/wvp

cd ${root}/wvp-pro-assist
git pull
mvn package

if [[ -e  "target/wvp-pro-assist" ]];then
   rm -f "target/wvp-pro-assist.jar"
fi
mv target/*.jar "target/wvp-pro-assist.jar"


