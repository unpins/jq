{
  description = "jq as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "jq";
      smoke = [ "--version" ];
      smokePattern = "^jq-[0-9]+\\.[0-9]+";

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        # The `.exe` on the engine too, not the nixpkgs mingw-gcc cross.
        windows = true;
        programs = [{ name = "jq"; }];
        # jq's build bakes the literal configure command line (autoconf
        # `$ac_configure_args` — `--prefix=/nix/store/…-jq-static-… --bindir=…`)
        # into the binary as build provenance. It's dead data (never a runtime
        # path lookup), but nix scans those store strings as references, so the
        # otherwise-0-ref static binary drags jq's own out/-bin outputs — and
        # their glibc/oniguruma closure — back in. Scrub the dead self-refs in
        # the final engine binary (remove-references-to → eee…-placeholder) so
        # the 0-ref invariant holds. `remove-references-to` on the base build
        # doesn't help: the engine re-links from bitcode that still carries the
        # string. grep et al. don't bake CONFIGURE_FLAGS, hence jq-specific.
        removeReferences = [ "jq-static" ];
      };

      # darwin: pkgsStatic.jq still builds `libjq.1.dylib` and libtool links the
      # `jq` binary against it; `dropSharedLibs` then deletes the dylib, leaving a
      # dangling dynamic ref the portability gate rejects. mkStandaloneFlake's
      # filterEnableStaticOnDarwin strips `--disable-shared` from configureFlags
      # (to stop `--enable-static` becoming `LDFLAGS=-static`), so push it back via
      # the bash `configureFlagsArray` — invisible to the Nix-list filter — the
      # same dodge curl/file use. Linux pkgsStatic suppresses the dylib already;
      # the array re-add is a harmless no-op there.
      build = pkgs:
        pkgs.pkgsStatic.jq.overrideAttrs (old: {
          preConfigure = (old.preConfigure or "") + ''
            configureFlagsArray+=("--disable-shared")
          '';
        });
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
          # On WIN32 jq calls its body `umain`: `wmain` widens argv to UTF-8 and
          # hands off to it, and -municode keeps `wmain` the real entry. Nothing
          # is then named `main`, which is the symbol an applet entry binds to.
          # Renaming the body restores that name and changes no behaviour —
          # `wmain` still runs first and still does the conversion.
          postPatch = (old.postPatch or "") + ''
            sed -i 's/\bumain\b/main/g' src/main.c
          '';
          # Scrub the dead baked store refs from jq.exe: the compiled-in
          # configure command line carries `--prefix=$out --bindir=$bin`
          # (plus the dev/man/doc dirs), so without $out/$bin here the .exe
          # keeps a live ref to jq's own out/-bin outputs and their closure —
          # the mingw mirror of the native `removeReferences = ["jq-static"]`.
          postFixup = ''
            remove-references-to \
              -t "$out" -t "$bin" -t "$dev" -t "$man" -t "$doc" \
              "$bin/bin/jq.exe"
          '';
        });
    };
}
