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

assistjar="target/wvp-pro-assist.jar"
if [[ -e  ${assistjar} ]];then
   rm -f ${assistjar}
fi
mv target/*.jar ${assistjar}


