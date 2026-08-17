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

      provider = {
        sudocode = {
          npm = "@ai-sdk/openai-compatible";
          "name" = "sudocode";
          options = {
            baseURL = "https://api.sudocode.chat/v1";
          };
          models = {
            "gpt-5.6-sol" = {
              "name" = "gpt-5.6-sol";
            };
            "gpt-5.6-terra" = {
              "name" = "gpt-5.6-terra";
            };
            "gpt-5.6-luna" = {
              "name" = "gpt-5.6-luna";
            };
          };
        };
      };
    };
  };
}
