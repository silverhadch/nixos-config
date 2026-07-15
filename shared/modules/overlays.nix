# overlays.nix
[
  ################################################################################
  # Bottles overlay
  ################################################################################
  (self: super: {
    bottles = super.bottles.override { removeWarningPopup = true; };
  })

  (final: prev: {
    bottles-unwrapped = prev.bottles-unwrapped.override {
      python3Packages = prev.python3Packages.overrideScope (pyfinal: pyprev: {
        patool = pyprev.patool.overridePythonAttrs (_: { doCheck = false; });
      });
    };
  })
]
