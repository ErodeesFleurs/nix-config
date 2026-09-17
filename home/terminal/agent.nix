{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # llm-agents.nix 用「未打补丁的 bun 1.3.14 模板 + nixpkgs 的 bun 编译器」拼出
  # omp 独立二进制（packages/omp/package.nix 的 bunRuntimeVersion）。nixpkgs 的
  # bun 升到 1.4.2 后编译器与模板跨代：1.4.x 把 `with { type = "text" }` 导入编成
  # $bunfs 内嵌资源（1.3.x 是直接内联字符串），1.3.14 运行时解不开 1.4.2 写的资源，
  # installCheck 的 smoke test 因此死在
  #   SyntaxError: Invalid character: '\0'
  #   at <parse> (/$bunfs/root/prelude-e649jhs8.txt:1)
  # 把编译器钉回 llm-agents.nix 当初使用的 bun 1.3.13（只覆盖 x86_64-linux，
  # 本 flake 也只构建该平台）。numtide/llm-agents.nix#9278（omp 18.2.0 改用
  # nixpkgs 的 bun 1.4.2、删掉模板，前置 #9264）合并后即可删除本段。
  bun1313 = pkgs.bun.overrideAttrs (_: {
    version = "1.3.13";
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.13/bun-linux-x64-baseline.zip";
      hash = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
    };
  });

  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  # bun2nix-hook 经 propagated-build-inputs 自带一个 bun（= nixpkgs 的 1.4.2）
  # 且排在 `bun` 参数之前，所以只 override { bun = ...; } 不会生效：buildPhase
  # 里的 `bun` 仍解析到 1.4.2。把 bun1313 放到 nativeBuildInputs 首位，PATH 里
  # 才会先命中它（probe 验证：command -v bun → bun-1.3.13）。
  omp = (llmAgents.omp.override { bun = bun1313; }).overrideAttrs (old: {
    nativeBuildInputs = [ bun1313 ] ++ old.nativeBuildInputs;
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
