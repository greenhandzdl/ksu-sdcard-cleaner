#!/bin/zsh

# 模块版本
VERSION="1.0"

# 创建构建目录
BUILD_DIR="build"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# 定义通用文件列表
COMMON_FILES=(
    "src/module.prop"
    "src/scripts/post-fs-data.sh"
    "src/scripts/cleaner.sh"
    "src/config.toml"
    "src/webui/index.html"
)

# 创建KernelSU包
mkdir -p $BUILD_DIR/ksu
for file in "${COMMON_FILES[@]}"; do
    if [ -e "$file" ]; then
        cp -r "$file" "$BUILD_DIR/ksu/"
    else
        echo "警告: 文件 $file 不存在"
    fi
done
cp src/scripts/init.sh src/scripts/uninstall.sh $BUILD_DIR/ksu/
cd $BUILD_DIR/ksu
zip -r ../ksu-sdcard-cleaner-ksu-v$VERSION.zip .

cd ../..

# 创建Magisk包
mkdir -p $BUILD_DIR/magisk
for file in "${COMMON_FILES[@]}"; do
    if [ -e "$file" ]; then
        cp -r "$file" "$BUILD_DIR/magisk/"
    else
        echo "警告: 文件 $file 不存在"
    fi
done

cat > $BUILD_DIR/magisk/customize.sh << 'EOL'
#!/bin/sh
MODDIR=${0%/*}

# Magisk兼容性调整
ln -sf /data/adb/modules/sdcard_cleaner $MODDIR
ln -sf /data/adb/modules/sdcard_cleaner/logs /sdcard/Android/data/sdcard_cleaner.logs 2>/dev/null
EOL

cat > $BUILD_DIR/magisk/post-fs-data.sh << 'EOL'
#!/system/bin/sh
MODDIR=${0%/*}

# 复制配置文件
cp $MODDIR/cleaner.sh /data/adb/modules/sdcard_cleaner/cleaner.sh
chmod 755 /data/adb/modules/sdcard_cleaner/cleaner.sh

cp $MODDIR/config.toml /data/adb/modules/sdcard_cleaner/config.toml

echo "0 * * * * /data/adb/modules/sdcard_cleaner/cleaner.sh" > /data/adb/modules/sdcard_cleaner/crontab

# 启动crond服务
crond -b -c /data/adb/modules/sdcard_cleaner/
EOL

cat > $BUILD_DIR/magisk/service.sh << 'EOL'
#!/system/bin/sh
while [ ! -f /data/adb/modules/sdcard_cleaner/enable ]; do sleep 30; done

# 获取Web端口
WEB_PORT=$(grep 'web_port' /data/adb/modules/sdcard_cleaner/config.toml | cut -d '=' -f2 | tr -d ' ')

# 启动Web服务
python3 -m http.server --bind 0.0.0.0 $WEB_PORT > /dev/null 2>&1 &
EOL

cd $BUILD_DIR/magisk
zip -r ../ksu-sdcard-cleaner-magisk-v$VERSION.zip .

echo "打包完成："
echo "- KernelSU版本: $BUILD_DIR/ksu-sdcard-cleaner-ksu-v$VERSION.zip"
echo "- Magisk版本: $BUILD_DIR/ksu-sdcard-cleaner-magisk-v$VERSION.zip"
echo "注意：打包后需要手动测试验证功能完整性"