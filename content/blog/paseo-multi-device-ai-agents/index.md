---
title: "用 Paseo 把 AI 编程 Agent 搬上全家桶：多设备部署实录（Windows + 飞牛NAS + MacBook + iPhone）"
meta_title: "用 Paseo 把 AI 编程 Agent 搬上全家桶：多设备部署实录"
description: "一台 Windows 主力机跑 AI 编程 Agent 不少见，但把它跑满 NAS、MacBook、甚至手机随时指挥，就需要 Paseo + Tailscale 这套组合了。本文完整记录这次三机一机的部署过程：Windows 无声运行的排雷、Linux 的 systemd 配方、macOS 的 launchd 配方、iPhone 端配对，以及一路踩过的坑。"
date: 2026-09-08T11:20:00+08:00
publishDate: 2026-09-08T11:20:00+08:00
draft: false
slug: "paseo-multi-device-ai-agents"
tags: ["Paseo", "Tailscale", "AI Agent", "Windows", "NAS", "macOS", "systemd", "launchd", "远程开发"]
categories: ["dev-environment", "ai-agent"]
author: "Jerry"
image: "/blog/paseo-multi-device-ai-agents/cover.svg"
summary: "Paseo + Tailscale 三机一机部署实录：Windows 无弹窗守护进程、飞牛NAS 的 systemd 配方、MacBook 的 launchd 零 sudo 安装、iPhone 随时指挥三台设备上的 pi agent。"
cover: "cover.svg"
---

本文记录我把本地 AI 编程 Agent（pi）规模化跑遍全家桶的完整过程：一台 Windows 主力机只是起点，目标是用手机和任意电脑，随时指挥 NAS、MacBook 和主力机上各自独立的 AI 编程会话。

