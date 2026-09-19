# NixOS 多设备配置架构

这是一份面向 **NixOS 26.05（Yarara）** 的配置架构设计，目标是使用 Flakes + Home Manager 管理多台设备，并同时提供两套登录会话：

- GNOME
- niri + Noctalia

本文定义目录、依赖边界和组合方式，并作为当前配置骨架的说明。当前已落地一个名为 thinkbook14 的设备示例；后续设备按相同边界新增自己的 host 目录即可。

当前工作区中的配置不会修改或替代 `/etc/nixos`。其中 `hosts/thinkbook14/hardware-configuration.nix` 仅复制了当前安装生成的硬件配置，其余系统和用户配置均为本仓库的新配置。

## 设计目标

1. 系统级模块和用户级模块物理分离。
2. 主机只负责组合模块，不重复编写功能配置。
3. 用户软件按功能拆分，可以被不同设备复用。
4. 桌面环境作为独立 profile，可在 GDM 登录界面选择 GNOME 或 niri。
5. 所有 NixOS/Home Manager 核心选项以 26.05 分支为准。
6. 第三方模块必须通过 flake input 锁定，并在 README 中明确其来源与版本边界。

这是单用户配置，不引入多用户抽象。每台设备拥有自己的模块组合，设备文件同时决定系统模块和该用户的 Home Manager 模块；flake 通过共享的 `mkHost` 装配函数复用公共依赖和 Home Manager 集成逻辑。

## 版本与依赖策略

核心依赖建议保持在同一个稳定发布系列：

~~~nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
home-manager.url = "github:nix-community/home-manager/release-26.05";
home-manager.inputs.nixpkgs.follows = "nixpkgs";
~~~

### NixOS

- 使用 nixos-26.05，不要在主配置中混用 nixos-unstable。
- 每台主机设置 system.stateVersion = "26.05"。
- system.stateVersion 是兼容性锚点，不代表自动升级系统。

### Home Manager

- 使用 release-26.05，与 NixOS 26.05 对齐。
- 唯一用户设置 home.stateVersion = "26.05"。
- 作为 NixOS module 集成，而不是同时使用 standalone Home Manager。
- 统一使用：

~~~nix
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
~~~

这样系统和用户配置使用同一个 pkgs 实例，减少重复实例化及包版本漂移。

### niri

NixOS 26.05 已提供原生 programs.niri 模块，系统侧优先使用它：

~~~nix
programs.niri.enable = true;
~~~

26.05 原生模块主要负责安装 niri、注册登录会话、Wayland portal、GNOME Keyring 等基础集成；niri 的窗口规则、键位、布局等配置由 Home Manager 管理为用户文件：

~~~nix
xdg.configFile."niri/config.kdl".source = ./config.kdl;
~~~

这样不会把 niri-flake 的不稳定或非 26.05 选项混入核心配置。如果未来确实需要 niri-flake 的声明式设置模块，应将它作为独立、明确锁定的第三方依赖，并保证其使用的 niri 包与系统侧完全一致。

### Noctalia

Noctalia v5 的 NixOS/Home Manager module 来自 Noctalia 自己的 flake，不属于 NixOS 26.05 核心模块。建议：

~~~nix
noctalia = {
  url = "github:noctalia-dev/noctalia";
  inputs.nixpkgs.follows = "nixpkgs";
};
~~~

实际版本以 flake.lock 锁定的 commit 为准。Home Manager 侧仅在 niri profile 中导入：

~~~nix
inputs.noctalia.homeModules.default
~~~

对应的选项属于 Noctalia module API，例如 `programs.noctalia.enable` 和 `programs.noctalia.settings`，不要将它们当成 NixOS 26.05 内置选项使用。当前配置将 Settings 导出的个人配置维护在 `modules/home-manager/apps/desktop/config.toml`，并通过 `programs.noctalia.settings` 接入。

## 推荐目录结构

