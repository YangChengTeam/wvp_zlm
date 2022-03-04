#! /bin/sh

#======================================================================#
#  System Required:  CentOS 7 or Higher                                #
#  GB28181+ZLMediaKit服务 升级脚本                                      #          
#  Author：zhangkai <mzpbvsig@gmail.com>                               #
#======================================================================#

root=/home/wvp


cd ${root}/wvp-GB28181-pro
git pull
mvn package

wvpjar="target/wvp-pro.jar"
if [[ -e  ${wvpjar} ]];then
   rm -f ${wvpjar}
fi
mv target/*.jar ${wvpjar}

pm2 restart wvp-pro



