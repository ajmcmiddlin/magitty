{
  description = "Magit in your terminal.";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });
      ghcVersion = "ghc924";
    in
    {
      overlay = (final: prev: {
        magitty = final.haskell.packages.${ghcVersion}.callCabal2nix "magitty" ./. {};
      });
      packages = forAllSystems (system: {
         magitty = nixpkgsFor.${system}.magitty;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.magitty);
      checks = self.packages;
      devShell = forAllSystems (system:
        let haskellPackages = nixpkgsFor.${system}.haskell.packages.${ghcVersion};
        in haskellPackages.shellFor {
          packages = p: [self.packages.${system}.magitty];
          withHoogle = true;
          buildInputs = with haskellPackages; [
            haskell-language-server
            ghcid
            cabal-install
          ];
        # Change the prompt to show that you are in a devShell
        shellHook = "export PS1='\\e[1;34mdev > \\e[0m'";
        });
  };
}
