---
title: "Windows / Linux 基础命令对照"
meta_title: "Windows / Linux 基础命令对照"
description: "整理 Windows cmd、PowerShell 和 Linux 中常见基础命令的对照关系，并给出新手练习流程。"
date: 2026-08-06T10:40:00+08:00
publishDate: 2026-08-06T10:40:00+08:00
draft: false
url: "/blog/windows-linux-terminal/04-windows-linux-command-comparison/"
weight: 40
tags: ["Windows", "Linux", "PowerShell", "基础命令"]
categories: ["terminal-basics"]
author: "Jerry"
summary: "同一个需求，在 Windows cmd、PowerShell 和 Linux 里的写法可能不同。先掌握常用动作，再记具体命令。"
---

学习命令行时，不要一开始就追求记住很多命令。更好的方式是先从需求出发：清屏、查看当前位置、列出文件、进入目录、创建目录、查看文件、复制文件、删除文件。

同一个需求，在 Windows `cmd`、PowerShell 和 Linux 里可能有不同写法。下面这张表适合新手先建立整体感觉。

## 常用命令对照表

| 需求 | Windows cmd | PowerShell | Linux / WSL |
| --- | --- | --- | --- |
| 清屏 | `cls` | `cls` / `clear` | `clear` |
| 查看当前目录 | `cd` | `pwd` | `pwd` |
| 列出文件 | `dir` | `ls` | `ls` |
| 进入目录 | `cd demo` | `cd demo` | `cd demo` |
| 返回上一级目录 | `cd ..` | `cd ..` | `cd ..` |
| 创建目录 | `mkdir demo` | `mkdir demo` | `mkdir demo` |
| 创建空文件 | `type nul > a.txt` | `New-Item a.txt` | `touch a.txt` |
| 查看文件内容 | `type a.txt` | `cat a.txt` | `cat a.txt` |
| 复制文件 | `copy a.txt b.txt` | `cp a.txt b.txt` | `cp a.txt b.txt` |
| 移动或重命名 | `move a.txt b.txt` | `mv a.txt b.txt` | `mv a.txt b.txt` |
| 删除文件 | `del a.txt` | `rm a.txt` | `rm a.txt` |
| 查看命令位置 | `where node` | `where.exe node` | `which node` |

这张表不需要一次背完。你只要先记住几个最高频的动作：`pwd`、`ls`、`cd`、`mkdir`、`cat`，就已经能完成很多基础操作。

## PowerShell 和 Linux 为什么有些命令一样

PowerShell 里能用 `ls`、`cat`、`pwd`，很容易让人以为它就是 Linux。其实不是。

PowerShell 为了方便使用，提供了一些别名，让常见操作看起来和 Linux 更接近。比如 `ls` 在 PowerShell 里通常是 `Get-ChildItem` 的别名，`cat` 是 `Get-Content` 的别名。

所以你可以这样理解：

- 简单文件操作上，PowerShell 和 Linux 有些命令很像。
- 一旦涉及权限、软件包管理、脚本语法、环境变量写法，就要注意区别。
- 教程里出现 `sudo`、`apt`、`chmod` 时，通常是在 Linux 或 WSL 场景。

## 一组安全练习

建议新手在一个临时目录里练习，不要直接在重要文件夹里测试删除命令。

PowerShell 可以这样练：

```powershell
pwd
mkdir terminal-demo
cd terminal-demo
New-Item hello.txt
cat hello.txt
ls
cd ..
```

Linux / WSL 可以这样练：

```bash
pwd
mkdir terminal-demo
cd terminal-demo
touch hello.txt
cat hello.txt
ls
cd ..
```

如果要测试删除文件，请确认自己在练习目录里：

PowerShell：

```powershell
rm hello.txt
```

Linux / WSL：

```bash
rm hello.txt
```

刚开始不要随便复制带有 `rm -rf` 的命令，尤其不要在自己不理解路径含义的时候执行。

## 学命令时抓住动作

命令行学习最稳的方式，是把命令背后的动作记住。

例如：

| 动作 | 你要问自己的问题 |
| --- | --- |
| 查看位置 | 我现在在哪个目录？ |
| 列出文件 | 这个目录里有什么？ |
| 进入目录 | 我要去哪个文件夹？ |
| 创建文件夹 | 我要放什么东西？ |
| 查看文件 | 我要读哪个文件？ |
| 检查命令 | 系统能不能找到这个程序？ |

这样你看到不同系统的命令时，就不会觉得完全割裂。`dir` 和 `ls` 写法不同，但它们都在回答同一个问题：这个目录里有什么？

## 一个容易混淆的点

在 Windows 里，很多教程会混用 `cmd` 和 PowerShell 示例。比如：

```cmd
where node
```

在 PowerShell 里也可以运行，但更稳妥的写法是：

```powershell
where.exe node
```

因为 `where` 在 PowerShell 里可能和别名或命令解析有关，写成 `where.exe` 可以明确调用 Windows 自带的 `where.exe` 程序。

这类细节不用一开始全记住。你只需要知道：当教程命令不工作时，先确认教程默认的是哪个 shell。
