# Evaluate with the same nixpkgs source as the flake. This checks membership,
# not a successful build or execution of the tools.
{ nixpkgs, flake ? import ../flake.nix }:
let
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; config.allowUnfree = false; };
  outputs = flake.outputs {
    self = {};
    inherit nixpkgs;
    bend.packages.${system}.bend = null;
  };
  included = map toString (builtins.concatLists
    (map (output: output.paths) outputs.packages.${system}.web.chosenOutputs));
  required = [ pkgs.typescript pkgs.eslint pkgs.prettier ];
in
assert builtins.all (package: builtins.elem (toString package) included) required;
true
