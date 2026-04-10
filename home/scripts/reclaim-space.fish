echo "==> docker system prune -a"
docker system prune -a -f

echo "==> nix store gc"
nix store gc

echo "==> nix-store --optimize"
nix-store --optimize

if command -q pnpm
    echo "==> pnpm store prune"
    pnpm store prune
end

switch (uname)
case Darwin
    if command -q brew
        echo "==> brew cleanup"
        brew cleanup
    end
case Linux
    echo "==> journalctl --vacuum-time=7d"
    journalctl --vacuum-time=7d
end

echo "Done."
