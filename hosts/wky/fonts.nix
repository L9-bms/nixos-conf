{ pkgs, ... }:

let
  comic-mono-nf = pkgs.callPackage ../../packages/fonts/comic-mono-nf { };
  ioskeley-mono = pkgs.callPackage ../../packages/fonts/ioskeley-mono { };
  bitmap-fonts = pkgs.callPackage ../../packages/fonts/personal-bitmap-fonts { };
in
{
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      # standard fonts
      noto-fonts
      cantarell-fonts
      liberation_ttf
      inter

      # monospace fonts
      monaspace
      nerd-fonts.jetbrains-mono
      nerd-fonts.recursive-mono
      comic-mono-nf
      ioskeley-mono

      # bitmap fonts
      terminus_font
      bitmap-fonts
    ];
    fontconfig = {
      enable = true;
      allowBitmaps = true;

      defaultFonts = {
        monospace = [ "Ioskeley Mono" ];
        sansSerif = [ "Inter" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
}
