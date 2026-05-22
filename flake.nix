{
  description = "A basic flake with a shell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };
      packageIf = name: packageDef:
        if builtins.hasAttr name inputs
        then [(packageDef inputs.${name})]
        else [];
    in {
      devShell = let
        rust_bin =
          pkgs.rust-bin.stable.latest.default;
      in
        pkgs.mkShell {
          packages = [rust_bin pkgs.cargo-workspaces];

          shellHook = ''
            export RUST_STD="${rust_bin}/share/doc/rust/html/std/index.html"
          '';
        };
    });
}
