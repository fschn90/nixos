{ config, ... }:
{

  networking.wireless.secretsFile = config.sops.secrets."wireless".path;
  networking.wireless.networks."FRITZ!Box 6660 Cable TA".psk = "ext:psk_home";

  sops.secrets."wireless" = { };

}