~~~text
.
├── README.md
├── flake.nix
├── flake.lock
│
├── hosts/                              # 设备入口：只做组合
│   ├── thinkbook14/                     # 当前已落地的第一个设备
│   │   ├── default.nix
│   │   ├── home.nix
│   │   └── hardware-configuration.nix
│   └── common.nix                       # 可选：设备共用的主机参数
│
├── modules/
│   ├── nixos/                           # 系统级模块
│   │   ├── base.nix                     # 启动、区域、Nix、单用户、stateVersion
│   │   ├── hardware.nix                 # 图形、音频、蓝牙、打印
│   │   ├── services.nix                 # 网络、电源等系统服务
│   │   ├── apps/                        # 系统层面的应用/基础组件
│   │   │   └── input-method.nix         # Fcitx5 + Rime
│   │   └── desktop/                     # 系统层面的桌面会话
│   │       ├── gdm.nix
│   │       ├── gnome.nix
│   │       └── niri.nix
│   │
│   └── home-manager/                    # 用户级模块
│       ├── base.nix                     # home、环境变量、stateVersion
│       ├── packages/                    # 用户软件集合，按职责拆分
│       │   ├── base.nix
│       │   └── development.nix
│       └── apps/                        # 用户应用；配置文件跟随应用
│           ├── shell/
│           │   ├── fish/
│           │   │   ├── default.nix
│           │   │   └── config.fish
│           │   └── starship/
│           │       ├── default.nix
│           │       └── starship.toml
│           ├── input-method/fcitx5/
│           │   ├── default.nix
│           │   ├── profile
│           │   ├── config
│           │   ├── classicui.conf
│           │   ├── rime.conf
│           │   └── rime/default.custom.yaml     # 雾凇拼音用户覆盖
│           ├── browser/firefox.nix
│           ├── browser/chrome.nix
│           ├── editor/neovim.nix
│           ├── terminal/kitty/
│           │   ├── default.nix
│           │   └── kitty.conf
│           ├── vcs/git/
│           │   ├── default.nix
│           │   └── config
│           └── desktop/
│               ├── niri.nix
│               ├── niri-config.kdl
│               ├── noctalia.nix                 # Noctalia Home Manager 模块
│               └── config.toml                   # Noctalia 个人配置
│
└── assets/
    ├── fonts/
    ├── wallpapers/
    └── scripts/
~~~

目录名 modules/nixos 和 modules/home-manager 是有意固定的：看到文件位置即可判断该文件运行在系统模块图还是 Home Manager 模块图中。

## 模块职责边界

### modules/nixos

只放需要 root、systemd system、内核、硬件、系统服务或登录会话的内容，例如：

- 唯一用户账户、sudo、SSH
- NetworkManager、Bluetooth、PipeWire、打印服务
- 文件系统、bootloader、GPU、虚拟化
- GDM、GNOME 系统组件、niri 系统集成
- nix.settings、自动垃圾回收、系统级 substituter

系统层面的组件按职责划分，桌面会话单独归入 desktop/，系统应用归入 apps/：

~~~text
base.nix             -> 启动、区域、Nix、用户账户
hardware.nix         -> 图形、音频、蓝牙、打印
services.nix         -> 网络、电源等系统服务
apps/input-method   -> 系统级输入法组件
desktop/             -> GDM、GNOME、niri 会话及其系统集成
~~~

GDM 只配置一次。GNOME 和 niri 都注册到同一个 display manager，用户在登录界面选择会话，不为两个桌面分别启用 display manager。

如果目标是让同一台设备在登录时同时看到两个会话，该设备的 default.nix 应同时导入 gnome.nix 和 niri.nix；不要用全局装配器推导桌面组合。只有在某台设备确实不需要某个桌面时，才省略对应的 desktop module。

### modules/home-manager

只放用户 home、用户 profile、用户 systemd、用户软件启用项和配置文件链接，例如：

- home.packages
- shell、Git、编辑器、终端、浏览器的启用项
- xdg.configFile 对各应用目录中原生配置文件的链接
- Noctalia 的 programs.noctalia.*
- 用户级 systemd services

Home Manager 模块不应配置 boot.*、services.displayManager.*、users.users.* 或其他系统级选项。

用户层不再设置独立的 desktop profile。桌面会话的启用和系统集成全部由 modules/nixos/desktop/ 负责；niri 的用户配置和 Noctalia 作为用户应用，分别跟随自己的应用目录维护。

### Fish + Starship

Fish 是当前唯一的默认交互 Shell，系统侧通过 `users.users.wenzhengcheng.shell = pkgs.fish` 设置默认 Shell，并通过 `programs.fish.enable = true` 安装系统所需的 Shell 路径。Home Manager 侧负责 Fish 的个人交互配置。

Starship 只负责提示符外观，不是终端模拟器或 Shell。它由 `programs.starship` 启用，原生配置文件放在 `modules/home-manager/apps/shell/starship/starship.toml`。Bash 保留用于脚本兼容，不再启用 Zsh。

## 两套桌面 profile

### 桌面会话与应用归属

系统侧的 modules/nixos/desktop/ 负责桌面会话：

~~~nix
services.desktopManager.gnome.enable = true;
services.displayManager.gdm.enable = true;
~~~

GNOME、niri 和 GDM 都属于系统层面。若一台设备需要同时提供两个登录会话，hosts/<hostname>/default.nix 同时导入 gdm.nix、gnome.nix 和 niri.nix；GDM 登录界面负责会话选择。

