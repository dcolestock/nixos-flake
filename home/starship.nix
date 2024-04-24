{
  programs.starship = {
    # enable = true;
    settings = {
      username = {
        style_user = "#3bfd8b bold";
        style_root = "red bold";
        format = "[$user]($style)";
        disabled = false;
        show_always = true;
      };
      hostname = {
        ssh_only = true;
        ssh_symbol = "🌐 ";
        format = "@[$hostname](bold red)";
        trim_at = ".local";
        disabled = false;
      };
    };
  };
  programs.oh-my-posh = {
    enable = true;
    # useTheme = "hunk";
    settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./config/ohmyposh.json));
  };
}
