#!/bin/sh
SOURCE_DIR=/usr/src
LUA_VERSION=5.3.5
CWD=$(pwd)

install_luaoauth_var=false
lua_installed=false
lua_dep_dir=/usr/local/share/lua/5.3/

cd $SOURCE_DIR

display_working() {
    pid=$1
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null
    do
        i=$(( (i+1) %4 ))
        printf "\r${spin:$i:1}"
        sleep .1
    done
}

download_rhel_lua() {
    printf "\r[+] Downloading Lua\n"
    curl -sLO https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz
    tar xf lua-$LUA_VERSION.tar.gz && rm lua-$LUA_VERSION.tar.gz
}

install_yum_deps() {
    printf "\r[+] Installing yum dependencies\n"
    yum -y install gcc openssl-devel readline-devel systemd-devel unzip >/dev/null 2>&1
}

build_lua() {
    printf "\r[+] Building Lua\n"
    cd $SOURCE_DIR/lua-$LUA_VERSION
    make linux test >/dev/null
}

install_deb_lua() {
    printf "\r[+] Installing Lua\n"
    apt-get update >/dev/null 2>&1
    apt-get install -y software-properties-common unzip build-essential libssl-dev lua5.3 liblua5.3-dev >/dev/null 2>&1
}

install_luaoauth_deps_alpine() {
    printf "\r[+] Installing haproxy-lua-oauth dependencies\n"

    if [ ! -e $lua_dep_dir ]; then
        mkdir -p $lua_dep_dir;
    fi;

    cd $SOURCE_DIR

    curl -sLO https://github.com/rxi/json.lua/archive/refs/heads/master.zip
    unzip -qo master.zip && rm master.zip
    cp json.lua-master/json.lua $lua_dep_dir 

    curl -sLO https://github.com/lunarmodules/luasocket/archive/refs/heads/master.zip
    unzip -qo master.zip && rm master.zip
    cd luasocket-master/
    make clean all install-both LUAINC=/usr/include/lua5.3/ >/dev/null
    cd ..

    curl -sLO https://github.com/wahern/luaossl/archive/refs/heads/master.zip
    unzip -qo master.zip && rm master.zip
    cd luaossl-master/
    make install >/dev/null
    cd ..
}

install_luaoauth() {
    printf "\r[+] Installing haproxy-lua-oauth\n"
    if [ ! -e $lua_dep_dir ]; then
        mkdir -p $lua_dep_dir;
    fi;

    cp $CWD/lib/*.lua $lua_dep_dir
}

case $1 in
    luaoauth)
        install_luaoauth_var=true
        ;;
    *)
        echo "Usage: install.sh luaoauth"
esac

if $install_luaoauth_var; then
    install_luaoauth_deps_alpine
    display_working $!
    install_luaoauth
    display_working $!
fi
