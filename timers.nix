{}: {
  systemd.timers."cloudflare_dns_update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "2h";
      Unit = "cloudflare_dns_update.service";
    };
  };

  systemd.services."cloudflare_dns_update" = {
    script = ''
      set -eu
      ${builtins.readFile ./secrets/cloudflare_tokens.txt}
      ${builtins.readFile ./home/scripts/cloudflare_dns_update.sh}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
