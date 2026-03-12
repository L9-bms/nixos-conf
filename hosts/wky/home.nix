{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  home.username = "callum";
  home.homeDirectory = "/home/callum";
  programs.git.enable = true;
  home.stateVersion = "25.11";

  programs.dank-material-shell = {
    enable = true;

    niri = {
      enableSpawn = true;
      includes.enable = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    settings = {
      user.name = config.home.username;
      user.email = "mail@callumwong.com";
    };
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
  };

  programs.foot = {
    enable = true;
    server.enable = true;

    settings = {
      main = {
        include = "${config.home.homeDirectory}/.config/foot/dank-colors.ini";
        term = "xterm-256color";
        font = "ComicMonoNF:size=11";
        pad = "4x4";
      };

      scrollback.lines = "16384";
      csd.preferred = "none";
    };
  };

  fonts.fontconfig.enable = true;

  programs.vscode.enable = true;
  programs.neovim = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    mise.enable = true;
    enableFishIntegration = true;
  };

  programs.fish.enable = true;

  programs.mise = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-conf/hosts/wky/configs/nvim";
  };

  home.packages = with pkgs; [
    ripgrep
  ];
}
