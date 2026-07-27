# overlays.nix
[
  ################################################################################
  # Bottles overlay
  ################################################################################
  (self: super: {
    bottles = super.bottles.override { removeWarningPopup = true; };
  })
]
