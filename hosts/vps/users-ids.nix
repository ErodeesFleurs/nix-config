# Existing numeric identities own persistent files; retain them across rebuilds.
{ lib, ... }:
{
  users.groups = builtins.mapAttrs (_: gid: { gid = lib.mkForce gid; }) {
    adm = 4;
    audio = 29;
    clock = 993;
    dialout = 20;
    floppy = 25;
    input = 995;
    kmem = 15;
    kvm = 992;
    lp = 7;
    messagebus = 996;
    nixbld = 987;
    render = 991;
    sgx = 994;
    shadow = 42;
    systemd-journal = 999;
    systemd-network = 998;
    systemd-resolve = 990;
    systemd-timesync = 997;
    tape = 26;
    tty = 5;
    utmp = 43;
    uucp = 10;
    video = 44;
  };
  users.users = builtins.mapAttrs (_: uid: { uid = lib.mkForce uid; }) {
    messagebus = 996;
    nixbld1 = 999;
    nixbld2 = 995;
    nixbld3 = 994;
    nixbld4 = 993;
    nixbld5 = 992;
    nixbld6 = 991;
    nixbld7 = 987;
    nixbld8 = 986;
    nixbld9 = 985;
    nixbld10 = 984;
    systemd-network = 998;
    systemd-resolve = 990;
    systemd-timesync = 997;
  };
}
