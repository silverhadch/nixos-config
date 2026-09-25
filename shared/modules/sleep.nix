{ lib, ... }:

let
  sleepServices = [
    "systemd-suspend"
    "systemd-hibernate"
    "systemd-hybrid-sleep"
    "systemd-suspend-then-hibernate"
  ];
in
{
  # Since systemd 256, going to sleep first freezes user.slice (all of your
  # session's processes). If anything in there doesn't freeze in time (Plasma,
  # a FUSE mount like MEGAsync, a process stuck on ClamAV's on-access scan...)
  # you get "Failed to freeze unit 'user.slice'" and the machine either doesn't
  # suspend or comes back frozen. Skip that step; the kernel still freezes
  # every task itself, like it always did.
  systemd.services = lib.genAttrs sleepServices (_: {
    environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  });

  # Hibernation (Ruhezustand): no resume= / resume_offset= needed. With the
  # systemd initrd (boot.nix) systemd stores where the image lives in the EFI
  # variable HibernateLocation, and the initrd resumes from it after you've
  # unlocked LUKS. Needs the persistent swapfile from swap.nix.
}
