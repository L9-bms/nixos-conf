# installation process

## hardware-configuration.nix

generate new hardware config:

```bash
nixos-generate-config --show-hardware-config
```

write to `hosts/<hostname>/hardware-configuration.nix` (without fileSystems)

add entry to `flake.nix` for new machine, create `hosts/<hostname>/default.nix`

import hardware config in `hosts/<hostname>/default.nix`

## disko

<https://github.com/nix-community/disko/blob/master/docs/quickstart.md>

write `hosts/<hostname>/disk-config.nix` and import in `hosts/<hostname>/default.nix`

find boot drive in `/dev/disk/by-id`

```bash
curl .../nixos-conf/raw/refs/heads/main/hosts/.../disk-config.nix -o /tmp/disk-config.nix
vim /tmp/disk-config.nix # set boot drive accordingly
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix
```

## install config

```bash
nix-shell -p git
git clone .../nixos-config /mnt/etc/nixos/config
sudo nixos-install --flake /mnt/etc/nixos/config#<hostname>
```

can move configuration to home directory if desired
