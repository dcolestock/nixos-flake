let
  dandesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGgfhOsDFQuBDdbMEpcHOSreP6aF4MRuzw+m/IrUMaF";
  users = [dandesktop];

  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqZ4moRQ1NPyN+ZC5NPslVal09N9czC9edMluXLY92l";
  systems = [desktop];
in {
  "cloudflare.age".publicKeys = users ++ systems;
  "vimgolf.age".publicKeys = users ++ systems;
  "tailscale.age".publicKeys = users ++ systems;
}
