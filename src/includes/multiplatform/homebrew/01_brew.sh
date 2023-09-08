# homebrew
if command -v brew &> /dev/null; then
    # get installed packages
    brew list --formula |
    # get installed directories
    xargs brew --prefix |
    # get directories size
    xargs du -Lks |
    # format output: %{bytes}d %{name}\n
    awk -f ./includes/multiplatform/homebrew/brew.awk
fi
