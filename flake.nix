{
  description = "Elm development environment for dm6-elm project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # or nixos-unstable for fresher versions
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-darwin"; # for your macOS machine
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs.elmPackages; [
          elm
          elm-format
          elm-language-server
        ];
      };
    };
}
