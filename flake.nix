{
  description = "Standalone build of jq";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    unpins-lib.url = "github:unpins/nix-lib/v1";
  };

  outputs = { self, nixpkgs, unpins-lib }:
    let
      lib = nixpkgs.lib;
      ulib = unpins-lib.lib;

      pkgsFor = system: import nixpkgs { inherit system; };

      mkNative = system:
        let pkgs = pkgsFor system;
        in ulib.packageWithMan pkgs "jq" pkgs.pkgsStatic.jq;

      mkWindows = buildSystem:
        let
          # allowUnsupportedSystem: jq's meta.platforms doesn't list mingw.
          pkgs = import nixpkgs {
            system = buildSystem;
            config.allowUnsupportedSystem = true;
          };
          cross = pkgs.pkgsCross.mingwW64;
          jqStandalone = ulib.mingwStandalone {
            pkg = cross.jq;
            staticDeps = { oniguruma = ulib.staticOnlyAuto cross.oniguruma; };
            extraInputs = [ cross.windows.pthreads ];
            extraOverrides = _: {
              # nixpkgs' jq hard-codes the binary name as "jq" in postFixup;
              # on MinGW it is "jq.exe". Without this fix, remove-references-to
              # gets an empty file list and sed bails with "no input files".
              postFixup = ''
                remove-references-to \
                  -t "$dev" -t "$man" -t "$doc" \
                  "$bin/bin/jq.exe"
              '';
            };
          };
        in
        pkgs.symlinkJoin {
          name = "jq-${jqStandalone.version}";
          paths = [ jqStandalone.bin jqStandalone.man ];
          passthru = { inherit (jqStandalone) version pname; };
        };
    in
    {
      # Native builds: pkgsStatic on Linux yields a fully static musl binary;
      # on Darwin libSystem stays dynamic (Apple constraint), but everything
      # else is linked statically.
      packages = lib.recursiveUpdate
        (ulib.forAllNative (system: { default = mkNative system; }))
        {
          # Windows cross-compile via MinGW-w64. Produces a PE/COFF .exe
          # whose only imports are system DLLs (KERNEL32, MSVCRT, ...).
          # Built on x86_64-linux runners; the resulting .exe runs on any
          # Windows x86_64 host without a /nix/store or MSYS environment.
          x86_64-linux."windows-x86_64" = mkWindows "x86_64-linux";
        };

      apps = ulib.forAllNative (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/jq";
        };
      });
    };
}
