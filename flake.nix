{
  description = "go-stop dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # node environment
        frontend = pkgs.buildNpmPackage {
          name = "frontend";
          src = ./frontend;

          npmDepsHash = "sha256-CHL+b1fh7yE7Ln98/2tcj9r6CQagV7PK6HbHloI+Puw="; # Replace this!
          installPhase = ''
            mkdir -p $out
            cp -r dist/* $out/
          '';

          buildPhase = ''
            export NODE_OPTIONS=--openssl-legacy-provider
            npm run build
          '';
        };

        # flask environment
        pythonEnv = pkgs.python3.withPackages (
          ps: with ps; [
            flask
            flask-cors
            pyjwt
            bcrypt
            gunicorn
            pandas
            scipy
            matplotlib
          ]
        );

      in
      {

        devShells.default = pkgs.mkShell {
          name = "fullstack-dev-shell";
          buildInputs = [
            pkgs.sqlitebrowser
            pkgs.nodejs_20
            pythonEnv
            frontend
            pkgs.gcc-unwrapped
            pkgs.libz
            pkgs.stdenv.cc.cc.lib
          ];
        };
      }
    );
}
