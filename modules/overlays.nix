{ ... }:

{
  nixpkgs.overlays = [
    # SpamAssassin's SSL tests flake in Calamares' sandbox and fail the
    # Evolution build. Skip them.
    (final: prev: {
      spamassassin = prev.spamassassin.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
