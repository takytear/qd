#!/bin/sh
cd /usr/src/app
git fetch --all
git reset --hard origin/master
git pull
echo "Info: 请手动重启容器，或设置环境变量AUTO_RELOAD以开启热更新功能"