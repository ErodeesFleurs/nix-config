{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    llmAgents.codex
    (pkgs.symlinkJoin {
      name = llmAgents.omp.name;
      paths = [ llmAgents.omp ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/omp" --suffix PATH : ${lib.makeBinPath [ pkgs.python3 ]}
      '';
    })
  ];

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
