# ArchLinux (expac)
# https://man.archlinux.org/man/community/expac/expac.1.en
if command -v expac &> /dev/null; then
    # get installed packages in format: %{bytes}d %{name}\n
    expac '%m %n'

    # prevent other plugins from running
    exit $?
fi
