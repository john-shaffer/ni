# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Specify the encrypted disk
  boot.initrd.luks.devices.root = {
    device = "##device##2";
    preLVM = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking setup
  networking.hostName = "##username##";

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Root password
  users.users.root.initialHashedPassword = "##rootpasswd##";

  nix = {
    autoOptimiseStore = true;
    extraOptions = ''
      keep-derivations = true
      keep-outputs = true
    '';
  };

  # Allow unfree proprietary packages such as spotify or vscode
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    jmtpfs
    # System utilities
    ark
    git
    usbutils
    unzip
    vim
    wget
    # Gnome specifics and utilities
    gnome.gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnomeExtensions.tray-icons-reloaded
  ];

  environment.gnome.excludePackages = with pkgs; [ gnome.geary ];

  # Enabling unfree packages, adding unstable channel to be able to install latest packages as user
  environment.interactiveShellInit = ''
    if [ ! -f ~/.config/nixpkgs/config.nix ]
      then
        mkdir -p ~/.config/nixpkgs/
        echo  '{ allowUnfree = true; }' > ~/.config/nixpkgs/config.nix
    fi
  '';

  # Enable BT
  hardware.bluetooth.enable = true;

  # Enable pulseaudio with BT support
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services.cron = { enable = true; };

  # Limit journal size
  services.journald = { extraConfig = "SystemMaxUse=500M"; };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "grp:win_space_toggle";
  };

  # Enable touchpad support.
  # It is needed to explicitly disable libinput if we want to use synaptics
  services.xserver.libinput.enable = false;

  # Enable Lenovo/IBM touchpad support
  services.xserver.synaptics.enable = true;

  # Enable for Gnome Desktop Environment
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."##username##" = {
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    home = "/home/##username##/";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "25.05"; # Did you read the comment?

}
