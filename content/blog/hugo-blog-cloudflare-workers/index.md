---
title: "这个博客是怎么搭的：Hugo + hugoplate + Cloudflare Workers 静态资源"
meta_title: "这个博客是怎么搭的：Hugo + hugoplate + Cloudflare Workers 静态资源"
description: "本文记录这个博客的完整搭建与部署方案：Hugo 生成静态站、hugoplate 主题定制、自动装 Hugo 的 CI 脚本，以及最终用 Cloudflare Workers 静态资源托管、push 即发布的流程。"
date: 2026-09-08T17:08:00+08:00
publishDate: 2026-09-08T17:08:00+08:00
draft: false
slug: "hugo-blog-cloudflare-workers"
tags: ["Hugo", "Cloudflare", "博客", "部署", "Tailwind"]
categories: ["dev-environment"]
author: "Jerry"
image: "/blog/hugo-blog-cloudflare-workers/cover.svg"
summary: "Markdown 写内容，Hugo 生成静态站，Cloudflare Workers 静态资源托管：npm run build 出 public/，push 到 GitHub 自动构建发布。"
cover: "cover.svg"
---

这个博客本身也是我折腾出来的东西。内容用 Markdown 长期保存，Hugo 渲染成静态网页，Cloudflare Workers 静态资源托管。整条链路没有数据库、没有后端，只有一堆文件和一条 push 命令。

这篇文章把这套方案完整拆开，从目录结构到构建管线，再到踩过的坑。

## 为什么是 Hugo

选 Hugo 的理由很直接：内容就是 Markdown 文件，放在 git 仓库里，不用维护数据库，换机器克隆下来就能写。博客要长期保存内容，文件格式的寿命比任何在线服务都长。渲染方面 Hugo 速度快，几百篇文章也是秒出，加上 hugoplate 这个 Tailwind 主题，样式不用自己从零写。

## 目录结构

```text
content/              文章，page bundle：文章和图片放同一个文件夹
data/                 结构化数据：profile.yaml、social.json、theme.json
layouts-custom/       自定义模板：首页、页眉页脚、head、404
assets-custom/        自定义样式：main.css 主题变量
static/               原样复制到站点根目录的文件（favicon.svg）
scripts/              theme.js、hugo.sh
hugo.toml             Hugo 配置
wrangler.toml         Cloudflare Workers 配置
```

`data/theme.json` 管主题颜色和字体，`scripts/theme.js` 把它编译成 `themes/hugoplate/assets/css/generated-theme.css`。改主题只需改这个 JSON，不用碰样式表。所以构建命令第一步总是先跑 `theme.js`：

```json
{
  "build": "node scripts/theme.js && scripts/hugo.sh --minify --cleanDestinationDir"
}
```

模板定制都放在 `layouts-custom/`，覆盖主题默认布局：首页有一段 hero 加一个站点结构面板，`head.html` 里补了 canonical、RSS、favicon 和带指纹的 CSS 引用。配色在 `assets-custom/css/main.css` 里用 CSS 变量统一管理，主色是 `#0f766e`。

## CI 里没有 Hugo 的问题

Cloudflare 的构建环境是 Linux 容器，没有装 Hugo。全站只有 `scripts/hugo.sh` 一个 80 行的脚本解决这件事：先检测本机有没有可用的 Hugo Extended（0.164.0 以上），有就直接用；没有且系统是 Linux，就从 GitHub Releases 自动下载 `hugo_extended_0.164.0_linux-amd64.tar.gz` 解压到 `.hugo-bin/`，缓存住，下次构建直接用。

```bash
if hugo_is_usable "hugo"; then
  exec hugo "$@"
fi

if [ -x "$HUGO_BIN" ] && hugo_is_usable "$HUGO_BIN"; then
  exec "$HUGO_BIN" "$@"
fi

# Linux CI 环境：自动下载 Extended 版
HUGO_ARCHIVE="hugo_extended_${REQUIRED_HUGO_VERSION}_linux-amd64.tar.gz"
```

Windows 本机没装 Hugo 的话，脚本会提示要么本地装，要么交给 Linux CI 构建。我在构建时还开启了 `buildStats`，Hugo 会把模板和内容用到的 class 名写进 `hugo_stats.json`，Tailwind 只生成用到的样式，产物不会膨胀。

## 部署：Cloudflare Workers 静态资源

部署从 Cloudflare Pages 起步，后来切到了 Workers 静态资源。区别在 `wrangler.toml`：Pages 用 `pages_build_output_dir = "public"`，Workers 用 `[assets]` 声明资源目录：

```toml
name = "jerry-s-hub"
compatibility_date = "2026-08-02"

[assets]
directory = "./public"
```

Cloudflare 后台的 Git 构建设置三项：

```text
Build command:   npm run build
Deploy command:  npx wrangler deploy
Node.js version: 22 或更高
```

之后每次 `git push`，Cloudflare 自动拉代码、跑 `npm run build`、把 `public/` 作为静态资源发布。整个流程：Markdown 写内容 → push → 构建 → 上线，不需要手动执行任何部署命令。

## 踩过的坑

- **缓存目录写死本机路径**。早期的 build 脚本里有 `HUGO_CACHEDIR=/Users/jerry/project/jerry-blog/resources/_cache`，这是 macOS 上的绝对路径，Windows 和 CI 里直接报错。后来删掉，让 Hugo 用默认缓存位置。
- **Pages 和 Workers 配置来回切换**。先配 Pages，之后发现 Workers 静态资源更合适，`wrangler.toml` 的两种写法不兼容，迁移时踩过一次配置错误，构建失败后才改对。
- **Node 版本漂移**。仓库里放了 `.nvmrc` 和 `.node-version` 锁定 Node 20+，配合后台的 Node 22 设置，避免本地和 CI 行为不一致。
- **文章更新不生效**。内容改了也 push 了，站点还是旧版。排查路径是先去 Cloudflare 后台的 Deployments 列表，看推送有没有触发构建、构建有没有失败；构建失败会有日志，比在浏览器里猜缓存快得多。

## 现在这套东西长什么样

构建一次全站 100 多页，耗时在 1 秒内。写新文章就是新建一个文件夹加一个 `index.md`：

```text
content/blog/my-post/
├── index.md       # front matter + 正文
└── cover.svg      # 文章封面
```

front matter 里填标题、日期、slug、标签，`draft: false` 就发布。文章配图和封面放在同目录，Hugo 的 page bundle 会一起处理。

这套方案没有魔法，都是普通文件加一条构建链路。好处是东西都在自己手里：内容在 git 里，构建脚本 80 行能看懂，部署配置 5 行能说清。哪天换托管商，也只是改 `wrangler.toml` 加新平台的构建设置问题。