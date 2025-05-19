#!/bin/bash

# 检查是否提供了 IPA 文件路径
if [ -z "$1" ]; then
    echo "用法: $0 <输入IPA文件路径> [输出IPA文件路径]"
    exit 1
fi

IPA_FILE="$1"
EXTRACT_DIR="ipa_extracted"

# 如果提供了输出文件名，则使用，否则自动生成
if [ -z "$2" ]; then
    OUTPUT_IPA="${IPA_FILE%.*}_resigned.ipa"
else
    OUTPUT_IPA="$2"
fi

# 确保指定的 IPA 文件存在
if [ ! -f "$IPA_FILE" ]; then
    echo "错误: 指定的 IPA 文件不存在: $IPA_FILE"
    exit 1
fi

# 创建临时目录
mkdir -p "$EXTRACT_DIR"

# 解压 IPA 文件到临时目录
echo "正在解压 IPA 文件..."
unzip -o "$IPA_FILE" -d "$EXTRACT_DIR" > /dev/null

# 删除现有签名
echo "正在删除旧的签名..."
rm -rf "$EXTRACT_DIR/Payload/Runner.app/_CodeSignature"

# 重新签名
echo "正在重新签名应用..."
ldid -S -M "$EXTRACT_DIR/Payload/Runner.app/Runner"

# 进入临时目录的父目录进行打包
echo "正在打包为新的 IPA..."
(cd "$EXTRACT_DIR" && zip -qr "../$OUTPUT_IPA" Payload)



# 清理临时文件
rm -rf "$EXTRACT_DIR"

echo "✅ 已生成重新签名的 IPA: $OUTPUT_IPA"