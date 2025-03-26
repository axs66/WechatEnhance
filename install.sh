#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 无颜色

# 获取脚本所在的绝对路径目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 设备信息
DEVICE_IP="192.168.31.23"
DEVICE_PORT="22"
SSH_OPTIONS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

# 输出带颜色的信息
print_info() {
    echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}==>${NC} $1"
}

print_error() {
    echo -e "${RED}==>${NC} $1"
}

# 查找最新编译的deb包
find_latest_deb() {
    # 使用脚本目录的绝对路径来查找deb包
    latest_deb=$(ls -t "${SCRIPT_DIR}/packages/"*.deb 2>/dev/null | head -1)
    if [ -z "$latest_deb" ]; then
        print_error "未找到deb包，请先运行 'make package SCHEME=rootless' 编译项目"
        exit 1
    fi
    print_info "找到deb包: $latest_deb"
    PACKAGE_NAME=$(basename "$latest_deb" | cut -d'_' -f1)
}

# 等待设备连接
wait_for_device() {
    print_info "正在等待设备连接，请确保设备已开启并连接到网络..."
    
    while true; do
        if ssh $SSH_OPTIONS -p $DEVICE_PORT root@$DEVICE_IP "echo 连接成功" >/dev/null 2>&1; then
            print_info "设备连接成功"
            return 0
        else
            print_warning "正在尝试连接设备 (IP: $DEVICE_IP)..."
            sleep 3
        fi
    done
}

# 上传并安装
upload_and_install() {
    # 上传文件
    while true; do
        print_info "正在上传deb包到设备..."
        if scp $SSH_OPTIONS -P $DEVICE_PORT "$latest_deb" root@$DEVICE_IP:/var/root/$PACKAGE_NAME.deb >/dev/null 2>&1; then
            print_info "上传成功"
            break
        else
            print_warning "上传失败，正在重试..."
            sleep 2
        fi
    done
    
    # 安装包
    while true; do
        print_info "正在安装deb包..."
        if ssh $SSH_OPTIONS -p $DEVICE_PORT root@$DEVICE_IP "dpkg -i --force-overwrite /var/root/$PACKAGE_NAME.deb && rm -f /var/root/$PACKAGE_NAME.deb" >/dev/null 2>&1; then
            print_info "安装成功"
            return 0
        else
            print_warning "安装失败，正在重试..."
            sleep 2
        fi
    done
}

# 主函数
main() {
    print_info "开始安装流程..."
    print_info "脚本路径: ${SCRIPT_DIR}"
    
    # 查找最新的deb包
    find_latest_deb
    
    # 等待设备连接
    wait_for_device
    
    # 上传并安装
    upload_and_install
    
    print_info "安装完成！请重启微信应用！"
}

# 执行主函数
main 