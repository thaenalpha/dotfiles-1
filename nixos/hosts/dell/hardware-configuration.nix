{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  boot = {
    initrd.availableKernelModules =
      [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelParams = [
      # HACK Disables fixes for spectre, meltdown, L1TF and a number of CPU
      #      vulnerabilities. Don't copy this blindly! And especially not for
      #      mission critical or server/headless builds exposed to the world.
      "mitigations=off"
    ];

    # Refuse ICMP echo requests on my desktop/laptop; nobody has any business
    # pinging them, unlike my servers.
    kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  };

  # Modules
  modules.hardware = {
    audio.enable = true;
    fs = {
      enable = true;
      ssd.enable = true;
    };
    bluetooth.enable = true;
    hibernate.enable = true;
  };

  # CPU
  nix.settings.max-jobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = true;

  # Displays
  services.xserver = {
    # Read a comment at hosts/kuro/hardware-configuration.nix.
    monitorSection = ''
      VendorName  "Unknown"
      ModelName   "DELL E2316H"
      HorizSync   30.0  - 113.0
      VertRefresh 56.0  - 86.0
      Option      "DPMS"
    '';
    screenSection = ''
      Option "metamodes" "VGA-0: 1920x1080_60 +1920+0, DP-1: 1920x1080_75 +0+0"
      Option "SLI" "Off"
      Option "MultiGPU" "Off"
      Option "BaseMosaic" "off"
      Option "Stereo" "0"
    '';
  };

  # Storage
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/96150b1a-fb21-448a-b83f-0b2e43d81b76";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/8C12-C9E6";
      fsType = "vfat";
    };
  };
  swapDevices =
    [{ device = "/dev/disk/by-uuid/7525580a-fa32-4f04-87f4-4f2b2a2572cb"; }];
  zramSwap.enable = true;
}
