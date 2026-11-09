{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  # pi-natives 的 zstd-sys 通过 pkg-config 链接系统 libzstd；上游包遗漏此构建依赖。
  omp = llmAgents.omp.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.zstd ];
  });
in
{
  home.packages = [ omp ];

  programs.opencode = {
    enable = true;
    package = llmAgents.opencode2;
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
