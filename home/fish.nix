{...}: {
  programs.fish = {
    enable = true;
    plugins = [];
    shellAbbrs = {
      c = "cd";
      ".." = "cd ..";
      "..." = "cd ../..";
      l = "ls";

      open = "xdg-open";
      ping = "ping -c 5";
      mkdir = "mkdir -pv";
      wget = "wget -c";
      chmod = "chmod -c --preserve-root";
      chown = "chown -c --preserve-root";
      chgrp = "chgrp -c --preserve-root";

      cp = "cp --interactive --verbose --recursive --reflink=auto";
      mv = "mv --interactive --verbose";
      ln = "ln --interactive --verbose";
      rm = "rm --verbose --interactive=once --preserve-root=all";

      cpv = "rsync -ah --info=progress2";

      diff = "delta";
      cat = "bat";
      du = "dust --limit-filesystem";
      df = "duf";
      ps = "procs";
      fd = "fd --mount";
      rg = "rg --one-file-system";

      less = "less -r"; # raw control characters
      where = "type -a";
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";

      untar = "tar -xvaf";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
      sudoedit = "command sudo -E nvim";
      nvim = "nvim -w ~/.nvimkeystrokes";
      myvim = "NVIM_APPNAME=myvim nvim";

      gs = "git status";
      gd = "git diff";
      gc = "git commit";
    };
    shellAliases = {
      path = "printf '%s\n' $PATH";
      please = "eval command sudo $history[1]";
      weather = "curl -sS wttr.in|head -n -2";
      tmux = "direnv exec / tmux -2 new -As0 -c ~";

      ls = "exa --group-directories-first --color=auto --icons=auto";
      ll = "ls -l";
      la = "ls -a ";
      lla = "ls -l -a";
      laa = "lla";
      lt = "ls -l -s=modified";
    };
  };
}
