{ config, ... }: {
  systemd.timers."cloudflare_dns_update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "2h";
      Unit = "cloudflare_dns_update.service";
    };
  };

  age.secrets.cloudflare = {
    file = ./secrets/cloudflare.age;
    owner = "root";
    group = "root";
  };
  systemd.services."cloudflare_dns_update" = {
    script = ''
      set -eu
      source "${config.age.secrets.cloudflare.path}"
      ${builtins.readFile ./home/scripts/cloudflare_dns_update.sh}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
