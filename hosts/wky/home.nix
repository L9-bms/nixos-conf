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

  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        import = [ "~/.config/alacritty/dank-theme.toml" ];
      };
      font = {
        size = 11;
        normal = {
          family = "Lilex Nerd Font";
          style = "Regular";
        };
      };
      window = {
        padding = {
          x = 4;
          y = 4;
        };
        decorations = "None";
      };
    };
  };

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

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  home.packages = with pkgs; [
    ripgrep
  ];
}
