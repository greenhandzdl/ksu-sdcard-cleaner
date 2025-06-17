#!/bin/zsh

# 强制设置初始版本号
CURRENT_VERSION="1.0"
# 版本号递增逻辑
MAJOR=${CURRENT_VERSION%%.*}
MINOR=${CURRENT_VERSION##*.}
VERSION="$MAJOR.$((MINOR+1))"

# 创建构建目录
BUILD_DIR="build"
rm -rf $BUILD_DIR/ksu 2>/dev/null
mkdir -p $BUILD_DIR

# 定义通用文件列表（包含KSU专用文件）
COMMON_FILES=(
    "src/module.prop"
    "src/scripts/post-fs-data.sh"
    "src/scripts/cleaner.sh"
    "src/scripts/init.sh"
    "src/scripts/uninstall.sh"
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

# 打包KSU模块
cd $BUILD_DIR/ksu
zip -r ../ksu-sdcard-cleaner-ksu-v$VERSION.zip .

# 返回工作目录
cd ../..

# 更新版本号
sed -i '' "s/^VERSION=\\\"[0-9]\\+\\.[0-9]\\+\\\"\$/VERSION=\\\"$VERSION\\\"/" build.sh

echo "打包完成："
echo "- KernelSU版本: $BUILD_DIR/ksu-sdcard-cleaner-ksu-v$VERSION.zip"
echo "注意：打包后需要手动测试验证功能完整性"