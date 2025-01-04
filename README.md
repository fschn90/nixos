# My NixOs config

personal setup with flakes and home-manager, deploying secrets with sops-nix.

## TO-DOs:

### Bugs
- check sops required keys on all machines: "Failed to get the data key required to decrypt the SOPS file."
- smartctl_exporter and scrutiny error logs
- spotify keeps redownloading saved songs when starting application every time
- helix does not yank into system clipboard

### Minor Features
- prometheus data on extra zfs dataset?
- persist deluge config
- auto login for user on headless machine

### Major Features
- NH the nix helper (vimjoyer)
- better modularization like vimjoyer
- disko

### Home lap
- immich
- HEADSCALE!!
- https://github.com/tailscale/tailscale/tree/main/cmd/nginx-auth
- restic off-site backup with hetzner storage box or backblaze
- git archive
- prometheus exporters and dashboards for:
  - dashboard monitoring sanoid and syncoid
  - alerting
  - restic (once offsite backup is done)

### Other
-


## Documentation

1. [Initial partitioning and formating the drive with zfs](#initial)
2. [Sanoid and Syncoid](#Sanoid)
3. [Setup of hdds](#hdds)
4. [Nextcloud](#Nextcloud)
5. [Auto unlock gnome keyring](#keyring)
6. [Jellyfin](#jellyfin)
7. [Deluge](#deluge)
8. [Firefox-syncserver](#firefox-syncserver)
9. [Syncthing](#syncthing)

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

# dont ask for "tank/rainbow-backup" credentials at boot, but have tank pool key loaded
boot.zfs.requestEncryptionCredentials = lib.mkForce [ "NIXROOT" "tank"];
```

- Finally on the target system(omhe) configure a `services.syncoid` to pull from the source system dataset `NIXROOT/home` in `hosts/omhe/sanoid-backup-target.nix`, and a 'services.sanoid' to keep around historical snapshots. The dataset I'm backing up to is 'tank/rainbow-backup' and this can not exist before syncoid and sanoid services inital run as they create it automatically and throw an error otherwise.

- On the source system (rainbow), configure a `services.sanoid` in `hosts/rainbow/sanoid-backup-source.nix` to keep around a few historical datasets.

### Nextcloud <a name="Nextcloud"></a>

---

- prerequesite for `home = "/tank/Nextcloud";` :

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

- ONLYOFFICE DocumentServer:

```nix

  services.onlyoffice = {
    enable = true;
    jwtSecretFile = config.sops.secrets."onlyoffice/jwtSecretFile".path;
    hostname = "office.fschn.org";
  };

  # reverse proxy
  services.nginx = {
    virtualHosts.${config.services.onlyoffice.hostname} = {
      useACMEHost = "fschn.org";
      forceSSL = true;
    };
  };

  # secret deployment
  sops.secrets."onlyoffice/jwtSecretFile" = {
    owner = "onlyoffice";
  };
```



Then point nextcloud to the document server from within the Nextcloud UI ("Administration Settings" -> Administration -> ONLYOFFICE), and make sure the 'services.onlyoffice.jwtSecretFile points to a file containing the same key as entered in the configuration of the Nextcloud app. 

Also needed to change the port of scrutiny from 8080 to 8081, as somehow the onlyoffice documentserver needs the 8080 port.


- nextcloud logs dashbaord with loki and promtail

extra nextcloud settings:
```nix
services.nextcloud.settings = {
      loglevel = 1;
      log_type = "file";
      logfile = "/tank/Nextcloud/data/nextcloud.log";
      log_type_audit = "file";
      logfile_audit = "/tank/Nextcloud/data/audit.log";
    };
```

add following scrape_config to `services.promtail.configuration`:
```nix
  {         
     job_name = "system";
    static_configs = [{
      targets = [ "100.106.245.44" ];
      labels = {
        instance = "nextcloud.fschn.org";
        env = "home-lab";
        job = "nextcloud";
        __path__ = "/tank/Nextcloud/data/{nextcloud,audit}.log";
      };
    }];
  };
```

and give the necesary permissions for the promtail user with:
```nix
 users.users.promtail.extraGroups = [ "nextcloud" ];
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

Then based on this [reddit.com reply](https://www.reddit.com/r/NixOS/comments/1c225c8/gnome_keyring_is_not_unlocked_upon_boot/?rdt=40009):

> This is extremely non obvious, but if you want to have autologin unlock your gnome keyring on startup, the keyring needs to have a blank password.
>
> I actually don't remember where I read this, I just have this as a comment in my config. I do remember spending hours trying to figure out wtf it wasn't working though.
>
> I can't speak to the security implications of this. I autologin on my laptop, because my "login" is the ZFS passphrase prompt to decrypt the drives, so that isn't really a concern for me.

Changing the keyring password with seahorse to blank, and voilà it works.

### Jellyfin <a name="jellyfin"></a>

---

prerequiste for `jellyfin.dataDir`:
```bash
sudo zfs create /tank/Jellyfin
sudo chown jellyfin:jellyfin /tank/Jellyfin
```

adding a plugin, via jellyfin web-ui: 

```bash
# admin-dashboard > plugins > repositories
https://raw.githubusercontent.com/intro-skipper/intro-skipper/master/manifest.json
```
### Deluge <a name="deluge"></a>

---

prerequiste for `deluge.dataDir`:
```bash
sudo zfs create /tank/Deluge
```

Setting up deluge in a sperate network namespace with only a wireguard vpn interface:

First, creating network namespace with wireguard vpn interface based on this [tutorual](https://discourse.nixos.org/t/setting-up-wireguard-in-a-network-namespace-for-selectively-routing-traffic-through-vpn/10252/8):

```nix
  # VPN wireguard conf file
  sops.secrets."Deluge/vpn.conf" = { };
  sops.secrets."Deluge/vpn-ip4addr-cidr" = { };

  # creating network namespace
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
    };
  };

  # setting up wireguard interafe within network namespace
  systemd.services.wg = {
    description = "wg network interface";
    bindsTo = [ "netns@wg.service" ];
    requires = [ "network-online.target" ];
    after = [ "netns@wg.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = with pkgs; writers.writeBash "wg-up" ''
        see -e
        ${iproute2}/bin/ip link add wg0 type wireguard
        ${iproute2}/bin/ip link set wg0 netns wg
        ${iproute2}/bin/ip -n wg address add ${toString config.sops.secrets."Deluge/vpn-ip4addr-cidr".path} dev wg0
        # ${iproute2}/bin/ip -n wg -6 address add <ipv6 VPN addr/cidr> dev wg0
        ${iproute2}/bin/ip netns exec wg \
          ${wireguard-tools}/bin/wg setconf wg0 ${toString config.sops.secrets."Deluge/vpn.conf".path}
        ${iproute2}/bin/ip -n wg link set wg0 up
        # need to set lo up as network namespace is started with lo down
        ${iproute2}/bin/ip -n wg link set lo up
        ${iproute2}/bin/ip -n wg route add default dev wg0
        # ${iproute2}/bin/ip -n wg -6 route add default dev wg0
      '';
      ExecStop = with pkgs; writers.writeBash "wg-down" ''
        ${iproute2}/bin/ip -n wg route del default dev wg0
        # ${iproute2}/bin/ip -n wg -6 route del default dev wg0
        ${iproute2}/bin/ip -n wg link del wg0
      '';
    };
  };
```

Second, binding deluged to newly created network namespace and enabling connectivity of delugeweb (in root namespace) to delguded in seperate network namespace, based on this [tutorial](https://github.com/existentialtype/deluge-namespaced-wireguard):
```nix
  # binding deluged to network namespace
  systemd.services.deluged.bindsTo = [ "netns@wg.service" ];
  systemd.services.deluged.requires = [ "network-online.target" "wg.service" ];
  systemd.services.deluged.serviceConfig.NetworkNamespacePath = [ "/var/run/netns/wg" ];

  # allowing delugeweb to access deluged in network namespace, a socket is necesarry 
  systemd.sockets."proxy-to-deluged" = {
    enable = true;
    description = "Socket for Proxy to Deluge Daemon";
    listenStreams = [ "58846" ];
    wantedBy = [ "sockets.target" ];
  };

  # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
  systemd.services."proxy-to-deluged" = {
    enable = true;
    description = "Proxy to Deluge Daemon in Network Namespace";
    requires = [ "deluged.service" "proxy-to-deluged.socket" ];
    after = [ "deluged.service" "proxy-to-deluged.socket" ];
    unitConfig = { JoinsNamespaceOf = "deluged.service"; };
    serviceConfig = {
      User = "deluge";
      Group = "deluge";
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:58846";
      PrivateNetwork = "yes";
    };
  };
```


### Firefox-syncserver <a name="firefox-syncserver"></a>

---

Navigate to **about:config** in your Firefox address bar and set **identity.sync.tokenserver.uri** to **https://firefox-sync.fschn.org/1.0/sync/1.5**.

On Firefox android go to Settings > About Firefox and tap the logo a bunch, it will enable a few hidden options back on the main Settings page. One of which should be custom Sync and Firefox Accound settings.

### Syncthing <a name="syncthing"></a>

---

as prerequisite for Paperless:
```bash
sudo zfs create tank/Paperless
sudo chown -R fschn:users /tank/Paperless
```


---

## Troubleshooting <a name="trouble"></a>

1. [Auto unlocking gnome keyring](#keyring)
2. [Switching bootloader from Grub to systemd-boot](#bootloader)
3. [Nextcloud reinstallation](#nextcloud)
4. [Grafana](#grafana-trouble)
5. [Firefox-syncserver](#syncserver)
6. [Deluge in network namespace with wireguard vpn](#deluge-netns)
7. [Jellyfin](#jellerror)


### Auto unlocking gnome keyring <a name="keyring"></a>

---


If changing to a blank password of the current keyring doesnt work, creating a new keyring with a blank password (while keeping the old one with all entries) seems to do the trick.


### Switching bootloader from Grub to systemd-boot <a name="bootloader"></a> 

---


- could not find any previously installed systemd-boot

run `sudo bootctl install`

- not enough space on /boot

based on this [discourse.nixos.org repy](https://discourse.nixos.org/t/what-to-do-with-a-full-boot-partition/2049/11?u=fschn90):

> 1.  Do a sudo nixos-rebuild build so that you’re sure that the build of your current configuration can be carried out
> 2.  Do a garbage collection to remove old system generations with sudo nix-collect-garbage -d
> 3.  Manually make some space in boot. Find your kernels and rm them.
> 4.  Run sudo nixos-rebuild switch or sudo nixos-rebuild boot. This time your bootloader will be installed correctly along with the new kernel and initrd
> 5.  Make sure point 4 was executed correctly by looking at the output and reboot
> 6.  [optional] remove the result directory created by point 1


### Nextcloud reinstallation <a name="nextcloud"></a>

---


After manually removing nextcloud data and rebuilding, with e.g.:

```bash
zfs destroy tank/Nextcloud
zfs create tank/Nextcloud
nixos-rebuild switch
```

- the user already exisits error

renaming the admin user with `services.nextcloud.config.adminuser` to another value does work. probably the previous user is kept in the cache despite delete the whole filesystem. also deleteing the old users in the nextcloud interface ensures not running out of names eventually.


### Grafana <a name="grafana-trouble"></a>

---


1. to avoid `provisioned dashboard cannot be deleted / saved`, the followgin needs to be edited:

```nix

  environment.etc = {
    "grafana-dashboards/node-exporter-full_rev37.json" = {
      source = ./dashboards/node-exporter-full_rev37.json;
      group = "grafana";
      user = "grafana";
    };
  };
```

but also, when adding a new dashboard it needs to be imported manually with the grafana web interface and then exported as json first, and only then to be added to the config via the above code. this adds the specific datasource uid to the json.

2. Node Exporter Dashboard graphs, displaying `no data` when selecting time range smaller than 24h. 
Because the dashboard is expecting prometheus to scrape every 15s.

### Firefox-syncserver <a name="syncserver"></a>

---


To view logs, type `about:sync-logs` into firefox address bar.

Logging out of mozilla account in firefox seemed to sometimes solve connection errors.
Especially when rebuilding firefox-syncserver with a new hostname it seemed to be necesarry.

To avoid error `findCluster has a pre-existing clusterURL, so fetching new token`.
In the firefox address bar type about:profiles.
Then in the profile dir, delete `weave` dir, firefox-sync used to be formerly named Weave.

To avoid error `The option services.nginx.virtualHosts."firefox-sync.fschn.org".forceSSL has conflicting definition values`,  use lib.mkForce value:

```nix
  services.nginx = {
    virtualHosts."firefox-sync.fschn.org" = {
      forceSSL = lib.mkForce true;
    };
  };
 ```

From [HackerNews](https://news.ycombinator.com/item?id=34674569), even though not relevant yet:
> sometimes the first sync times out when you have a larger data set, and you need to manually enable each sync type to reduce the size. But once it's up and running, I don't really have any issues.

### Deluge in network namespace with wireguard vpn <a name="deluge-netns"></a>

first rebuild switch failed with `Failed to open network namespace path /var/run/netns/wg: No such file or directory`, solved then with:

```bash
sudo systemctl restart deluged
```

also delugeweb failed with `Dependency failed for Deluge BitTorrent WebUI.`, solved then with:

```bash
sudo systemctl restart delugeweb
```


How to get magnet links into deluge web client: use the firefox extention `Torrent to Web`.

### Jellyfin <a name="jellerror"></a>

`Error displaying media content` for all media files, then this helped:
```bash
mv /var/cache/jellyfin /var/cache/jellyfin-bak
mv /tank/Jellyfin/config /tank/Jellyfin/config-bak
sudo systemctl restart jellyfin
```

didnt remove metadata in fact.
