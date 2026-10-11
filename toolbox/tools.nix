# What goes into the portable debug AppImage.
#
# Two things to edit here:
#   groups   -- named bags of packages
#   profiles -- named combinations of groups, each becomes a buildable image
#
# Every profile shows up as `nix build .#toolbox-<profile>` (core is just
# `.#toolbox`), and any ad-hoc combination works too:
#   ./toolbox/build.sh <host> base,net,kube
{ pkgs }:

let
  groups = with pkgs; {

    # Shell, coreutils, prompt. Every profile wants this.
    base = [
      zsh
      bashInteractive
      coreutils-full
      findutils
      diffutils
      gnugrep
      gnused
      gawk
      which
      file
      less
      hostname
      util-linux
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-completions
      oh-my-posh
      starship
    ];

    # Finding things.
    search = [
      ripgrep
      fd
      fzf
      bat
      eza
      tree
      zoxide
      lf
      sd
      ranger
    ];

    # Talking to things.
    net = [
      curl
      wget
      httpie
      dnsutils # dig, nslookup
      iproute2 # ip, ss
      nettools # ifconfig, netstat, route
      iputils # ping
      traceroute
      mtr
      gping
      socat
      netcat-gnu
      openssl
      tcpdump
      nmap
      grpcurl
      websocat
      rsync
    ];

    # Looking at the machine.
    sys = [
      htop
      btop
      procps
      psmisc # fuser, killall, pstree
      lsof
      strace
      sysstat
      iotop
      pciutils
      usbutils
      dmidecode
      smartmontools
      ethtool
      ncdu
      duf
      dust
    ];

    # Unpacking things.
    archive = [
      gnutar
      gzip
      xz
      zstd
      unzip
      p7zip
    ];

    # Working on things.
    dev = [
      git
      lazygit
      delta
      difftastic
      gh
      neovim
      tmux
      jq
      yq-go
      moreutils # sponge, ts, vipe, ...
      entr
      watchexec
      hyperfine
      just
      direnv
      shellcheck
      shfmt
      yamllint
      python3
    ];

    kube = [
      kubectl
      kubectx
      k9s
      stern
      kubernetes-helm
    ];

    aws = [
      awscli2
      ssm-session-manager-plugin
    ];

    iac = [
      opentofu
      terragrunt
    ];

    containers = [
      docker-client
      lazydocker
      dive
      skopeo
    ];

    secrets = [
      age
      sops
      step-cli
    ];

    # Heavy. Only in `everything`.
    db = [
      postgresql
      mysql-client
      redis
      mongosh
    ];
  };

  profiles = {
    minimal = [ "base" "search" ];
    netdebug = [ "base" "search" "net" "sys" ];
    core = [ "base" "search" "net" "sys" "archive" "dev" ];
    k8s = [ "base" "search" "net" "sys" "archive" "dev" "kube" "containers" ];
    aws = [ "base" "search" "net" "sys" "archive" "dev" "aws" "iac" ];
    full = [ "base" "search" "net" "sys" "archive" "dev" "kube" "aws" "iac" "containers" "secrets" ];
    everything = builtins.attrNames groups;
  };
in
{
  inherit groups profiles;
}
