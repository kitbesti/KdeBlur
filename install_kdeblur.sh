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

# 创建autostart条目
echo "创建自启动项..."
mkdir -p ~/.config/autostart/
cat > ~/.config/autostart/kdeblur.desktop <<EOF
[Desktop Entry]
Type=Application
Name=KDE Blur Effect
Exec=/usr/local/bin/kdeblur
Icon=preferences-desktop-effects
X-GNOME-Autostart-enabled=true
OnlyShowIn=KDE;
EOF

# 创建全局应用程序菜单项
echo "创建应用程序菜单项..."
sudo tee /usr/share/applications/kdeblur.desktop <<EOF
[Desktop Entry]
Type=Application
Name=KDE Blur Control
Comment=Control window blur effects
Exec=/usr/local/bin/kdeblur
Icon=preferences-desktop-effects
Categories=Utility;
Terminal=false
EOF

echo "安装完成！脚本将在下次登录时自动启动。"
echo "可以在应用程序菜单中找到KDE Blur Control项"