# Jerry Blog

这是一个最小可运行的 Hugo 博客骨架。它没有依赖外部主题，方便你先看清楚 Hugo 项目里每一层分别做什么。

## 目录怎么理解

```text
content/              文章和页面，长期保存的 Markdown 内容
content/posts/        博客文章，推荐用 page bundle，把图片和文章放一起
data/                 结构化数据，适合链接、书单、项目列表等
layouts/              页面模板，也就是 UI 的 HTML 结构
assets/css/           前端样式，会被 Hugo 处理后输出
static/               原样复制到网站根目录的静态文件
hugo.toml             Hugo 站点配置
```

Hugo 不是传统意义上的后端框架。它的“后端感”主要来自内容文件、数据文件、模板渲染和本地开发服务器。正式发布时，它会把这些文件编译成 `public/` 里的静态网页。

## MacBook 上先装 Hugo

```bash
brew install hugo
hugo version
```

## 本地启动

```bash
hugo server -D
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
hugo --minify
```

生成结果会在：

```text
public/
```

这个目录可以部署到 GitHub Pages、Cloudflare Pages、Netlify、Vercel 等静态托管服务。
