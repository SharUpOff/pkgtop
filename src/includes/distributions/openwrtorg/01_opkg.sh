# OpenWRT (opkg)
if command -v opkg &> /dev/null; then
    # get installed packages
    LC_ALL=C opkg info |
    # format output: %{bytes}d %{name}\n
    awk -f ./includes/distributions/openwrtorg/opkg.awk

    # prevent other plugins from running
    exit $?
fi
