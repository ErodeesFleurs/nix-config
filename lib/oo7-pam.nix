{ pkgs }:

pkgs.oo7-pam.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ../patches/oo7/pam-login.patch ];
})
