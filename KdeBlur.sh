#!/bin/bash
declare -A processed_windows  # 使用关联数组存储已处理的窗口ID

# xprop | grep -E 'WM_CLASS|_NET_WM_NAME|_NET_WM_WINDOW_TYPE'

# 排除桌面背景、桌面程序和dock栏
exclude_processes=("plasmashell" "plasma-desktop" "dde-desktop" "latte-dock" "lattedock" "dde-dock" "dde-shell")

while true; do
    sleep 0.5  # 减少CPU使用率
    declare -A current_windows  # 创建一个新数组来存储当前循环的窗口ID
    current_window_ids=$(wmctrl -l | cut -d " " -f 1)  # 获取当前所有窗口的ID

    for id in $current_window_ids; do
        # 获取窗口的进程名
        pid=$(xprop -id $id _NET_WM_PID | awk '{print $3}')
        process_name=$(ps -p $pid -o comm= 2>/dev/null)
        
        # 检查进程名是否在排除列表中
        exclude=false
        for proc in "${exclude_processes[@]}"; do
            if [[ "$process_name" == "$proc" ]]; then
                exclude=true
                break
            fi
        done
        
        if [[ "$exclude" == "true" ]]; then
            continue  # 跳过排除的进程
        fi
        
        current_windows[$id]=1  # 标记当前窗口为存在
        
        # 检查窗口是否已有模糊效果
        current_opacity=$(xprop -id $id _NET_WM_WINDOW_OPACITY 2>/dev/null | awk -F' = ' '{print $2}')
        current_blur=$(xprop -id $id _KDE_NET_WM_BLUR_BEHIND_REGION 2>/dev/null | awk -F' = ' '{print $2}')
        
        # 如果效果未设置或已改变，则重新应用
        if [[ -z "${processed_windows[$id]}" || 
              "$current_opacity" != "0xCCCCCCCC" || 
              "$current_blur" != "0" ]]; then
            # 设置窗口模糊效果
            xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $id

            # 设置窗口透明度(固定0.8透明度值)
            xprop -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0xCCCCCCCC -id $id
            
            processed_windows[$id]=1  # 记录已处理的窗口ID
        fi
    done

    # 清除已关闭的窗口ID
    for id in "${!processed_windows[@]}"; do
        if [ -z "${current_windows[$id]}" ]; then
            unset processed_windows[$id]  # 如果窗口ID不在当前窗口列表中，从processed_windows中移除
        fi
    done
done