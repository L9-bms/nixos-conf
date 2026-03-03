# installation process

## disko

<https://github.com/nix-community/disko/blob/master/docs/quickstart.md>

write `hosts/<hostname>/disk-config.nix` and import in `hosts/<hostname>/default.nix`

find boot drive in `/dev/disk/by-id`

```bash
curl .../nixos-conf/raw/refs/heads/main/hosts/.../disk-config.nix -Lo /tmp/disk-config.nix
vim /tmp/disk-config.nix # set boot drive accordingly
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix
```

## hardware-configuration.nix

generate new hardware config:

```bash
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

remote fileSystem configs

add entry to `flake.nix` for new machine, create `hosts/<hostname>/configuration.nix` and import `./hardware-configuration.nix`

## install config

```bash
nix-shell -p git
git clone .../nixos-config /mnt/etc/nixos/config
# or git clone .../nix-config /persist/nixos-conf, etc.
sudo nixos-install --flake /mnt/etc/nixos/config#<hostname>
```

## copy secrets, passwords, etc.
