{...}: {
  flake.modules.homeManager.tmux = {pkgs, ...}: {
    programs.tmux = {
      enable = true;
      shortcut = "a";
      baseIndex = 1;
      newSession = true;
      escapeTime = 0;
      secureSocket = false;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        better-mouse-mode
        vim-tmux-navigator
        {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-show-powerline true
            set -g @dracula-show-left-icon session
            set -g @dracula-plugins "cpu-usage ram-usage"
            set -g @dracula-show-flags true
            set -g @dracula-refresh-rate 10
          '';
        }
      ];
      extraConfig = ''
        bind-key b copy-mode\; send-keys -X start-of-line\; send-keys -X search-backward "❯"\; send-keys -X top-line
        unbind r
        bind r source-file /home/dan/.config/tmux/tmux.conf
        bind C-l send-keys 'C-l'
        bind C-c new-window -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        bind C-o select-pane -t :.+
        set -g mouse on
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection primary -i"
        set -g default-terminal "screen-256color"
        set -ga terminal-overrides ",*256col*:RGB"
        set-environment -g COLORTERM "truecolor"
      '';
    };
  };
}
