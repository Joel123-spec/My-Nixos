# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, lib, ... }:

  let
    river-next = builtins.fetchTarball {
      url = "https://github.com/dmkhitaryan/river-next-nix-module/archive/refs/heads/stable.tar.gz";
    };
    
    home-manager = builtins.fetchTarball {
      url = "https://github.com/nix-community/home-manager/archive/refs/heads/release-26.05.tar.gz";
    };

    nixpkgsUnstable = builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    };
    
    pkgsUnstable = import nixpkgsUnstable {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };

  in
  {
    imports = [
      ./hardware-configuration.nix
      "${home-manager}/nixos"
      "${river-next}/river-module.nix"
    ];

  # Override from stable channel
  nixpkgs.overlays = [
   (final: prev: {
     zig = pkgsUnstable.zigPackages."0.17";
     wivrn = pkgsUnstable.wivrn;
    })
   ];

  # Experimental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  networking.hostName = "hybrid"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Services
  services.seatd.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Sound via pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # VR
  services.wivrn = {
    enable = true;
    openFirewall = true;
    package = pkgsUnstable.wivrn; # Reason for pulling the unstable wivrn is so it would match the same version as the headset quest 3
  };
   
  # Nvida
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Set a password with ‘passwd’.
  users.users."joel" = {
    isNormalUser = true;
    description = "joel";
    extraGroups = [ "networkmanager" "wheel" "video" "seat" "input" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true; 

  hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs; [
      micro
      firefox
      curl
      heroic
      libinput
      ## Packages for the desktop envirment
      python3 # strictly used for argen keybind hopfully changed soon (unaffiliated) https://codeberg.org/pkap/argen/pulls/31
      brightnessctl
      adwaita-icon-theme
      wl-clipboard
      wlr-randr
      wdisplays
      myxer # replaced pavucontrol
      i3status-rust
      i3bar-river
      fastfetch
      nvtopPackages.full
    ];

    programs.steam.enable = true; # Steam

  # River --environment setup
  
  # Fonts and icons
  fonts.packages = with pkgs; [
    font-awesome # Icons
    nerd-fonts.jetbrains-mono # Font
  ];
  
  # Login Manager
   services.displayManager.defaultSession = "river-argen";
   services.displayManager.ly.enable = true; # Login Manager

  # River
  programs.river-next = {
      enable = true;
      windowManagers = [ "argen" ];
  
      extraPackages = with pkgs; [
        foot
        fuzzel
        (pkgs.callPackage (import "${river-next}/default.nix").packages.channel { }) # magical leopardon
      ];
    };
    
  # configuration files
  home-manager.users = lib.genAttrs
    (lib.attrNames (lib.filterAttrs (n: v: v.isNormalUser) config.users.users))
      (username: {
        home.stateVersion = "26.05";
        home.file.".config/argen/init" = {
         executable = true;
         source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/Joel123-spec/My-Nixos/refs/heads/main/argen_init"; # Argen Init Config
         };
        };
      home.file.".config/i3bar-river/config.toml" = { 
        source = builtins.fetchurl {
         url = "https://raw.githubusercontent.com/Joel123-spec/My-Nixos/refs/heads/main/bar_config.toml"; # i3bar-river Config
         };
        };
      home.file.".config/river/config.rh" = { 
              source = builtins.fetchurl {
               url = "https://raw.githubusercontent.com/Joel123-spec/My-Nixos/refs/heads/main/channel_config.rh"; # MOUSE CONFIG (took awhile)
               };
              };
      home.file.".config/i3status-rust/config.toml" = {
        source = builtins.fetchurl {
         url = "https://raw.githubusercontent.com/Joel123-spec/My-Nixos/refs/heads/main/status_config.toml"; # i3status-rust Config
         };
        };
      });
 

  # End of River --environment setup
  
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
