{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.nixosModules.niri
    inputs.dms.nixosModules.greeter
    ./hardware-configuration.nix
  ];

  boot.loader.limine.enable = true;

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lzo";
    memoryPercent = 50;
  };

  networking.hostName = "wky";
  networking.networkmanager.enable = true;
  #networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  services.tailscale.enable = true;

  programs.nix-ld.enable = true;

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.kernelModules = [ "wl" ];
  boot.kernel.sysctl."ibt" = "off";

  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "callum";
    dataDir = "/home/callum";
  };

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;

  nixpkgs.overlays = [
    inputs.niri.overlays.niri
    inputs.yazi.overlays.default
  ];

  programs.niri = {
    package = pkgs.niri-unstable;
    enable = true;
  };

  xdg.portal.enable = true;

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/callum";
  };

  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig."11-bluetooth-policy" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 32;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 32;
      };
    };
    extraConfig.pipewire-pulse."92-low-latency" = {
      "context.properties" = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = { };
        }
      ];
      "pulse.properties" = {
        "pulse.min.req" = "32/48000";
        "pulse.default.req" = "32/48000";
        "pulse.max.req" = "32/48000";
        "pulse.min.quantum" = "32/48000";
        "pulse.max.quantum" = "32/48000";
      };
      "stream.properties" = {
        "node.latency" = "32/48000";
        "resample.quality" = 1;
      };
    };
  };

  programs.fish.enable = true;
  documentation.man.cache.enable = false; # prevent extra long build times

  programs.kdeconnect.enable = true;

  users.users.callum = {
    isNormalUser = true;
    home = "/home/callum";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
    ];
  };

  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    foot
    adwaita-icon-theme
    nmap
    qalculate-gtk
    vesktop
    obsidian
    nautilus
    scrcpy
    android-tools
    blueman
    pavucontrol
    libreoffice-fresh
    xournalpp
    btop
    nixd
    nixfmt
    unzip
    kdePackages.okular
    (texliveBasic.withPackages (
      ps: with ps; [
        collection-xetex
        collection-latex
        collection-basic
        collection-luatex
        collection-binextra
        collection-fontutils
        collection-latexextra
        collection-bibtexextra
        collection-mathscience
        collection-plaingeneric
        collection-formatsextra
        collection-latexrecommended
        collection-fontsrecommended
      ]
    ))
    zellij
    wl-clipboard
    lua-language-server
    ncdu
    foliate
  ];

  programs.firefox = {
    enable = true;
    autoConfig = ''
      // Any comment. You must start the file with a single-line comment!
      var { classes: Cc, interfaces: Ci, utils: Cu } = Components;

      // Set new tab page
      try {
        ChromeUtils.importESModule(
          "resource:///modules/AboutNewTab.sys.mjs",
        ).AboutNewTab.newTabURL = "https://prism.tower.7sref";
      } catch (e) {
        Cu.reportError(e);
      } // report errors in the Browser Console

      // Auto focus new tab content
      try {
        const { BrowserWindowTracker } = ChromeUtils.importESModule(
          "resource:///modules/BrowserWindowTracker.sys.mjs",
        );
        const Services = globalThis.Services;
        Services.obs.addObserver((event) => {
          window = BrowserWindowTracker.getTopWindow();
          window.gBrowser.selectedBrowser.focus();
        }, "browser-open-newtab-start");
      } catch (e) {
        Cu.reportError(e);
      }
    '';
  };

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      cantarell-fonts
      hack-font
      inter
      jetbrains-mono
      liberation_ttf
      monaspace
      noto-fonts
      ubuntu-classic
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.lilex
      nerd-fonts.comic-shanns-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "ComicShannsMono Nerd Font" ];
        sansSerif = [ "ComicShannsMono Nerd Font" ];
        serif = [ "ComicShannsMono Nerd Font" ];
      };
    };
  };

  hardware.facetimehd.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.download-buffer-size = 524288000;
  nix.buildMachines = [
    {
      hostName = "acid";
      sshUser = "callum";
      system = "x86_64-linux";
      maxJobs = 6;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    }
  ];

  system.stateVersion = "25.11"; # no
}
