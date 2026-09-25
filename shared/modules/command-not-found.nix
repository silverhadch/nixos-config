{ ... }:

# Type a command you don't have → it gets looked up in nix-index, fetched from
# nixpkgs, run, and put on $PATH in every open zsh until you log out.
#
#   $ cowsay hi              # not installed
#   » cowsay → nixpkgs#cowsay (on PATH until logout)
#    ____
#   < hi >
#   ...
#
# Nothing is installed permanently; after logging out it's gone again.
# `, <cmd>` (comma) does the same for a single run without touching PATH.
#
# The database comes prebuilt from the nix-index-database flake input, so there
# is no need to ever run `nix-index` yourself.
{
  programs.command-not-found.enable = false;

  programs.nix-index = {
    enable = true;
    # zsh gets the auto-run handler below instead of nix-index's "try nix-shell -p" hint.
    enableZshIntegration = false;
  };

  programs.nix-index-database.comma.enable = true;

  programs.zsh.interactiveShellInit = ''
    # Per-login state: GC roots for fetched packages + the list of their bin dirs.
    _cnf_dir="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}/cnf-$UID}/command-not-found"

    # zsh runs command_not_found_handler in a forked child, so it can't touch
    # this shell's PATH itself. It appends to $_cnf_dir/paths instead and every
    # shell picks new entries up before drawing its next prompt.
    _cnf_sync_path() {
      [[ -r "$_cnf_dir/paths" ]] || return 0
      local d
      for d in ''${(f)"$(<"$_cnf_dir/paths")"}; do
        [[ -d "$d" ]] && (( ! ''${path[(Ie)$d]} )) && path=( "$d" $path )
      done
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _cnf_sync_path

    command_not_found_handler() {
      local cmd="$1"

      # Paths (./foo) aren't package lookups; no nix-locate → plain error.
      if [[ "$cmd" == */* ]] || ! (( $+commands[nix-locate] )); then
        print -u2 "zsh: command not found: $cmd"
        return 127
      fi

      local -a attrs
      attrs=( ''${(f)"$(nix-locate --minimal --no-group \
                        --type x --type s --whole-name --at-root \
                        "/bin/$cmd" 2>/dev/null)"} )
      attrs=( ''${attrs:#} )

      if (( ''${#attrs} == 0 )); then
        print -u2 "zsh: command not found: $cmd"
        return 127
      fi

      # Prefer the package named like the command, else the first hit.
      local attr="''${attrs[1]}" a
      for a in "''${attrs[@]}"; do
        if [[ "''${a%.*}" == "$cmd" ]]; then attr="$a"; break; fi
      done

      if (( ''${#attrs} > 1 )); then
        print -u2 "» '$cmd' is in: ''${(j:, :)''${attrs[@]%.out}}"
      fi

      # The out-link is a GC root that lives in $XDG_RUNTIME_DIR (wiped on
      # logout), so the hourly nix gc can't delete the package while in use.
      mkdir -p "$_cnf_dir"
      local out
      out="$(NIXPKGS_ALLOW_UNFREE=1 nix build --impure --print-out-paths \
               --out-link "$_cnf_dir/''${attr}" "nixpkgs#$attr")" || {
        print -u2 "» couldn't build nixpkgs#$attr"
        return 127
      }

      if [[ ! -x "$out/bin/$cmd" ]]; then
        print -u2 "zsh: command not found: $cmd"
        return 127
      fi

      print -r -- "$out/bin" >> "$_cnf_dir/paths"
      print -u2 "» $cmd → nixpkgs#''${attr%.out} (on PATH until logout)"

      path=( "$out/bin" $path )
      "$out/bin/$cmd" "''${@:2}"
    }
  '';
}
