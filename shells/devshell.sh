# shellcheck shell=bash
# Sourced from ~/.zshrc – provides the `devshell` helper.
#
# Every shells/<name>.nix is exposed by flake.nix as devShells.<name>, so this
# is just a thin wrapper around `nix develop /etc/nixos#<name>`.

SHELLS_DIR="${SHELLS_DIR:-/etc/nixos/shells}"

_devshell_names() {
  local file
  for file in "$SHELLS_DIR"/*.nix; do
    [[ -f "$file" ]] && basename "$file" .nix
  done
}

_devshell_completion() {
  local -a shell_names
  local name
  while IFS= read -r name; do
    shell_names+=("$name")
  done < <(_devshell_names)
  _describe 'devshell' shell_names
}

devshell() {
  if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'USAGE'
Usage:
  devshell list                    - List available devshells
  devshell <name>                  - Enter devshell environment
  devshell <name> --command 'cmd'  - Run command in devshell

Example:
  devshell kontainer
USAGE
    return 1
  fi

  if [[ "$1" == "list" ]]; then
    if [[ ! -d "$SHELLS_DIR" ]]; then
      echo "Shells directory not found: $SHELLS_DIR" >&2
      return 1
    fi
    echo "Available devshells:"
    _devshell_names | sed 's/^/  /'
    return 0
  fi

  local shell_name="$1"
  shift

  if [[ ! -f "$SHELLS_DIR/$shell_name.nix" ]]; then
    echo "Devshell not found: $shell_name" >&2
    devshell list
    return 1
  fi

  if [[ "$1" == "--command" ]]; then
    shift
    echo "Running command in devshell '$shell_name': $*"
    nix develop "/etc/nixos#$shell_name" --command zsh -c "$*"
  else
    echo "Entering devshell: $shell_name"
    echo "Use 'exit' to leave the devshell"
    nix develop "/etc/nixos#$shell_name"
  fi
}

# Register completion for zsh
if [[ -n "$ZSH_VERSION" ]]; then
  compdef _devshell_completion devshell
fi
