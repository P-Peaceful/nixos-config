{
  config,
  userName,
  ...
}:

{
  sops = {
    #
    # 所有设备使用同一个加密文件
    #
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    #
    # 但是每台设备本地拥有自己的 age private key
    #
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
    };

    secrets = {
      #
      # GitHub SSH 私钥
      #
      "github/ssh-private-key" = {
        owner = config.users.users.${userName}.name;
        group = config.users.users.${userName}.group;

        mode = "0400";
      };

      # 以后其它共享 secret
      #
      # "openai/api-key" = {
      #   owner = config.users.users.${userName}.name;
      #   group = config.users.users.${userName}.group;
      #   mode = "0400";
      # };
    };
  };
}