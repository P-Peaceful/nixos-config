# Fish 个人交互配置。
# Starship 的初始化由 Home Manager 的 programs.starship 模块负责。

# 不显示 Fish 默认欢迎语。
set -g fish_greeting

# Fish 原生缩写：输入后按空格会展开，适合替代一部分 alias。
abbr --add --position command g git
abbr --add --position command ga 'git add'
abbr --add --position command gaa 'git add --all'
abbr --add --position command gc 'git commit'
abbr --add --position command gco 'git checkout'
abbr --add --position command gd 'git diff'
abbr --add --position command gl 'git log --oneline --decorate --graph'
abbr --add --position command gs 'git status --short --branch'
abbr --add --position command ll 'ls -lah'

# 进入 Nix 开发环境时使用当前目录的 flake。
function nd
  nix develop --command fish
end
