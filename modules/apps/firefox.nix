{inputs, ...}: {
  flake.modules.homeManager.firefox = {pkgs, ...}: {
    programs.firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        isDefault = true;
        extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [ublock-origin canvasblocker istilldontcareaboutcookies bitwarden keepassxc-browser vimium darkreader];
        search = {
          default = "ddg";
          force = true;
          engines = {
            "Github Nix" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}+lang:nix";
                    }
                    {
                      name = "type";
                      value = "code";
                    }
                  ];
                }
              ];
              definedAliases = ["@gn"];
            };
            "Github Python" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}+lang:python";
                    }
                    {
                      name = "type";
                      value = "code";
                    }
                  ];
                }
              ];
              definedAliases = ["@gp"];
            };
            "Github Lua" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}+lang:lua";
                    }
                    {
                      name = "type";
                      value = "code";
                    }
                  ];
                }
              ];
              definedAliases = ["@gl"];
            };
            "Nix Packages" = {
              urls = [
                {
                  template = "https://mynixos.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@n"];
            };
            "bing".metaData.hidden = true;
            "google".metaData.hidden = true;
            "amazondotcom-us".metaData.hidden = true;
            "ebay".metaData.hidden = true;
            "ddg".metaData.hidden = false;
          };
        };
      };
      policies = {
        DisablePocket = true;
        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = true;
        DontCheckDefaultBrowser = true;
        OfferToSaveLogins = false;
        NoDefaultBookmarks = true;
        PasswordManagerEnable = false;
        DNSOverHTTPS.Enabled = true;
        UserMessaging = {
          SkipOnboarding = true;
          ExtensionRecommendations = false;
        };
      };
    };
  };
}
