---
title: "Windows 里到底有哪些命令行"
meta_title: "Windows 里到底有哪些命令行"
description: "解释 cmd、PowerShell、Windows Terminal 和 WSL 的区别，帮助 Windows 新手选择合适的终端环境。"
date: 2026-08-06T10:20:00+08:00
publishDate: 2026-08-06T10:20:00+08:00
draft: false
url: "/blog/windows-linux-terminal/02-windows-terminal-options/"
weight: 20
tags: ["Windows", "PowerShell", "cmd", "Windows Terminal", "WSL"]
categories: ["terminal-basics"]
author: "Jerry"
summary: "Windows 不只有一个黑框。cmd、PowerShell、Windows Terminal 和 WSL 承担的角色不同，理解它们的关系会让教程更好读。"
---

很多同学会把 Windows 里的命令行简单理解成“那个黑框”。但真正开始配置开发环境之后，很快就会遇到几个名字：`cmd`、`PowerShell`、`Windows Terminal`、`WSL`。它们都能和命令行有关，但不是同一种东西。

先把这几个概念分清楚，会让后面看教程轻松很多。因为有些教程默认你在 PowerShell 里执行命令，有些教程默认你在 Linux shell 里执行命令，如果把环境弄错，命令写得再对也可能跑不起来。

## cmd

`cmd` 是 Windows 里比较传统的命令行环境，全称通常叫 Command Prompt。很多老教程、批处理脚本和系统维护文档里都会看到它。

它的命令风格比较传统，例如：

```cmd
cls
dir
type a.txt
copy a.txt b.txt
```

`cmd` 现在仍然能用，但如果你是刚开始学习开发环境，通常不需要把它当成唯一入口。它适合了解，也适合在某些老教程或老脚本里使用。

## PowerShell

`PowerShell` 比 `cmd` 更现代，也是现在 Windows 开发场景里很常见的选择。它既能执行很多 Windows 管理命令，也兼容一些接近 Linux 风格的别名。

比如在 PowerShell 中，下面这些命令通常都能使用：

```powershell
pwd
ls
cd
cat a.txt
mkdir demo
```

这也是为什么很多新手教程会建议打开 PowerShell。它比传统 `cmd` 更适合现代开发场景，而且和 Linux 终端的使用习惯更接近一些。

不过要注意，PowerShell 不是 Linux。它支持一些相似命令，不代表所有 Linux 命令都能直接运行。

## Windows Terminal

`Windows Terminal` 很容易被误解成“一套新的命令”。其实它更像是一个终端窗口管理器。

它可以把多个命令行环境放在同一个应用里，比如：

- PowerShell
- cmd
- WSL Ubuntu
- Git Bash
- 其他自定义 shell

也就是说，Windows Terminal 本身不是一套新命令。你在里面打开 PowerShell，就使用 PowerShell 的命令；打开 WSL，就使用 Linux 环境里的命令。

对新手来说，Windows Terminal 的优点是界面更舒服，标签页更方便，也更接近现在常见的开发体验。你可以把它当成 Windows 上统一管理终端的入口。

## WSL

`WSL` 是 Windows Subsystem for Linux，也就是 Windows 上的 Linux 子系统。它可以让你在 Windows 里运行一个接近真实 Linux 的环境。

如果你以后会接触这些内容，WSL 会很有用：

- Linux 基础命令
- 服务器操作
- Docker 或部分后端开发环境
- 依赖 Linux 工具链的项目
- `apt`、`bash`、`ssh` 等工具

在 WSL 里，你会看到更典型的 Linux 路径和命令，例如：

```bash
pwd
ls
cd /home/jerry
sudo apt update
which node
```

但是不要把 WSL 和 Windows 原生命令行混在一起。比如 `apt` 通常是在 WSL 或 Linux 里用的，不是在普通 PowerShell 里用的。

## 终端程序和 shell 的区别

这里可以用一个简单说法：

- 终端程序负责提供窗口，例如 Windows Terminal。
- shell 负责解释你输入的命令，例如 PowerShell、cmd、bash。

你看到的窗口不一定决定你能用哪些命令，真正决定命令规则的是当前打开的 shell。

举个例子：你在 Windows Terminal 里打开 PowerShell，输入的是 PowerShell 命令；你在 Windows Terminal 里打开 WSL Ubuntu，输入的是 Linux shell 命令。

## 新手应该用哪个

如果你主要使用 Windows，可以这样选择：

| 场景 | 推荐选择 |
| --- | --- |
| 跟着 Windows 开发教程操作 | Windows Terminal + PowerShell |
| 看老教程或运行批处理脚本 | cmd |
| 学 Linux 命令或接触服务器 | Windows Terminal + WSL |
| 不确定用什么 | 先用 PowerShell |

很多时候，学习命令行的第一步不是记命令，而是确认自己正在哪个环境里。环境对了，教程才容易跟得上。
