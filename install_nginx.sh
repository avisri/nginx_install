#!/bin/bash

set -o errexit

pkg=""

download()
{
    cd /usr/local/src
    url=$1
    sha1=$2
    pkg=`echo $url | tr '/' '\n'|tail -1`
    rm -vf $pkg
    rm -rf $name-$version
    wget $url
    verify=`openssl sha1 $pkg|tr ' ' '\n'|tail -1`
    [ "$sha1" != "$verify" ] && echo "checksum is not macthing $sha1 != $verify for $pkg downloaded from $url.. exiting" && exit 1 || true
}

make_install()
{
    tar xvzf $pkg
    cd $name-$version
    ./configure --prefix=/usr/local
    make
    sudo make install
}

# create, then go into the build directory
mkdir -p /usr/local/src
cd /usr/local/src

# download, build, and install pcre
name="prce"
version="8.36"
sha1="fb537757756818133d8157ec878bc11f5a93ef4d"
#url="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$name-${version}.tar.bz2"
url="https://downloads.sourceforge.net/project/$name/$name/$version/$name-$version.tar.gz"
#download $url $sha1
#make_install
#cd ..


cd /usr/local/src

# download, build, and install nginx
name="nginx"
version="1.8.0"
url="http://nginx.org/download/$name-$version.tar.gz"
sha1="12bad312764feae50246685ab2e74512d1aa9b2f"
download $url $sha1
tar xvfz $name-$version.tar.gz
cd $name-$version
#get custom modules
git clone https://github.com/avisri/chunkin-nginx-module            modules/avisri/chunkin-nginx-module
git clone https://github.com/avisri/ngx_http_auth_request_module    modules/avisri/ngx_http_auth_request_module
args=( \
        "--prefix=/usr/local/$name"                         \
        "--with-http_ssl_module"                            \
        "--with-pcre"                                       \
        "--with-ipv6"                                       \
        "--with-http_ssl_module"                            \
        " --add-module=modules/avisri/ngx_http_auth_request_module" \
     )
./configure ${args[*]}
make
sudo make install

# need to let users manage configurations and see logs
sudo chown  -R  $(whoami):admin  /usr/local/$name

# start nginx
/usr/local/sbin/nginx
