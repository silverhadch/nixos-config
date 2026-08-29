{ lib, pkgs, osConfig, ... }:

let
  nixfmt = pkgs.nixfmt;
in
{
  programs.helix = {
    enable = true;

    extraPackages = with pkgs; [
      nixd
      nixfmt
      lldb
    ];

    settings = {
      theme = "autumn_night_transparent";

      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        true-color = true;
        bufferline = "multiple";
        completion-trigger-len = 1;
        idle-timeout = 50;
        rulers = [ 80 100 ];

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        indent-guides = {
          render = true;
          character = "┊";
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
        };
        end-of-line-diagnostics = "hint";

        file-picker.hidden = false;

        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "register"
            "file-type"
            "file-encoding"
            "position"
          ];
        };
      };

      keys.normal = {
        C-s = ":write";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };

    languages = {
      language-server = {
        nixd = {
          command = "nixd";
          config.nixd = {
            nixpkgs.expr = ''import (builtins.getFlake "/etc/nixos").inputs.nixpkgs { }'';
            options.nixos.expr =
              ''(builtins.getFlake "/etc/nixos").nixosConfigurations.${osConfig.networking.hostName}.options'';
            formatting.command = [ "${nixfmt}/bin/nixfmt" ];
          };
        };

        clangd = {
          command = "clangd";
          args = [
            "--background-index"
            "--clang-tidy"
            "--completion-style=detailed"
            "--header-insertion=never"
          ];
        };

        rust-analyzer = {
          command = "rust-analyzer";
          config.check.command = "clippy";
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nixd" ];
          formatter.command = "${nixfmt}/bin/nixfmt";
        }
        {
          name = "c";
          auto-format = true;
          language-servers = [ "clangd" ];
          formatter = {
            command = "clang-format";
            args = [ "--assume-filename=a.c" ];
          };
        }
        {
          name = "cpp";
          auto-format = true;
          language-servers = [ "clangd" ];
          formatter = {
            command = "clang-format";
            args = [ "--assume-filename=a.cpp" ];
          };
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" ];
        }
      ];
    };

    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };
}
