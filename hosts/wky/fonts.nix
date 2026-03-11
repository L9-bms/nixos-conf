{ pkgs, ... }:

let
  comic-mono-nf = pkgs.callPackage ../../packages/comic-mono-nf.nix { inherit pkgs; };
in
{
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
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.comic-shanns-mono
      comic-mono-nf
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "ComicMonoNF" ];
        sansSerif = [ "ComicMonoNF" ];
        serif = [ "ComicMonoNF" ];
      };
    };
  };
}
