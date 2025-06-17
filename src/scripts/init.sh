#!/system/bin/sh

MODDIR=${0%/*}
CONFIG="$MODDIR/config.toml"
CRON_DIR="$MODDIR/cron"
LOGDIR="/data/adb/modules/cleaner/logs"
CRON_FILE="$CRON_DIR/cleaner.cron"
WEB_PID_FILE="$LOGDIR/webserver.pid"

# 确保目录存在
mkdir -p $CRON_DIR $LOGDIR

# 获取Web端口
WEB_PORT=$(grep 'web_port' $CONFIG | cut -d '=' -f2 | tr -d ' ')

# 设置日志文件权限
chmod 644 $LOGDIR/latest.log 2>/dev/null

case "$1" in
    enable)
        # 创建crontab文件 [[3]]
        echo "$(grep 'cron' $CONFIG | cut -d '=' -f2 | tr -d ' ') $MODDIR/cleaner.sh" > $CRON_FILE
        # 启动crond并加载crontab
        crond -b -l 2 -c $CRON_DIR
        # 启动Web服务并记录PID
        if ! netstat -tuln | grep -q ":$WEB_PORT"; then
            python3 -m http.server --bind 0.0.0.0 $WEB_PORT > "$LOGDIR/webserver.log" 2>&1 &
            echo $! > $WEB_PID_FILE
        else
            echo "Web port $WEB_PORT is already in use" >> $LOGDIR/latest.log
        fi
        ;;
    disable)
        # 仅删除模块自己的crontab文件
        rm -f $CRON_FILE
        # 停止Web服务（使用PID文件精准控制）
        if [ -f $WEB_PID_FILE ]; then
            kill -9 $(cat $WEB_PID_FILE) 2>/dev/null
            rm -f $WEB_PID_FILE
        fi
        ;;
esac