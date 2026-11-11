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

  in
  {
    imports = [
      ./hardware-configuration.nix
      "${home-manager}/nixos"
      "${river-next}/river-module.nix"
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
  services.power-profiles-daemon.enable = true;

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

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs; [
      micro
      firefox
      curl
      ## Packages for the desktop envirment
      python3
      brightnessctl
      adwaita-icon-theme
      wl-clipboard
      wlr-randr
      waybar
    ];
    
  # River --environment setup
  
  # Fonts
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];
  
  # Login Manager
   services.displayManager.defaultSession = "river-argen";
   services.displayManager.gdm.enable = true; # Login Manager

  # River
  programs.river-next = {
      enable = true;
      kanshi.enable = true;
      windowManagers = [ "argen" ]; # Window Manager

      extraPackages = with pkgs; [ # Packages
      foot 
      fuzzel
      kanshi 
      ];
    };

  # Init file for Argen
  # https://gitea.lupan.pl/lupan/dotfiles/src/commit/dbdfac823c38f0212c1708636c78a21f6d84b0a1/argen/.config/argen/init <-- Reference only (unaffiliated)
  home-manager.users = lib.genAttrs
   (lib.attrNames (lib.filterAttrs (n: v: v.isNormalUser) config.users.users))
   (username: {
    home.stateVersion = "26.05";
    home.file.".config/argen/init" = {
     executable = true;
     text = ''
#!/bin/sh

# Startup Applications
waybar & disown

# Terminal
argenctl binding set normal Super Return exec foot

# App Launcher
argenctl binding set normal Super D exec fuzzel

# Close Window
argenctl binding set normal Super+Shift Q window close

# Window focus and swap
argenctl binding set normal Super Left window focus prev
argenctl binding set normal Super Right window focus next
argenctl binding set normal Super+Shift Left window swap prev
argenctl binding set normal Super+Shift Right window swap next

argenctl binding set normal Super F window fullscreen
argenctl binding set normal Super W window float

# Audio controls
VOL_DEC="wpctl set-volume @DEFAULT_SINK@ --limit 1.5 5%-"
VOL_INC="wpctl set-mute @DEFAULT_SINK@ 0 && wpctl set-volume @DEFAULT_SINK@ --limit 1.5 5%+"
VOL_TOGGLE="wpctl set-mute @DEFAULT_SINK@ toggle"
for mode in normal locked; do
    argenctl binding set $mode Super Bracketleft sh "$VOL_DEC"
    argenctl binding set $mode Super Bracketright sh "$VOL_INC"
    argenctl binding set $mode Super+Shift M sh "$VOL_TOGGLE"
    argenctl binding set $mode None XF86AudioLowerVolume sh "$VOL_DEC"
    argenctl binding set $mode None XF86AudioRaiseVolume sh "$VOL_INC"
    argenctl binding set $mode None XF86AudioMute sh "$VOL_TOGGLE"
    argenctl binding set $mode None XF86MonBrightnessDown sh "brightnessctl s 5%-"
    argenctl binding set $mode None XF86MonBrightnessUp sh "brightnessctl s +5%"
    argenctl binding set $mode Super+Shift Bracketleft sh "brightnessctl s 5%-"
    argenctl binding set $mode Super+Shift Bracketright sh "brightnessctl s +5%"
done
       '';
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
