{ pkgs, ... }:

let
  comic-mono-nf = pkgs.callPackage ../../packages/comic-mono-nf.nix { };
  ioskeley-mono = pkgs.callPackage ../../packages/ioskeley-mono.nix { };
in
{
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      noto-fonts
      cantarell-fonts
      liberation_ttf
      inter
      monaspace
      nerd-fonts.jetbrains-mono
      nerd-fonts.recursive-mono
      comic-mono-nf
      ioskeley-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Ioskeley Mono" ];
        sansSerif = [ "Inter" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
}
