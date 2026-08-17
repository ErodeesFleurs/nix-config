{ ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      compaction = {
        auto = true;
      };

      lsp = true;

      plugin = [
        "opencode-worktree"
        "opencode-skillful"
        "opencode-notificator"
      ];
    };
  };
}
