{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "wenzhengcheng";
        email = "wenzhengcheng0223@gmail.com";
      };

      init.defaultBranch = "main";

      # GitHub 在当前 Linux 网络环境下使用 SSH，避免 HTTPS remote 连接失败。
      url."git@github.com:".insteadOf = [
        "https://github.com/"
        "http://github.com/"
        "git://github.com/"
      ];

      # 使用 sops-nix 部署的 GitHub 私钥，并禁止 SSH 尝试其它身份。
      core.sshCommand =
        "ssh -i /run/secrets/github/ssh-private-key -o IdentitiesOnly=yes";
    };
  };
}
