{
    sub("^.+/", "", $2);
    sub(".app$", "", $2);

    bytes = $1 * 1024;
    name = $2;

    printf("%d %s\n", bytes, name);
}