部署思路参考了 [Paseo 入门文章](https://zeroicey.me/posts/paseo-ai-coding-agents/)，但这是一份更贴地的 Windows + 国产 NAS + macOS 实战记录——尤其 Windows 上"守护进程完全不出弹窗"这一节，是我排了最久的雷。

## 背景：为什么要把一个终端程序搬到别处

我的开发主力机是 Windows 10，长期使用 pi 这个本地 AI 编程 Agent（`@earendil-works/pi-coding-agent`）。它配合我改过的多窗格扩展（基于 herdr 的后端）在本地跑得很顺，还做了两处个性化：去掉了代码操作的确认门槛（改代码全自动），并保留了 Windows Toast 任务完成通知。

问题在于：它一直被"绑"在这台机器的终端里。于是有了这次的目标——

1. 让飞牛 NAS（Debian 12）也能跑 pi agent，分担离线任务；
2. 让 MacBook 也能跑，换台机器就换一种体验；
3. 最重要的是：**出门在外，用 iPhone 随时查看和指挥这几台机器上的 AI 会话**。

## 最终架构

```
┌─────────────┐   Tailscale 私有网络 (100.64.0.0/24)   ┌─────────────┐
│   iPhone     │──Direct connection──▶  每台机器一个      │  winpc       │
│  Paseo App   │    host:IP:6767 + 同一把密码            │  (Windows 10)│
└─────────────┘                                        │  100.64.0.2  │
                                                        │  paseo daemon│
┌─────────────┐          ┌─────────────┐                │  + new-api   │
│   fnnas      │          │   mbp16     │                │  网关 30006  │
│ 飞牛 NAS     │          │  macOS 26   │                └─────────────┘
│ Debian 12    │          │  arm64      │                      │
│ 100.64.0.1   │          │ 100.64.0.5  │                      │
│ paseo daemon │          │ paseo daemon│◀──── 模型全部走 ──────┘
└─────────────┘          └─────────────┘        winpc 的 new-api 网关
```

- **算力宿主（3 台）**：winpc / fnnas / mbp16，各自跑一个 headless 的 paseo daemon，daemon 负责托管 pi agent 实例（每一个 agent 就是一个完整的 pi 会话，有独立的工作目录和上下文）。
- **控制端**：iPhone 上的 Paseo App，以及任何一台能 ssh 进 Tailscale 网络的电脑。
- **模型网关**：winpc 的 Docker 里跑着 new-api（`0.0.0.0:30006`），统一给三台机器提供 OpenAI 兼容接口；三台共享同一把 key，`~/.pi/agent/models.json` 里的 baseURL 都指向 `http://100.64.0.2:30006`。
- **网络**：全部走 Tailscale，daemon 只绑定 Tailscale 内网 IP，不暴露任何公网端口；三台共用同一把 16 位随机 daemon 密码（配置里存哈希）。

## 为什么选 Paseo

- **headless 守护进程**：paseo daemon 本身没有一个像素的界面，可以交给 systemd / launchd / Windows 任务计划程序任意托管。
- **多 host 聚合**：手机 App 和 CLI 都能把多台机器的 daemon 组织在同一个"hosts"列表里，按设备切换管理各自的 agent 会话。
- **provider 抽象**：默认的 `pi` provider 直接把 pi-coding-agent 接到 paseo 上，还支持接 Claude、Codex 等外部会话。
- **与现有 herdr 工作流零耦合**：paseo 托管的 pi 通过独立 node-pty 运行，我本地 herdr 多开完全不受影响；唯一要处理的是环境变量隔离（下面会讲）。

## 第一站 winpc：Windows 上的无声运行（排雷记录）

Windows 没有 systemd，开机自启用"任务计划程序"做等价物。但真正难的不是自启，是**让它全程一个窗口都不出现**。

### 1. 隐藏启动链

最终的可执行链是这样的：

```
任务计划程序 PaseoDaemon (Hidden=true)
  └─▶ wscript.exe PaseoDaemon.vbs
       └─▶ powershell -WindowStyle Hidden -File start-daemon.ps1
            ├─ 清空 HERDR_* 环境变量（隔离本地多窗格工作流）
            ├─ 等待 Tailscale IP 就绪（最多 120s）
            ├─ netstat 幂等检测（已监听则跳过）
            └─ paseo daemon start --web-ui （CreateNoWindow=true）
```

`PaseoDaemon.vbs` 是关键：VBScript 走 GUI 子系统，天生没有控制台窗口，用 `shell.Run(..., 0, False)` 以零窗口方式拉起隐藏 PowerShell。假设这个链条后，所有 paseo 进程的 `MainWindowHandle` 都应该是 0。

### 2. 弹窗元凶：worker 会自己开一个可见控制台

第一轮改造后 daemon 自己没窗口了，但任务栏还是时不时蹦出黑框。逐进程扫描后发现问题不在启动链，而在 **paseo 内部**：

- 持有 `6767` 端口的 worker 进程（`daemon-worker`）身上挂着一个 `conhost.exe`——说明它拥有一个自己的控制台；
- 查源码 `supervisor.js`，发现 supervisor 用 `child_process.fork/spawn` 拉起 worker 时**没有设置 `windowsHide`**；
- Windows 的规则：父进程没有控制台可继承时，子进程会新建一个**可见**控制台。我们的 supervisor 恰好因为 `CreateNoWindow` 没有控制台，于是每个 worker 都开一个黑框。

修复非常小：给 `supervisor.js` 的两处 spawn/fork 选项加上 `windowsHide: true`。

```js
child = fork(workerEntry, workerArgs, {
    stdio: ["inherit", "pipe", "pipe", "ipc"],
    env: workerEnv,
    windowsHide: true,   // ← 关键
    execArgv: workerExecArgv,
});
```

### 3. 让补丁"自愈"

这个补丁打在 `node_modules` 里，`npm` 升级 `@getpaseo/cli` 就会丢。所以我把补丁做成了每次启动自动重打：`start-daemon.ps1` 开头读 `supervisor.js`，如果还没有 `windowsHide: true` 就用字符串替换写回去（幂等，已打则跳过）。以后升级也不怕复发。

最终复扫：所有 paseo 相关的 conhost 进程 `MainWindowHandle=0`，**任务栏零残留**。手动停止仍用 `paseo-stop.cmd`（故意带窗口，方便看结果）。

> 一个反直觉结论：Windows 上"隐藏 daemon 自己"不够，**还要隐藏它 spawn 的所有子进程**。Linux/macOS 根本没有这个问题——见下文。

### 4. Windows 上的其他细节

- **配置写入**：用 `@getpaseo/server` 的 `loadPersistedConfig(paseoHome)` + `savePersistedConfig()`（注意 paseoHome 是必传参数），密码用 `hashDaemonPassword()` 哈希后落盘，不存明文。
- **CLI 真入口**：`dist/index.js`（bin 头是 `#!/usr/bin/env -S node --disable-warning=DEP0040`）；`dist/cli.js` 是个静默退出的 stub，用它做服务入口会"5 秒烧 4 秒 CPU 后干净退出"。
- **模型**：`local-newapi` provider 一次拿到 45 个模型（在 App 里选模型，CLI 用 `--model`）。

## 第二站 fnnas：飞牛 NAS 走 systemd 标准配方

NAS 比 Windows 省心一个数量级，因为 Linux 服务天生没有"弹窗"概念。流程：

1. 装 Node.js 22（官方二进制解压到 `/usr/local`）；
2. `npm i -g @getpaseo/cli @earendil-works/pi-coding-agent`；
3. pi 配置照搬 winpc：`settings.json` 去掉 Windows 专属项（npmCommand、herdr 包），`models.json` 的 baseURL 从 `127.0.0.1:30006` 改成 `100.64.0.2:30006`；
4. paseo 配置：`listen = 100.64.0.1:6767`、`hostnames: true`、哈希密码；
5. 写 systemd 单元：

```ini
[Unit]
Description=Paseo daemon
After=network-online.target tailscaled.service

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/node /usr/local/lib/node_modules/@getpaseo/cli/dist/index.js daemon start --foreground --listen 100.64.0.1:6767 --web-ui
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

系统提醒两条：入口必须是 `dist/index.js` + 显式 `daemon start --foreground`；`--listen` 要绑 Tailscale IP 而不是 `127.0.0.1`。验证三连：

```bash
systemctl is-active paseo        # active
ss -tln | grep 6767              # LISTEN
paseo provider diagnostic pi     # Ready, 45 models
```

## 第三站 mbp16：macOS 走 launchd，全程零 sudo

macOS 的服务管理器是 launchd，不是 systemd——但同样 headless、同样没有弹窗概念。这次部署刻意做了**纯用户态**（不污染 `/usr/local`、不触发 sudo 密码交互）：

1. 开启系统设置 → 共享 → 远程登录；把 winpc 生成的一次性 ed25519 公钥写进 `~/.ssh/authorized_keys`；
2. Node 22 用户态安装到 `~/node`，`npm config set prefix ~/node`（ARM 架构选 `darwin-arm64` 包）；
3. 写 LaunchAgent plist `~/Library/LaunchAgents/com.paseo.daemon.plist`：

```xml
<key>ProgramArguments</key>
<array>
  <string>/Users/jerry/node/bin/node</string>
  <string>/Users/jerry/node/lib/node_modules/@getpaseo/cli/dist/index.js</string>
  <string>daemon</string><string>start</string>
  <string>--foreground</string>
  <string>--listen</string><string>100.64.0.5:6767</string>
  <string>--web-ui</string>
</array>
<key>RunAtLoad</key><true/>
<key>KeepAlive</key><true/>
<key>EnvironmentVariables</key>
<dict><key>PATH</key><string>/Users/jerry/node/bin:/usr/bin:/bin</string></dict>
```

4. 加载：`launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.paseo.daemon.plist`。

途中踩了一个很典型的坑：plist 里入口路径写成了 `…/@getpaseo/cli/node_modules/@getpaseo/cli/dist/index.js`（多嵌套了一层 `node_modules`），launchd 日志直接抛 `MODULE_NOT_FOUND`。修成 `npm root -g` 的单层路径后一次通过。查状态的命令是 `launchctl print gui/$(id -u)/com.paseo.daemon`，daemon 自己的输出看 `~/.paseo/daemon.log`。

> 顺带纠正一个我自己最初的误解：MacBook 是 macOS，不是 Linux。部署命令和 Linux 几乎一样，但服务托管必须用 launchd（或者 brew services），用它替代 systemd 那一格。

## 最后一公里：iPhone 端配对

1. iPhone 装好 Tailscale，保持在线（状态栏出现 VPN 图标）；
2. 装 Paseo App → Settings / hosts → Add host，全部用 **Direct connection**：

| Host | 地址 | 密码 |
|---|---|---|
| winpc | `100.64.0.2:6767` | 同一把 daemon 密码 |
| fnnas | `100.64.0.1:6767` | 同一把 |
| mbp16 | `100.64.0.5:6767` | 同一把 |

3. 在每个 host 下新建 agent：provider 选 **pi**，模型选 `local-newapi/deepseek-v4-flash`；
4. 发一条消息测试，即可看到对应机器被唤醒干活。

一个反直觉的体验：**App 里的会话按 host 归属**。想看哪台机器的会话，就切到哪台，不需要"导入"——App 的"导入会话"只服务于已归档（archived）workspace 的恢复，对活着的会话会直接拒绝，报错原文是：

> `This workspace is not archived, but it is unavailable from the host.`

我第一次见这行字还以为文件选错了，其实只是不该走导入这条路，从主机列表直接点开历史会话即可。

## 验证清单（三台共用）

```bash
# 1. daemon 状态
paseo status
#   Local Daemon      running
#   Connected Daemon  reachable

# 2. provider 诊断
paseo provider diagnostic pi
#   Models: 45
#   Status: Ready

# 3. 端到端
paseo run --provider pi --model local-newapi/deepseek-v4-flash "只回复两个字：就绪"
#   ✓ completed
```

另外从 winpc `curl http://100.64.0.5:6767` 能拿到 HTTP 200，说明跨机直连和 macOS 防火墙都没问题。

## 踩坑速查表

| 问题 | 解法 |
|---|---|
| Windows worker 弹黑框 | `supervisor.js` 的 spawn/fork 加 `windowsHide: true`，启动脚本每次自动重打 |
| 启动链不彻底 | 任务计划 → `wscript.exe`（GUI 子系统）→ 隐藏 PowerShell → `CreateNoWindow` |
| systemd/launchd 入口写成 `cli.js` | 用 `dist/index.js` + `daemon start --foreground` |
| launchd 路径双嵌套 | 入口 = `npm root -g` 下的单层 `@getpaseo/cli/dist/index.js` |
| paseo 托管的 pi 继承 HERDR 环境 | 启动脚本里通配删除 `HERDR_*`（共 5 个变量，漏清会在子进程泄漏） |
| 密码明文落盘 | `hashDaemonPassword()` 哈希后存 config.json |
| 手机上"导入会话"失败 | 活会话直接打开即可；导入只恢复已归档 workspace |
| 网关单点风险 | winpc 关机 → NAS/Mac 的 pi 无模型；可在 NAS 自装 new-api 并改 models.json 指向本机 |

## 现在的日常

手机锁屏时是好看的 Tailscale 状态，点开 Paseo App 就是三台机器的各自会话——在 NAS 上排队跑任务、在 MacBook 上换个环境写代码、回到 winpc 继续本地 herdr 多开。全程没有开任何公网端口，密码哈希存储，daemon 在 Windows 上连一个任务栏图标都不出现。

如果你也在用 AI 编程 Agent，并且有几台闲置机器——这个组合值得一试。最难的不是配置本身，而是理解自己平台的"服务托管"模型：Linux 的 systemd、macOS 的 launchd、Windows 的任务计划，它们对"无头进程"的态度差异很大，而 Paseo 的 headless 设计恰好是这三者的公约数。