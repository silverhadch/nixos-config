{ config, ... }:

{
  boot = {
    extraModprobeConfig = "options kvm_intel nested=1";
  };
}
