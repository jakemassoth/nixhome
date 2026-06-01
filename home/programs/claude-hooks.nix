{
  pkgs,
  lib,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  jq = "${pkgs.jq}/bin/jq";

  # Fire a desktop notification. $msg must be set by the caller.
  # On macOS we use the built-in osascript (passing text as argv to avoid
  # AppleScript quoting issues); elsewhere fall back to notify-send so the
  # shared common.nix still evaluates on Linux hosts.
  notify = sound:
    if isDarwin
    then ''
      /usr/bin/osascript \
        -e 'on run argv' \
        -e 'display notification (item 1 of argv) with title (item 2 of argv) sound name (item 3 of argv)' \
        -e 'end run' \
        "$msg" "Claude Code" "${sound}"
    ''
    else ''${pkgs.libnotify}/bin/notify-send "Claude Code" "$msg"'';

  # Notification hook: fires when Claude needs permission or is waiting on you.
  notificationHook = pkgs.writeShellScript "claude-notify" ''
    input=$(cat)
    msg=$(${jq} -r '.message // "Claude needs your attention"' <<<"$input")
    ${notify "Ping"}
  '';

  # Stop hook: fires when Claude finishes responding (task complete).
  stopHook = pkgs.writeShellScript "claude-stop" ''
    input=$(cat)
    cwd=$(${jq} -r '.cwd // ""' <<<"$input")
    dir="''${cwd##*/}"
    if [ -n "$dir" ]; then
      msg="Task complete in $dir"
    else
      msg="Task complete"
    fi
    ${notify "Glass"}
  '';

  hooksConfig = {
    Notification = [{hooks = [{type = "command"; command = "${notificationHook}";}];}];
    Stop = [{hooks = [{type = "command"; command = "${stopHook}";}];}];
  };

  # Merge our hooks into ~/.claude/settings.json without clobbering other
  # keys (model/theme/permissions, or anything Claude writes itself). Deep
  # merge with `*` preserves sibling hook events while replacing ours.
  mergeHooks = pkgs.writeShellScript "claude-merge-hooks" ''
    set -eu
    settings="$HOME/.claude/settings.json"
    mkdir -p "$HOME/.claude"
    if [ ! -f "$settings" ] || ! ${jq} -e . "$settings" >/dev/null 2>&1; then
      printf '{}' >"$settings"
    fi
    tmp="$(${pkgs.coreutils}/bin/mktemp)"
    ${jq} --argjson hooks '${builtins.toJSON hooksConfig}' \
      '.hooks = ((.hooks // {}) * $hooks)' "$settings" >"$tmp"
    mv "$tmp" "$settings"
  '';
in {
  home.activation.claudeHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${mergeHooks}
  '';
}
