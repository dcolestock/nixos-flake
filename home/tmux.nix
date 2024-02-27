{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shortcut = "a";
    # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;
    # Force tmux to use /tmp for sockets (WSL2 compat)
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
      bind-key b copy-mode\;\
                 send-keys -X start-of-line\;\
                 send-keys -X search-backward "❯"\;\
                 send-keys -X top-line

      unbind r
      bind r source-file /home/dan/.config/tmux/tmux.conf

      bind C-l send-keys 'C-l'

      bind C-c new-window      -c "#{pane_current_path}"
      bind  c  new-window      -c "#{pane_current_path}"
      bind  %  split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      bind C-o select-pane -t :.+

      #set-option -sa terminal-overrides ',xterm:RGB'
      #set-option -sa terminal-features ',xterm:RGB'

      set -g mouse on
      # set-option -s set-clipboard off
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection primary -i"
      # bind -T root MouseDown2Pane run-shell -b "xclip -o | tmux load-buffer - && tmux paste-buffer"


      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:RGB"
      #set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

    '';
  };
}