用户层不再出现 GNOME 或 niri 的第二套桌面 profile。GNOME 没有额外的 Home Manager 桌面配置；niri 仅作为用户应用维护其必须的用户配置文件。

### niri 用户应用

系统侧的 modules/nixos/desktop/niri.nix 只负责：

~~~nix
programs.niri.enable = true;
~~~

原生 niri 模块会注册 niri session，并提供其基础 Wayland 集成。niri 配置本身放在 Home Manager：

- niri/config.kdl：窗口规则、键位、布局、启动项
- xdg-desktop-portal 相关用户偏好
- Wayland 工具、启动器、锁屏、通知等用户软件

用户侧的 modules/home-manager/apps/wayland/niri/ 负责链接 niri 用户配置：

~~~nix
xdg.configFile."niri/config.kdl".source = ./config.kdl;
~~~

niri 的 config.kdl 是 niri 应用自己的用户配置，不与系统侧的 niri.nix 重复。Noctalia 的启动由该文件中的 spawn-at-startup 完成。

### Noctalia 用户应用

Noctalia 只应被 niri 使用，并由 `modules/home-manager/apps/desktop/noctalia.nix` 自己维护：

~~~nix
imports = [ inputs.noctalia.homeModules.default ];

programs.noctalia = {
  enable = true;
  systemd.enable = false;
  settings = ./config.toml;
};
~~~

Noctalia 的个人 TOML 由 Home Manager 生成到 `~/.config/noctalia/config.toml`；`~/.local/state/noctalia/settings.toml` 仍作为可写的 GUI 覆盖层。Noctalia 由 niri 的 `spawn-at-startup "noctalia"` 启动；独立 user service 保持关闭，避免用户登录 GNOME 时启动 Noctalia。V5 的 IPC 快捷键使用 `noctalia msg ...`，例如启动器使用 `noctalia msg panel-toggle launcher`。

Noctalia 使用 NetworkManager、Bluetooth、电源配置和电池信息时，系统侧应按需启用：

- networking.networkmanager.enable
- hardware.bluetooth.enable
- services.upower.enable
- services.power-profiles-daemon.enable 或 services.tuned.enable

## 系统应用与用户应用

应用按运行位置和职责分层，最终由设备文件选择：

~~~text
modules/nixos/desktop/       系统桌面会话与集成
modules/nixos/apps/          系统级应用/基础组件
modules/home-manager/apps/   用户级应用与用户配置
modules/home-manager/packages/ 用户软件集合
hosts/<name>/default.nix     设备选择系统组件
hosts/<name>/home.nix        设备选择用户组件
~~~

划分规则：

- GDM、GNOME、niri 的系统启用和会话注册属于系统层，放在 modules/nixos/desktop/。
- Fcitx5 的框架启用、Wayland 前端和 `rime-ice` 插件属于系统层，放在 modules/nixos/apps/；Fcitx5 的用户 profile、ClassicUI 外观和 Rime 用户覆盖属于用户应用，放在 modules/home-manager/apps/input-method/fcitx5/。两层职责不同，不重复维护同一份配置。
- Firefox、Google Chrome、Neovim、Git、Kitty 属于用户应用，放在 modules/home-manager/apps/。
- niri 的 config.kdl、Kitty 的 kitty.conf、Fcitx5 的 profile/config/conf 文件和 Noctalia 的 config.toml 都是用户应用配置，分别跟随自己的应用目录维护。
- 用户软件集合放在 modules/home-manager/packages/，按基础工具、开发工具等职责拆分。

Fcitx5 当前默认使用雾凇拼音 Rime，用户侧配置包括：默认输入法、Ctrl+Space 切换、逗号/句号翻页、候选词数量以及 `rime_ice_suggestion` 引用。系统侧通过 `fcitx5-rime.override` 注入 `rime-ice` 数据包。Home Manager 使用 `hm-backup` 作为冲突文件备份扩展名，首次接管已有 Fcitx5 配置时会先备份原文件。

软件包集合文件可以被多个 host 重复引用；host 不应该复制 home.packages 列表。

应用配置内容不要写入 Nix 表达式。需要自定义配置的用户应用目录包含自己的 default.nix 和原生配置文件；default.nix 只负责安装/启用应用及链接配置文件。使用默认配置的应用可以只保留 default.nix。

## 主机组合模型

每个 hosts/<hostname>/default.nix 只表达设备差异和 profile 选择，组合关系应接近：

~~~text
host
├── nixos/base.nix
├── nixos/hardware.nix
├── nixos/services.nix
├── nixos/apps/input-method.nix
├── nixos/desktop/gdm.nix
├── nixos/desktop/gnome.nix
├── nixos/desktop/niri.nix
├── hardware-configuration.nix
└── home.nix                         # 该设备唯一的用户模块组合文件
    ├── home-manager/base.nix
    ├── home-manager/packages/base.nix
    ├── home-manager/packages/development.nix
    └── home-manager/apps/<responsibility>/<app>/
