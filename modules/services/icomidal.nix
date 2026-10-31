{ config, icomidal, ... }:
{
  # Run icomidal script daily
  systemd.timers.icomidal = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "icomidal.service";
    };
  };
  systemd.services.icomidal = {
    script = ''
      ${icomidal}/bin/icomidal > /var/lib/icomidal/komida.ics
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "icomidal";
    };
  };
  users.users.icomidal = {
    isSystemUser = true;
    group = "icomidal";
  };
  users.groups.icomidal = {};
}
