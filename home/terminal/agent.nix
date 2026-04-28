{ ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      compaction = {
        auto = true;
        strategy = "summarize";
        threshold = 0.8;
        prune_tool_outputs = true;
      };

      plugin = [
        "opencode-worktree"
        "opencode-skillful"
      ];
    };
  };
}
