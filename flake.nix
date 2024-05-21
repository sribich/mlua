{
  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ { self, fenix, nixpkgs }: let
    system = "x86_64-linux";

    rustToolchain = fenix.packages.${system}.minimal.toolchain;
    rustPlatform = pkgs.makeRustPlatform {
      cargo = rustToolchain;
      rustc = rustToolchain;
    };

    mkPkgs = system:
      import inputs.nixpkgs {
        inherit system;
        overlays = [
          fenix.overlays.default
        ];
      };

    pkgs = mkPkgs system;
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        (pkgs.fenix.complete.withComponents [
          "cargo"
          "clippy"
          "rust-src"
          "rustc"
          "rustfmt"
          "llvm-tools-preview"
        ])
        rust-analyzer-nightly
      ];
    };
  };
}
