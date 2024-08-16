# My NixOs config

personal setup with a flake and home-manager, deploying secrets with sops-nix.

## TO-DOs:

- better neovim integratoin
  - auto fetch github repo for lua part (plugins, lsps, etc)?
  - or configure everythin in nix?
  - nixvim seems out of the question
  - systemPackages vs userPackages
- NH the nix helper (vimjoyer)
- zfs backup for laptop via tailscale after some data clean up
- better modularization like vimjoyer
- disko
- check sops required keys on all machines: "Failed to get the data key required to decrypt the SOPS file."
- systemd-boot for non dual boot devices

## Home Lab ideas

- sync firefox tabs
- photoprism?
- fritz.home reverse proxy
- openbooks?
- maybes: deluge, sonarr, homeassistant, arr suit, navidrome, paperless, immich
- graphana loki
- HEADSCALE?
- remove node source in prometheus scraper ?? maybe not necessary

## Documentation

1. [Initial partitioning and formating the drive with zfs](#initial)
2. [Sanoid and Syncoid](#Sanoid)
3. [Nextcloud](#Nextcloud)

### Initial partitioning and formating the drive with zfs <a name="inital"></a>

---

- full credit to https://github.com/mcdonc/p51-thinkpad-nixos/blob/zfsvid/README.rst

- Partition and format the drive:

- `sudo sgdisk --zap-all /dev/nvme0n1`

- `sudo fdisk /dev/nvme0n1`, then:

```bash
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
```

- No swap partition (huge amount of memory, also security)

- Create the boot volume:

```bash
  sudo mkfs.fat -F 32 /dev/nvme0n1p1
  sudo fatlabel /dev/nvme0n1p1 NIXBOOT
```

- Create a zpool:

```bash
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
```

- Create zfs volumes::

```bash
  sudo zfs create -o mountpoint=legacy NIXROOT/root
  sudo zfs create -o mountpoint=legacy NIXROOT/home
  # reserved to cope with running out of disk space
  sudo zfs create -o refreservation=1G -o mountpoint=none NIXROOT/reserved
```

- `sudo mount -t zfs NIXROOT/root /mnt`
- Mount subvolumes:

```bash
  sudo mkdir /mnt/boot
  sudo mkdir /mnt/home
  sudo mount /dev/nvme0n1p1 /mnt/boot
  sudo mount -t zfs NIXROOT/home /mnt/home
```

### Sanoid and Syncoid <a name="Sanoid"></a>

---

fully based on: https://github.com/mcdonc/.nixconfig/blob/master/videos/zfsremotebackups/script.rst

backup target is home-server (omhe) and backup source is eg desktop (rainbow, with data to be backed up).

prerequisites:

- ssh key passphraseless generated via `ssh-keygen` and then deployed via sops:

```nix
# hosts/omhe/sanoid-backup-target.nix

sops.secrets."ssh/keys/backup" = {
      mode = "0600";
      path = "/var/lib/syncoid/backup"; # key need to be on this location, if this directory doesnt exist yet: i think it gets created when syncoid is either installed or maybe when it attempts to sync at least one source
      owner = "syncoid"; # key is for the syncoid user, if this is not set there are permission issues
    };
```

- on the source machine (rainbow) set up a backup user:

```nix
# hosts/rainbow/sanoid-backup-source.nix

  users.users.backup = {
    isNormalUser = true;
    createHome = false;
    home = "/var/empty";
    extraGroups = [ ];
    openssh = {
      authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMg2AFhpk8nsyxXSRLnSaEWXDQFQzCEsw+TsQsK/Hi9U fschn@rainbow''
      ];
    };
  };
```

- On your source system (rainbow), give some ZFS permissions to the backup user on the dataset that you want to back up. These are necessary for syncoid to do its job:

```bash
sudo zfs allow backup compression,hold,send,snapshot,mount,destroy NIXROOT/home
```

- for backup target (omhe):

```nix
# hosts/omhe/configuration.nix

# dont ask for "tank/rainbow-backup" credentials at boot
boot.zfs.requestEncryptionCredentials = lib.mkForce [ "NIXROOT" ];
```

- Finally on the target system(omhe) configure a `services.syncoid` to pull from the source system dataset `NIXROOT/home` in `hosts/omhe/sanoid-backup-target.nix`, and a 'services.sanoid' to keep around historical snapshots. The dataset I'm backing up to is 'tank/rainbow-backup' and this can not exist before syncoid and sanoid services inital run as they create it automatically and throw an error otherwise.

- On the source system (rainbow), configure a `services.sanoid` in `hosts/rainbow/sanoid-backup-source.nix` to keep around a few historical datasets.

### Nextcloud <a name="Nextcloud"></a>

---

- prerequesite for `home = "/mnt/Nextcloud-test";` :

```bash
sudo zfs create NIXROOT/Nextcloud
sudo zfs set mountpoint=/mnt/Nextcloud tank/Nextcloud
```

- to avoid `nexcould version is marked insecure` error, specify nextcloud package:

```nix
    services.nextcloud.package = pkgs.nextcloud29;
```
