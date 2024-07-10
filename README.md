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

### Initial ZFS setup

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
