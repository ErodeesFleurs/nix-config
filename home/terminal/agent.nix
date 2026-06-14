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
        "opencode-pty"
        "opencode-dynamic-context-pruning"
        "opencode-goal-plugin"
        "superpowers@git+https://github.com/obra/superpowers.git"
      ];
    };
  };
}
