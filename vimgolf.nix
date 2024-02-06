{
  pkgs,
  config,
  ...
}: {
  age.secrets.vimgolf = {
    file = ./secrets/vimgolf.age;
    path = "/home/dan/.config/vimgolfkey";
    owner = "dan";
    group = "users";
    mode = "600";
  };

  # environment.systemPackages = with pkgs; [
  users.users.dan.packages = with pkgs; [
    (writeShellApplication {
      name = "vimgolf";
      text = ''
        CHALLENGE_ID=$1
        VIMGOLF_KEY=$(cat "${config.age.secrets.vimgolf.path}")
        docker run --rm -it -e "key=$VIMGOLF_KEY" ghcr.io/filbranden/vimgolf "$CHALLENGE_ID"
      '';
    })
  ];
}
