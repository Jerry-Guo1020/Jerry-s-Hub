---
title: "命令行没有那么难：Windows / Linux 基础命令与实用工具"
meta_title: "命令行没有那么难：Windows / Linux 基础命令与实用工具"
description: "面向新手的终端入门专题，从 Windows 命令行、Linux 基础命令、PATH、环境变量、常见报错和实用工具开始建立命令行认知。"
date: 2026-08-06T10:00:00+08:00
publishDate: 2026-08-06T10:00:00+08:00
draft: false
layout: "series"
url: "/blog/windows-linux-terminal/"
tags: ["命令行", "Windows", "Linux", "PowerShell", "WSL"]
categories: ["terminal-basics"]
author: "Jerry"
summary: "一个面向新手的命令行入门专题：先认识 Windows 里的终端，再理解路径、命令、PATH、环境变量，最后处理常见报错并认识几个实用工具。"
---

这个专题整理自一次面向新手的终端入门分享。它不打算把 Windows、Linux、Shell、服务器、开发环境一次讲完，而是先帮你建立几个足够稳的基础认识：终端是什么、命令在哪里执行、路径怎么看、为什么命令会找不到、报错应该从哪里读起。

命令行并没有看起来那么神秘。很多时候，它只是让系统按照文字指令做事：进入一个目录、查看一个文件、创建一个文件夹、安装一个工具、确认某个命令是否存在。只要这些基础概念通了，后面再遇到 Node.js、Python、Git、Linux 服务器或者 WSL，都不会那么慌。

## 阅读路径

建议按下面顺序阅读：

1. [为什么要学命令行](/blog/windows-linux-terminal/01-command-line-is-not-hard/)
2. [Windows 里到底有哪些命令行](/blog/windows-linux-terminal/02-windows-terminal-options/)
3. [当前目录、路径、命令、PATH 和环境变量](/blog/windows-linux-terminal/03-path-command-and-environment-variables/)
4. [Windows / Linux 基础命令对照](/blog/windows-linux-terminal/04-windows-linux-command-comparison/)
5. [新手最常见的几个终端问题](/blog/windows-linux-terminal/05-common-terminal-problems/)
6. [实用终端工具与现场演示思路](/blog/windows-linux-terminal/06-terminal-tools-and-demo/)

## 这个专题适合谁

- 平时主要使用 Windows，但对命令行不熟悉的人。
- 刚开始接触编程、开发环境、服务器或 Linux 的人。
- 经常照着教程复制命令，但不知道命令具体在哪里运行的人。
- 遇到 `node`、`npm`、`PATH`、`apt`、镜像源就开始紧张的人。

## 你会建立什么认知

读完这个专题之后，你不一定会立刻变成终端高手，但至少应该能做到：

- 分清 `cmd`、`PowerShell`、`Windows Terminal` 和 `WSL` 的关系。
- 看懂当前目录和路径，不再完全依赖图形界面找文件。
- 理解一个命令为什么能被系统找到，为什么有时又会提示找不到。
- 知道 Windows 和 Linux 中常见命令的对应关系。
- 遇到报错时先读关键词，而不是直接怀疑电脑坏了。
- 认识几个真正能提升效率的终端工具。

这个专题的主线很简单：同一个需求，在不同系统里的写法可能不同；但背后的思维其实是共通的。
