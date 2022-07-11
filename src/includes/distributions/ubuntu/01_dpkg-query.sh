# Ubuntu/Debian (dpkg-query)
if command -v dpkg-query &> /dev/null; then
    # get installed packages
    dpkg-query --show --showformat='${Package} ${Installed-Size}\n' |
    # format output: %{bytes}d %{name}\n
    awk -f ./includes/distributions/ubuntu/dpkg-query.awk

    # get installed packages
    exit $?
fi
