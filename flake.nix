{
  description = "Standalone build of jq";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "jq";
      # Three things upstream nixpkgs doesn't do for jq on mingw:
      # - winpthreads in buildInputs (mingw-w64 ships it separately; jq #includes <pthread.h>).
      # - LDFLAGS=-all-static: windows.pthreads ships .a + .dll.a; without it libtool picks
      #   .dll.a and the DLL-link hook copies libwinpthread.dll next to jq.exe.
      # - postFixup: nixpkgs jq.nix hard-codes `$bin/bin/jq`; on mingw it's jq.exe.
      windowsBuild = pkgs:
        let cross = unpins-lib.lib.mingwStaticCross pkgs; in
        cross.jq.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ cross.windows.pthreads ];
          makeFlags = (old.makeFlags or [ ]) ++ [ "LDFLAGS=-all-static" ];
          postFixup = ''
            remove-references-to \
              -t "$dev" -t "$man" -t "$doc" \
              "$bin/bin/jq.exe"
          '';
        });
    };
}
