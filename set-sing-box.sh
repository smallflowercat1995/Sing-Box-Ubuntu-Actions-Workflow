#!/usr/bin/env bash
# 前戏初始化函数 initall
initall() {
    # 更新源
    sudo apt update
    sudo apt -y install ntpdate
    # 获取当前日期
    echo 老时间$(date '+%Y-%m-%d %H:%M:%S')
    # 修改地点时区软连接
    sudo ln -sfv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    # 写入地点时区配置文件
    sudo cat <<SMALLFLOWERCAT1995 | sudo tee /etc/timezone
Asia/Shanghai
SMALLFLOWERCAT1995
    sudo cat <<SMALLFLOWERCAT1995 | sudo tee /etc/cron.daily/ntpdate
ntpdata ntp.ubuntu.com cn.pool.ntp.org
SMALLFLOWERCAT1995
    sudo chmod -v 7777 /etc/cron.daily/ntpdate
    sudo ntpdate -d cn.pool.ntp.org
    # 重新获取修改地点时区后的时间
    echo 新时间$(date '+%Y-%m-%d %H:%M:%S')
    # 起始时间
    REPORT_DATE="$(TZ=':Asia/Shanghai' date +'%Y-%m-%d %T')"
    # 安装可能会用到的工具
    sudo apt-get install -y aria2 catimg git locales curl wget tar socat qrencode uuid net-tools jq
    # 配置简体中文字符集支持
    sudo perl -pi -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
    sudo perl -pi -e 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g' /etc/locale.gen
    sudo locale-gen zh_CN
    sudo locale-gen zh_CN.UTF-8
    # 将简体中文字符集支持写入到环境变量
    cat <<SMALLFLOWERCAT1995 | sudo tee /etc/default/locale
LANGUAGE=zh_CN.UTF-8
LC_ALL=zh_CN.UTF-8
LANG=zh_CN.UTF-8
LC_CTYPE=zh_CN.UTF-8
SMALLFLOWERCAT1995
    cat <<SMALLFLOWERCAT1995 | sudo tee -a /etc/environment
export LANGUAGE=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export LANG=zh_CN.UTF-8
export LC_CTYPE=zh_CN.UTF-8
SMALLFLOWERCAT1995
    cat <<SMALLFLOWERCAT1995 | sudo tee -a $HOME/.bashrc
export LANGUAGE=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export LANG=zh_CN.UTF-8
export LC_CTYPE=zh_CN.UTF-8
SMALLFLOWERCAT1995
    cat <<SMALLFLOWERCAT1995 >>$HOME/.profile
export LANGUAGE=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export LANG=zh_CN.UTF-8
export LC_CTYPE=zh_CN.UTF-8
SMALLFLOWERCAT1995
    sudo update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_CTYPE=zh_CN.UTF-8
    # 检查字符集支持
    locale
    locale -a
    cat /etc/default/locale
    # 应用中文字符集环境编码
    source /etc/environment $HOME/.bashrc $HOME/.profile
}
# 生成随机不占用的端口函数 get_random_port
get_random_port() {
    # 初始端口获取
    min=$1
    # 终末端口获取
    max=$2
    # 在 min~max 范围内生成随机排列端口并获取其中一个
    port=$(sudo shuf -i $min-$max -n1)
    # 从网络状态信息中获取全部连接和监听端口，并将所有的 端口 和 IP 以数字形式显示
    # 过滤出包含特定端口号 :$port
    # 使用 awk 进行进一步的过滤，只打印出第一个字段协议是 TCP 且最后一个字段状态为 LISTEN 的行。
    # 计算输出的行数，从而得知特定端口上正在侦听的 TCP 连接数量
    tcp=$(sudo netstat -an | grep ":$port " | awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' | wc -l)
    # 从网络状态信息中获取全部连接和监听端口，并将所有的 端口 和 IP 以数字形式显示
    # 过滤出包含特定端口号 :$port
    # 使用 awk 进行进一步的过滤，只打印出第一个字段协议是 UDP 且最后一个字段状态为 LISTEN 的行。
    # 计算输出的行数，从而得知特定端口上正在侦听的 UDP 连接数量
    udp=$(sudo netstat -an | grep ":$port " | awk '$1 == "udp" && $NF == "0.0.0.0:*" {print $0}' | wc -l)
    # 判断 tcp 连接数 + udp 连接数是否大于0，大于0则证明端口占用，继续以下步骤
    # 从网络状态信息中获取全部连接和监听端口，并将所有的 端口 和 IP 以数字形式显示
    # 过滤出包含特定端口号 :$port
    # 使用 awk 进行进一步的过滤，只打印出第一个字段协议是 TCP/UDP 且最后一个字段状态为 LISTEN 的行。
    # 计算输出的行数，从而得知特定端口上正在侦听的 TCP/UDP 连接数量
    while [ $((tcp + udp)) -gt 0 ]; do
        port=$(sudo shuf -i $min-$max -n1)
        tcp=$(sudo netstat -an | grep ":$port " | awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' | wc -l)
        udp=$(sudo netstat -an | grep ":$port " | awk '$1 == "udp" && $NF == "0.0.0.0:*" {print $0}' | wc -l)
    done
    # 输出不占用任何端口的数值
    echo $port
}
# 初始化用户密码
createUserNamePassword() {
    # 判断 USER_NAME 变量是否在 actions 环境中存在
    # 不存在则打印提示并退出，返回一个退出号
    # 存在则添加 USER_NAME 变量用户，将用户添加到 sudo 组
    if [[ -z "$USER_NAME" ]]; then
        echo "Please set 'USER_NAME' for linux"
        exit 2
    else
        sudo useradd -m $USER_NAME
        sudo adduser $USER_NAME sudo
    fi
    # 判断 USER_PW 变量是否在 actions 环境中存在
    # 不存在则打印提示并退出，返回一个退出号
    # 存在则执行以下步骤
    # 将通过管道将用户名和密码传递给 chpasswd 更改用户密码
    # 使用 sed 工具在 "/etc/passwd" 文件中将所有 "/bin/sh" 替换为 "/bin/bash"
    # 打印提示信息
    # 以防万一，通过管道将两次输入的密码传递给 passwd 命令，以更新用户的密码
    if [[ -z "$USER_PW" ]]; then
        echo "Please set 'USER_PW' for linux"
        exit 3
    else
        echo "$USER_NAME:$USER_PW" | sudo chpasswd
        sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
        echo "Update linux user password !"
        echo -e "$USER_PW\n$USER_PW" | sudo passwd "$USER_NAME"
    fi
    # 判断 HOST_NAME 变量是否在 actions 环境中存在
    # 不存在则打印提示并退出，返回一个退出号
    # 存在则设置 hostname 变量
    if [[ -z "$HOST_NAME" ]]; then
        echo "Please set 'HOST_NAME' for linux"
        exit 4
    else
        sudo hostname $HOST_NAME
    fi
    # 执行 sudo 免密码脚本生成
    cat <<EOL | sudo tee test.sh
# 在 /etc/sudoers.d 路径下创建一个 USER_NAME 变量的文件
sudo touch /etc/sudoers.d/$USER_NAME
# 给文件更改使用者和使用组 USER_NAME 变量
sudo chown -Rv $USER_NAME:$USER_NAME /etc/sudoers.d/$USER_NAME
# 给文件更改可读写执行的权限 777
sudo chmod -Rv 0777 /etc/sudoers.d/$USER_NAME
# 允许 USER_NAME 用户在执行sudo时无需输入密码，写入到文件
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee > /etc/sudoers.d/$USER_NAME
# 给文件更改使用者和使用组 root
sudo chown -Rv root:root  /etc/sudoers.d/$USER_NAME
# 给文件更改 root 可读 USER_NAME 可读 其他用户无权限 0440
sudo chmod -Rv 0440 /etc/sudoers.d/$USER_NAME
# 打印文件信息
sudo cat /etc/sudoers.d/$USER_NAME
EOL
    # 以 sudo 权限执行免密码脚本并删除
    sudo bash -c "bash test.sh ; rm -rfv test.sh"
}
# 下载 CloudflareSpeedTest sing-box cloudflared ngrok 配置并启用
getAndStart() {
    # 启用 TCP BBR 拥塞控制算法，参考 https://github.com/teddysun/across
    sudo su root bash -c "bash <(curl -L -s https://raw.githubusercontent.com/teddysun/across/master/bbr.sh)"
    # 判断系统 cpu 架构 ARCH_RAW ，并重新赋值架构名 ARCH
    ARCH_RAW=$(uname -m)
    case "$ARCH_RAW" in
    'x86_64') ARCH='amd64' ;;
    'x86' | 'i686' | 'i386') ARCH='386' ;;
    'aarch64' | 'arm64') ARCH='arm64' ;;
    'armv7l') ARCH='armv7' ;;
    's390x') ARCH='s390x' ;;
    *)
        echo "Unsupported architecture: $ARCH_RAW"
        exit 1
        ;;
    esac

    # github 项目 XIU2/CloudflareSpeedTest
    URI="XIU2/CloudflareSpeedTest"
    # 从 XIU2/CloudflareSpeedTest github中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
    VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | head -n 1)
    echo $VERSION
    # 拼接下载链接 URI_DOWNLOAD 后打印
    URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/CloudflareST_$(uname -s)_$ARCH.tar.gz"
    echo $URI_DOWNLOAD
    # 获取文件名 FILE_NAME 后打印
    FILE_NAME=$(basename $URI_DOWNLOAD)
    echo $FILE_NAME
    # 下载文件，可续传并打印进度
    wget --verbose --show-progress=on --progress=bar --hsts-file=/tmp/wget-hsts -c "$URI_DOWNLOAD" -O $FILE_NAME
    # 创建目录 /home/$USER_NAME/CloudflareST
    sudo mkdir -pv /home/$USER_NAME/${FILE_NAME%%_$(uname -s)_$ARCH.tar.gz}
    # 解压项目到目录 /home/$USER_NAME/CloudflareST
    sudo tar xzvf $FILE_NAME -C /home/$USER_NAME/${FILE_NAME%%_$(uname -s)_$ARCH.tar.gz}
    # 执行测速命令，返回优选 ip
    cd /home/$USER_NAME/${FILE_NAME%%_$(uname -s)_$ARCH.tar.gz}
    VM_WEBSITE=$(./CloudflareST -dd -tll 90 -p 1 -o "" | tail -n1 | awk '{print $1}')
    cd -
    # 删除文件
    sudo rm -rfv $FILE_NAME /home/$USER_NAME/${FILE_NAME%%_$(uname -s)_$ARCH.tar.gz}

    # github 项目 SagerNet/sing-box
    URI="SagerNet/sing-box"
    # 从 SagerNet/sing-box 官网中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
    VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | head -n 1)
    echo $VERSION
    # 拼接下载链接 URI_DOWNLOAD 后打印
    URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/sing-box_${VERSION#v}_$(uname -s)_$ARCH.deb"
    echo $URI_DOWNLOAD
    # 获取文件名 FILE_NAME 后打印
    FILE_NAME=$(basename $URI_DOWNLOAD)
    echo $FILE_NAME
    # 下载文件，可续传并打印进度
    wget --verbose --show-progress=on --progress=bar --hsts-file=/tmp/wget-hsts -c "$URI_DOWNLOAD" -O $FILE_NAME
    # 安装文件
    sudo dpkg -i $FILE_NAME
    # 删除文件
    rm -fv $FILE_NAME

    # github 项目 cloudflare/cloudflared
    URI="cloudflare/cloudflared"
    # 从 cloudflare/cloudflared 官网中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
    VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | head -n 1)
    echo $VERSION
    # 拼接下载链接 URI_DOWNLOAD 后打印
    URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/cloudflared-$(uname -s)-$ARCH.deb"
    echo $URI_DOWNLOAD
    # 获取文件名 FILE_NAME 后打印
    FILE_NAME=$(basename $URI_DOWNLOAD)
    echo $FILE_NAME
    # 下载文件，可续传并打印进度
    wget --verbose --show-progress=on --progress=bar --hsts-file=/tmp/wget-hsts -c "$URI_DOWNLOAD" -O $FILE_NAME
    # 创建目录 /home/$USER_NAME/cloudflared
    sudo mkdir -pv /home/$USER_NAME/${FILE_NAME%%-$(uname -s)-$ARCH.deb}
    # 安装文件
    sudo dpkg -i $FILE_NAME
    # 删除文件
    rm -fv $FILE_NAME

    # 判断 NGROK_AUTH_TOKEN 变量是否在 actions 环境中存在
    # 不存在则打印提示并退出，返回一个退出号
    # 存在则执行 ngrok 安装
    if [[ -z "$NGROK_AUTH_TOKEN" ]]; then
        echo "Please set 'NGROK_AUTH_TOKEN'"
        exit 5
    else
        curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok
        sudo mkdir -pv /home/$USER_NAME/ngrok
        # 执行函数 get_random_port 传入端口号范围，赋值给 V_PORT
        V_PORT="$(get_random_port 0 65535)"
        # 执行函数 get_random_port 传入端口号范围，赋值给 VM_PORT
        VM_PORT="$(get_random_port 0 65535)"
        # 执行函数 get_random_port 传入端口号范围，赋值给 H2_PORT
        H2_PORT="$(get_random_port 0 65535)"
        # 写入 ngrok 配置文件，包含 ngrok 认证 key 、tcp 协议 ssh 端口和 tcp 协议 vless 端口
        cat <<SMALLFLOWERCAT1995 | sudo tee /home/$USER_NAME/ngrok/ngrok.yml >/dev/null
