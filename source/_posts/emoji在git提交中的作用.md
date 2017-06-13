---
title: emoji在git提交中的作用😉
date: 2017-06-13 17:09:06
tags:
- emoji
---
## emoji表情
经常看到很多的github项目中都用emoji但是很多时候我不知道他是什么意思，今天花了点时间翻译了一下大神的解释，并且把他的网站中文翻译了一下。
<!--more-->
## 网站地址
> 翻译的网站来自https://gitmoji.carloscuesta.me/


我的翻译网站就在自己的博客下面[点击进入查看](https://forvoid.github.io/files/emoji_develop/index.html)
这个网站在hexo博客下面必须要去`站点配置文件`进行配置说明不能解析该html文件
```yml
skip_render:
  - 'files/*.html'
  - 'files/**'
```
## 下面说一下如何在自己的网站上使用emoji
因为hexo不支持emoji和GTM方式的编码解析，所以我们要将我们的hexo的编译方式换成`hexo-renderer-markdown-it`方式如何进行`hexo-renderer-markdown-it`安装这里放一个传送门[点击进入https://github.com/hexojs/hexo-renderer-markdown-it的github页面](https://github.com/hexojs/hexo-renderer-markdown-it)。

然后在里面添加emoji模块
下载模块
```bash
npm install markdown-it-emoji --save
```

然后在`站点配置文件中`添加配置文件
```yml
# Markdown-it config
## Docs: https://github.com/celsomiranda/hexo-renderer-markdown-it/wiki
markdown:
  render:
    html: true
    xhtmlOut: false
    breaks: true
    linkify: true
    typographer: true
    quotes: '“”‘’'
  plugins:
    - markdown-it-abbr
    - markdown-it-footnote
    - markdown-it-ins
    - markdown-it-sub
    - markdown-it-sup
    - markdown-it-emoji
    # - hexo-tag-emojis
  anchors:
    level: 2
    collisionSuffix: 'v'
    permalink: true
    permalinkClass: header-anchor
    permalinkSymbol: ¶
```
上面是我的配置文件，可以到[https://github.com/celsomiranda/hexo-renderer-markdown-it/wiki](https://github.com/celsomiranda/hexo-renderer-markdown-it/wiki)查看配置
