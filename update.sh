#!/bin/bash
#
# FILE: update.sh
#
# DESCRIPTION: Update QianDao for Python3 
#
# NOTES: This requires GNU getopt.
#        I do not issue any guarantee that this will work for you!
#
# COPYRIGHT: (c) 2021-2022 by a76yyyy
#
# LICENSE: MIT
#
# ORGANIZATION: qiandao-today (https://github.com/qiandao-today)
#
# CREATED: 2021-10-28 20:00:00
#
#=======================================================================
_file=$(readlink -f $0)
_dir=$(dirname $_file)
cd $_dir
AUTO_RELOAD=$AUTO_RELOAD

# Treat unset variables as an error
set -o nounset

__ScriptVersion="2021.10.28"
__ScriptName="update.sh"


#-----------------------------------------------------------------------
# FUNCTION: usage
# DESCRIPTION:  Display usage information.
#-----------------------------------------------------------------------
usage() {
    cat << EOT

Usage :  ${__ScriptName} [OPTION] ...
  Update QianDao for Python3 from given options.

Options:
  -h, --help                    Display help message
  -s, --script-version          Display script version
  -u, --update                  Default update method
  -v, --version=TAG_VERSION     Forced Update to the specified tag version
  -f, --force                   Forced version update
  -l, --local                   Display Local version
  -r, --remote                  Display Remote version

Exit status:
  0   if OK,
  !=0 if serious problems.

Example:
  1) Use short options:
    $ sh $__ScriptName -v=$(python -c 'import sys, json; print(json.load(open("version.json"))["version"])')

  2) Use long options:
    $ sh $__ScriptName --update

Report issues to https://github.com/qiandao-today/qiandao

EOT
}   # ----------  end of function usage  ----------

update() {
    localversion=$(python -c 'import sys, json; print(json.load(open("version.json"))["version"])')
    remoteversion=$(git ls-remote --tags origin | grep -o 'refs/tags/[0-9]*' | sort -r | head -n 1 | grep -o '[^\/]*$')
    if [ $(echo $localversion $remoteversion | awk '$1>=$2 {print 0} $1<$2 {print 1}') -eq 1 ];then
        echo -e "Info: 当前版本: $localversion \nInfo: 新版本: $remoteversion \nInfo: 正在更新中，请稍候..."
        git fetch --all
        git reset --hard origin/master
        git checkout master
        git pull
    else
        echo "Info: 当前版本: $localversion , 无需更新!"
    fi
    if [ $AUTO_RELOAD ] && [ "$AUTO_RELOAD" == "False" ];then
        echo "Info: 请手动重启容器，或设置环境变量AUTO_RELOAD以开启热更新功能"
    fi
}

force_update() {
    echo -e "Info: 正在强制更新中，请稍候..."
    git fetch --all
    git reset --hard origin/master
    git checkout master
    git pull
    if [ $AUTO_RELOAD ] && [ "$AUTO_RELOAD" == "False" ];then
        echo "Info: 请手动重启容器，或设置环境变量AUTO_RELOAD以开启热更新功能"
    fi
}

update_version() {
    echo -e "Info: 正在强制切换至指定Tag版本: $1，请稍候..."
    git fetch --all
    git checkout -f $1
    if [ $AUTO_RELOAD ] && [ "$AUTO_RELOAD" == "False" ];then
        echo "Info: 请手动重启容器，或设置环境变量AUTO_RELOAD以开启热更新功能"
    fi
}


if [ $# -eq 0 ]; then update; exit 0; fi

# parse options:
RET=`getopt -o hsuv:flr \
    --long help,script-version,update,version:,force,local,remote \
    -n ' * ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Error: $__ScriptName exited with doing nothing." >&2 ; exit 1 ; fi

# Note the quotes around $RET: they are essential!
eval set -- "$RET"

# set option values
while true; do
    case "$1" in
        -h | --help ) usage; exit 1 ;;
        -s | --script-version ) echo "$(basename $0) -- version $__ScriptVersion"; exit 1 ;;

        -u | --update ) update; exit 0 ;;

        -v | --version ) echo "$2" | grep [^0-9] >/dev/null && echo "'$2' is not correct type of tag" || update_version $2; exit 0 ;;

        -f | --force ) force_update; exit 0 ;;

        -l | --local ) echo "当前版本: $(python -c 'import sys, json; print(json.load(open("version.json"))["version"])')"; shift ;;

        -r | --remote ) echo "远程版本: $(git ls-remote --tags origin | grep -o 'refs/tags/[0-9]*' | sort -r | head -n 1 | grep -o '[^\/]*$')"; shift ;;

        -- ) shift; break ;;
        * ) echo "Error: internal error!" ; exit 1 ;;
     esac
done

# # remaining argument
# for arg do
#     # method
# done