authtoken: $NGROK_AUTH_TOKEN

tunnels:
  ssh:
    proto: tcp
    addr: 22

  vless:
    proto: tcp
    addr: $V_PORT

  hysteria2:
    proto: tcp
    addr: $H2_PORT
SMALLFLOWERCAT1995
        # 更新指定 ngrok 配置文件，添加版本号和网速最快的国家代码
        sudo ngrok config upgrade --config /home/$USER_NAME/ngrok/ngrok.yml
        # 后台启用 ngrok 且让其脱离 shell 终端寿命
        sudo nohup ngrok start --all --config /home/${USER_NAME}/ngrok/ngrok.yml --log /home/${USER_NAME}/ngrok/ngrok.log >/dev/null 2>&1 & disown
        # 睡 10 秒让 ngrok 充分运行
        sleep 10
    fi

    # sing-box 服务器配置所需变量
    # vless 配置所需变量
    # vless 协议
    V_PROTOCOL=vless
    # vless 入站名
    V_PROTOCOL_IN_TAG=$V_PROTOCOL-in
    # sing-box 生成 uuid
    V_UUID="$(sing-box generate uuid)"

    # reality 配置所需变量
    # reality 偷取域名证书，域名需要验证是否支持 TLS 1.3 和 HTTP/2
    R_STEAL_WEBSITE_CERTIFICATES=itunes.apple.com

    # 验证域名是否支持 TLS 1.3 和 HTTP/2
    # while true; do
    #       # 默认 reality_server_name 变量默认值为 itunes.apple.com
    # 	reality_server_name="itunes.apple.com"
    #       # 获得用户输入的域名并赋值给 input_server_name
    # 	read -p "请输入需要的网站，检测是否支持 TLS 1.3 and HTTP/2 (默认: $reality_server_name): " input_server_name
    #       # 赋值给 reality_server_name 变量，如果用户输入为空则是用 reality_server_name 默认值 itunes.apple.com
    # 	reality_server_name=${input_server_name:-$reality_server_name}
    #       # 使用 curl 验证域名是否支持 TLS 1.3 和 HTTP/2
    # 	# 支持则打印信息退出死循环
    #       # 不支持则打印重新进入死循环让用户重新输出新域名
    # 	if curl --tlsv1.3 --http2 -sI "https://$reality_server_name" | grep -q "HTTP/2"; then
    # 		echo "域名 $reality_server_name 支持 TLS 1.3 或 HTTP/2"
    # 		break
    # 	else
    # 		echo "域名 $reality_server_name 不支持 TLS 1.3 或 HTTP/2，请重新输入."
    # 	fi
    # done

    # reality 域名默认端口 443
    R_STEAL_WEBSITE_PORT=443
    # sing-box 生成 reality 公私钥对
    R_PRIVATEKEY_PUBLICKEY="$(sing-box generate reality-keypair)"
    # reality 私钥信息提取
    R_PRIVATEKEY="$(echo $R_PRIVATEKEY_PUBLICKEY | awk '{print $2}')"
    # sing-box 生成 16 位 reality hex
    R_HEX="$(sing-box generate rand --hex 8)"

    # vmess 配置所需变量
    # vmess 协议
    VM_PROTOCOL=vmess
    # vmess 入站名
    VM_PROTOCOL_IN_TAG=$VM_PROTOCOL-in
    # sing-box 生成 uuid
    VM_UUID="$(sing-box generate uuid)"
    # vmess 类型
    VM_TYPE=ws
    # sing-box 生成 12 位 vmess hex 路径
    VM_PATH="$(sing-box generate rand --hex 6)"

    # hysteria2 配置所需变量
    # hysteria2 协议
    H2_PROTOCOL=hysteria2
    # hysteria2 入站名
    H2_PROTOCOL_IN_TAG=$H2_PROTOCOL-in
    # sing-box 生成 16 位 hysteria2 hex
    H2_HEX="$(sing-box generate rand --hex 8)"
    # hysteria2 类型
    H2_TYPE=h3
    # hysteria2 证书域名
    H2_WEBSITE_CERTIFICATES=bing.com
    # sing-box 生成 12 位 vmess hex 路径
    sudo mkdir -pv /home/$USER_NAME/self-cert
    sudo openssl ecparam -genkey -name prime256v1 -out /home/$USER_NAME/self-cert/private.key
    sudo openssl req -new -x509 -days 36500 -key /home/$USER_NAME/self-cert/private.key -out /home/$USER_NAME/self-cert/cert.pem -subj "/CN="$H2_WEBSITE_CERTIFICATES

    # 写入服务器端 sing-box 配置文件
    cat <<SMALLFLOWERCAT1995 | sudo tee /etc/sing-box/config.json >/dev/null
{
  "log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "sniff": true,
      "sniff_override_destination": true,
      "type": "$V_PROTOCOL",
      "tag": "$V_PROTOCOL_IN_TAG",
      "listen": "::",
      "listen_port": $V_PORT,
      "users": [
        {
          "uuid": "$V_UUID",
          "flow": "xtls-rprx-vision"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "$R_STEAL_WEBSITE_CERTIFICATES",
        "reality": {
          "enabled": true,
          "handshake": {
            "server": "$R_STEAL_WEBSITE_CERTIFICATES",
            "server_port": $R_STEAL_WEBSITE_PORT
          },
          "private_key": "$R_PRIVATEKEY",
          "short_id": ["$R_HEX"]
        }
      }
    },
    {
        "sniff": true,
        "sniff_override_destination": true,
        "type": "$VM_PROTOCOL",
        "tag": "$VM_PROTOCOL_IN_TAG",
        "listen": "::",
        "listen_port": $VM_PORT,
        "users": [
            {
                "uuid": "$VM_UUID",
                "alterId": 0
            }
        ],
        "transport": {
            "type": "$VM_TYPE",
            "path": "$VM_PATH",
            "max_early_data":2048,
            "early_data_header_name":"Sec-WebSocket-Protocol"
        }
    },
    {
        "sniff": true,
        "sniff_override_destination": true,
        "type": "$H2_PROTOCOL",
        "tag": "$H2_PROTOCOL_IN_TAG",
        "listen": "::",
        "listen_port": $H2_PORT,
        "users": [
            {
                "password": "$H2_HEX"
            }
        ],
        "tls": {
            "enabled": true,
            "alpn": [
                "$H2_TYPE"
            ],
            "certificate_path": "/home/$USER_NAME/self-cert/cert.pem",
            "key_path": "/home/$USER_NAME/self-cert/private.key"
        }
    }
  ],
    "outbounds": [
        {
            "type": "direct",
            "tag": "direct"
        },
        {
            "type": "block",
            "tag": "block"
        }
    ]
}
SMALLFLOWERCAT1995
    # 使用grep命令在 ngrok 日志文件中查找运行失败时包含的 "command failed" 字符串行，并将结果存储在变量 HAS_ERRORS 中
    HAS_ERRORS=$(grep "error" </home/${USER_NAME}/ngrok/ngrok.log)
    # 检查变量HAS_ERRORS是否为空
    # 为空（即没有找到"error"字符串），则执行下一条命令
    # 不为空打印 HAS_ERRORS 内容，返回退出号
    if [[ -z "$HAS_ERRORS" ]]; then
        # 从 ngrok api 中获取必备信息赋值给 NGROK_INFO
        NGROK_INFO="$(curl -s http://127.0.0.1:4040/api/tunnels)"
        # ngrok 日志提取 vless 信息
        VLESS_N_INFO="$(echo "$NGROK_INFO" | jq -r '.tunnels[] | select(.name=="vless") | .public_url')"
        # vless 域名
        VLESS_N_DOMAIN="$(echo "$VLESS_N_INFO" | awk -F[/:] '{print $4}')"
        # vless 端口
        VLESS_N_PORT="$(echo "$VLESS_N_INFO" | awk -F[/:] '{print $5}')"

        # ngrok 日志提取 vmess 信息
        H2_N_INFO="$(echo "$NGROK_INFO" | jq -r '.tunnels[] | select(.name=="hysteria2") | .public_url')"
        # vmess 域名
        H2_N_DOMAIN="$(echo "$H2_N_INFO" | awk -F[/:] '{print $4}')"
        # vmess 端口
        H2_N_PORT="$(echo "$H2_N_INFO" | awk -F[/:] '{print $5}')"

        # ngrok 日志提取 ssh 信息
        SSH_N_INFO="$(echo "$NGROK_INFO" | jq -r '.tunnels[] | select(.name=="ssh") | .public_url')"
        # ssh 连接域名
        SSH_N_DOMAIN="$(echo "$SSH_N_INFO" | awk -F[/:] '{print $4}')"
        # ssh 连接端口
        SSH_N_PORT="$(echo "$SSH_N_INFO" | awk -F[/:] '{print $5}')"
    else
        echo "$HAS_ERRORS"
        # exit 6
        VLESS_N_PORT=$V_PORT
    fi
    # 启动 sing-box 服务
    sudo systemctl daemon-reload && sudo systemctl enable --now sing-box && sudo systemctl restart sing-box
    # 后台启用 cloudflared 获得隧穿日志并脱离 shell 终端寿命
    sudo nohup cloudflared tunnel --url http://localhost:$VM_PORT --no-autoupdate --edge-ip-version auto --protocol http2 >/home/$USER_NAME/cloudflared/cloudflared.log 2>&1 & disown
    # 杀死 cloudflared
    sudo kill -9 $(sudo ps -ef | grep -v grep | grep cloudflared | awk '{print $2}')
    # 再次后台启用 cloudflared 获得隧穿日志并脱离 shell 终端寿命
    sudo nohup cloudflared tunnel --url http://localhost:$VM_PORT --no-autoupdate --edge-ip-version auto --protocol http2 >/home/$USER_NAME/cloudflared/cloudflared.log 2>&1 & disown
    # 睡 5 秒，让 cloudflared 充分运行
    sleep 5
    # sing-box 客户端配置所需变量
    # 出站代理名
    SB_ALL_PROTOCOL_OUT_TAG=proxy
    # 出站类型
    SB_ALL_PROTOCOL_OUT_TYPE=selector
    # 组
    SB_ALL_PROTOCOL_OUT_GROUP_TAG=sing-box
    # vless 出站名
    SB_V_PROTOCOL_OUT_TAG=$V_PROTOCOL-out
    #SB_V_PROTOCOL_OUT_TAG_A=$SB_V_PROTOCOL_OUT_TAG-A
    # vmess 出站名
    SB_VM_PROTOCOL_OUT_TAG=$VM_PROTOCOL-out
    #SB_VM_PROTOCOL_OUT_TAG_A=$SB_VM_PROTOCOL_OUT_TAG-A
    # hysteria2 出站名
    SB_H2_PROTOCOL_OUT_TAG=$H2_PROTOCOL-out
    #SB_H2_PROTOCOL_OUT_TAG_A=$SB_H2_PROTOCOL_OUT_TAG-A
    # reality 公钥信息提取
    R_PUBLICKEY="$(echo $R_PRIVATEKEY_PUBLICKEY | awk '{print $4}')"
    # 默认优选 IP/域名 和 端口，可修改成自己的优选
    # 不为空打印 VM_WEBSITE 域名
    # 为空赋值默认域名后打印
    if [ "$VM_WEBSITE" != "" ]; then
        echo $VM_WEBSITE
    else
        VM_WEBSITE=icook.hk
        echo $VM_WEBSITE
    fi

    # 从 cloudflared 日志中获得遂穿域名
    CLOUDFLARED_DOMAIN="$(cat /home/$USER_NAME/cloudflared/cloudflared.log | grep trycloudflare.com | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')"
    # 备用判断获取 CLOUDFLARED_DOMAIN 是否为空
    # 不为空打印 cloudflared 域名
    # 为空赋值 ngrok 域名后打印
    # if [ "$CLOUDFLARED_DOMAIN" != "" ]; then
    # 	echo $CLOUDFLARED_DOMAIN
    # else
    # 	CLOUDFLARED_DOMAIN=$VMESS_N_DOMAIN
    # 	echo $CLOUDFLARED_DOMAIN
    # fi
    # cloudflared 默认端口
    CLOUDFLARED_PORT=443
    
    # VLESS 二维码生成扫描文件
    VLESS_LINK="vless://$V_UUID@$VLESS_N_DOMAIN:$VLESS_N_PORT/?type=tcp&encryption=none&flow=xtls-rprx-vision&sni=$R_STEAL_WEBSITE_CERTIFICATES&fp=chrome&security=reality&pbk=$R_PUBLICKEY&sid=$R_HEX&packetEncoding=xudp#$SB_V_PROTOCOL_OUT_TAG"
    #qrencode -t UTF8 $VLESS_LINK
    qrencode -o VLESS.png $VLESS_LINK

    # VMESS 二维码生成扫描文件
    VMESS_LINK='vmess://'$(echo '{"add":"'$VM_WEBSITE'","aid":"0","alpn":"","fp":"chrome","host":"'$CLOUDFLARED_DOMAIN'","id":"'$VM_UUID'","net":"'$VM_TYPE'","path":"/'$VM_PATH'?ed\u003d2048","port":"'$CLOUDFLARED_PORT'","ps":"'$SB_VM_PROTOCOL_OUT_TAG'","scy":"auto","sni":"'$CLOUDFLARED_DOMAIN'","tls":"tls","type":"","v":"2"}' | base64 -w 0)
    #qrencode -t UTF8 $VMESS_LINK
    qrencode -o VMESS.png $VMESS_LINK

    # HYSTERIA2 二维码生成扫描文件
    HYSTERIA2_LINK="hy2://$H2_HEX@$H2_N_DOMAIN:$H2_N_PORT/?insecure=1&sni=$H2_WEBSITE_CERTIFICATES#$SB_H2_PROTOCOL_OUT_TAG"
    #qrencode -t UTF8 $HYSTERIA2_LINK
    qrencode -o HYSTERIA2.png $HYSTERIA2_LINK

    # 写入 nekobox 客户端配置到 client-nekobox-config.yaml 文件
    cat <<SMALLFLOWERCAT1995 | sudo tee client-nekobox-config.yaml >/dev/null
