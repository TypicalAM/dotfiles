# toolbox

One self-contained file. Drop it on a Linux box, get a shell with your tools and
your dotfiles. Delete the folder, nothing remains on the host.

Built from this repo with [nix-appimage](https://github.com/ralismark/nix-appimage).

## Example

The real prompt is your oh-my-posh rose theme; abbreviated here.

```console
$ scp toolbox.AppImage prod-box:~/debug/
$ ssh prod-box
$ cd debug && ./toolbox.AppImage
toolbox | 496 tools | state: /home/adam/debug/.toolbox

~/debug ❯ gs                          # your aliases
~/debug ❯ nvim                        # your kickstart config, 31 plugins
~/debug ❯ tmux                        # C-Space prefix, rose-pine
~/debug ❯ exit

$ ./toolbox.AppImage rg -i oom /var/log     # one tool, no shell
$ ./toolbox.AppImage -c 'ss -tlnp | rg 8080'
$ ./toolbox.AppImage --list                 # what's inside
$ ln -s toolbox.AppImage htop && ./htop     # busybox-style dispatch

$ cd .. && rm -rf debug                     # gone, host untouched
```

## Profiles

`tools.nix` has **groups** (bags of packages) and **profiles** (combinations of
groups). Each profile is a buildable image with its own `.toolbox-<name>/` state
directory, so several can share a folder.

| profile | contents | size |
|---|---|---|
| `minimal` | shell + search | 106 MB |
| `netdebug` | + net, sys | |
| `core` | + archive, dev (nvim, tmux, git) | 300 MB |
| `k8s` | core + kube, containers | |
| `aws` | core + aws, iac | |
| `full` | core + kube, aws, iac, containers, secrets | |
| `everything` | every group, including `db` | |

Adding one is a single line — it becomes `.#toolbox-<name>` automatically:

```nix
profiles = {
  incident = [ "base" "search" "net" "sys" "kube" "aws" ];
};
```

## Building

Needs a Linux builder; the image is a Linux ELF.

```sh
./toolbox/build.sh goralek16 --list          # profiles and their groups
./toolbox/build.sh goralek16 k8s             # build there, fetch image back
./toolbox/build.sh goralek16 base,net,aws    # ad-hoc mix, no profile needed
nix build .#toolbox-netdebug                 # or directly, from Linux
```

`build.sh` rsyncs the repo over rather than using git, so a package you just
added to `tools.nix` builds without `git add` first.

## SBOM and vulnerabilities

```sh
./toolbox/vulncheck.sh k8s               # SBOM + scan, exits 1 on findings
./toolbox/vulncheck.sh k8s --sbom-only   # just the SBOM
```

Runs locally (Linux nix). Writes CycloneDX and SPDX SBOMs of the image's
closure to `./sbom/` (or `$OUT`), plus the 32 nvim plugins at their locked
commits, which the nix closure can't see. Nix packages are scanned by sbomnix's
`vulnxscan` (vulnix, grype, OSV), the plugins by OSV commit lookup. Accepted
findings go in `toolbox/vulns-whitelist.csv` (`"vuln_id","comment"`).

Scanners disagree a lot: vulnix knows nixpkgs patches but matches by name,
grype matches by version only. Treat a single-scanner hit as a lead.

## How the disposable part works

nix-appimage's AppRun bind-mounts the real host root except `/nix`, and mounts
the image's own store there instead — tools see the machine, bring their own
dependencies, install nothing. On top of that `entrypoint.sh` points `HOME`,
`ZDOTDIR`, every `XDG_*_HOME` and `TMPDIR` at `<folder>/.toolbox/`, so shell
history, nvim plugins, tmux sockets and caches all land next to the image.
Configs are copied out of the read-only squashfs, so they stay editable.

Verified: a full session plus `nvim +Lazy! sync` adds nothing to the real `$HOME`.

`--where` prints the state dir, `--purge` deletes it, `--reseed` re-copies configs
after a rebuild (overwrites, does not merge).

## Target host needs

- `fusermount3`. Without it: `APPIMAGE_EXTRACT_AND_RUN=1 ./toolbox.AppImage ...`
  — unpacks to `$TMPDIR`, cleans up after itself, needs nothing installed.
- Unprivileged user namespaces. Standard on modern kernels, blocked inside
  unprivileged containers.

Tested on NixOS, Ubuntu 24.04 (glibc) and Alpine 3.21 (musl), both ways.

## Gotchas

- nvim's lazy.nvim plugins are prefetched at build time at the commits in
  `lazy-lock.json` (~29 MB) and seeded into the state dir, so nvim starts
  offline. A new plugin needs its repo added to `nvim-plugins.nix`; the build
  fails naming it otherwise. Treesitter parsers are not prefetched yet: offline,
  `ensure_installed` fails to download them and those languages fall back to
  regex highlighting.
- Some dotfiles hardcode host paths. `btop.conf`'s `color_theme` is rewritten to
  a bare theme name at build time because it degrades silently; the rest are left
  alone and only fail when invoked — `aliases.sh:33`, `functions.sh:48,62,92,101`,
  `nvim/lua/kickstart/keymaps.lua:55-56`.
- The seed is profile-independent: `toolbox-minimal` still ships the nvim and
  tmux configs it has no binaries for. ~200 KB, not worth gating.
- `mkToolbox {...}.appimage` parses as `mkToolbox ({...}.appimage)` — the ad-hoc
  expression needs outer parens.
