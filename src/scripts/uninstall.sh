#!/system/bin/sh

# 停止Web服务
killall -9 python3 2>/dev/null

# 删除日志目录
rm -rf /data/adb/modules/cleaner/logs

# 删除配置文件
rm -f /data/adb/modules/cleaner/config.toml

# 删除定时任务
rm -f /data/adb/modules/cleaner/crontab

# 清理crond状态
rm -f /data/adb/modules/cleaner/cron.db