port: 7891
socks-port: 7892
mixed-port: 7893
external-controller: :7894
redir-port: 7895
tproxy-port: 7896
allow-lan: true
mode: rule
log-level: info
secret: ""
dns:
  enable: false
  listen: 127.0.0.1:7053
  nameserver:
     - 119.29.29.29
     - 114.114.114.114
  fallback:
     - https://1.1.1.1/dns-query
     - tls://1.0.0.1:853
proxies:
  - {"name": "$SB_V_PROTOCOL_OUT_TAG","type": "$V_PROTOCOL","server": "$VLESS_N_DOMAIN","port": $VLESS_N_PORT,"uuid": "$V_UUID","network": "tcp","udp": true,"tls": true,"flow": "xtls-rprx-vision","servername": "$R_STEAL_WEBSITE_CERTIFICATES","client-fingerprint": "chrome","reality-opts": {"public-key": "$R_PUBLICKEY","short-id": "$R_HEX"}}
  - {"name": "$SB_VM_PROTOCOL_OUT_TAG","type": "$VM_PROTOCOL","server": "$VM_WEBSITE","port": $CLOUDFLARED_PORT,"uuid": "$VM_UUID","alterId": 0,"cipher": "auto","udp": true,"tls": true,"client-fingerprint": "chrome","skip-cert-verify": true,"servername": "$CLOUDFLARED_DOMAIN","network": "$VM_TYPE","ws-opts": {"path": "/$VM_PATH?ed=2048","headers": {"Host": "$CLOUDFLARED_DOMAIN"}}}
  - {"name": "$SB_H2_PROTOCOL_OUT_TAG","type": "$H2_PROTOCOL","server": "$H2_N_DOMAIN","port": $H2_N_PORT,"up": "100 Mbps","down": "100 Mbps","password": "$H2_HEX","sni": "$H2_WEBSITE_CERTIFICATES","skip-cert-verify": true,"alpn": ["$H2_TYPE"]}
proxy-groups:
  - name: Auto-Fast
    type: "url-test"
    url: "http://www.gstatic.cn/generate_204"
    interval: 300
    tolerance: 100
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG"
        - "$SB_VM_PROTOCOL_OUT_TAG"
        - "$SB_H2_PROTOCOL_OUT_TAG"
  - name: Auto-Edge
    type: "url-test"
    url: "http://www.gstatic.cn/generate_204"
    interval: 900
    tolerance: 100
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG"
        - "$SB_VM_PROTOCOL_OUT_TAG"
        - "$SB_H2_PROTOCOL_OUT_TAG"
  - name: Auto-Failover
    type: "url-test"
    url: "http://www.gstatic.cn/generate_204"
    interval: 1800
    tolerance: 100
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG"
        - "$SB_VM_PROTOCOL_OUT_TAG"
        - "$SB_H2_PROTOCOL_OUT_TAG"
  - name: Express
    type: "fallback"
    url: "http://www.gstatic.cn/generate_204"
    interval: 900
    tolerance: 50
    proxies:
        - Auto-Edge
        - Auto-Fast
        - Auto-Failover
  - name: Auto
    type: "fallback"
    url: "http://www.gstatic.cn/generate_204"
    interval: 600
    proxies:
        - Auto-Fast
        - Auto-Edge
        - Auto-Failover
  - name: Proxy
    type: "select"
    proxies:
        - "Auto"
        - "$SB_V_PROTOCOL_OUT_TAG"
        - "$SB_VM_PROTOCOL_OUT_TAG"
        - "$SB_H2_PROTOCOL_OUT_TAG"
  - name: Video
    type: "select"
    interval: 900
    url: "http://www.gstatic.cn/generate_204"
    proxies:
        - Express
        - "$SB_V_PROTOCOL_OUT_TAG"
        - "$SB_VM_PROTOCOL_OUT_TAG"
        - "$SB_H2_PROTOCOL_OUT_TAG"
  - name: Netflix
    type: "select"
    url: "http://www.gstatic.cn/generate_204"
    interval: 1200
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG"
        - "$SB_VM_PROTOCOL_OUT_TAG"
        - "$SB_H2_PROTOCOL_OUT_TAG"
        - Auto-Edge
        - DIRECT
  - name: Scholar
    type: "select"
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG"
        - "$SB_VM_PROTOCOL_OUT_TAG"
        - "$SB_H2_PROTOCOL_OUT_TAG"
        - Proxy
        - DIRECT
  - name: Steam
    type: "select"
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG"
        - "$SB_VM_PROTOCOL_OUT_TAG"
        - "$SB_H2_PROTOCOL_OUT_TAG"
        - Auto-Edge
        - DIRECT
