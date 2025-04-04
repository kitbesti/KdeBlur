#!/bin/bash
# KDE Blur效果自动安装脚本

# 检查并安装依赖
if ! command -v wmctrl &> /dev/null || ! command -v xprop &> /dev/null; then
    echo "安装依赖: wmctrl x11-utils..."
    sudo apt-get install -y wmctrl x11-utils
fi

# 部署主脚本
echo "部署KDE Blur脚本到/usr/local/bin..."
sudo cp KdeBlur.sh /usr/local/bin/kdeblur
sudo chmod +x /usr/local/bin/kdeblur

# 创建systemd用户服务
echo "创建systemd用户服务..."
#mkdir -p /etc/systemd/system/
cat > /etc/systemd/system/kdeblur.service <<EOF
[Unit]
Description=KDE Window Blur Effect
After=graphical-session.target

[Service]
ExecStart=/usr/local/bin/kdeblur
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# 启用并启动服务
echo "启用服务..."
sudo systemctl enable kdeblur.service
sudo systemctl start kdeblur.service

echo "安装完成！服务已设置为开机自启动。"