{
    name = $4;
    char_count = "wc -m";

    printf("%s %s ", $0, length(name));
    printf(name) | char_count;
    close(char_count);
}