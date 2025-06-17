#!/system/bin/sh
MODDIR=${0%/*}

# 创建日志目录
mkdir -p /data/adb/modules/cleaner/logs

# 复制配置文件
cp $MODDIR/config.toml /data/adb/modules/cleaner/config.toml

# 设置定时任务
echo "0 * * * * /data/adb/modules/cleaner/cleaner.sh" > /data/adb/modules/cleaner/crontab

# 安装清理脚本
cp $MODDIR/cleaner.sh /data/adb/modules/cleaner/cleaner.sh
chmod 755 /data/adb/modules/cleaner/cleaner.sh