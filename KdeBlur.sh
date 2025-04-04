#!/bin/bash
declare -A processed_windows  # 使用关联数组存储已处理的窗口ID

# 排除桌面背景和桌面程序
exclude_processes=("plasmashell" "plasma-desktop" "dde-desktop")

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
        if [ -z "${processed_windows[$id]}" ]; then  # 检查窗口ID是否未被处理
            # 设置窗口透明度(固定0.666透明度值)
            xprop -id $id -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0xAAAAAAAA
            
            # 设置窗口模糊效果
            xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $id
            
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