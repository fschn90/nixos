{

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/interface".show-battery-percentage = true;
      "org/gnome/desktop/input-sources".xkb-options = [ "terminate:ctrl_alt_bksp" "lv3:ralt_switch" "compose:menu" ];
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-timeout = 0;
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
        {
          binding = "<Primary><Alt>t";
          command = "alacritty";
          name = "open-terminal";
        };

      "org/gnome/shell".enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "dash-to-dock@micxgx.gmail.com"
        "clipboard-indicator@tudmotu.com"
        "system-monitor-next@paradoxxx.zero.gmail.com"
        "advanced-weather@sanjai.com"
      ];

    };
  };

}
