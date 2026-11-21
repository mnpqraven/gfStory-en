{
  description = "gfStory-en, a Girls' Frontline cutscene simulator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      deps =
        pkgs: with pkgs; [
          git
          python312
          uv
          ffmpeg
          zip
          pngquant
          imagemagick
          nodejs_22
          pnpm_10
          libb2
          vgmstream
          ncurses
        ];

      shellEnv = pkgs: {
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
          pkgs.libb2
        ];
        UV_PYTHON = "${pkgs.python312}/bin/python3.12";
        UV_PYTHON_DOWNLOADS = "never";
      };
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.writeShellApplication {
          name = "gfstory-build";
          runtimeInputs = deps pkgs;
          runtimeEnv = shellEnv pkgs;
          text = ''
            cd "$(git rev-parse --show-toplevel)"
            exec bash ./build.sh
          '';
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = deps pkgs ++ [ pkgs.just ];
          env = shellEnv pkgs;
        };
      });
    };
}
