{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };

      system = "x86_64-linux";
      app = "game";

      shellInputs = with pkgs; [
        (rust-bin.nightly.latest.default.override { extensions = [ "rust-src" ]; })
        clang
      ];
      appNativeBuildInputs = with pkgs; [
        pkg-config
      ];
      appBuildInputs = appRuntimeInputs ++ (with pkgs; [
        udev alsaLib x11 libGL
        vulkan-tools vulkan-headers vulkan-validation-layers
      ]);
      appRuntimeInputs = with pkgs; [
        vulkan-loader
        xlibs.libXcursor xlibs.libXi xlibs.libXrandr
      ];
    in
    {
      devShells.${system}.${app} = pkgs.mkShell {
        nativeBuildInputs = appNativeBuildInputs;
        buildInputs = shellInputs ++ appBuildInputs;

        shellHook = ''
          export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath appRuntimeInputs}"
        '';
      };
      devShell.${system} = self.devShells.${system}.${app};

      checks.${system}.build = self.packages.${system}.${app};
    };
}
