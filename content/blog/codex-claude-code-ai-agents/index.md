---
title: "Codex 与 Claude Code：CLI、TUI、GUI 三种形态的区别和取舍"
meta_title: "Codex 与 Claude Code：CLI、TUI、GUI 三种形态的区别和取舍"
description: "详细介绍 OpenAI Codex 和 Anthropic Claude Code 这两个能运行代码的 AI 智能体：它们在不同端叫什么名字、各有什么优势，CLI/TUI/GUI 三种界面形态的本质区别，外加国内使用环境的真实路径和 CC Switch 的一个坑。"
date: 2026-09-11T10:48:00+08:00
publishDate: 2026-09-11T10:48:00+08:00
draft: false
slug: "codex-claude-code-ai-agents"
tags: ["Codex", "Claude Code", "AI Agent", "CLI", "TUI", "GUI", "CC Switch"]
categories: ["ai-tools"]
author: "Jerry"
image: "/blog/codex-claude-code-ai-agents/cover.svg"
summary: "Codex 和 Claude Code 是同一类能运行代码的 AI 智能体，却在终端和桌面上换了不同的名字和形态。这篇文章讲清 CLI/TUI/GUI 的区别与各自优势，以及国内用上它们的真实路径，外加 CC Switch 的一个坑。"
cover: "cover.svg"
---

Codex 和 Claude Code，说白了是一类东西：**AI 编程智能体（AI coding agent）**。它们不只是聊天陪你写代码，而是真的能在一个环境里**运行代码**——读文件、跑命令、改代码、执行测试，把结果反馈回来，再接着往下干。区别在于它们背后各有一家大厂：Codex 是 OpenAI 的，Claude Code 是 Anthropic 的，绑定的模型分别是 GPT 和 Claude。

这篇文章想讲清楚几件事：它们在不同平台上到底叫什么、各有什么优势；CLI、TUI、GUI 这三种界面形态到底差在哪；以及在国内这个特殊环境下怎么把它们用起来——顺便记一个 CC Switch 的坑。

## 同一个东西，在不同端有不同的名字

这俩工具是「终端起家」的，后来才往桌面端延伸。所以同一个产品，换个端名字就变了：

| 产品 | 终端端 | 桌面端 |
|---|---|---|
| OpenAI 的 Codex | Code X（Codex） | ChatGPT App |
| Anthropic 的 Claude Code | Claude Code | Claude（桌面 App） |

终端端是它们的原生形态：Codex 在终端里就叫 Code X，Claude 在终端里叫 Claude Code（这个名字后来也成了产品名）。到了桌面端，OpenAI 把 Codex 的能力并进了 ChatGPT App；Anthropic 这边则是 Claude 桌面应用。

也就是说：你在终端里敲的是 Claude Code / Code X，在桌面上用鼠标点开的是 Claude / ChatGPT。背后是同一批模型、同一套「能运行代码」的能力，只是外壳不一样。

## 三个词的差别：CLI、TUI、GUI

这三个词经常被混着说，其实指的是三种完全不同的界面形态：

- **CLI（Command Line Interface，命令行界面）**：一切都是文本。你敲一行命令，它回一行结果，没有鼠标、没有面板，最纯粹也最轻。
- **TUI（Terminal User Interface，终端用户界面）**：跑在终端里，但是「有画面」。有面板、有状态栏、有颜色分区，支持鼠标点选和拖拽，看起来像个简化版桌面软件。
- **GUI（Graphical User Interface，图形用户界面）**：就是桌面 App。窗口、按钮、菜单、拖拽文件，全靠鼠标。

可以这么理解：CLI 是一张白纸只让你写字，TUI 是终端里画了个仪表盘，GUI 是完整的应用程序。

它们各自的优势很清晰：

- **CLI 的优势**：轻。单个进程、几乎没有界面开销，内存和 CPU 占用最低；还能脚本化、管道串联，`command | grep ...` 这种组合拳最顺手，也好做自动化。
- **TUI 的优势**：好看 + 好用。它把终端里的信息做了可视化排版，面板清晰、状态一目了然，还支持鼠标拖拽，不像纯 CLI 只能靠脑补。
- **GUI 的优势**：最省心。所见即所得，拖文件、点按钮、看通知，上手成本最低，完全不用记命令。

三者不是谁取代谁，而是「轻量 ↔ 直观」这条轴上的三个点：CLI 偏轻量，GUI 偏直观，TUI 卡中间——既要终端的轻，又想要一点可视化。

## 我的选择：从桌面端回到了终端

我最早用的是桌面端，后来转回了终端。这个过程中，我对 TUI 和 CLI 的体会很具体。

