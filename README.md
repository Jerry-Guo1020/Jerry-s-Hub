# Jerry Blog

这是一个基于 Hugo 和 Hugoplate 的个人博客。内容写在 `content/`，主题与样式由 Hugo 和 Tailwind 构建，最终输出到 `public/`。

## 目录怎么理解

```text
content/              文章和页面，长期保存的 Markdown 内容
content/posts/        博客文章，推荐用 page bundle，把图片和文章放一起
data/                 结构化数据，适合链接、书单、项目列表等
layouts/              页面模板，也就是 UI 的 HTML 结构
assets/css/           前端样式，会被 Hugo 处理后输出
static/               原样复制到网站根目录的静态文件
hugo.toml             Hugo 站点配置
scripts/hugo.sh       CI 构建时自动安装/调用 Hugo Extended
wrangler.toml         Cloudflare Workers 静态资源部署配置
```

Hugo 不是传统意义上的后端框架。它的“后端感”主要来自内容文件、数据文件、模板渲染和本地开发服务器。正式发布时，它会把这些文件编译成 `public/` 里的静态网页。

## 本地环境

项目使用 Node 20+。仓库里的 `scripts/hugo.sh` 会优先使用本机 Hugo Extended；如果 CI 里没有可用版本，会自动下载 Hugo Extended 0.164.0+。

## 本地启动

```bash
npm ci
npm run dev
```

默认会打开类似下面的地址：

```text
http://localhost:1313/
```

## 新建一篇文章

推荐用 page bundle，让文章和图片放在同一个文件夹：

```bash
hugo new content posts/my-first-post/index.md
```

然后编辑：

```text
content/posts/my-first-post/index.md
```

发布前把 front matter 里的 `draft: true` 改成 `draft: false`。

## 打包静态网站

```bash
npm ci
npm run build
```

生成结果会在：

```text
public/
```

## Cloudflare Workers 部署设置

当前项目连接在 Cloudflare Workers 的 Git 构建里。后台使用下面设置：

```text
Build command: npm run build
Deploy command: npx wrangler deploy
Node.js version: 22 或更高
```

`wrangler.toml` 会把 Hugo 生成的 `public/` 作为 Workers 静态资源上传。不要把这个项目配置成普通 Worker 入口文件部署，也不要删除 `[assets]` 配置。
