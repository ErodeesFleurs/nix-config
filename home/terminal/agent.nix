{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
  ];

  programs.opencode = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;
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
          name = "sudocode";
          options = {
            baseURL = "https://api.sudocode.chat/v1";
          };
          models = {
            "gpt-5.6-sol" = {
              name = "gpt-5.6-sol";
              variants = {
                low = { };
                medium = { };
                high = { };
                xhigh = { };
              };
            };
            "gpt-5.6-terra" = {
              name = "gpt-5.6-terra";
              variants = {
                low = { };
                medium = { };
                high = { };
                xhigh = { };
              };
            };
            "gpt-5.6-luna" = {
              name = "gpt-5.6-luna";
              variants = {
                low = { };
                medium = { };
                high = { };
                xhigh = { };
              };
            };
          };
        };
      };
    };
  };
}
