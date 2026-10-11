# Builds the portable debug toolbox AppImage out of the dotfiles in this repo.
#
# Two halves:
#   env   -- a buildEnv of the groups selected by `profile` (or `groups`)
#   seed  -- the config tree that gets copied next to the image on first run
# ./entrypoint.sh glues them together and is what the AppImage actually starts.
#
# Pick the contents either by profile name:      { profile = "k8s"; }
# or by an ad-hoc list of group names:           { groups = [ "base" "net" ]; }
{ pkgs
, mkAppImage
, profile ? "core"
, groups ? null
, name ? null
}:

let
  inherit (pkgs) lib;

  tools = import ./tools.nix { inherit pkgs; };

  selected =
    if groups != null then groups
    else tools.profiles.${profile} or (throw
      "unknown toolbox profile '${profile}'; known: ${lib.concatStringsSep ", " (builtins.attrNames tools.profiles)}");

  paths = lib.unique (lib.concatMap
    (g: tools.groups.${g} or (throw
      "unknown tool group '${g}'; known: ${lib.concatStringsSep ", " (builtins.attrNames tools.groups)}"))
    selected);

  # Each variant gets its own name, so `.toolbox-k8s/` and `.toolbox/` state
  # directories never collide when several images land in the same folder.
  imageName =
    if name != null then name
    else if groups != null then "toolbox-custom"
    else if profile == "core" then "toolbox"
    else "toolbox-${profile}";

  env = pkgs.buildEnv {
    name = "${imageName}-env";
    inherit paths;
    pathsToLink = [ "/bin" "/share" "/etc" ];
    ignoreCollisions = true;
  };

  # --- configs -----------------------------------------------------------------

  zshrc = pkgs.runCommand "toolbox-zshrc" { } ''
    substitute ${./zshrc} $out \
      --replace-fail '@completions@' '${pkgs.zsh-completions}/share/zsh/site-functions' \
      --replace-fail '@autosuggestions@' '${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh' \
      --replace-fail '@syntaxhighlighting@' '${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
  '';

  # The dotfiles' tmux.conf loads tpm from ~/.tmux/plugins, which does not exist
  # in the image. Swap that one line for nix-provided plugins so the rest of the
  # config (keybinds, rose-pine settings, status line overrides) still applies in
  # the original order.
  tmuxPluginRuns = lib.concatMapStringsSep "\n"
    (p: "run-shell ${p.rtp}") [
    pkgs.tmuxPlugins.sensible
    pkgs.tmuxPlugins.resurrect
    pkgs.tmuxPlugins.yank
    pkgs.tmuxPlugins.rose-pine
  ];

  tmuxConf = pkgs.runCommand "toolbox-tmux.conf"
    {
      pluginRuns = tmuxPluginRuns;
    } ''
    awk -v repl="$pluginRuns" \
      '{ if ($0 ~ /tpm\/tpm/) print repl; else print }' \
      ${../dot_tmux.conf} >$out
  '';

  # Every lazy.nvim plugin at the commit pinned in lazy-lock.json, laid out the
  # way lazy expects under stdpath('data')/lazy. With them present, the init.lua
  # bootstrap and lazy's install step both find nothing to clone, so nvim works
  # offline. builtins.fetchGit with a rev needs no hash and is allowed in pure
  # eval; `ref` is the lock's branch so non-default branches (telescope 0.1.x)
  # resolve.
  nvimLock = lib.importJSON ../dot_config/nvim/lazy-lock.json;
  nvimRepos = import ./nvim-plugins.nix;
  nvimUnmapped = builtins.filter (n: !(nvimRepos ? ${n})) (builtins.attrNames nvimLock);

  fetchNvimPlugin = name: builtins.fetchGit {
    url = "https://github.com/${nvimRepos.${name}}";
    ref = nvimLock.${name}.branch;
    rev = nvimLock.${name}.commit;
  };

  nvimPlugins =
    assert lib.assertMsg (nvimUnmapped == [ ])
      "toolbox/nvim-plugins.nix has no repo for: ${lib.concatStringsSep ", " nvimUnmapped}";
    pkgs.linkFarm "toolbox-nvim-plugins" (map
      (name: { inherit name; path = fetchNvimPlugin name; })
      (builtins.attrNames nvimLock));

  # Compiled tree-sitter parsers, laid out like nvim-treesitter's own install
  # dir: parser/<lang>.so plus parser-info/<lang>.revision. With both present
  # ensure_installed finds nothing to do and :TSUpdate sees them as current.
  # Revisions come from the locked plugin's lockfile.json, so parsers and
  # queries stay in step.
  tsLock = lib.importJSON "${fetchNvimPlugin "nvim-treesitter"}/lockfile.json";
  tsParsers = import ./treesitter-parsers.nix;
  # a tarball of the exact revision: some locked revisions are on no branch
  # fetchGit would look in, and the repos' history is large
  tsParserSrc = lang:
    let repo = lib.splitString "/" tsParsers.${lang}.repo; in
    builtins.fetchTree {
      type = "github";
      owner = builtins.elemAt repo 0;
      repo = builtins.elemAt repo 1;
      rev = tsLock.${lang}.revision;
    };

  tsParsersBuilt = pkgs.runCommandCC "toolbox-treesitter-parsers" { } ''
    mkdir -p $out/parser $out/parser-info
    ${lib.concatStrings (lib.mapAttrsToList (lang: p: ''
      src=${tsParserSrc lang}/${p.location or "."}/src
      $CC -shared -fPIC -Os -I$src $src/parser.c \
        $(test -e $src/scanner.c && echo $src/scanner.c) \
        -o $out/parser/${lang}.so
      echo ${tsLock.${lang}.revision} >$out/parser-info/${lang}.revision
    '') tsParsers)}
  '';

  seed = pkgs.runCommand "${imageName}-seed" { } ''
    mkdir -p $out/config $out/data/nvim $out/home/.bashrc.d $out/home/bin

    cp -RL ${nvimPlugins} $out/data/nvim/lazy

    cp -RL ${../dot_config/nvim} $out/config/nvim
    cp -RL ${../dot_config/lazygit} $out/config/lazygit
    cp -RL ${../dot_config/btop} $out/config/btop
    cp -RL ${../dot_config/ohmyposh} $out/config/ohmyposh
    cp -RL ${../dot_config/lf} $out/config/lf
    cp -L ${../dot_config/starship.toml} $out/config/starship.toml

    cp -L ${../dot_bashrc.d}/* $out/home/.bashrc.d/
    cp -L ${zshrc} $out/home/.zshrc
    cp -L ${tmuxConf} $out/home/.tmux.conf

    # chezmoi's executable_ prefix is not meaningful outside the source tree
    for f in ${../bin}/executable_*; do
      install -m755 "$f" $out/home/bin/"$(basename "$f" | sed 's/^executable_//')"
    done

    chmod -R u+w $out

    cp -RL ${tsParsersBuilt}/. $out/data/nvim/lazy/nvim-treesitter/
    chmod -R u+w $out/data/nvim/lazy/nvim-treesitter

    # btop.conf hardcodes color_theme as an absolute path from whichever host it
    # was written on, so inside the image it silently falls back to the default
    # theme. A bare name resolves against <config>/themes, which we do ship.
    sed -i -E 's|^(color_theme = ")[^"]*/([^"/]+)\.theme"|\1\2"|' $out/config/btop/btop.conf
  '';

  # --- entrypoint --------------------------------------------------------------

  entrypoint = pkgs.runCommand "${imageName}-entrypoint" { } ''
    mkdir -p $out/bin
    substitute ${./entrypoint.sh} $out/bin/${imageName} \
      --replace-fail '@shell@' '${pkgs.runtimeShell}' \
      --replace-fail '@name@' '${imageName}' \
      --replace-fail '@env@' '${env}' \
      --replace-fail '@seed@' '${seed}' \
      --replace-fail '@stamp@' "$(basename ${seed})" \
      --replace-fail '@cacert@' '${pkgs.cacert}' \
      --replace-fail '@localeArchive@' '${pkgs.glibcLocales}/lib/locale/locale-archive' \
      --replace-fail '@terminfo@' '${pkgs.ncurses}'
    chmod +x $out/bin/${imageName}
  '';

  appimage = mkAppImage {
    program = "${entrypoint}/bin/${imageName}";
    pname = imageName;
    name = "${imageName}.AppImage";
    # nix-appimage defaults to gzip; the type2 runtime links zstd, which is both
    # smaller and much faster to page in for an image this size.
    squashfsArgs = [ "-comp" "zstd" "-Xcompression-level" "19" ];
  };
  # --- sbom --------------------------------------------------------------------

  # The entrypoint's runtime closure is what the image ships, so vulncheck.sh
  # points sbomnix at it. The nvim plugins are the exception: seed copies them
  # out of the store, dropping the references, and they have no nix version
  # anyway. These CycloneDX components cover them, keyed by the locked commit.
  # The compiled tree-sitter parsers are copied the same way, so they are listed
  # here too.
  nvimSbomComponents = lib.mapAttrsToList
    (name: lock:
      let repo = nvimRepos.${name}; in {
        type = "library";
        bom-ref = "nvim-plugin:${name}";
        inherit name;
        version = lock.commit;
        purl = "pkg:github/${lib.toLower repo}@${lock.commit}";
        externalReferences = [{ type = "vcs"; url = "https://github.com/${repo}"; }];
        properties = [{ name = "lazy-lock:branch"; value = lock.branch; }];
      })
    nvimLock
  ++ lib.mapAttrsToList
    (lang: p:
      let rev = tsLock.${lang}.revision; in {
        type = "library";
        bom-ref = "treesitter-parser:${lang}";
        name = "tree-sitter-${lang}";
        version = rev;
        purl = "pkg:github/${lib.toLower p.repo}@${rev}";
        externalReferences = [{ type = "vcs"; url = "https://github.com/${p.repo}"; }];
      })
    tsParsers;
in
{
  inherit env seed entrypoint appimage paths nvimSbomComponents;
  name = imageName;
  groups = selected;
}
