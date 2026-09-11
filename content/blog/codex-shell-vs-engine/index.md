---
title: "为什么 Codex 里能跑 DeepSeek：外壳和发动机是两码事"
meta_title: "为什么 Codex 里能跑 DeepSeek：外壳和发动机是两码事"
description: "解答一个高频问题：为什么 OpenAI 的 Codex 里能跑 DeepSeek、Kimi、Claude 这些模型。核心是「外壳」和「发动机」解耦——Codex/Claude Code 只负责读写文件、执行命令、跑测试，真正动脑子的模型是发动机，中间靠一层标准接口随意切换。"
date: 2026-09-11T16:25:00+08:00
publishDate: 2026-09-11T16:25:00+08:00
draft: false
slug: "codex-shell-vs-engine"
tags: ["Codex", "Claude Code", "DeepSeek", "Kimi", "AI Agent", "模型", "API"]
categories: ["ai-tools"]
author: "Jerry"
image: "/blog/codex-shell-vs-engine/cover.svg"
summary: "为什么 Codex 里能跑 DeepSeek？因为 Codex、Claude Code 都是「外壳」，负责读写文件和执行命令；真正思考的「发动机」是模型。外壳与发动机解耦，中间是一层标准接口，所以 DeepSeek、Kimi、Claude 都能接。"
cover: "cover.svg"
---

有人看我 Codex 的模型栏里挂着 DeepSeek，就问了一句：这不是 OpenAI 的工具吗，怎么里面跑的是 DeepSeek 的模型？

这个问题问到点子上了。答案一句话就能说清：**Codex 这类工具是「外壳」，里面跑哪个模型是「发动机」，两码事。** 外壳可以原封不动，发动机随便换。

这篇算上一篇 [《Codex 与 Claude Code：CLI 与 GUI，终端和桌面怎么选》](/blog/codex-claude-code-ai-agents/) 的续——上一篇里我提过「自定义供应商」「baseURL」，但都是一笔带过。这篇就把那层窗户纸捅破，讲清楚为什么能把 DeepSeek 塞进 Codex。

## 外壳负责手脚，发动机负责脑子

以 Codex 为例，它干的活可以拆成两半：

- **外壳（shell）**：读写文件、执行命令、跑测试、管理终端、维护上下文、决定下一步调哪个工具。这是它的「手脚」。
- **发动机（engine）**：真正「动脑子」的那部分——理解你的需求、读懂代码、决定怎么改。这是模型（LLM）在干。

外壳和发动机之间是**解耦**的。Codex 这个外壳并不知道、也不在乎给它供能的是哪家模型；它只负责把手脚活干好，然后问发动机一句「下一步怎么办」。

反过来，Claude Code 也一样：它那个能在终端里读写文件、跑命令的外壳是一回事，背后接的是 Claude、还是换成别的模型，是另一回事。官方默认接自家的，但没人规定必须接自家的。

## 为什么发动机能随便换：一层标准接口

为什么 DeepSeek、Kimi、Claude 这些不同家的模型，都能塞进同一个外壳？因为大家约定了**一套差不多的接口**。

现在主流的模型服务基本都是「OpenAI 兼容接口」——不管你是 OpenAI、DeepSeek、Kimi 还是别的，只要给我一个 `base_url` 和一把 API key，我发出去的请求格式就是同一套。外壳只要把请求发到这个 `base_url`，就能把对应模型当发动机用。

所以我常说的「配模型」，本质就两件事：

1. 告诉外壳，发动机的接口在哪（`base_url`）；
2. 告诉外壳，用哪个发动机（模型名 + key）。

## 上一篇其实已经交代了一半

上一篇讲终端明文配置时，我贴过 `~/.codex/config.toml`，里面就是这套「接线」。拿它当例子（做了简化）：

```toml
model_provider = "custom"
model = "deepseek-chat"

[model_providers.custom]
name = "DeepSeek"
base_url = "https://.../v1"   # 发动机接口
```

`model_provider = "custom"` 的意思是：我这个发动机不是官方默认那台，是自定义的。`base_url` 指向哪，发动机就从哪来——指向 DeepSeek 就跑 DeepSeek，换成 Kimi 就跑 Kimi。

所以你看到的「Codex 里跑 DeepSeek」，翻译过来就是：**外壳还是 Codex 的外壳，发动机换成了 DeepSeek。**

## 一张图说清楚

![外壳与发动机：Codex / Claude Code 通过 base_url 接口接入不同模型](shell-engine.svg)

左边是外壳，右边是发动机，中间那根「线」就是 `base_url + key` 这层标准接口。换发动机 = 换那根线指向的地址和模型名，外壳这边几乎不用动。

## 承上启下

搞懂「外壳 vs 发动机」之后，上一篇里的那些东西就全通了：

- **CC Switch / CodeX++** 干的活，就是「帮外壳换发动机」——替你管理不同的 `base_url` 和模型配置。
- 终端里改 `auth.json` / `config.toml`，就是直接手动接线，连工具都不用。
- 上一篇那个「一调推理强度，DeepSeek 变回 GPT」的坑，本质也是：发动机没换利索，外壳一按默认档位，就跳回了官方那台 GPT。

带着这个框架，再看「怎么换发动机」「怎么自己搭网关」这些事，就都顺理成章了。下一篇再展开。