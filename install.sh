#!/bin/bash

#项目名称
project=$1
portIndex=$2

if [ -z $project ] || [ -z $portIndex ];then
    echo "usage: $0 projectname portindex"
    exit
fi 

workPath=/data/work
projectPath=$workPath/$project
srcPath=$PWD/make/soft
nginxPort=$((8000+$2))
phpPort=$((9000+$2))

if [ -d $projectPath ];then
    echo "work path '$projectPath' has exsit!"
    exit 1
fi

#创建项目目录
mkdir -p $projectPath

#编译安装nginx
#解压nginx
rm -rf $srcPath/nginx-1.8.1
cd $srcPath/ && tar zxvf nginx-1.8.1.tar.gz
#解压nginx需求包
#if [ ! -d "$workPath/base/pcre-8.33" ] && if [ ! -d "$workPath/base/zlib-1.2.8" ] && if [ ! -d "$workPath/base/openssl-1.0.0o" ];then
rm -rf $srcPath/base/openssl-1.0.0o $srcPath/base/pcre-8.33 $srcPath/base/zlib-1.2.8
cd $srcPath/base/ && tar zxvf openssl-1.0.0o.tar.gz && tar zxvf pcre-8.33.tar.gz && tar zxvf zlib-1.2.8.tar.gz
#fi
#编译nginx
cd $srcPath/nginx-1.8.1/ && ./configure --prefix=$projectPath/nginx --with-poll_module --with-pcre=$srcPath/base/pcre-8.33 --with-zlib=$srcPath/base/zlib-1.2.8  --with-md5-asm  --with-openssl=$srcPath/base/openssl-1.0.0o  --with-sha1-asm --with-libatomic  --with-http_dav_module  --with-http_flv_module   --with-http_ssl_module  --with-http_gunzip_module --with-http_gzip_static_module && make && make install

#编译安装php
#解压php
rm -rf $srcPath/php-5.6.36
cd $srcPath/ && tar zxvf php-5.6.36.tar.gz
#编译php
cd $srcPath/php-5.6.36 && ./configure --prefix=$projectPath/php --with-curl=/usr/lib --with-freetype-dir=/usr/lib --with-gd --with-iconv-dir=/usr/lib --with-jpeg-dir=/usr/lib --with-mysql --with-mysqli --with-openssl --with-pdo-mysql=shared --with-pdo-sqlite=shared --with-png-dir=/usr/lib --with-zlib --enable-fpm --enable-libxml --enable-inline-optimization --enable-mbregex --enable-mbstring --enable-opcache --enable-xml --enable-zip --enable-sockets --enable-exif --disable-rpath --enable-ftp  --enable-pcntl  --enable-bcmath --enable-shmop --enable-sysvsem   --with-mcrypt  --with-mhash  --with-pdo-sqlite && make && make install

# 同步模板文件
rsync -a $srcPath/base/template/ $projectPath/

# 替换变量,变量中不能有逗号
replace(){
   src=$1
   dest=$2
   for i in `grep -r "$1" $projectPath|awk -F: '{print $1}'|grep -v replace.sh|sort|uniq`;do
        echo $i: $1 '===>' $2
        sed -i "s,$1,$2,g" $i;
   done
}
replace {PROJECT_PATH} $projectPath
replace {NGINX_PORT}   $nginxPort
replace {PHP_PORT}     $phpPort
replace {PROJECT_NAME} $project

mkdir -p $projectPath/logs/nginx
mkdir -p $projectPath/logs/php

#install php ext
$workPath/$project/php/bin/pecl install yaf-2.2.9
$workPath/$project/php/bin/pecl install apcu-4.0.7
$workPath/$project/php/bin/pecl install swoole-1.7.6
$workPath/$project/php/bin/pecl install memcache-2.2.7 
$workPath/$project/php/bin/pecl install zookeeper
$workPath/$project/php/bin/pecl install redis
