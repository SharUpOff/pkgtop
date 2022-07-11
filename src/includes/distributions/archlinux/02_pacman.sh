# ArchLinux (pacman)
# https://man.archlinux.org/man/pacman.8
if command -v pacman &> /dev/null; then
    # get installed packages
    LC_ALL=C pacman -Qi |
    # format output: %{bytes}d %{name}\n
    awk -f ./includes/distributions/archlinux/pacman.awk

    # prevent other plugins from running
    exit $?
fi
