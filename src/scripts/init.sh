#!/system/bin/sh

# 启动crond服务
crond -b -c /data/adb/modules/cleaner/

# 检查并重启crond
if ! pgrep -x "crond" > /dev/null; then
    crond -b -c /data/adb/modules/cleaner/
f

MODDIR=${0%/*}
CONFIG="$MODDIR/config.toml"
LOGDIR="/data/adb/modules/cleaner/logs"

# 确保日志目录存在
mkdir -p $LOGDIR

# 获取Web端口
WEB_PORT=$(grep 'web_port' $CONFIG | cut -d '=' -f2 | tr -d ' ')

# 设置日志文件权限
chmod 644 $LOGDIR/latest.log 2>/dev/null

case "$1" in
    enable)
        # 启动Web服务 [[2]]
        python3 -m http.server --bind 0.0.0.0 $WEB_PORT > /dev/null 2>&1 &
        ;;
    disable)
        killall -9 python3 2>/dev/null
        ;;
esac