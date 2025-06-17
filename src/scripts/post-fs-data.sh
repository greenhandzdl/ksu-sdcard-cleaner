#!/system/bin/sh
MODDIR=${0%/*}
CRON_DIR="$MODDIR/cron"

# 如果模块被启用，则启动crond服务
if [ -f "$MODDIR/enable" ]; then
    # 检查并创建crontab文件
    if [ ! -f "$CRON_DIR/cleaner.cron" ]; then
        cp $MODDIR/config.toml $CRON_DIR/config.tmp
        CRON=$(grep 'cron' $CRON_DIR/config.tmp | cut -d '=' -f2 | tr -d ' ')
        echo "$CRON $MODDIR/cleaner.sh" > $CRON_DIR/cleaner.cron
        rm -f $CRON_DIR/config.tmp
    fi
    # 启动crond服务
    crond -b -l 2 -c $CRON_DIR
else
    # 如果模块未启用，清理crond相关文件
    rm -rf $CRON_DIR
fi