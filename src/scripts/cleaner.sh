#!/system/bin/sh

# 读取配置文件
WHITELIST=$(cat /data/adb/modules/cleaner/config.toml | grep "whitelist" | cut -d'=' -f2 | tr -d ' ')
LOGFILE="/data/adb/modules/cleaner/logs/latest.log"
SDCARD="/sdcard"

# 创建日志文件
touch $LOGFILE

# 记录开始时间
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Cleaning started..." >> $LOGFILE

# 获取所有目录
ALL_DIRS=$(ls $SDCARD | grep -v "^\.$" | grep -v "^\.\.$")

# 执行清理
for dir in $ALL_DIRS; do
    if ! echo "$WHITELIST" | grep -q "$dir$"; then
        rm -rf "$SDCARD/$dir"
        echo "[INFO] Removed directory: $dir" >> $LOGFILE
    fi
done

# 记录结束时间
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Cleaning completed." >> $LOGFILE