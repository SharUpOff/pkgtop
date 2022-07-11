# Fedora/RedHat/CentOS/OpenSUSE (rpm)
if command -v rpm &> /dev/null; then
    # get installed packages in format: %{bytes}d %{name}\n
    rpm --query --all --queryformat='%{size} %{name}\n'

    # prevent other plugins from running
    exit $?
fi
