{
  pkgs,
  lib,
  inputs,
  ...
}:
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
          models =
            lib.genAttrs
              [
                "gpt-5.6-sol"
                "gpt-5.6-terra"
                "gpt-5.6-luna"
              ]
              (name: {
                inherit name;
                variants = lib.genAttrs [
                  "low"
                  "medium"
                  "high"
                  "xhigh"
                ] (_: { });
              });
        };
      };
    };
  };
}
