# fastlane-qyer (停止维护，看如下迁移说明)

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/icyleaf/fastlane-qyer/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/icyleaf/fastlane-qyer.svg?branch=master)](https://travis-ci.org/icyleaf/fastlane-qyer)

[fastlane](http://github.com/fastlane/fastlane) 的自定义 action，制定了一些用于穷游网移动开发项目使用到的 `lanes`，底层依赖于 `qyer-mobile-app` gem，提供上传内部分发系统。

## 迁移说明

本工具是在 fastlane 前期过程中的产物，在 fastlane 支持 plugins 之后，该工具已拆分并分享为如下个插件：

插件 | 原由 action | 说明 |
---|---|---
[fastlane-plugin-ci_changelog](https://github.com/icyleaf/fastlane-plugin-ci_changelog) | jenkins | 支持多种 CI 系统自动生成变更历史
[fastlane-plugin-update_jenkins_build](https://github.com/icyleaf/fastlane-plugin-update_jenkins_build) | - | 自动更新 Jenkins Build 描述
[fastlane-plugin-humanable_build_number](https://github.com/icyleaf/fastlane-plugin-humanable_build_number) | - | 生成开发可识别的构建版本号
[fastlane-plugin-app_info](https://github.com/icyleaf/fastlane-plugin-app_info) | - | 解析 apk/ipa 包的 metadata 并打印
[fastlane-plugin-android_channels](https://github.com/icyleaf/fastlane-plugin-android_channels) | - | 通用性 Android 多渠道打包
[fastlane-plugin-upload_to_qmobile](https://github.com/icyleaf/fastlane-plugin-upload_to_qmobile) | qyer | 上传只 qmobile 新系统

<hr />

# 旧的说明

## 安装配置

确保已经安装了 `fastlane` 并进行初始化：

```bash
$ gem install fastlane
$ gem install fastlane-qyer
$ fastlane init
```

根据工具的提示输入和配置你项目的具体参数和账户情况，直至完成之后会在当前路径下生成 `fastlane` 的目录结构，打开其中的 `Fastlane` 在头部加入并保存：

```ruby
require 'fastlane-qyer'
```

接着我们就可以直接使用了！

## Actions

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


### qyer

封装 [qyer-mobile-app](http://github.com/icyleaf/qyer-mobile-app) 的功能，用于上传 ipa 和相关参数到穷游内部分发系统。

#### 参数

名称 | 环境变量 | 说明 | 默认值 |
---|---|---|---
api_key | `QYER_API_KEY` | API KEY | 可在穷游内部分发系统账户设置获取
ipa | `QYER_IPA` | ipa 的路径 | `SharedValues::IPA_OUTPUT_PATH` 获取
app_name | `QYER_APP_NAME` | 应用名| 不设置会解析 ipa 信息
slug | `QYER_SLUG` | 地址唯一标识 | 不设置随机生成
changelog | `QYER_CHANGELOG` | 更新日志 | `JENKINS_CHANGLOG` 获取
channel | `QYER_CHANNEL` | 渠道名 | `api`
branch | `QYER_GIT_BRANCH` | API KEY | `QYER_CVS_BRANCH` 获取
commit | `QYER_GIT_COMMIT` | API KEY | `QYER_CVS_COMMIT` 获取
ci_url | `QYER_CI_URL` | 本地构建地址 | `JENKINS_CI_URL` 获取

#### 使用方法

在定义好的 lane 添加：

```ruby

lane :beta do
  sigh
  gym
  qyer(
    api_key: 'xxxxxxxx',
    channel: 'fastlane'
  )
end
```

如果你在 CI 中设置可以设置好环境变量，上述的很多参数可以省略：

```ruby
# export QYER_API_KEY=xxxxxxx
# export QYER_CHANNEL=jenkins

lane :beta do
  sigh
  gym
  qyer
end
```

打开你的终端执行:

```bash
$ fastlane ios beta
```


### jenkins

[Jenkins](http://jenkins-ci.org) 每次打包都会获取当次打包的变更记录，再实际情况下如果遇到构建中止或出错的情况下，再次打包会丢失上述情况的记录。
为了解决开发和测试更好的查看每次分发的提交记录，会从本地构建往前追溯到上次失败或中止期间的所有变更记录。

#### 参数

暂不提供参数

#### 环境变量

环境变量 | 说明 | 备注 |
---|---|---
`JENKINS_CHANGLOG` | 变更记录 | 代码智能判断获取
`JENKINS_CVS_BRANCH` | 分支名 | 环境变量 `GIT_BRANCH` 获取
`JENKINS_CVS_COMMIT` | 最新的 commit 值 | 环境变量 `GIT_COMMIT` 获取
`JENKINS_CI_URL` | 本次构建的 URL | 环境变量 `BUILD_URL` 获取

#### 使用方法

```ruby
after_all do
  cocapods
  jenkins if is_ci?
end

lane :jenkins do
  sigh
  gym
  qyer
end
```

## 发布协议

[MIT License](http://opensource.org/licenses/MIT).
