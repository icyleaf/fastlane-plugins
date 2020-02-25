# fastlane-plugins

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/icyleaf/fastlane-plugins/blob/master/LICENSE)

本仓库是本人在多年所整理使用的超实用 [fastlane](http://github.com/fastlane/fastlane) 的自定义 actions，制定了一些用于公司内部移动开发项目使用到的 `lanes`，同时也有部分 action 在确定可以贡献社区的会被抽成 plugin 让更多的人检索和使用。

## 引入教程

确保已经安装了 `fastlane` 并进行初始化：

```bash
$ gem install fastlane
$ fastlane init
```

根据工具的提示输入和配置你项目的具体参数和账户情况，直至完成之后会在当前路径下生成 `fastlane` 的目录结构，打开其中的 `Fastfile` 在头部加入并保存：

```ruby
import_from_git(url: 'https://github.com/icyleaf/fastlane-plugins.git')
```

接着我们就可以直接使用了！

## Plugins

如下是已经从本仓库移除并重新定义的 plugins

插件 | 说明
---|---
[ci_changelog](https://github.com/icyleaf/fastlane-plugin-ci_changelog) | 支持多种 CI 系统自动生成变更历史
[update_jenkins_build](https://github.com/icyleaf/fastlane-plugin-update_jenkins_build) | 自动更新 Jenkins Build 描述
[humanable_build_number](https://github.com/icyleaf/fastlane-plugin-humanable_build_number) | 生成开发可识别的构建版本号
[app_info](https://github.com/icyleaf/fastlane-plugin-app_info) | 解析 apk/ipa 包的 metadata 并打印
[android_channels](https://github.com/icyleaf/fastlane-plugin-android_channels) | 通用性 Android 多渠道打包
[ram_disk](https://github.com/icyleaf/fastlane-plugin-ram_disk) | 创建内存虚拟磁盘，主要用于提升 App 构建速度
[debug_file](https://github.com/icyleaf/fastlane-plugin-debug_file) | 自动化搜索 iOS/macOS dSYM 或 Android Proguard（混淆）并打包 Zip 文件

## Actions

### git_last_commit

默认是对 CI 且安装了 git 客户端的机器使用，主要用于获取当前拉取的 commit 的基本信息。

### git_remotes

和上面类似，只是获取当前 git 仓库的 remotes 信息

### wechat_works

使用企业微信的机器人 WebHook 发消息到群

#### 参数

名称 | 环境变量 | 说明 | 默认值 |
---|---|---|---
webhook_url | WECHATWORK_WEBHOOK_URL | 企业微信机器人 webhook
type | WECHATWORK_TYPE | 消息类型，可选值：`:text` 和 `:markdown`
message | WECHATWORK_MESSAGEE | 消息内容
to | WECHATWORK_TO | @ 某人的 id 或手机号、不支持昵称
fail_on_error | WECHATWORK_FAIL_ON_ERROR | 运行遇到错误是否抱错退出

#### 使用方法

```ruby
lane :notice do
  # 发送纯文本消息
  wechat_work(
    webhook_url: '...',
    type: :text,
    message: "hello\nworld"
  )

  # 发送 markdown 消息
  wechat_work(
    webhook_url: '...',
    type: :markdown,
    message: "# Head 1\n- List 1\n- List 2"
  )
end
```

### xcode_bootstrap

每当新启动一个项目，在支持 fastlane 都需要花费时间和规范来配置参数，有了它可以轻松帮你一键配置如下的设置：

- 支持 Cocoapods
- 添加 **AdHoc** Build Confiuration 用于 fastlane 打包（自动处理 `Podfile` 文件)
- 根据 Build Confiuration 区别安装应用的名称
  - Debug: {应用名}开发版（默认配置，可自定义）
  - AdHoc: {应用名}内测版（默认配置，可自定义）
  - Release: {应用名}
- 根据 Build Confiuration 区别安装应用的 identifier
  - Debug: {应用identifier}.debug (默认配置，可自定义）
  - AdHoc: {应用identifier}
  - Release: {应用identifier}

#### 参数

名称 | 环境变量 | 说明 | 默认值 |
---|---|---|---
project_path | `XCODE_PROJECT_PATH` | 项目路径 | 默认根目录
cocoapods | `XCODE_COCOAPODS_SUPPORT` | 是否处理 Podfile | 默认 `true`
build_configuration_name | `XCODE_BUILD_CONFIGURATION_NAME` | 新加编译配置名 | 默认 `AdHoc`
build_configuration_base | `XCODE_BUILD_CONFIGURATION_BASE` | 新加编译配置的继承  | 默认 `:release`
app_suffix | `XCODE_APP_SUFFIX` | 自定义应用名和唯一标识 | 默认参考上面说明

#### 使用方法

在 `Fastfile` 添加你定义好的 lane:

```ruby
# 默认配置（参考上面说明配置）
lane :bootstrap do
  xcode_bootstrap
end

# 自定义 Build Confiugration
lane :bootstrap do
  xcode_bootstrap({
    build_configuration_name: 'Beta',
    build_configuration_base: :release,
    app_suffix: {
      'Debug': {
        name: '开发版',
        identifier: '.debug'
      },
      'Beta': {
        name: '测试版',
        identifier: '.beta'
      },
      'Release': {
        name: '',
        identifier: ''
      },
    }
  })
end
```

打开你的终端执行:

```bash
$ fastlane ios bootstrap
```

## 发布协议

[MIT License](http://opensource.org/licenses/MIT).
