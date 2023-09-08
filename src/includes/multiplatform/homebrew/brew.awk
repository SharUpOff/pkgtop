{
    sub("^.+/", "", $2);

    bytes = $1 * 1024;
    name = sprintf("homebrew/%s", $2);

    printf("%d %s\n", bytes, name);
}