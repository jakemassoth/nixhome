{ config, pkgs, lib, ... }:

{
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ vaapiVdpau ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.displayManager.sddm.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = let
      rcu_patch = pkgs.fetchpatch {
        url =
          "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
        hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
      };
    in config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "535.154.05";
      sha256_64bit = "sha256-fpUGXKprgt6SYRDxSCemGXLrEsIA6GOinp+0eGbqqJg=";
      sha256_aarch64 = "sha256-G0/GiObf/BZMkzzET8HQjdIcvCSqB1uhsinro2HLK9k=";
      openSha256 = "sha256-wvRdHguGLxS0mR06P5Qi++pDJBCF8pJ8hr4T8O6TJIo=";
      settingsSha256 = "sha256-9wqoDEWY4I7weWW05F4igj1Gj9wjHsREFMztfEmqm10=";
      persistencedSha256 =
        "sha256-d0Q3Lk80JqkS1B54Mahu2yY/WocOqFFbZVBh+ToGhaE=";

      #version = "550.40.07";
      #sha256_64bit = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
      #sha256_aarch64 = "sha256-AV7KgRXYaQGBFl7zuRcfnTGr8rS5n13nGUIe3mJTXb4=";
      #openSha256 = "sha256-mRUTEWVsbjq+psVe+kAT6MjyZuLkG2yRDxCMvDJRL1I=";
      #settingsSha256 = "sha256-c30AQa4g4a1EHmaEu1yc05oqY01y+IusbBuq+P6rMCs=";
      #persistencedSha256 = "sha256-11tLSY8uUIl4X/roNnxf5yS2PQvHvoNjnd2CB67e870=";

      patches = [ rcu_patch ];
    };
  };
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

  boot.extraModprobeConfig = "options nvidia " + lib.concatStringsSep " " [
    # nvidia assume that by default your CPU does not support PAT,
    # but this is effectively never the case in 2023
    "NVreg_UsePageAttributeTable=1"
    # This may be a noop, but it's somewhat uncertain
    "NVreg_EnablePCIeGen3=1"
    # This is sometimes needed for ddc/ci support, see
    # https://www.ddcutil.com/nvidia/
    #
    # Current monitor does not support it, but this is useful for
    # the future
    "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
    # When (if!) I get another nvidia GPU, check for resizeable bar
    # settings
  ];

  environment.variables = {
    # Necessary to correctly enable va-api (video codec hardware
    # acceleration). If this isn't set, the libvdpau backend will be
    # picked, and that one doesn't work with most things, including
    # Firefox.
    LIBVA_DRIVER_NAME = "nvidia";
    # Required to run the correct GBM backend for nvidia GPUs on wayland
    GBM_BACKEND = "nvidia-drm";
    # Apparently, without this nouveau may attempt to be used instead
    # (despite it being blacklisted)
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Hardware cursors are currently broken on nvidia
    WLR_NO_HARDWARE_CURSORS = "1";
    # Required to use va-api it in Firefox. See
    # https://github.com/elFarto/nvidia-vaapi-driver/issues/96
    MOZ_DISABLE_RDD_SANDBOX = "1";
    # It appears that the normal rendering mode is broken on recent
    # nvidia drivers:
    # https://github.com/elFarto/nvidia-vaapi-driver/issues/213#issuecomment-1585584038
    NVD_BACKEND = "direct";
    # Required for firefox 98+, see:
    # https://github.com/elFarto/nvidia-vaapi-driver#firefox
    EGL_PLATFORM = "wayland";
    GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
  };
}
