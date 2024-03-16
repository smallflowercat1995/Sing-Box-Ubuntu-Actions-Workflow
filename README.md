# Sing-Box-Ubuntu-Actions-Workflow
这是借用 actions 产生的虚拟机网络环境并使用 sing-box + reality(vless) + vmess 共享网络环境并通过 ngrok + cloudflared 透传网络数据从而让我访问国际互联网的临时应急方案  

[![GitHub Workflow Status](https://github.com/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow/actions/workflows/actions.yml/badge.svg)](https://github.com/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow/actions/workflows/actions.yml)![Watchers](https://img.shields.io/github/watchers/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow) ![Stars](https://img.shields.io/github/stars/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow) ![Forks](https://img.shields.io/github/forks/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow) ![Vistors](https://visitor-badge.laobi.icu/badge?page_id=smallflowercat1995.Sing-Box-Ubuntu-Actions-Workflow) ![LICENSE](https://img.shields.io/badge/license-CC%20BY--SA%204.0-green.svg)
<a href="https://star-history.com/#smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow&type=Date" />
  </picture>
</a>

## 描述
1. 这个项目主要是为了临时能够正常看 youtube 和 google。  
2. 运行 actions workflow 用于运行脚本，需要添加 `GITHUB_TOKEN` 环境变量，这个是访问 GitHub API 的令牌，可以在 GitHub 主页，点击个人头像，Settings -> Developer settings -> Personal access tokens ，设置名字为 GITHUB_TOKEN 接着要勾选权限，勾选repo、admin:repo_hook和workflow即可，最后点击Generate token，如图所示  

![1](https://github.com/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow/assets/144557489/114eb860-d110-44b7-ae82-e84942b34ec1)

3. 赋予 actions[bot] 读/写仓库权限 -> Settings -> Actions -> General -> Workflow Permissions -> Read and write permissions -> save，如图所示  

![2](https://github.com/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow/assets/144557489/665df9d6-f795-4000-95c8-08a4aeb50197)  

4. 添加 linux 用户名 `USER_NAME` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret  
5. 添加 linux 密码 `USER_PW` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret  
6. 添加 linux hostname `HOST_NAME` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret  
7. 注册 Ngrok 账户登录，并复制 Ngrok AUTH TOKEN key 位置在此 https://dashboard.ngrok.com/get-started/your-authtoken
8. 添加 ngrok `NGROK_AUTH_TOKEN` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret  
9. 添加 email smtp 服务器域名 `MAILADDR` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret    
10. 添加 email smtp 服务器端口 `MAILPORT` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret    
11. 添加 email smtp 服务器登录账号 `MAILUSERNAME` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret  
12. 添加 email smtp 服务器第三方登陆授权码 `MAILPASSWORD` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret  
13. 添加  email smtp 服务器应该发送邮件位置 `MAILSENDTO` 在 GitHub 仓库页 -> Settings -> Secrets -> actions -> New repository secret
14. 以上流程如图所示

![3](https://github.com/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow/assets/144557489/d0a72247-334d-4032-9a91-94d7004fc62e)  

15. 转到 Actions -> Sing-Box-Ubuntu-Actions-Workflow 并且启动 workflow，实现自动化  
16. 新目录结构  

        .
        ├── .github                                     # github actions 配置目录  
        │   ├── workflows                               # github actions 配置文件目录  
        │   ├── actions.yml                             # github actions workflow 配置  
        │   └── remove-old-workflow.yml                 # github actions 移除老旧的 workflow  
        ├── set-sing-box.sh                             # 搭建配置 sing-box 脚本  
        └── README.md                                   # 这个是说明文件   
17. 脚本会生成6个文件发送到邮箱，如下图  

        1. result.txt
            a. 包含 ssh 端口转发信息以及连接命令
            b. 包含 vless 端口转发信息以及共享支持 nekobox 导入链接
            c. 包含 vmess 端口转发信息以及共享支持 nekobox 导入链接
            d. 包含 hysteria2 端口转发信息以及共享支持 nekobox 导入链接
        2. VLESS.png
            a. vless 支持 nekobox 二维码扫描导入
        3. VMESS.png
            a. vmess 支持 nekobox 二维码扫描导入
        4. HYSTERIA2.png
            a. hysteria2 支持 nekobox 二维码扫描导入
        5. client-nekobox-config.yaml
            a. nekobox 配置文件支持 nekobox 导入
        6. client-sing-box-config.json
            a. sing-box 配置文件支持 sing-box 导入

![image](https://github.com/smallflowercat1995/Sing-Box-Ubuntu-Actions-Workflow/assets/144557489/027575e8-5d88-410b-8e71-30317a795452)



# 更新
    1. 出于安全考虑还是使用邮箱把发送内容发给自己的邮箱，生成的文件支持 sing-box nekobx 客户端  
    2. 维持的时间还是不稳定，最长维持 44min42s  
    3. 修改发件内容为文本附近形式  
    4. 修改了描述文件，提供详细的描述，方便他人
    5. 添加注释，方便以后的人改写脚本代码
    6. 更新添加优选IP
    7. 生成 vless vmess 和 hysteria2 二维码图片和链接方便 nekobox 客户端导入
    8. 生成 nekobox yaml 配置文件方便 nekobox 客户端导入

# 缺陷
    1. 经历了许多次无奈，反复折磨，tcp和udp互转，我终于认清了现实，
       在github的actions流环境下，ngrok不支持 sing-box 的 hysteria2 udp 数据转发
       我尝试了很多，udp转tcp，tcp转udp，端口监听，我真的尽力了，现在我一点办法也没有，
       唉，我只能用vmess和vless，也许你会问我为什么不买云服务器，我只是想说，太贵了，
       唉，我不想花钱，忍着吧
    2. ngrok 有每月带宽 1g 限制，到一定程度，就会报错，所以修改了逻辑
       即使 ngrok 暂时不能用还有 cloudflared 可以接着用

# 声明
本项目仅作学习交流使用，用于查找资料，学习知识，不做任何违法行为。所有资源均来自互联网，仅供大家交流学习使用，出现违法问题概不负责。  

# 注意
多人 fork 本项目且一起运行 actions 时，可能会导致本人项目被ban掉，所以，你可以创建新项目，把文件复制过去，自己享用

# 感谢&参考  
sing-box: https://sing-box.sagernet.org/  
ngrok 使用: https://dashboard.ngrok.com/get-started/setup/linux  
cloudflared: https://github.com/cloudflare/cloudflared  
CloudflareSpeedTest: https://github.com/XIU2/CloudflareSpeedTest  
使用 email smtp 发送邮件: https://blog.csdn.net/liuyuinsdu/article/details/113878840  
youtube 绵阿羊 在sing-box上安装reality和hysteria2: https://www.youtube.com/watch?v=hbrOxWrGmTc  
文档 绵阿羊 在sing-box上安装reality和hysteria2: https://blog.mareep.net/posts/15209  
github vveg26/sing-box-reality-hysteria2: https://github.com/vveg26/sing-box-reality-hysteria2  
github teddysun/across: https://github.com/teddysun/across  
