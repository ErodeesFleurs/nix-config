# VPS

`nixosConfigurations.vps` / `packages.x86_64-linux.vps` manages the Hong Kong server at 198.44.178.249. It has direct egress: no proxy or Mihomo service. The workstation-to-server SSH connection separately needs the workstation's dae bypass (`IPQoS=16`).

## Storage and state

Reuse the existing ext4 root and 124 MiB EFI partition by UUID. Do not run disko or format either partition. GRUB keeps kernels on ext4. Retain `/var/lib/osbswap/swapfile` (48 GiB).

Runtime secrets and administrator-deployed application data stay outside the Nix store. Preserve:

- `/etc/qq-agent`, `/etc/qq-agent-public`, `/etc/outfit-studio`.
- `/etc/ssh/ssh_host_*` and `/root/.ssh`.
- `/opt/qq-agent`, including capabilities and media models.
- `/var/lib/qq-agent`, `/var/lib/qq-agent-public`, `/var/lib/qq-agent-tunnel`, `/var/lib/outfit-studio`.
- `/srv/outfit-studio` including releases, not just the current symlink.
- `/root/.local/share/osb-build-progress`.
- `/usr/local/cloud-agent` and `/etc/sysconfig/cloud-agent` if present.
- Existing source trees, toolchains, Nix profiles and build evidence.

Service configuration and root password credentials are declared by `secrets.nix`, `secrets-qq.nix`, `secrets-web.nix` and `users.nix`, encrypted under `secrets/vps/`. `secrets/secrets.nix` authorizes both the VPS SSH host identity and the existing administrator dae identity. agenix decrypts at boot; consumers wait for its ownership pass. Do not edit the decrypted paths: re-encrypt the corresponding file and deploy. Preserve the host SSH private key for recovery. Application executables/models, certificates, sessions, databases, releases and progress data remain persistent runtime state, not Nix-store inputs.

## First installation

Requires confirmed KVM/IPMI/console or a provider rescue environment. A copied Nix store closure is staging, not an installed or activated NixOS system. Do not run `switch-to-configuration switch` on live Debian. Prepare a recoverable `/etc` transition: Debian's `/etc/systemd/system` directory cannot simply be replaced by NixOS's managed symlink while its units are running. Take a quiesced final application-state backup before cutover; a live preflight archive is not an application-consistent snapshot. Preserve a usable Debian recovery path and the original EFI files before installing GRUB.

## Deployed system

The server was migrated in place to NixOS 26.11 with Linux 6.18.57. The original filesystem UUIDs, SSH host keys, service data and 48 GiB swap were retained. `users-ids.nix` pins existing system identities so rebuilds do not change ownership of persistent data. The source configuration is also available at `/etc/nixos`; rebuild this host with `nixos-rebuild switch --flake /etc/nixos#vps` after synchronizing changes.

The root shell no longer sources the old clashctl proxy setup. Mihomo is not part of the system and proxy ports 1053/9090 are not opened.

Recovery material remains on the server at `/var/backups/nixos-migration-20261024`: `etc-debian`, `boot-debian.tar`, `partition-table.txt`, the pinned NapCat OCI image and `final-service-state.tar.gz`. The workstation's migration backup directory was removed at the user's request (about 1.5 GiB). Server backups contain secrets; keep them private.

New OpenSSH configuration and QQ ELF-loader checks passed on the server. Both HTTPS applications and the progress webpage responded after the first NixOS boot. NapCat initially required QR login; a running container or reachable management page is not proof of a logged-in QQ account or working bot reply.

Further controlled reboots confirmed the final system generation, SSH, static routing, swap and all application daemons. Outfit, the public QQ management page and progress UI each returned HTTP 200; the private model tunnel returned an HTTP response from its upstream. The final boot has no failed systemd units. A real sandboxed Nix build produced `nixos-builder-ok`. Obsolete Debian `/usr/lib/systemd` and `/usr/lib/binfmt.d` were moved into the recovery directory to prevent loading old dynamically linked service executables.

Authorize QQ through `https://198.44.178.249:8444/` using the existing management credentials, then open **账号登录**, scan with the configured QQ account and confirm on the phone. If the QR expires or the page retains a NapCat WebUI authentication timeout, use **刷新二维码**; this cleared the observed cached error without restarting NapCat or deleting its session data. Do not refresh again while a scan is in progress. Before QQ login, a refused OneBot port 3001 is not by itself a token/configuration mismatch. Avoid the old `/opt/qq-agent/qq-agent-login` helper, which bypasses the Nix ELF loader and launches another foreground bot.