### 为什么我喜欢 TUI

TUI 最大的好处是**好看**。界面排版清晰，状态、输出、历史都能一眼看清，比一屏一屏滚文本的纯 CLI 舒服太多。

另一个特别实在的点是**支持拖拽**。要引用某个文件，直接把文件图标拖进窗口就行，它自己就把路径塞进去了。这个细节在纯 CLI 里是没有的——纯命令行根本不认「拖」这个动作。

### 为什么我现在用 CLI

我最后落在 CLI 上，动机很朴素：**轻量，省内存**。

桌面端用起来是方便，但内存占用是真的高。我的机器是一台 MacBook Air，而这台机器**没有风扇**。桌面端一开，内存和 CPU 占用直接拉满，机身很快就发烫——没有风扇就只能靠外壳散热，摸上去烫手是常态。CPU 一高，又没有风扇，结果就是又烫又卡。

切到终端的 CLI 之后，这个问题基本消失：界面开销没了，内存和 CPU 占用低一大截，机器不再动不动发烫。代价是 CLI 的可视化确实没那么亮，而且**引用文件要自己复制路径**——把路径贴进命令里它才认得。这算是轻量换来的一个小麻烦，我认了。

> 一句话总结我的取舍：要好看要顺手选 TUI，要省内存要机器不烫选 CLI。我没有选 GUI，因为桌面端对无风扇的 MacBook Air 太不友好。

## 国内环境：不能直接登录，得绕一圈

这俩工具在国内的使用环境有一个共同前提：**Codex 和 Claude Code 都不能直接登录**，模型接口和登录鉴权都连不上。

常见的解法是用 **CC Switch** 这类工具做自定义配置——把请求指到国内的模型网关或者兼容接口上，绕开官方的直连。它本质上是个「配置切换器」，帮你管理这些工具该连哪个 baseURL、用哪把 key、默认选哪个模型。

### 终端里其实不需要 CC Switch

这是我自己折腾出来的一个体会：**在终端里用这两款工具，根本不需要动用 CC Switch。**

因为终端版的配置就是一堆明文文件——`auth.json`、`config.json` 这类。我可以直接跟 AI 说：去改自己的 `auth.json` 或 `config.json`，把 baseURL 和模型配好。AI 能自己读、自己改、再写回去，完事重启一下就能用。整个过程不需要一个额外的「配置切换器」来兜底。

CC Switch 的价值在桌面端更明显：桌面 App 没有这么透明的配置文件让你随手改，或者说改起来要折腾。**如果你不愿意折腾，用 CC Switch 确实是不错的选择**——点几下把配置切过去，省心。愿不愿意折腾，是桌面端选不选 CC Switch 的分界线。

## CC Switch 的一个坑：Codex 调 fast 变成 GPT

即便用了 CC Switch，坑还是有的，而且这个坑我踩得挺深。

场景是这样的：我在用 Codex，模型配的是国产的 **DeepSeek**。在 CC Switch 里把自定义模型（custom）设为 DeepSeek，于是 Codex 里默认调用的就是 custom，也就是 DeepSeek。到这里一切正常。

问题出在我想调**运行速率**的时候。Codex 客户端里有一个速度选项，我想把它调成 `fast`（快速档）。结果一调整，模型就自动变成了 **GPT**。

更离谱的是，这不只是当前会话里变一下——它**直接改掉了 CC Switch 里的默认模型**。本来我在 CC Switch 里设的是 DeepSeek，结果这一下连 CC Switch 里的默认模型都一起变成了 GPT。就很扯淡。

这意味着：一旦你在 Codex 里动了速度档位，之前费劲配好的 DeepSeek 默认值就被悄悄抹掉，下次默认又变回 GPT。所以现在每次调完速度，我都得回 CC Switch 里确认一眼默认模型有没有被改，发现变了再改回来。这件事值得单独记一笔，免得下次又莫名其妙踩进去。

## 结尾

Codex 和 Claude Code 是同一类「能运行代码」的 AI 智能体，不同端换不同的壳：终端是 Code X / Claude Code，桌面是 ChatGPT / Claude。

选 TUI 还是 CLI，本质是「好看顺手」和「轻量省内存」之间的取舍。我的 MacBook Air 没有风扇，所以最后站在了 CLI 这边。

国内的登录问题绕不开：桌面端用 CC Switch 是省心解，终端里完全可以自己改 `auth.json` / `config.json` 解决。只是别忘了 CC Switch 那个「Codex 调 fast 变 GPT、连默认模型一起改」的坑——调完速度，记得回头确认一眼。