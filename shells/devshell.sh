#!/usr/bin/env bash

_devshell_completion() {
  local shells_dir="/etc/nixos/shells"
  local -a shell_names
  
  if [[ -d "$shells_dir" ]]; then
    for file in "$shells_dir"/*.nix; do
      if [[ -f "$file" ]]; then
        shell_names+=("$(basename "$file" .nix)")
      fi
    done
  fi
  
  _describe 'devshell' shell_names
}

devshell() {
  local SHELLS_DIR="/etc/nixos/shells"
  
  # List available devshells
  if [[ "$1" == "list" ]]; then
    if [[ -d "$SHELLS_DIR" ]]; then
      echo "Available devshells:"
      for file in "$SHELLS_DIR"/*.nix; do
        if [[ -f "$file" ]]; then
          local name="$(basename "$file" .nix)"
          echo "  $name"
        fi
      done
    else
      echo "Shells directory not found: $SHELLS_DIR"
      return 1
    fi
    return 0
  fi
  
  # Show help if no arguments
  if [[ $# -eq 0 ]]; then
    echo "Usage:"
    echo "  devshell list                     - List available devshells"
    echo "  devshell <name>                   - Enter devshell environment"
    echo "  devshell <name> --command 'cmd'  - Run command in devshell"
    echo ""
    echo "Example:"
    echo "  devshell kontainer"
    return 1
  fi
  
  local shell_name="$1"
  local shell_file="$SHELLS_DIR/$shell_name.nix"
  
  # Shift to get remaining arguments
  shift
  
  if [[ ! -f "$shell_file" ]]; then
    echo "Devshell not found: $shell_name"
    echo "Available shells:"
    devshell list
    return 1
  fi
  
  # Determine current directory (try to preserve it)
  local original_dir="$(pwd)"
  
  # Enter devshell
  if [[ "$1" == "--command" ]]; then
    shift
    local command="$*"
    echo "Running command in devshell '$shell_name': $command"
    cd "$original_dir" && nix develop --impure -f "$shell_file" -c zsh -c "$command"
  else
    echo "Entering devshell: $shell_name"
    echo "Use 'exit' to leave the devshell"
    cd "$original_dir" && nix develop --impure -f "$shell_file"
  fi
}

# Register completion for zsh
if [[ -n "$ZSH_VERSION" ]]; then
  compdef _devshell_completion devshell
fi
