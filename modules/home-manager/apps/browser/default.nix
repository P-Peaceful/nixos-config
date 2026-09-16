{
  imports = [
    ./firefox.nix
    ./chrome.nix
  ];

  # 桌面环境通用的默认应用关联；Noctalia、xdg-open 以及其他应用都会使用它。
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = [ "google-chrome.desktop" ];
      "application/xhtml+xml" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
    };
  };
}
