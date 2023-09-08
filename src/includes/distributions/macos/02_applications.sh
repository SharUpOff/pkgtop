# macOS (Applications)
if [[ -d /Applications ]]; then
    # get directories size
    du -Lks /Applications/*.app |
    # format output: %{bytes}d %{name}\n
    awk -f ./includes/distributions/macos/applications.awk

    # prevent other plugins from running
    exit $?
fi
