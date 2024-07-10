# My NixOs config

personal setup with a flake and home-manager, deploying secrets with sops-nix.

## TO-DOs:

- better neovim integratoin
  - auto fetch github repo for lua part (plugins, lsps, etc)?
  - or configure everythin in nix?
  - nixvim seems out of the question
  - systemPackages vs userPackages
- NH the nix helper (vimjoyer)
- documentation:
  - zfs backup
  - zfs setup (see videos)
- zfs backup for laptop via tailscale after some data clean up
- next cloud
- zfs backup:
  - sanoid more frequent, every 15 mins
  - syncoid less frequent, every 6 hours eg
- HEADSCALE?
- better modularization like vimjoyer

## Documentation

### Initial partitioning and formating the drive with zfs

- `sudo sgdisk --zap-all /dev/nvme0n1`

- `sudo fdisk /dev/nvme0n1`, then::

  g
  n
  accept default part num
  accept default first sector
  last sector: +2G
  t
  use partiton type 1 (EFI System)
  n
  accept default partition number
  accept default first sector
  accept default last sector
  w

- No swap partition (huge amount of memory, also security)

- Create the boot volume::

  sudo mkfs.fat -F 32 /dev/nvme0n1p1
  sudo fatlabel /dev/nvme0n1p1 NIXBOOT

- Create a zpool::

  sudo zpool create -f \
   -o altroot="/mnt" \
   -o ashift=12 \
   -o autotrim=on \
   -O compression=lz4 \
   -O acltype=posixacl \
   -O xattr=sa \
   -O relatime=on \
   -O normalization=formD \
   -O dnodesize=auto \
   -O sync=disabled \
   -O encryption=aes-256-gcm \
   -O keylocation=prompt \
   -O keyformat=passphrase \
   -O mountpoint=none \
   NIXROOT \
   /dev/nvme0n1p2

- Create zfs volumes::

  sudo zfs create -o mountpoint=legacy NIXROOT/root
  sudo zfs create -o mountpoint=legacy NIXROOT/home

  # reserved to cope with running out of disk space

  sudo zfs create -o refreservation=1G -o mountpoint=none NIXROOT/reserved

- `sudo mount -t zfs NIXROOT/root /mnt`
- Mount subvolumes::
  sudo mkdir /mnt/boot
  sudo mkdir /mnt/home
  sudo mount /dev/nvme0n1p1 /mnt/boot
  sudo mount -t zfs NIXROOT/home /mnt/home

### Sanoid and Syncoid

### Nextcloud

prerequesite for `home = "/mnt/Nextcloud-test";` :

```bash
sudo zfs create NIXROOT/Nextcloud-test
sudo zfs set mountpoint=/mnt/Nextcloud-test NIXROOT/Nextcloud-test
```

to avoid `nexcould version is marked insecure` error, specify nextcloud package:

```nix
    services.nextcloud.package = pkgs.nextcloud29;
```

TODO: make available on vpn only with custom url
