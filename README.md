# My NixOs config

personal setup with flakes and home-manager, deploying secrets with sops-nix.

## TO-DOs:

### Bugs

- nextcloud cospend error msg: `Failed to get projects: failure 500 Internal Server Error`
- signal crashed several times since latest update -> check logs
- check sops required keys on all machines: "Failed to get the data key required to decrypt the SOPS file."

### Minor Features

- systemd-boot for non dual boot devices
- zfs backup for laptop via tailscale
- better structure for monitoring files

### Major Features

- zed as nvim replacement ?????????
- NH the nix helper (vimjoyer)
- better modularization like vimjoyer
- disko

### Home lap

- sync firefox tabs
- fritz.home reverse proxy
- deluge, paperless
- maybes: sonarr, homeassistant, arr suit, navidrome, immich, photoprism?
- HEADSCALE!!
- https://github.com/tailscale/tailscale/tree/main/cmd/nginx-auth
- restic off-site backup with hetzner storage box or backblaze
- git archive
- prometheus exporters and dashboards for:
  - snmp
  - fritzbox_exporter
  - smokeping
  - nextcloud
  - node exporter for windows?
  - restic (once offsite backup is done)

### Other

- update list of packaged apps on wiki.nixos.org/nextcloud page

## Documentation

1. [Initial partitioning and formating the drive with zfs](#initial)
2. [Sanoid and Syncoid](#Sanoid)
3. [Setup of hdds](#hdds)
4. [Nextcloud](#Nextcloud)
5. [Auto unlock gnome keyring](#keyring)
6. [Troubleshooting](#trouble)

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

### Setup of hdds <a name="hdds"></a>

---

```bash
sudo zpool create tank raidz1 sdb sdc sdd -O compression=lz4  -o autotrim=on -O encryp
tion=aes-256-gcm -O keylocation=prompt  -O keyformat=passphrase
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
sudo zfs create tank/Nextcloud
sudo zfs set mountpoint=/tank/Nextcloud tank/Nextcloud
```

- to avoid `nexcould version is marked insecure` error, specify nextcloud package:

```nix
    services.nextcloud.package = pkgs.nextcloud29;
```

- prometheus nextcloud-exporter prerequesite:

```bash
# Generate random value (for example using openssl)
TOKEN=$(openssl rand -hex 32)
# Set token (using the occ console application)
nextcloud-occ config:app:set serverinfo token --value "$TOKEN"
```

### Auto unlock gnome keyring <a name="keyring"></a>

---

needed for protonmail-bridge and nextclould-client. First:

```nix
# modules/gnome.nix

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  programs.seahorse.enable = true; # installing gui
```

Then from [reddit](https://www.reddit.com/r/NixOS/comments/1c225c8/gnome_keyring_is_not_unlocked_upon_boot/?rdt=40009):

> This is extremely non obvious, but if you want to have autologin unlock your gnome keyring on startup, the keyring needs to have a blank password.
>
> I actually don't remember where I read this, I just have this as a comment in my config. I do remember spending hours trying to figure out wtf it wasn't working though.
>
> I can't speak to the security implications of this. I autologin on my laptop, because my "login" is the ZFS passphrase prompt to decrypt the drives, so that isn't really a concern for me.

Changing the keyring password with seahorse to blank, and voilà it works. If that doesnt work, creating a new keyring with a blank password (while keeping the old one with all the password) seems to do the trick.

### Troubleshooting <a name="trouble"></a>

---

#### Switching bootloader from grub to systemd-boot

> could not find any previously installed systemd-boot

run `sudo bootctl install`

> not enough space on /boot

based on https://discourse.nixos.org/t/what-to-do-with-a-full-boot-partition/2049/10

> 1.  Do a sudo nixos-rebuild build so that you’re sure that the build of your current configuration can be carried out
> 2.  Do a garbage collection to remove old system generations with sudo nix-collect-garbage -d
> 3.  Manually make some space in boot. Find your kernels and rm them.
> 4.  Run sudo nixos-rebuild switch or sudo nixos-rebuild boot. This time your bootloader will be installed correctly along with the new kernel and initrd
> 5.  Make sure point 4 was executed correctly by looking at the output and reboot
> 6.  [optional] remove the result directory created by point 1