After authorizing QQ login, verify the management page reports the account logged in and OneBot connected, then send an intentional test message and exercise media capabilities. A running container, visible QR or reachable management page is insufficient proof. Preserve the backup and provider rescue access until those application-level checks are complete.

After phone authorization on 2026-10-24, authenticated checks confirmed the expected account logged in, OneBot connected and an authenticated WebSocket handshake successful, with no reported login/connection errors. These remained healthy after deploying build isolation without restarting QQ or NapCat. Actual message replies and media capabilities still require an intentional user test.

## Mainline kernel

`boot.kernelPackages = pkgs.linuxPackages_latest` follows the newest released kernel packaged in the locked nixpkgs, rather than NixOS's default LTS or release candidates. On 2026-10-24 this selected Linux 7.3, matching [kernel.org's latest release](https://www.kernel.org/releases.json). The server was rebooted into generation 6; `uname -r` reported `7.3.0`. SSH, static routing, the retained swap and NapCat recovered; both HTTPS sites, the progress UI and the private model endpoint returned HTTP 200, with no failed systemd units. At that boot QQ still reported `OneBot unavailable`; it was subsequently restored through phone authorization as described above.

This is lock-based tracking, not an automatic upstream updater. After intentionally updating the nixpkgs lock, build/install the next boot generation with `sudo nixos-rebuild boot --flake /etc/nixos#vps`, then reboot in a maintenance window. A rebuild without rebooting does not replace the running kernel. GRUB retains five generations, including the preceding Linux 6.18.57 generation after this upgrade; select the previous generation from GRUB if a new kernel cannot boot. Keep old generations and provider rescue access until the new boot is verified.

## Shared build resource budget

`build.slice` is a top-level sibling of `system.slice` and `user.slice`. All participating builds share `MemoryHigh=20G`, `MemoryMax=24G` and `CPUQuota=1200%` in aggregate, not per job. Its CPU and IO weights are 25 versus the default 100 for other slices, favoring application responsiveness under contention. The memory ceiling is a build-side safety limit, not a reservation for applications. Nix keeps one concurrent build, 12 build cores and disk-backed temporary storage.

The Nix daemon belongs to this slice automatically. Independent local-store builds must use the installed `build-run [systemd-run options] -- COMMAND [ARG ...]` launcher; bare `NIX_REMOTE=local` or arbitrary root commands are not automatically covered:

```sh
sudo build-run --scope --quiet -- env NIX_REMOTE=local nix build --no-link path:/etc/nixos#vps
```

`--scope` waits and preserves the invoking environment, working directory and standard streams. Durable services may use systemd-run's `--unit`/`--no-block` options but must specify their working directory/environment explicitly. The launcher rejects slice overrides and remote-manager selection and disables argument environment expansion; pass environment variables explicitly rather than embedding shell expansion in command arguments.

The canonical `/root/.local/share/osb-build-progress/build-progress.py --run` capture entrypoint now enters this slice before launching its payload, unless already inside it. Its observer/`--auto` mode remains outside the build budget. This runtime script is retained application state, not a Nix-store source; preserve it during recovery. Historical probe scripts were not rewritten, so new independent build launchers must use `build-run` rather than bare `systemd-run`.

Live verification compiled and executed a C program through both the Nix daemon and `NIX_REMOTE=local`, proving their builders/children ran below the same parent slice. Scope and canonical capture smoke checks covered literal arguments, cwd/environment/stdin, nonzero exit status, signal termination and capture metadata. Kernel cgroup files confirmed the aggregate limits; QQ, Caddy and the progress observer remained in `system.slice`. The deployed generation has no failed units and the HTTPS/progress endpoints still return HTTP 200.

## Declarative administrator account

`users.nix` reuses `hosts/common/users.nix`: immutable users managed by userborn, with `fleurs` UID 1000, Nushell and only the wheel supplemental group. The personal workstation SSH key is authorized; SSH password authentication remains disabled. The account password hash matches the configured Surface account; sudo-rs requires that password. Wheel uses GID 1001 because the retained Debian daemon group already owns GID 1.

`homeConfigurations."fleurs@vps"` / `packages.x86_64-linux.fleurs-vps` manages the user's Nushell, Starship, Carapace, Helix and btop environment without importing desktop modules. Apply both layers from the configuration checkout:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#vps
home-manager switch --flake /etc/nixos#fleurs@vps
```

User creation, group membership, SSH authorization and sudo policy must be changed in Nix, not with useradd/usermod. Business configuration changes restart the relevant services through ciphertext restart triggers. Service state remains external and must be backed up separately.