~~~

建议将主机差异放在 host 文件或单独的 host-options.nix 中，例如：

- hostname
- 文件系统和磁盘
- GPU 驱动
- 电池/桌面硬件差异
- 设备专属服务
- 该设备选择的 desktop profile
- 该设备选择的用户软件 profile

每台设备可以有自己的 home.nix，但其中只放该设备的模块选择和少量覆盖；共享配置仍放在 modules/home-manager/ 中，避免复制完整配置。

## Flake 输出规划

flake.nix 提供系统输出；每个系统输出内部集成对应设备的 Home Manager：

~~~text
nixosConfigurations.<hostname>    # 设备系统 + 内嵌 Home Manager
~~~

实际激活通过对应的 nixosConfigurations.<hostname> 完成。`mkHost` 只负责复用公共模块、用户参数和 Home Manager 接入；每台设备仍通过自己的 host 模块和 `home.nix` 决定具体配置。flake 不提供额外的 standalone Home Manager 入口。

通过 home-manager.extraSpecialArgs 将 inputs、主机名和少量公共参数传入该设备的 Home Manager 配置，而不是在模块中隐式读取路径或使用 builtins.getEnv。

## 导入规则

采用以下规则可以避免模块图失控：

1. 每个 hosts/<hostname>/default.nix 负责该设备的系统模块组合。
2. 每个 hosts/<hostname>/home.nix 负责该设备唯一用户的 Home Manager 模块组合。
3. hosts/<hostname>/default.nix 导入系统层模块，hosts/<hostname>/home.nix 导入用户层模块。
4. modules/nixos/ 不直接导入 modules/home-manager/。
5. modules/home-manager/ 不设置系统级 NixOS 选项。
6. 共享模块不读取某台主机的硬编码路径。
7. 应用配置文件跟随对应 app，放在 modules/home-manager/apps/<responsibility>/<app>/ 中。
8. 第三方 module 的 import 集中在对应 app 模块中，不散落在各个 host。

推荐依赖方向：

~~~text
flake inputs -> hosts/<hostname>/default.nix -> nixos modules
            -> hosts/<hostname>/home.nix    -> home modules -> package profiles
~~~

不要让公共模块反向依赖具体 host，也不要让某台设备的桌面模块被另一台设备隐式导入。

## 版本校验清单

开始实际搭建前，逐项确认：

- nixpkgs 为 nixos-26.05。
- Home Manager 为 release-26.05。
- home-manager.inputs.nixpkgs.follows = "nixpkgs"。
- 每台主机的 system.stateVersion 为 "26.05"。
- 唯一用户的 home.stateVersion 为 "26.05"。
- niri 使用 NixOS 26.05 的 programs.niri 模块。
- Noctalia 使用锁定的外部 flake module，而不是假设它是 NixOS 内置模块。
- Noctalia 的 module API 与锁定 commit 的文档一致。
- GNOME 和 niri 共用一个 GDM。
- Noctalia 不会在 GNOME 会话中自动启动。
- 用户软件没有重复写入多个 host。
- 所有第三方输入都记录在 flake.lock，并在更新后执行至少一次全量 build 检查。

## 后续扩展顺序

当前 nixos 设备已经完成基础骨架。后续扩展建议按以下顺序进行：

1. 在 hosts/ 下新增设备目录，并复制该设备专属的硬件配置。
2. 在 hosts/<hostname>/default.nix 中选择系统层硬件、服务和桌面模块。
3. 在 hosts/<hostname>/home.nix 中选择用户软件集合和用户应用。
4. 新增应用时，在对应的 modules/home-manager/apps/<responsibility>/<app>/ 中同时放置 default.nix 与原生配置文件。
5. 只有确实需要系统权限或系统服务的应用，才新增 modules/nixos/apps/ 下的系统模块。

## 参考文档

- [NixOS 26.05 Manual](https://nixos.org/manual/nixos/26.05/)
- [NixOS 26.05 Release Notes](https://nixos.org/manual/nixos/26.05/release-notes/release-notes-26.05)
- [Home Manager NixOS module](https://home-manager.dev/manual/26.05/nix-flakes/nixos.html)
- [Home Manager release-26.05](https://github.com/nix-community/home-manager/tree/release-26.05)
- [NixOS 26.05 niri module](https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/programs/wayland/niri.nix)
- [Noctalia NixOS/Home Manager installation](https://docs.noctalia.dev/noctalia/getting-started/nixos/)
