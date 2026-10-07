{
  description = "adam's dotfiles + a portable debug toolbox AppImage built from them";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-appimage = {
      url = "github:ralismark/nix-appimage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix-appimage }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;

        tools = import ./toolbox/tools.nix { inherit pkgs; };

        # profile = "k8s", or groups = [ "base" "net" ] for an ad-hoc mix
        mkToolbox = args: import ./toolbox/toolbox.nix (args // {
          inherit pkgs;
          mkAppImage = nix-appimage.lib.${system}.mkAppImage;
        });

        # one package per profile: core is `.#toolbox`, the rest `.#toolbox-<name>`
        byProfile = lib.mapAttrs'
          (profile: _:
            let tb = mkToolbox { inherit profile; }; in
            lib.nameValuePair tb.name tb.appimage)
          tools.profiles;

        core = mkToolbox { profile = "core"; };
      in
      {
        packages = byProfile // {
          default = core.appimage;

          # handy for poking at the contents without building an image
          toolbox-env = core.env;
          toolbox-seed = core.seed;
        };

        # ad-hoc mixes, see toolbox/build.sh:
        #   ((builtins.getFlake "path:.").lib.${builtins.currentSystem}.mkToolbox { groups = [ "base" "net" ]; }).appimage
        lib = { inherit mkToolbox; inherit (tools) profiles; };
      });
}
