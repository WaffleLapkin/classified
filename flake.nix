{
  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-unstable";
    naersk.url       = "github:nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, naersk, systems }:
      let 
       
        forAllSystems =
          function:
          nixpkgs.lib.genAttrs (import systems) (
            system: function nixpkgs.legacyPackages.${system}
          );
      in rec {
        packages = forAllSystems (pkgs: rec {
          classified = naersk.lib.${pkgs.stdenv.hostPlatform.system}.buildPackage {
            pname = "classified";
            root = ./.;
            postInstall = ''
              mkdir -p $out/share/{bash-completion/completions,zsh/site-functions,fish/vendor_completions.d}
              $out/bin/classified completions bash > $out/share/bash-completion/completions/classified.bash
              $out/bin/classified completions zsh > $out/share/zsh/site-functions/_classified
              $out/bin/classified completions fish > $out/share/fish/vendor_completions.d/classified.fish
            '';
          };
          default = classified;
        });
        
        # apps.${packageName} = packages.${packageName};
        # defaultApp = apps.${packageName};

        nixosModules.default = import ./module.nix;

        # devShell = pkgs.mkShell {
        #   buildInputs = with pkgs; [
        #     rustc
        #     cargo
        #     clippy
        #     rustfmt
        #     rust-analyzer
        #   ];
        # };
      };
}
