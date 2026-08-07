---
title: "当前目录、路径、命令、PATH 和环境变量"
meta_title: "当前目录、路径、命令、PATH 和环境变量"
description: "用新手能理解的方式解释终端里的当前目录、路径、命令格式、PATH 和环境变量。"
date: 2026-08-06T10:30:00+08:00
publishDate: 2026-08-06T10:30:00+08:00
draft: false
url: "/blog/windows-linux-terminal/03-path-command-and-environment-variables/"
weight: 30
tags: ["PATH", "环境变量", "路径", "终端"]
categories: ["terminal-basics"]
author: "Jerry"
summary: "理解当前目录、路径、命令、PATH 和环境变量，是看懂终端报错和开发环境配置的基础。"
---

学命令行时，有几个概念会反复出现：当前目录、路径、命令、`PATH`、环境变量。它们听起来有点抽象，但只要用文件夹和“系统去哪里找程序”来理解，就没有那么难。

这一篇先把这些基础概念讲清楚。后面遇到 `node` 找不到、`npm` 不能用、`apt update` 报错时，你会更容易判断问题出在哪里。

## 当前目录

当前目录可以理解成“你现在站在哪个文件夹里”。很多命令都是以当前位置为基础执行的。

在 PowerShell 或 Linux 终端里，可以用下面命令查看当前目录：

```powershell
pwd
```

输出可能类似：

```text
C:\Users\Jerry\Desktop
```

或者在 Linux / WSL 里：

```text
/home/jerry/Desktop
```

如果你在桌面目录里创建文件，文件就会出现在桌面目录；如果你在项目目录里运行安装命令，依赖通常就会安装到项目目录附近。很多新手问题，本质上都是“命令执行的位置不对”。

## 路径

路径就是文件或文件夹的位置。

Windows 路径通常长这样：

```text
C:\Users\Jerry\Desktop\demo
```

Linux 路径通常长这样：

```text
/home/jerry/Desktop/demo
```

两者最明显的区别是：Windows 常见盘符和反斜杠，Linux 常见根目录 `/` 和正斜杠。

路径可以分为绝对路径和相对路径。

| 类型 | 含义 | 示例 |
| --- | --- | --- |
| 绝对路径 | 从系统固定起点写完整位置 | `C:\Users\Jerry\Desktop`、`/home/jerry/Desktop` |
| 相对路径 | 从当前目录出发描述位置 | `demo`、`./demo`、`../` |

`..` 表示上一级目录，`.` 表示当前目录。这个概念在 Windows、Linux、macOS 里都很常见。

## 命令

命令就是你让系统执行的操作。最简单的命令可能只有一个单词：

```bash
pwd
```

稍微复杂一点的命令会带参数：

```bash
ls -la
```

这里可以先粗略理解为：

- `ls` 是命令。
- `-la` 是选项，用来改变命令的行为。

有些命令后面还会跟操作对象：

```bash
cat hello.txt
```

这里的意思是查看 `hello.txt` 的内容。

不同系统的命令写法可能不同，但结构大致相似：

```text
命令 选项 操作对象
```

刚入门时不需要记住所有选项。更重要的是知道：命令不是一句魔法咒语，而是由“要做什么”和“对谁做”组成的。

## PATH

`PATH` 是终端入门里最值得讲清楚的概念之一。

当你输入一个命令，比如：

```bash
node -v
```

系统并不是凭空知道 `node` 在哪里。它会去一组提前配置好的目录里找有没有叫 `node` 的可执行程序。这组目录列表就是 `PATH`。

在 PowerShell 里查看 `PATH`：

```powershell
echo $env:Path
```

在 Linux / WSL 里查看 `PATH`：

```bash
echo $PATH
```

如果你安装了 Node.js，但终端提示找不到 `node`，常见原因就是：

- Node.js 没有安装成功。
- 安装了，但安装目录没有加入 `PATH`。
- 刚安装完，旧终端还没刷新环境变量。
- 安装到了其他位置，当前 shell 找不到。

这也是为什么很多安装教程最后都会让你重新打开终端，再执行：

```bash
node -v
npm -v
```

重新打开终端，是为了让新的环境变量配置生效。

## 环境变量

环境变量可以理解成系统或程序运行时会参考的一组配置。`PATH` 就是最常见的环境变量之一。

除了 `PATH`，你以后还可能见到这些环境变量：

```bash
HOME
USER
JAVA_HOME
NODE_ENV
HTTP_PROXY
```

它们可以保存用户目录、运行模式、代理地址、工具安装位置等信息。

新手阶段不需要一口气掌握所有环境变量。你只需要先记住：环境变量是系统运行时的配置；`PATH` 决定系统会去哪些目录里找命令。

## 一个判断问题的小方法

如果某个命令不能用，可以按这个顺序排查：

1. 这个工具真的安装了吗？
2. 当前终端是不是正确的环境？比如 PowerShell 还是 WSL。
3. 终端有没有重新打开？
4. 系统能不能找到这个命令？
5. 命令所在目录有没有进 `PATH`？

对应的检查命令是：

Windows PowerShell：

```powershell
where.exe node
node -v
echo $env:Path
```

Linux / WSL：

```bash
which node
node -v
echo $PATH
```

只要你开始用这种方式思考，很多环境配置问题就会从“看不懂”变成“可以一步步排查”。
