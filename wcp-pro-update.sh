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

jarfile='jar.txt'
ls ${root}/wvp-GB28181-pro/target/*.jar > $jarfile
while read name; do
    if [[ $name != "wvp-pro-2.0.jar" ]]; then
       yes | cp -f $name "wvp-pro-2.0.jar"
    fi
done < $jarfile

rm -f $jarfile



