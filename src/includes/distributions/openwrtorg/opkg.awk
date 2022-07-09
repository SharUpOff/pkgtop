{
    if ($1 == "Package:") {
        name = $2;
    };

    if ($1 == "Status:") {
        status = $NF;
    }

    if ($1 == "Size:" && status == "installed") {
        bytes = $2;

        printf("%d %s\n", bytes, name);
    }
}