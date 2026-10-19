{ pkgs }:

# Zed 会并发读取多组凭据；等待中的解锁请求在轮到 UI 时重新检查集合状态，
# 每个请求仍执行自身动作并收到 Completed，不保存密码或共享可被取消的 prompt。
pkgs.oo7-server.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ../patches/oo7/concurrent-unlock.patch
    ../patches/oo7/pam-completion.patch
  ];
})