rules:
- DST-PORT,25,DIRECT
- DST-PORT,26,DIRECT
- DST-PORT,465,DIRECT
- DST-PORT,587,DIRECT
- DST-PORT,2525,DIRECT
- DST-PORT,6881,DIRECT
- DST-PORT,6882,DIRECT
- DST-PORT,6883,DIRECT
- DST-PORT,6884,DIRECT
- DST-PORT,6885,DIRECT
- DST-PORT,6886,DIRECT
- DST-PORT,6887,DIRECT
- DST-PORT,6888,DIRECT
- DST-PORT,6889,DIRECT
- DOMAIN-SUFFIX,qq.com,DIRECT
- DOMAIN-SUFFIX,taobao.com,DIRECT
- DOMAIN-SUFFIX,baidu.com,DIRECT
- DOMAIN-SUFFIX,weibo.com,DIRECT
- DOMAIN-SUFFIX,jd.com,DIRECT
- DOMAIN-SUFFIX,tmall.com,DIRECT
- DOMAIN-SUFFIX,360.cn,DIRECT
- DOMAIN-SUFFIX,zhihu.com,DIRECT
- DOMAIN-SUFFIX,com.cn,DIRECT
- DOMAIN,graph.instagram.com,DIRECT
- DOMAIN,www.googleadservices.com,DIRECT
- DOMAIN,control.kochava.com,DIRECT
- DOMAIN,www.google-analytics.com,DIRECT
- DOMAIN,ssl.google-analytics.com,DIRECT
- DOMAIN,nexus.officeapps.live.com,DIRECT
- DOMAIN,googleads.g.doubleclick.net,DIRECT
- DOMAIN,e.crashlytics.com,DIRECT
- DOMAIN,ib.adnxs.com,DIRECT
- DOMAIN,safebrowsing.googleapis.com,DIRECT
- DOMAIN-SUFFIX,googlesyndication.com,DIRECT
- DOMAIN-SUFFIX,googletagmanager.com,DIRECT
- DOMAIN-SUFFIX,googletagservices.com,DIRECT
- DOMAIN-SUFFIX,paypal.com,Proxy
- DOMAIN-SUFFIX,stripe.com,Proxy
- DOMAIN-SUFFIX,bing.com,Proxy
- DOMAIN-SUFFIX,byteoversea.com,$SB_V_PROTOCOL_OUT_TAG
- DOMAIN-SUFFIX,muscdn.com,$SB_V_PROTOCOL_OUT_TAG
- DOMAIN-SUFFIX,musical.ly,$SB_V_PROTOCOL_OUT_TAG
- DOMAIN-SUFFIX,tik-tokapi.com,$SB_V_PROTOCOL_OUT_TAG
- DOMAIN-SUFFIX,tiktokcdn.com,$SB_V_PROTOCOL_OUT_TAG
- DOMAIN-SUFFIX,tiktok.com,$SB_V_PROTOCOL_OUT_TAG
- DOMAIN-SUFFIX,tiktokv.com,$SB_V_PROTOCOL_OUT_TAG
- DOMAIN-KEYWORD,scholar,Scholar
- DOMAIN-KEYWORD,openai,Scholar
- DOMAIN-SUFFIX,openai.com,Scholar
- DOMAIN-SUFFIX,chatgpt.com,Scholar
- DOMAIN-SUFFIX,oaistatic.com,Scholar
- DOMAIN-SUFFIX,oaiusercontent.com,Scholar
- DOMAIN-SUFFIX,ai.com,Scholar
- DOMAIN-SUFFIX,hotmail.com,Proxy
- DOMAIN-SUFFIX,slack.com,Proxy
- DOMAIN-SUFFIX,live.com,Proxy
- DOMAIN-SUFFIX,figma.com,Proxy
- DOMAIN-SUFFIX,firefox.com,Proxy
- DOMAIN-SUFFIX,notion.com,Proxy
- DOMAIN-SUFFIX,x.com,Proxy
- DOMAIN-SUFFIX,reddit.com,Proxy
- DOMAIN-SUFFIX,office.com,Proxy
- DOMAIN-SUFFIX,twimg.com,Proxy
- DOMAIN-SUFFIX,pinterest.com,Proxy
- DOMAIN-SUFFIX,auth0.com,Proxy
- DOMAIN,openaiapi-site.azureedge.net,Proxy
- DOMAIN-SUFFIX,rxiv.org,Proxy
- DOMAIN-SUFFIX,acrjournals.org,Proxy
- DOMAIN-SUFFIX,cademic.eb.com,Proxy
- DOMAIN-SUFFIX,caric.co.jp,Proxy
- DOMAIN-SUFFIX,clweb.org,Proxy
- DOMAIN-SUFFIX,cm.org,Proxy
- DOMAIN-SUFFIX,cs.org,Proxy
- DOMAIN-SUFFIX,gu.org,Proxy
- DOMAIN-SUFFIX,iaa.org,Proxy
- DOMAIN-SUFFIX,imsciences.org,Proxy
- DOMAIN-SUFFIX,ms.org,Proxy
- DOMAIN-SUFFIX,natomy.tv,Proxy
- DOMAIN-SUFFIX,nalytictech.com,Proxy
- DOMAIN-SUFFIX,nnualreviews.org,Proxy
- DOMAIN-SUFFIX,ps.org,Proxy
- DOMAIN-SUFFIX,rabidopsis.org,Proxy
- DOMAIN-SUFFIX,rtstor.org,Proxy
- DOMAIN-SUFFIX,scelibrary.org,Proxy
- DOMAIN-SUFFIX,sha.org,Proxy
- DOMAIN-SUFFIX,sm.org,Proxy
- DOMAIN-SUFFIX,sme.org,Proxy
- DOMAIN-SUFFIX,sminternational.org,Proxy
- DOMAIN-SUFFIX,sn-online.org,Proxy
- DOMAIN-SUFFIX,spbjournals.org,Proxy
- DOMAIN-SUFFIX,spenpublishing.com,Proxy
- DOMAIN-SUFFIX,stm.org,Proxy
- DOMAIN-SUFFIX,siam.org,Proxy
- DOMAIN-KEYWORD,github,Proxy
- DOMAIN-SUFFIX,atom.io,Proxy
- DOMAIN-SUFFIX,dependabot.com,Proxy
- DOMAIN-SUFFIX,ghcr.io,Proxy
- DOMAIN-SUFFIX,git.io,Proxy
- DOMAIN-SUFFIX,myoctocat.com,Proxy
- DOMAIN-SUFFIX,npm.community,Proxy
- DOMAIN-SUFFIX,npmjs.com,Proxy
- DOMAIN-SUFFIX,npmjs.org,Proxy
- DOMAIN-SUFFIX,opensource.guide,Proxy
- DOMAIN-SUFFIX,rawgit.com,Proxy
- DOMAIN-SUFFIX,repo.new,Proxy
- DOMAIN-KEYWORD,discord,Proxy
- DOMAIN-SUFFIX,airhorn.solutions,Proxy
- DOMAIN-SUFFIX,airhornbot.com,Proxy
- DOMAIN-SUFFIX,bigbeans.solutions,Proxy
- DOMAIN-SUFFIX,dis.gd,Proxy
- DOMAIN-SUFFIX,gstatic.com,Proxy
- DOMAIN-SUFFIX,google.com,Proxy
- DOMAIN-SUFFIX,v2ex.com,Proxy
- DOMAIN-KEYWORD,gitlab,Proxy
- DOMAIN-KEYWORD,npm,Proxy
- DOMAIN-KEYWORD,stackoverflow.com,Proxy
- DOMAIN-SUFFIX,techcrunch.com,Proxy
- DOMAIN-SUFFIX,go-lang.com,Proxy
- DOMAIN-SUFFIX,go-lang.net,Proxy
- DOMAIN-SUFFIX,go-lang.org,Proxy
- DOMAIN-SUFFIX,go.dev,Proxy
- DOMAIN-SUFFIX,godoc.org,Proxy
- DOMAIN-SUFFIX,golang.com,Proxy
- DOMAIN-SUFFIX,golang.net,Proxy
- DOMAIN-SUFFIX,golang.org,Proxy
- DOMAIN-SUFFIX,trello.com,Proxy
- DOMAIN-SUFFIX,techsmith.com,Proxy
- DOMAIN-SUFFIX,thepiratebay.org,Proxy
- DOMAIN-KEYWORD,qiyi,DIRECT
- DOMAIN-SUFFIX,qy.net,DIRECT
- DOMAIN-SUFFIX,letv.com,DIRECT
- DOMAIN-SUFFIX,71.am,DIRECT
- DOMAIN-SUFFIX,71edge.com,DIRECT
- DOMAIN-SUFFIX,iqiyi.com,DIRECT
- DOMAIN-SUFFIX,iqiyipic.com,DIRECT
- DOMAIN-SUFFIX,ppsimg.com,DIRECT
- DOMAIN-SUFFIX,qiyi.com,DIRECT
- DOMAIN-SUFFIX,qiyipic.com,DIRECT
- DOMAIN-SUFFIX,163yun.com,DIRECT
- DOMAIN-SUFFIX,music.126.net,DIRECT
- DOMAIN-SUFFIX,music.163.com,DIRECT
- DOMAIN-SUFFIX,tnkjmec.com,DIRECT
- DOMAIN-SUFFIX,clngaa.com,DIRECT
- DOMAIN-SUFFIX,ksyna.com,DIRECT
- DOMAIN-SUFFIX,bscstorage.net,DIRECT
- DOMAIN-SUFFIX,eccdnx.com,DIRECT
- DOMAIN-SUFFIX,pinyuncloud.com,DIRECT
- DOMAIN-SUFFIX,8686c.com,DIRECT
- DOMAIN-SUFFIX,pphimalayanrt.com,DIRECT
- DOMAIN-SUFFIX,qbox.me,DIRECT
- DOMAIN-SUFFIX,qiniu.com,DIRECT
- DOMAIN-SUFFIX,qiniudn.com,DIRECT
- DOMAIN-SUFFIX,qiniup.com,DIRECT
- DOMAIN-SUFFIX,qnsdk.com,DIRECT
- DOMAIN-SUFFIX,qnssl.com,DIRECT
- DOMAIN-SUFFIX,qiniucdn.com,DIRECT
- DOMAIN-SUFFIX,qiniudns.com,DIRECT
- DOMAIN-SUFFIX,sandai.net,DIRECT
- DOMAIN-KEYWORD,toutiao,DIRECT
- DOMAIN-SUFFIX,bdxiguastatic.com,DIRECT
- DOMAIN-SUFFIX,bdurl.net,DIRECT
- DOMAIN-SUFFIX,douyinstatic.com,DIRECT
- DOMAIN-SUFFIX,douyin.com,DIRECT
- DOMAIN-SUFFIX,douyinpic.com,DIRECT
- DOMAIN-SUFFIX,douyinvod.com,DIRECT
- DOMAIN-SUFFIX,huoshan.com,DIRECT
- DOMAIN-SUFFIX,huoshanstatic.com,DIRECT
- DOMAIN-SUFFIX,huoshanzhibo.com,DIRECT
- DOMAIN-SUFFIX,ixigua.com,DIRECT
- DOMAIN-SUFFIX,ixiguavideo.com,DIRECT
- DOMAIN-SUFFIX,ixgvideo.com,DIRECT
- DOMAIN-SUFFIX,bdxiguaimg.com,DIRECT
- DOMAIN-SUFFIX,pstatp.com,DIRECT
- DOMAIN-SUFFIX,snssdk.com,DIRECT
- DOMAIN-SUFFIX,zijiecdn.com,DIRECT
- DOMAIN-SUFFIX,zijiecdn.net,DIRECT
- DOMAIN-SUFFIX,zjbyte.cn,DIRECT
- DOMAIN-SUFFIX,zjcdn.com,DIRECT
- DOMAIN-SUFFIX,bytedance.com,DIRECT
- DOMAIN-SUFFIX,bytedance.net,DIRECT
- DOMAIN-SUFFIX,bytedns.net,DIRECT
- DOMAIN-SUFFIX,byteimg.com,DIRECT
- DOMAIN-SUFFIX,feiliao.com,DIRECT
- DOMAIN-SUFFIX,gifshow.com,DIRECT
- DOMAIN-SUFFIX,iesdouyin.com,DIRECT
- DOMAIN-SUFFIX,kspkg.com,DIRECT
- DOMAIN-SUFFIX,wukong.com,DIRECT
- DOMAIN-SUFFIX,zijieimg.com,DIRECT
- DOMAIN-SUFFIX,zjbyte.com,DIRECT
- DOMAIN-KEYWORD,bili,DIRECT
- DOMAIN-SUFFIX,acg.tv,DIRECT
- DOMAIN-SUFFIX,acgvideo.com,DIRECT
- DOMAIN-SUFFIX,b23.tv,DIRECT
- DOMAIN-SUFFIX,hdslb.com,DIRECT
- DOMAIN-SUFFIX,im9.com,DIRECT
- DOMAIN-SUFFIX,blizzard.com,DIRECT
- DOMAIN-SUFFIX,battle.net,DIRECT
- DOMAIN,blzddist1-a.akamaihd.net,DIRECT
- DOMAIN-SUFFIX,digicert.com,DIRECT
- DOMAIN-SUFFIX,code.visualstudio.com,DIRECT
- DOMAIN-SUFFIX,cctv.com,DIRECT
- DOMAIN-SUFFIX,cctvpic.com,DIRECT
- DOMAIN-SUFFIX,livechina.com,DIRECT
- DOMAIN-SUFFIX,didialift.com,DIRECT
- DOMAIN-SUFFIX,didiglobal.com,DIRECT
- DOMAIN-SUFFIX,udache.com,DIRECT
- DOMAIN-SUFFIX,douyu.com,DIRECT
- DOMAIN-SUFFIX,douyu.tv,DIRECT
- DOMAIN-SUFFIX,douyuscdn.com,DIRECT
- DOMAIN-SUFFIX,douyutv.com,DIRECT
- DOMAIN-SUFFIX,dbankcdn.com,DIRECT
- DOMAIN-SUFFIX,hc-cdn.com,DIRECT
- DOMAIN-SUFFIX,hicloud.com,DIRECT
- DOMAIN-SUFFIX,huawei.com,DIRECT
- DOMAIN-SUFFIX,huaweicloud.com,DIRECT
- DOMAIN-SUFFIX,huaweishop.net,DIRECT
- DOMAIN-SUFFIX,hwccpc.com,DIRECT
- DOMAIN-SUFFIX,vmall.com,DIRECT
- DOMAIN-SUFFIX,vmallres.com,DIRECT
- DOMAIN-SUFFIX,iflyink.com,DIRECT
- DOMAIN-SUFFIX,iflyrec.com,DIRECT
- DOMAIN-SUFFIX,iflytek.com,DIRECT
- DOMAIN,dig.bdurl.net,DIRECT
- DOMAIN,pagead2.googlesyndication.com,DIRECT
- DOMAIN,csgo.wmsj.cn,Steam
- DOMAIN,dl.steam.clngaa.com,Steam
- DOMAIN,dl.steam.ksyna.com,Steam
- DOMAIN,dota2.wmsj.cn,Steam
- DOMAIN,st.dl.bscstorage.net,Steam
- DOMAIN,st.dl.eccdnx.com,Steam
- DOMAIN,st.dl.pinyuncloud.com,Steam
- DOMAIN,steampipe.steamcontent.tnkjmec.com,Steam
- DOMAIN,steampowered.com.8686c.com,Steam
- DOMAIN,steamstatic.com.8686c.com,Steam
- DOMAIN,wmsjsteam.com,Steam
- DOMAIN-SUFFIX,cm.steampowered.com,Steam
- DOMAIN-SUFFIX,steamchina.com,Steam
- DOMAIN-SUFFIX,steamcontent.com,Steam
- DOMAIN-SUFFIX,steamusercontent.com,Steam
- DOMAIN-SUFFIX,fanatical.com,Steam
- DOMAIN-SUFFIX,humblebundle.com,Steam
- DOMAIN-SUFFIX,steamcommunity.com,Steam
- DOMAIN-SUFFIX,steampowered.com,Steam
- DOMAIN-SUFFIX,steamstatic.com,Steam
- DOMAIN-SUFFIX,steam-chat.com,Steam
- DOMAIN-SUFFIX,valvesoftware.com,Steam
- DOMAIN-KEYWORD,steamuserimages,Steam
- DOMAIN-KEYWORD,steamcontent,Steam
- DOMAIN,steambroadcast.akamaized.net,Steam
- DOMAIN,steamcdn-a.akamaihd.net,Steam
- DOMAIN,steamcommunity-a.akamaihd.net,Steam
- DOMAIN,steampipe.akamaized.net,Steam
- DOMAIN,steamstore-a.akamaihd.net,Steam
- DOMAIN,steamusercontent-a.akamaihd.net,Steam
- DOMAIN,steamuserimages-a.akamaihd.net,Steam
- DOMAIN-SUFFIX,playartifact.com,Steam
- DOMAIN-SUFFIX,steamgames.com,Steam
- DOMAIN-SUFFIX,steamserver.net,Steam
- DOMAIN-SUFFIX,steamstat.us,Steam
- DOMAIN-SUFFIX,underlords.com,Steam
- DOMAIN-SUFFIX,epicgames.com,Steam
- DOMAIN-SUFFIX,helpshift.com,Steam
- DOMAIN-SUFFIX,paragon.com,Steam
- DOMAIN-SUFFIX,unrealengine.com,Steam
- DOMAIN-SUFFIX,ol.epicgames.com,Steam
- DOMAIN-KEYWORD,epicgames,Steam
- DOMAIN,ip.sb,Proxy
- DOMAIN,myip.ipip.net,Video
- DOMAIN,ifconfig.me,Netflix
- DOMAIN,services.googleapis.cn,Proxy
- DOMAIN,googleapis.cn,Proxy
- DOMAIN-SUFFIX,ping.pe,Proxy
- DOMAIN-SUFFIX,f2pool.com,Proxy
- DOMAIN-SUFFIX,static.wikia.nocookie.net,Proxy
- DOMAIN-SUFFIX,cc98.org,DIRECT
- DOMAIN,google.com,Proxy
- DOMAIN-SUFFIX,google.cn,Proxy
- DOMAIN-SUFFIX,googleapis.cn,Proxy
- DOMAIN-KEYWORD,facebook,Proxy
- DOMAIN-SUFFIX,fb.me,Proxy
- DOMAIN-KEYWORD,gmail,Proxy
- DOMAIN-KEYWORD,twitter,Proxy
- DOMAIN-KEYWORD,instagram,Proxy
- DOMAIN-KEYWORD,blogspot,Proxy
- DOMAIN-KEYWORD,whatsapp,Proxy
- DOMAIN-KEYWORD,glados,Proxy
- DOMAIN-KEYWORD,wikipedia,Proxy
- DOMAIN-SUFFIX,facebook.com,Proxy
- DOMAIN-SUFFIX,yahoo.com,Proxy
- DOMAIN-SUFFIX,amazon.com,Proxy
- DOMAIN-SUFFIX,vk.com,Proxy
- DOMAIN-SUFFIX,zoom.us,Proxy
- DOMAIN-SUFFIX,wikipedia.org,Proxy
- DOMAIN-SUFFIX,myshopify.com,Proxy
- DOMAIN-SUFFIX,instagram.com,Proxy
- DOMAIN-SUFFIX,okezone.com,Proxy
- DOMAIN-SUFFIX,ebay.com,Proxy
- DOMAIN-SUFFIX,bongacams.com,Proxy
- DOMAIN-SUFFIX,blogspot.com,Proxy
- DOMAIN-SUFFIX,yahoo.co.jp,Proxy
- DOMAIN-SUFFIX,babytree.com,Proxy
- DOMAIN-SUFFIX,amazon.co.jp,Proxy
- DOMAIN-SUFFIX,adobe.com,Proxy
- DOMAIN-SUFFIX,livejasmin.com,Proxy
- DOMAIN-SUFFIX,stackoverflow.com,Proxy
- DOMAIN-SUFFIX,dropbox.com,Proxy
- DOMAIN-SUFFIX,msn.com,Proxy
- DOMAIN-SUFFIX,yandex.ru,Proxy
- DOMAIN-SUFFIX,linkedin.com,Proxy
- DOMAIN-SUFFIX,twitter.com,Proxy
- DOMAIN-SUFFIX,imgur.com,Proxy
- DOMAIN-SUFFIX,amazonaws.com,Proxy
- DOMAIN-SUFFIX,imdb.com,Proxy
- DOMAIN-SUFFIX,whatsapp.com,Proxy
- DOMAIN-SUFFIX,google.co.jp,Proxy
- DOMAIN-SUFFIX,wordpress.com,Proxy
- DOMAIN-SUFFIX,nytimes.com,Proxy
- DOMAIN-SUFFIX,spotify.com,Proxy
- DOMAIN-SUFFIX,s3.amazonaws.com,Video
- DOMAIN-KEYWORD,akam,Video
- DOMAIN-KEYWORD,youtube,Video
- DOMAIN,lybmc.com,DIRECT
- DOMAIN,dayi.com,Video
- DOMAIN-SUFFIX,phncdn.com,Video
- DOMAIN-SUFFIX,phprcdn.com,Video
- DOMAIN-SUFFIX,youtu.be,Video
- DOMAIN-SUFFIX,ytimg.com,Video
- DOMAIN-KEYWORD,twitch,Video
- DOMAIN-SUFFIX,googlevideo.com,Video
- DOMAIN-SUFFIX,googleusercontent.com,Video
- DOMAIN-KEYWORD,netflix,Netflix
- DOMAIN-SUFFIX,netflix.com,Netflix
- DOMAIN-SUFFIX,netflix.net,Netflix
- DOMAIN-SUFFIX,nflxext.com,Netflix
- DOMAIN-SUFFIX,nflximg.com,Netflix
- DOMAIN-SUFFIX,nflximg.net,Netflix
- DOMAIN-SUFFIX,nflxso.net,Netflix
- DOMAIN-KEYWORD,dualstack.apiproxy-,Netflix
- DOMAIN-KEYWORD,dualstack.ichnaea-web-,Netflix
- DOMAIN-SUFFIX,netflix.com.edgesuite.net,Netflix
- DOMAIN-SUFFIX,us-west-2.amazonaws.com,Netflix
- DOMAIN-KEYWORD,apiproxy-device-prod-nlb-,Netflix
- DOMAIN-KEYWORD,ichnaea-web-,Netflix
- DOMAIN,netflix.com.edgesuite.net,Netflix
- DOMAIN-SUFFIX,nflxvideo.net,Netflix
- DOMAIN-KEYWORD,foxplus,Netflix
- DOMAIN-SUFFIX,config.fox.com,Netflix
- DOMAIN-SUFFIX,emome.net,Netflix
- DOMAIN-SUFFIX,fox.com,Netflix
- DOMAIN-SUFFIX,foxdcg.com,Netflix
- DOMAIN-SUFFIX,foxnow.com,Netflix
- DOMAIN-SUFFIX,foxplus.com,Netflix
- DOMAIN-SUFFIX,foxplay.com,Netflix
- DOMAIN-SUFFIX,ipinfo.io,Netflix
- DOMAIN-SUFFIX,mstage.io,Netflix
- DOMAIN-SUFFIX,now.com,Netflix
- DOMAIN-SUFFIX,theplatform.com,Netflix
- DOMAIN-SUFFIX,urlload.net,Netflix
- DOMAIN-SUFFIX,hbo.com,Netflix
- DOMAIN-SUFFIX,hboasia.com,Netflix
- DOMAIN-SUFFIX,hbogo.com,Netflix
- DOMAIN-SUFFIX,hbogoasia.hk,Netflix
- DOMAIN-SUFFIX,hulu.com,Netflix
- DOMAIN-SUFFIX,huluim.com,Netflix
- DOMAIN-SUFFIX,hulustream.com,Netflix
- DOMAIN-SUFFIX,fast.com,Netflix
- DOMAIN-SUFFIX,oca.nflxvideo.net,Netflix
- DOMAIN,cdn.registerdisney.go.com,Netflix
- DOMAIN-SUFFIX,adobedtm.com,Netflix
- DOMAIN-SUFFIX,bam.nr-data.net,Netflix
- DOMAIN-SUFFIX,bamgrid.com,Netflix
- DOMAIN-SUFFIX,braze.com,Netflix
- DOMAIN-SUFFIX,cdn.optimizely.com,Netflix
- DOMAIN-SUFFIX,cdn.registerdisney.go.com,Netflix
- DOMAIN-SUFFIX,cws.conviva.com,Netflix
- DOMAIN-SUFFIX,d9.flashtalking.com,Netflix
- DOMAIN-SUFFIX,disney-plus.net,Netflix
- DOMAIN-SUFFIX,disney-portal.my.onetrust.com,Netflix
- DOMAIN-SUFFIX,disney.demdex.net,Netflix
- DOMAIN-SUFFIX,disney.my.sentry.io,Netflix
- DOMAIN-SUFFIX,disneyplus.bn5x.net,Netflix
- DOMAIN-SUFFIX,disneyplus.com,Netflix
- DOMAIN-SUFFIX,disneyplus.com.ssl.sc.omtrdc.net,Netflix
- DOMAIN-SUFFIX,disneystreaming.com,Netflix
- DOMAIN-SUFFIX,dssott.com,Netflix
- DOMAIN-SUFFIX,execute-api.us-east-1.amazonaws.com,Netflix
- DOMAIN-SUFFIX,js-agent.newrelic.com,Netflix
- DOMAIN-SUFFIX,edgedatg.com,Video
- DOMAIN-SUFFIX,go.com,Video
- DOMAIN,linear-abematv.akamaized.net,Video
- DOMAIN-SUFFIX,abema.io,Video
- DOMAIN-SUFFIX,abema.tv,Video
- DOMAIN-SUFFIX,akamaized.net,Video
- DOMAIN-SUFFIX,ameba.jp,Video
- DOMAIN-SUFFIX,hayabusa.io,Video
- DOMAIN-SUFFIX,aiv-cdn.net,Video
- DOMAIN-SUFFIX,amazonaws.com,Video
- DOMAIN-SUFFIX,amazonvideo.com,Video
- DOMAIN-SUFFIX,llnwd.net,Video
- DOMAIN-SUFFIX,bahamut.com.tw,Netflix
- DOMAIN-SUFFIX,gamer.com.tw,Netflix
- DOMAIN-SUFFIX,hinet.net,Netflix
- DOMAIN-KEYWORD,bbcfmt,Video
- DOMAIN-KEYWORD,co.uk,Video
- DOMAIN-KEYWORD,uk-live,Video
- DOMAIN-SUFFIX,bbc.co,Video
- DOMAIN-SUFFIX,bbc.co.uk,Video
- DOMAIN-SUFFIX,bbc.com,Video
- DOMAIN-SUFFIX,bbci.co,Video
- DOMAIN-SUFFIX,bbci.co.uk,Video
- DOMAIN-SUFFIX,chocotv.com.tw,Video
- DOMAIN-SUFFIX,imkan.tv,Video
- DOMAIN-SUFFIX,joox.com,Video
- DOMAIN-KEYWORD,nowtv100,Video
- DOMAIN-KEYWORD,rthklive,Video
- DOMAIN-SUFFIX,mytvsuper.com,Video
- DOMAIN-SUFFIX,tvb.com,Video
- DOMAIN-SUFFIX,pandora.com,Video
- DOMAIN-SUFFIX,sky.com,Video
- DOMAIN-SUFFIX,skygo.co.nz,Video
- DOMAIN-KEYWORD,spotify,Video
- DOMAIN-SUFFIX,scdn.co,Video
- DOMAIN-SUFFIX,spoti.fi,Video
- DOMAIN-SUFFIX,viu.tv,Video
- DOMAIN-SUFFIX,gvt2.com,Video
- DOMAIN-SUFFIX,yt.be,Video
- DOMAIN-KEYWORD,pornhub,Video
- DOMAIN-KEYWORD,porn,Video
- DOMAIN-KEYWORD,phncdn,Video
- DOMAIN-SUFFIX,vimeo.com,Video
- DOMAIN-SUFFIX,vimeocdn.com,Video
- DOMAIN-KEYWORD,google,Proxy
- DOMAIN-SUFFIX,abc.xyz,Proxy
- DOMAIN-SUFFIX,android.com,Proxy
- DOMAIN-SUFFIX,androidify.com,Proxy
- DOMAIN-SUFFIX,dialogflow.com,Proxy
- DOMAIN-SUFFIX,autodraw.com,Proxy
- DOMAIN-SUFFIX,capitalg.com,Proxy
- DOMAIN-SUFFIX,certificate-transparency.org,Proxy
- DOMAIN-SUFFIX,chrome.com,Proxy
- DOMAIN-SUFFIX,chromeexperiments.com,Proxy
- DOMAIN-SUFFIX,chromestatus.com,Proxy
- DOMAIN-SUFFIX,chromium.org,Proxy
- DOMAIN-SUFFIX,creativelab5.com,Proxy
- DOMAIN-SUFFIX,debug.com,Proxy
- DOMAIN-SUFFIX,deepmind.com,Proxy
- DOMAIN-SUFFIX,firebaseio.com,Proxy
- DOMAIN-SUFFIX,getmdl.io,Proxy
- DOMAIN-SUFFIX,ggpht.com,Proxy
- DOMAIN-SUFFIX,gmail.com,Proxy
- DOMAIN-SUFFIX,gmodules.com,Proxy
- DOMAIN-SUFFIX,gv.com,Proxy
- DOMAIN-SUFFIX,gwtproject.org,Proxy
- DOMAIN-SUFFIX,itasoftware.com,Proxy
- DOMAIN-SUFFIX,madewithcode.com,Proxy
- DOMAIN-SUFFIX,material.io,Proxy
- DOMAIN-SUFFIX,polymer-project.org,Proxy
- DOMAIN-SUFFIX,admin.recaptcha.net,Proxy
- DOMAIN-SUFFIX,recaptcha.net,Proxy
- DOMAIN-SUFFIX,shattered.io,Proxy
- DOMAIN-SUFFIX,synergyse.com,Proxy
- DOMAIN-SUFFIX,tensorflow.org,Proxy
- DOMAIN-SUFFIX,tiltbrush.com,Proxy
- DOMAIN-SUFFIX,waveprotocol.org,Proxy
- DOMAIN-SUFFIX,waymo.com,Proxy
- DOMAIN-SUFFIX,webmproject.org,Proxy
- DOMAIN-SUFFIX,webrtc.org,Proxy
- DOMAIN-SUFFIX,whatbrowser.org,Proxy
- DOMAIN-SUFFIX,widevine.com,Proxy
- DOMAIN-SUFFIX,x.company,Proxy
- DOMAIN-SUFFIX,contest.com,Proxy
- DOMAIN-SUFFIX,graph.org,Proxy
- DOMAIN-SUFFIX,quiz.directory,Proxy
- DOMAIN-SUFFIX,t.me,Proxy
- DOMAIN-SUFFIX,tdesktop.com,Proxy
- DOMAIN-SUFFIX,telega.one,Proxy
- DOMAIN-SUFFIX,telegra.ph,Proxy
- DOMAIN-SUFFIX,telegram.dog,Proxy
- DOMAIN-SUFFIX,telegram.me,Proxy
- DOMAIN-SUFFIX,telegram.org,Proxy
- DOMAIN-SUFFIX,telegram.space,Proxy
- DOMAIN-SUFFIX,telesco.pe,Proxy
- DOMAIN-SUFFIX,tg.dev,Proxy
- DOMAIN-SUFFIX,tx.me,Proxy
- DOMAIN-SUFFIX,usercontent.dev,Proxy
- DOMAIN,hls.itunes.apple.com,DIRECT
- DOMAIN,itunes.apple.com,DIRECT
- DOMAIN,www.apple.com,DIRECT
- DOMAIN-SUFFIX,apple.com,DIRECT
- DOMAIN-SUFFIX,icloud.com,DIRECT
- DOMAIN-SUFFIX,icloud-content.com,DIRECT
- DOMAIN-SUFFIX,mzstatic.com,DIRECT
- DOMAIN-SUFFIX,aaplimg.com,DIRECT
- DOMAIN-SUFFIX,cdn-apple.com,DIRECT
- DOMAIN-SUFFIX,live.com,DIRECT
- DOMAIN-SUFFIX,live.net,DIRECT
- DOMAIN-SUFFIX,office.com,DIRECT
- DOMAIN-SUFFIX,office.net,DIRECT
- DOMAIN-SUFFIX,sharepoint.com,DIRECT
- DOMAIN-SUFFIX,office365.com,DIRECT
- DOMAIN-SUFFIX,officeppe.net,DIRECT
- DOMAIN-SUFFIX,skype.com,DIRECT
- DOMAIN-SUFFIX,onedrive.com,DIRECT
- DOMAIN-SUFFIX,msocsp.com,DIRECT
- DOMAIN-SUFFIX,msauthimages.net,DIRECT
- DOMAIN-SUFFIX,msauth.net,DIRECT
- DOMAIN-SUFFIX,msn.com,DIRECT
- DOMAIN-SUFFIX,onenote.com,DIRECT
- DOMAIN-SUFFIX,onenote.net,DIRECT
- DOMAIN-SUFFIX,1drv.com,DIRECT
- DOMAIN-SUFFIX,microsoft.com,DIRECT
- DOMAIN-SUFFIX,microsoftonline.com,DIRECT
- DOMAIN-SUFFIX,miui.com,DIRECT
- DOMAIN-SUFFIX,miwifi.com,DIRECT
- DOMAIN-SUFFIX,mob.com,DIRECT
- DOMAIN-SUFFIX,netease.com,DIRECT
- DOMAIN-KEYWORD,officecdn,DIRECT
- DOMAIN-SUFFIX,oschina.net,DIRECT
- DOMAIN-SUFFIX,qcloud.com,DIRECT
- DOMAIN-SUFFIX,qdaily.com,DIRECT
- DOMAIN-SUFFIX,qdmm.com,DIRECT
- DOMAIN-SUFFIX,qhimg.com,DIRECT
- DOMAIN-SUFFIX,qhres.com,DIRECT
- DOMAIN-SUFFIX,qidian.com,DIRECT
- DOMAIN-SUFFIX,qihucdn.com,DIRECT
- DOMAIN-SUFFIX,qq.com,DIRECT
- DOMAIN-SUFFIX,qqurl.com,DIRECT
- DOMAIN-SUFFIX,rarbg.to,DIRECT
- DOMAIN-SUFFIX,ruguoapp.com,DIRECT
- DOMAIN-SUFFIX,segmentfault.com,DIRECT
- DOMAIN-SUFFIX,sinaapp.com,DIRECT
- DOMAIN-SUFFIX,smzdm.com,DIRECT
- DOMAIN-SUFFIX,sogou.com,DIRECT
- DOMAIN-SUFFIX,sogoucdn.com,DIRECT
- DOMAIN-SUFFIX,sohu.com,DIRECT
- DOMAIN-SUFFIX,soku.com,DIRECT
- DOMAIN-SUFFIX,speedtest.net,DIRECT
- DOMAIN-SUFFIX,sspai.com,DIRECT
- DOMAIN-SUFFIX,suning.com,DIRECT
- DOMAIN-SUFFIX,taobao.com,DIRECT
- DOMAIN-SUFFIX,tenpay.com,DIRECT
- DOMAIN-SUFFIX,tmall.com,DIRECT
- DOMAIN-SUFFIX,tudou.com,DIRECT
- DOMAIN-SUFFIX,umetrip.com,DIRECT
- DOMAIN-SUFFIX,upaiyun.com,DIRECT
- DOMAIN-SUFFIX,upyun.com,DIRECT
- DOMAIN-SUFFIX,veryzhun.com,DIRECT
- DOMAIN-SUFFIX,weather.com,DIRECT
- DOMAIN-SUFFIX,weibo.com,DIRECT
- DOMAIN-SUFFIX,xiami.com,DIRECT
- DOMAIN-SUFFIX,xiami.net,DIRECT
- DOMAIN-SUFFIX,xiaomicp.com,DIRECT
- DOMAIN-SUFFIX,ximalaya.com,DIRECT
- DOMAIN-SUFFIX,xmcdn.com,DIRECT
- DOMAIN-SUFFIX,xunlei.com,DIRECT
- DOMAIN-SUFFIX,xycdn.com,DIRECT
- DOMAIN-SUFFIX,yhd.com,DIRECT
- DOMAIN-SUFFIX,yihaodianimg.com,DIRECT
- DOMAIN-SUFFIX,yinxiang.com,DIRECT
- DOMAIN-SUFFIX,ykimg.com,DIRECT
- DOMAIN-SUFFIX,youdao.com,DIRECT
- DOMAIN-SUFFIX,youku.com,DIRECT
- DOMAIN-SUFFIX,zealer.com,DIRECT
- DOMAIN-SUFFIX,zhihu.com,DIRECT
- DOMAIN-SUFFIX,zhimg.com,DIRECT
- DOMAIN-SUFFIX,zimuzu.tv,DIRECT
- DOMAIN-SUFFIX,apcdns.net,DIRECT
- DOMAIN-SUFFIX,cdntip.com,DIRECT
- DOMAIN-SUFFIX,cdntips.com,DIRECT
- DOMAIN-SUFFIX,foxmail.com,DIRECT
- DOMAIN-SUFFIX,gtimg.com,DIRECT
- DOMAIN-SUFFIX,idqqimg.com,DIRECT
- DOMAIN-SUFFIX,imqq.com,DIRECT
- DOMAIN-SUFFIX,myapp.com,DIRECT
- DOMAIN-SUFFIX,myqcloud.com,DIRECT
- DOMAIN-SUFFIX,qcloudimg.com,DIRECT
- DOMAIN-SUFFIX,qqmail.com,DIRECT
- DOMAIN-SUFFIX,qzone.com,DIRECT
- DOMAIN-SUFFIX,servicewechat.com,DIRECT
- DOMAIN-SUFFIX,smtcdns.com,DIRECT
- DOMAIN-SUFFIX,smtcdns.net,DIRECT
- DOMAIN-SUFFIX,tencent.com,DIRECT
- DOMAIN-SUFFIX,tencent.com.hk,DIRECT
- DOMAIN-SUFFIX,tencent-cloud.com,DIRECT
- DOMAIN-SUFFIX,tencent-cloud.net,DIRECT
- DOMAIN-SUFFIX,tencentcs.com,DIRECT
- DOMAIN-SUFFIX,tencentmusic.com,DIRECT
- DOMAIN-SUFFIX,tencentyun.com,DIRECT
- DOMAIN-SUFFIX,wechat.com,DIRECT
- DOMAIN-SUFFIX,wegame.com,DIRECT
- DOMAIN-SUFFIX,weiyun.com,DIRECT
- DOMAIN-SUFFIX,25pp.com,DIRECT
- DOMAIN-SUFFIX,56che.com,DIRECT
- DOMAIN-SUFFIX,95095.com,DIRECT
- DOMAIN-SUFFIX,aliapp.org,DIRECT
- DOMAIN-SUFFIX,alibaba-inc.com,DIRECT
- DOMAIN-SUFFIX,alibaba.com,DIRECT
- DOMAIN-SUFFIX,alibabacapital.com,DIRECT
- DOMAIN-SUFFIX,alibabacorp.com,DIRECT
- DOMAIN-SUFFIX,alibabadoctor.com,DIRECT
- DOMAIN-SUFFIX,alibabafuturehotel.com,DIRECT
- DOMAIN-SUFFIX,alibabagroup.com,DIRECT
- DOMAIN-SUFFIX,alibabaplanet.com,DIRECT
- DOMAIN-SUFFIX,alibabaued.com,DIRECT
- DOMAIN-SUFFIX,alibabausercontent.com,DIRECT
- DOMAIN-SUFFIX,alifanyi.com,DIRECT
- DOMAIN-SUFFIX,alihealth.hk,DIRECT
- DOMAIN-SUFFIX,aliimg.com,DIRECT
- DOMAIN-SUFFIX,alikmd.com,DIRECT
- DOMAIN-SUFFIX,alimama.com,DIRECT
- DOMAIN-SUFFIX,alimebot.com,DIRECT
- DOMAIN-SUFFIX,alimei.com,DIRECT
- DOMAIN-SUFFIX,alipay.com,DIRECT
- DOMAIN-SUFFIX,alipaydns.com,DIRECT
- DOMAIN-SUFFIX,alipayobjects.com,DIRECT
- DOMAIN-SUFFIX,aliplus.com,DIRECT
- DOMAIN-SUFFIX,aliresearch.com,DIRECT
- DOMAIN-SUFFIX,alisoft.com,DIRECT
- DOMAIN-SUFFIX,alisports.com,DIRECT
- DOMAIN-SUFFIX,alitianji.com,DIRECT
- DOMAIN-SUFFIX,aliunicorn.com,DIRECT
- DOMAIN-SUFFIX,aliway.com,DIRECT
- DOMAIN-SUFFIX,aliwork.com,DIRECT
- DOMAIN-SUFFIX,alixiaomi.com,DIRECT
- DOMAIN-SUFFIX,alizhaopin.com,DIRECT
- DOMAIN-SUFFIX,asczwa.com,DIRECT
- DOMAIN-SUFFIX,asczxcefsv.com,DIRECT
- DOMAIN-SUFFIX,atatech.org,DIRECT
- DOMAIN-SUFFIX,b2byao.com,DIRECT
- DOMAIN-SUFFIX,bazai.com,DIRECT
- DOMAIN-SUFFIX,bcvbw.com,DIRECT
- DOMAIN-SUFFIX,cheng.xin,DIRECT
- DOMAIN-SUFFIX,dayu.com,DIRECT
- DOMAIN-SUFFIX,dongting.com,DIRECT
- DOMAIN-SUFFIX,dratio.com,DIRECT
- DOMAIN-SUFFIX,emas-poc.com,DIRECT
- DOMAIN-SUFFIX,ialicdn.com,DIRECT
- DOMAIN-SUFFIX,kanbox.com,DIRECT
- DOMAIN-SUFFIX,lazada.com,DIRECT
- DOMAIN-SUFFIX,liangxinyao.com,DIRECT
- DOMAIN-SUFFIX,maitix.com,DIRECT
- DOMAIN-SUFFIX,1688.com,DIRECT
- DOMAIN-SUFFIX,etao.com,DIRECT
- DOMAIN-SUFFIX,juhuasuan.com,DIRECT
- DOMAIN-SUFFIX,lingshoujia.com,DIRECT
- DOMAIN-SUFFIX,pailitao.com,DIRECT
- DOMAIN-SUFFIX,taobao.org,DIRECT
- DOMAIN-SUFFIX,taobaocdn.com,DIRECT
- DOMAIN-SUFFIX,taobizhong.com,DIRECT
- DOMAIN-SUFFIX,taopiaopiao.com,DIRECT
- DOMAIN-SUFFIX,tbcache.com,DIRECT
- DOMAIN-SUFFIX,tburl.in,DIRECT
- DOMAIN-SUFFIX,tmall.ru,DIRECT
- DOMAIN-SUFFIX,tmalltv.com,DIRECT
- DOMAIN-SUFFIX,tmjl.ai,DIRECT
- DOMAIN-SUFFIX,alitrip.com,DIRECT
- DOMAIN-SUFFIX,feizhu.com,DIRECT
- DOMAIN-SUFFIX,fliggy.com,DIRECT
- DOMAIN,dns.google,Proxy
- IP-CIDR,1.1.1.1/32,Proxy,no-resolve
- IP-CIDR,1.0.0.1/32,Proxy,no-resolve
- IP-CIDR,8.8.8.8/32,Proxy,no-resolve
- IP-CIDR,119.29.29.29/32,DIRECT,no-resolve
- IP-CIDR,114.114.114.114/32,DIRECT,no-resolve
- IP-CIDR,127.0.0.0/8,DIRECT,no-resolve
- IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
- IP-CIDR,17.0.0.0/8,DIRECT,no-resolve
- IP-CIDR,100.64.0.0/10,DIRECT,no-resolve
- IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
- IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
- DOMAIN,2020020202.version.clash.im,REJECT
- DOMAIN-SUFFIX,cn,DIRECT
- GEOIP,CN,DIRECT
- MATCH,Proxy
SMALLFLOWERCAT1995

    # 写入 sing-box 客户端配置到 client-sing-box-config.json 文件
    cat <<SMALLFLOWERCAT1995 | sudo tee client-sing-box-config.json >/dev/null
{
  "log": {
    "level": "debug",
    "timestamp": true
  },
  "experimental": {
    "clash_api": {
      "external_controller": ":7894",
      "external_ui": "ui",
      "secret": "",
      "external_ui_download_url": "https://mirror.ghproxy.com/https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip",
      "external_ui_download_detour": "direct",
      "default_mode": "rule"
    },
    "cache_file": {
      "enabled": true,
      "path": "cache.db",
      "cache_id": "cache",
      "store_fakeip": true
    }
  },
  "dns": {
    "servers": [
      {
        "tag": "proxyDns",
        "address": "tls://8.8.8.8",
        "detour": "proxy"
      },
      {
        "tag": "localDns",
        "address": "https://223.5.5.5/dns-query",
        "detour": "direct"
      },
      {
        "tag": "block",
        "address": "rcode://success"
      }
    ],
    "rules": [
      {
        "domain": [
          "ghproxy.com",
          "cdn.jsdelivr.net",
          "testingcf.jsdelivr.net"
        ],
        "server": "localDns"
      },
      {
        "rule_set": "geosite-category-ads-all",
        "server": "block"
      },
      {
        "outbound": "any",
        "server": "localDns",
        "disable_cache": true
      },
      {
        "rule_set": "geosite-cn",
        "server": "localDns"
      },
      {
        "clash_mode": "direct",
        "server": "localDns"
      },
      {
        "clash_mode": "global",
        "server": "proxyDns"
      },
      {
        "rule_set": "geosite-geolocation-!cn",
        "server": "proxyDns"
      }
    ],
    "final": "localDns",
    "strategy": "ipv4_only"
  },
  "inbounds": [
    {
      "type": "tun",
      "inet4_address": "172.19.0.1/30",
      "mtu": 9000,
      "auto_route": true,
      "strict_route": false,
      "sniff": true
    },
    {
      "type": "http",
      "listen": "0.0.0.0",
      "listen_port": 7891,
      "sniff": true,
      "users": []
    },
    {
      "type": "socks",
      "listen": "0.0.0.0",
      "listen_port": 7892,
      "sniff": true,
      "users": []
    },
    {
      "type": "mixed",
      "listen": "0.0.0.0",
      "listen_port": 7893,
      "sniff": true,
      "users": []
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "type": "selector",
      "outbounds": [
        "auto",
        "direct",
        "$SB_ALL_PROTOCOL_OUT_GROUP_TAG"
      ]
    },
    {
      "tag": "OpenAI",
      "type": "selector",
      "outbounds": [
        "Others"
      ],
      "default": "Others"
    },
    {
      "tag": "Google",
      "type": "selector",
      "outbounds": [
        "Others"
      ]
    },
    {
      "tag": "Telegram",
      "type": "selector",
      "outbounds": [
        "Others"
      ]
    },
    {
      "tag": "Twitter",
      "type": "selector",
      "outbounds": [
        "Others"
      ]
    },
    {
      "tag": "Facebook",
      "type": "selector",
      "outbounds": [
        "Others"
      ]
    },
    {
      "tag": "BiliBili",
      "type": "selector",
      "outbounds": [
        "direct"
      ]
    },
    {
      "tag": "Bahamut",
      "type": "selector",
      "outbounds": [
        "Others"
      ],
      "default": "Others"
    },
    {
      "tag": "Spotify",
      "type": "selector",
      "outbounds": [
        "Others"
      ]
    },
    {
      "tag": "TikTok",
      "type": "selector",
      "outbounds": [
        "Others"
      ],
      "default": "Others"
    },
    {
      "tag": "NETFLIX",
      "type": "selector",
      "outbounds": [
        "Others"
      ]
    },
    {
      "tag": "Disney+",
      "type": "selector",
      "outbounds": [
        "Others"
      ]
    },
    {
      "tag": "Apple",
      "type": "selector",
      "outbounds": [
        "direct",
        "Others"
      ]
    },
    {
      "tag": "Microsoft",
      "type": "selector",
      "outbounds": [
        "direct",
        "Others"
      ]
    },
    {
      "tag": "Games",
      "type": "selector",
      "outbounds": [
        "direct",
        "Others"
      ]
    },
    {
      "tag": "Streaming",
      "type": "selector",
      "outbounds": [
        "Others"
      ]
    },
    {
      "tag": "Global",
      "type": "selector",
      "outbounds": [
        "direct",
        "Others"
      ],
      "default": "Others"
    },
    {
      "tag": "China",
      "type": "selector",
      "outbounds": [
        "direct",
        "proxy"
      ]
    },
    {
      "tag": "AdBlock",
      "type": "selector",
      "outbounds": [
        "block",
        "direct"
      ]
    },
    {
      "tag": "Others",
      "type": "selector",
      "outbounds": [
        "$SB_V_PROTOCOL_OUT_TAG",
        "$SB_VM_PROTOCOL_OUT_TAG",
        "$SB_H2_PROTOCOL_OUT_TAG",
        "proxy"
      ]
    },
    {
      "tag": "$SB_ALL_PROTOCOL_OUT_GROUP_TAG",
      "type": "selector",
      "outbounds": [
        "$SB_V_PROTOCOL_OUT_TAG",
        "$SB_VM_PROTOCOL_OUT_TAG",
        "$SB_H2_PROTOCOL_OUT_TAG"
      ]
    },
    {
      "tag": "auto",
      "type": "urltest",
      "outbounds": [
        "$SB_V_PROTOCOL_OUT_TAG",
        "$SB_VM_PROTOCOL_OUT_TAG",
        "$SB_H2_PROTOCOL_OUT_TAG"
      ],
      "url": "http://www.gstatic.com/generate_204",
      "interval": "10m",
      "tolerance": 50
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "$V_PROTOCOL",
      "tag": "$SB_V_PROTOCOL_OUT_TAG",
      "uuid": "$V_UUID",
      "flow": "xtls-rprx-vision",
      "packet_encoding": "xudp",
      "server": "$VLESS_N_DOMAIN",
      "server_port": $VLESS_N_PORT,
      "tls": {
        "enabled": true,
        "server_name": "$R_STEAL_WEBSITE_CERTIFICATES",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
        "reality": {
          "enabled": true,
          "public_key": "$R_PUBLICKEY",
          "short_id": "$R_HEX"
        }
      }
    },
    {
      "server": "$VM_WEBSITE",
      "server_port": $CLOUDFLARED_PORT,
      "tag": "$SB_VM_PROTOCOL_OUT_TAG",
      "tls": {
        "enabled": true,
        "server_name": "$CLOUDFLARED_DOMAIN",
        "insecure": true,
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        }
      },
      "packet_encoding": "packetaddr",
      "transport": {
        "headers": {
          "Host": [
            "$CLOUDFLARED_DOMAIN"
          ]
        },
        "path": "$VM_PATH",
        "type": "$VM_TYPE",
        "max_early_data": 2048,
        "early_data_header_name": "Sec-WebSocket-Protocol"
      },
      "type": "$VM_PROTOCOL",
      "security": "auto",
      "uuid": "$VM_UUID"
    },
    {
      "type": "$H2_PROTOCOL",
      "server": "$H2_N_DOMAIN",
      "server_port": $H2_N_PORT,
      "tag": "$SB_H2_PROTOCOL_OUT_TAG",
      "up_mbps": 100,
      "down_mbps": 100,
      "password": "$H2_HEX",
      "network": "tcp",
      "tls": {
        "enabled": true,
        "server_name": "$H2_WEBSITE_CERTIFICATES",
        "insecure": true,
        "alpn": [
          "$H2_TYPE"
        ]
      }
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "final": "proxy",
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "port": 53,
        "outbound": "dns-out"
      },
      {
        "network": "udp",
        "port": 443,
        "outbound": "block"
      },
      {
        "rule_set": "geosite-category-ads-all",
        "outbound": "AdBlock"
      },
      {
        "clash_mode": "direct",
        "outbound": "direct"
      },
      {
        "clash_mode": "global",
        "outbound": "proxy"
      },
      {
        "domain": [
          "clash.razord.top",
          "yacd.metacubex.one",
          "yacd.haishan.me",
          "d.metacubex.one"
        ],
        "outbound": "direct"
      },
      {
        "rule_set": "geosite-openai",
        "outbound": "OpenAI"
      },
      {
        "rule_set": "geosite-youtube",
        "outbound": "Google"
      },
      {
        "rule_set": "geoip-google",
        "outbound": "Google"
      },
      {
        "rule_set": "geosite-google",
        "outbound": "Google"
      },
      {
        "rule_set": "geosite-github",
        "outbound": "Google"
      },
      {
        "rule_set": "geoip-telegram",
        "outbound": "Telegram"
      },
      {
        "rule_set": "geosite-telegram",
        "outbound": "Telegram"
      },
      {
        "rule_set": "geoip-twitter",
        "outbound": "Twitter"
      },
      {
        "rule_set": "geosite-twitter",
        "outbound": "Twitter"
      },
      {
        "rule_set": "geoip-facebook",
        "outbound": "Facebook"
      },
      {
        "rule_set": [
          "geosite-facebook",
          "geosite-instagram"
        ],
        "outbound": "Facebook"
      },
      {
        "rule_set": "geoip-bilibili",
        "outbound": "BiliBili"
      },
      {
        "rule_set": "geosite-bilibili",
        "outbound": "BiliBili"
      },
      {
        "rule_set": "geosite-bahamut",
        "outbound": "Bahamut"
      },
      {
        "rule_set": "geosite-spotify",
        "outbound": "Spotify"
      },
      {
        "rule_set": "geosite-tiktok",
        "outbound": "TikTok"
      },
      {
        "rule_set": "geoip-netflix",
        "outbound": "NETFLIX"
      },
      {
        "rule_set": "geosite-netflix",
        "outbound": "NETFLIX"
      },
      {
        "rule_set": "geosite-disney",
        "outbound": "Disney+"
      },
      {
        "rule_set": "geosite-apple",
        "outbound": "Apple"
      },
      {
        "rule_set": "geosite-amazon",
        "outbound": "Apple"
      },
      {
        "rule_set": "geosite-microsoft",
        "outbound": "Microsoft"
      },
      {
        "rule_set": "geosite-category-games",
        "outbound": "Games"
      },
      {
        "rule_set": "geosite-hbo",
        "outbound": "Streaming"
      },
      {
        "rule_set": "geosite-primevideo",
        "outbound": "Streaming"
      },
      {
        "rule_set": "geosite-geolocation-!cn",
        "outbound": "Global"
      },
      {
        "rule_set": "geosite-private",
        "outbound": "direct"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      },
      {
        "rule_set": "geoip-cn",
        "outbound": "China"
      },
      {
        "rule_set": "geosite-cn",
        "outbound": "China"
      }
    ],
    "rule_set": [
      {
        "tag": "geoip-google",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/google.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geoip-telegram",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/telegram.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geoip-twitter",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/twitter.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geoip-facebook",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/facebook.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geoip-netflix",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/netflix.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geoip-apple",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo-lite/geoip/apple.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geoip-bilibili",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo-lite/geoip/bilibili.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geoip-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/cn.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-private",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/private.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-openai",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/openai.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-youtube",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/youtube.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-google",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/google.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-github",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/github.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-telegram",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/telegram.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-twitter",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/twitter.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-facebook",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/facebook.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-instagram",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/instagram.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-bilibili",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/bilibili.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-bahamut",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/bahamut.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-spotify",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/spotify.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-tiktok",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/tiktok.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-netflix",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/netflix.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-disney",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/disney.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-apple",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/apple.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-amazon",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/amazon.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-microsoft",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/microsoft.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-category-games",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-games.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-hbo",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/hbo.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-primevideo",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/primevideo.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/cn.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-geolocation-!cn",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/geolocation-!cn.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-category-ads-all",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-ads-all.srs",
        "download_detour": "direct"
      }
    ]
  }
}
SMALLFLOWERCAT1995
    # 发送到邮件所需变量
    # 本机 ip
    HOSTNAME_IP="$(hostname -I)"
    # 终末时间=起始时间+6h
    #F_DATE="$(date -d '${REPORT_DATE}' --date='6 hour' +'%Y-%m-%d %T')"
    F_DATE="$(TZ=':Asia/Shanghai' date +'%Y-%m-%d %T')"
    # 写入 result.txt
    cat <<SMALLFLOWERCAT1995 | sudo tee result.txt >/dev/null
