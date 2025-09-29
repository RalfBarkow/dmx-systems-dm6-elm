{
  description = "Elm development environment for dm6-elm (multi-arch)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          packages =
            (with pkgs; [
              # Node LTS (includes npm). Use nodejs_22 on newer channels if you prefer.
              nodejs_20

              # editors/tools
              nixfmt-rfc-style
              git curl cacert gnutar xz
            ]) ++ (with pkgs.elmPackages; [
              elm
              elm-format
              elm-language-server
              elm-test
              elm-review
            ]);

          shellHook = ''
            echo "🐢 Node: $(node -v)  npm: $(npm -v)"
            # Optional: enable Corepack so yarn/pnpm shims are available
            if command -v corepack >/dev/null 2>&1; then
              corepack enable >/dev/null 2>&1 || true
            fi
          '';
        };
      });
}
