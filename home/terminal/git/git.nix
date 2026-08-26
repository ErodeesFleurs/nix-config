{ config, ... }:

{
  programs.git = {
    enable = true;

    # delta 主题由 monet 主题系统生成
    includes = [
      { path = "${config.home.homeDirectory}/.config/git/monet-delta.gitconfig"; }
    ];

    settings = {
      user = {
        name = "ErodeesFleurs";
        email = "862959461@qq.com";
      };

      core = {
        editor = "hx";
        autocrlf = "input";
      };

      init.defaultBranch = "main";
      pull.rebase = false;
      push.default = "simple";

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --graph --oneline --decorate --all";
      };
    };

    lfs.enable = true;
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
    };
  };
}