SSH is accessible at: 
$HOSTNAME_IP:22 -> $SSH_N_DOMAIN:$SSH_N_PORT
ssh $USER_NAME@$SSH_N_DOMAIN -o ServerAliveInterval=60 -p $SSH_N_PORT

VLESS is accessible at: 
$HOSTNAME_IP:$V_PORT -> $VLESS_N_DOMAIN:$VLESS_N_PORT
$VLESS_LINK

# VMESS is accessible at: 
# $HOSTNAME_IP:$VM_PORT -> $CLOUDFLARED_DOMAIN:$CLOUDFLARED_PORT
$VMESS_LINK

# HYSTERIA2 is accessible at: 
# $HOSTNAME_IP:$H2_PORT -> $H2_N_DOMAIN:$H2_N_PORT
$HYSTERIA2_LINK

Time Frame is accessible at: 
$REPORT_DATE~$F_DATE
SMALLFLOWERCAT1995
}
# 前戏初始化函数 initall
initall
# 初始化用户密码
createUserNamePassword
# 神秘的分割线
echo "=========================================="
# 下载 CloudflareSpeedTest sing-box cloudflared ngrok 配置并启用
getAndStart
# 神秘的分隔符
echo "=========================================="
# 删除脚本自身
rm -fv set-sing-box.sh
# 清理 bash 记录
echo '' >$HOME/.bash_history
echo '' >$HOME/.bash_logout
history -c
