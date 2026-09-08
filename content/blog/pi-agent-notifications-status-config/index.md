---
title: "给 pi 配了提问通知和状态灯，配置也推上了 GitHub"
meta_title: "给 pi 配了提问通知和状态灯，配置也推上了 GitHub"
description: "终端 AI 编程助手 pi 提问不响铃不弹窗，人一离开屏幕就漏看。这次给它配了跨平台桌面通知和 Agent 状态指示灯，把整套配置整理进了 pi-config 仓库。"
date: 2026-09-08T11:15:00+08:00
publishDate: 2026-09-08T11:15:00+08:00
draft: false
slug: "pi-agent-notifications-status-config"
tags: ["pi", "AI 编程助手", "扩展", "桌面通知", "GitHub", "配置管理"]
categories: ["ai-tools"]
author: "Jerry"
image: "/blog/pi-agent-notifications-status-config/cover.svg"
summary: "给 pi 配上提问桌面通知、Agent 状态指示灯和权限方案，并把 extensions、skills、settings 整理进 GitHub 仓库统一管理。"
cover: "cover.svg"
---

我在终端里用一个叫 pi 的 AI 编程助手。它在一个终端窗口里干活，调用模型、读写文件、跑命令，然后停下来等我的答复。pi 的工作方式有一个麻烦：它提问不响铃、不弹窗，只是安静地在终端里换一行等待输入。人一旦切去别的窗口，就会漏看它的提问，回来才发现它已经干等了好几分钟。

这次我给 pi 补了三样东西：提问桌面通知、Agent 状态指示灯、配置版本管理。

## 做完之后的样子

打开 pi 时，窗口顶部有一行状态：一个圆圈加文字。圆圈颜色跟着 pi 的状态走。

- 绿色，空闲，pi 在等你输入
- 蓝色，工作中，pi 正在执行任务
- 橙色，提问中，pi 弹出了窗口，正在等你回答

提问的同时，系统会弹一条桌面通知。Windows 上是系统 Toast，macOS 上是右上角的通知，Linux 终端里走 OSC 协议。通知里带问题原文，比如「Pi 正在问你问题，需要你回答『要不要删掉这个文件？』」。pi 干完活也有通知，「Pi 已完成，等待输入」。人不用盯着终端，切走窗口也不会漏。

## 通知扩展

通知逻辑写在一个扩展文件里，叫 `notify.ts`。核心是监听两个事件：`ui_prompt_start` 和 `agent_end`。前者是 pi 弹出任何提问窗口的时刻，后者是 pi 干完活的时刻。

```ts
pi.on("ui_prompt_start", async (event) => {
	const e = event as { title?: string; kind?: string };
	const question = e.title ?? getLastQuestion();
	const detail = question ? `「${question}」` : `(${e.kind ?? "question"})`;
	notify("Pi", `❓ Pi 正在问你问题，需要你回答 ${detail}`);
});
```

平台差异在一套 `notify` 函数里处理：Windows 用 PowerShell 调系统 Toast，不需要 Windows Terminal，普通 PowerShell 也能弹；macOS 用 `osascript display notification`，带 Glass 提示音；WSL 和 Linux 终端写 OSC 777 / OSC 99 序列，终端会自己处理成系统通知，最后补一个 BEL 字符兜底。

## 状态灯扩展

`status-line.ts` 负责顶部的状态行。pi 的 API 里有 `ui.setHeader` 和 `ui.setStatus`，可以替换默认的页眉，也能往底部状态栏写东西。我把状态同时写到这两个位置，窗口上下都能看到那个圈。

```ts
function stateColor(state: AgentState): "success" | "accent" | "warning" {
	switch (state) {
		case "idle": return "success";
		case "working": return "accent";
		case "asking": return "warning";
	}
}
```

橙色用了主题里的 `warning` 色，和 pi 的橙色提示一个色系，看到橙色就知道有窗口在等回答。

## 踩了一个坑：弹窗标题是空的

写通知的时候发现一个问题。我自己的 `ask-user-question` 扩展提供提问工具，单选和多选走的是 `ui.custom()`。pi 的事件 `ui_prompt_start` 会带上弹窗的 `kind` 和 `title`，但 `custom` 类型的弹窗 title 永远是空。结果通知里只能显示「需要你回答 (custom)」，不带问题内容。

解决办法是在两个扩展里都监听 `tool_call`，抓住 `ask_user_question` 工具被调用的时机，把 `question` 参数存到 `globalThis` 上的一个共享槽里，弹窗事件再从这里取。弹窗监听拿不到 title 时读这个槽，问题原文就有了。这个做法和我扩展里现成的共享锁 `__piSharedUiLock` 一样，都是跨扩展共享状态。

## 权限方案的取舍

顺着这次改动，我把之前的权限配置也理了一遍。现在的规则是这样的：

- bash 命令完全放行，不再弹「危险命令」确认框。我用 pi 的时候知道自己在干什么，弹窗只挡事。
- 真实的 `.env` 文件（`.env`、`.env.local`、`.env.production` 这类）读写直接被拦，防止 key 被模型读出来写进会话。`.env.example` 不受影响，样板文件本来就是要给人看的。
- 曾经写过「改动项目代码前确认」的扩展，用了一阵子觉得确认框还是烦，已经移出有效配置，扔到备份目录里了。

`protected-paths.ts` 用正则按文件名匹配，而不是简单的字符串包含。早期版本用 `includes(".env")` 判断，会把 `.env.example` 一起误拦，后来改成按 basename 匹配，`example` 和 `sample` 后缀放行。

## 配置推上 GitHub

这些东西散落在 `~/.pi/agent/` 里，机器一坏就没了。我开了一个仓库 `pi-config`，把有效配置镜像进去：

```
pi-config/
├── README.md              # 方案说明，含目录映射和扩展功能表
├── .gitignore             # 敏感文件忽略规则
├── settings.json          # 全局设置
├── models.example.json    # 模型配置示例，API Key 已脱敏
├── extensions/            # 全部扩展
└── skills/                # 三个技能：画图、科研配图、去 AI 腔
```

敏感文件不进仓库：`auth.json`（API Key）、`models.json`（含明文 key）、`models-store.json`、`sessions/`（完整的会话历史）。`.gitignore` 把这些全部兜住。真实 `models.json` 脱敏成 `models.example.json` 放进去，换机时复制改名、填上 key 就能用。仓库里有一份 README 记录配置方案，往后每次改配置，把变更复制回仓库提交一次，机器和仓库保持同步。

## 一点收尾

这次写的代码不算多，但把「看不见的 Agent 状态」变成了「系统通知加状态灯」，体验差别很大。通知和状态圈可以随时开关，配置都在扩展文件顶部的 `CONFIG` 常量里。这套东西后面肯定还会改，改完往 `pi-config` 仓库推一次就行。这篇文章本身也按 `stop-slop` 技能的规则顺过一遍，算是用上了自己搭的那套技能。

相关链接：

- [pi](https://github.com/badlogic/pi-mono)（终端 AI 编程助手）
- [pi-config 仓库](https://github.com/Jerry-Guo1020/pi-config)（本次推上去的配置）