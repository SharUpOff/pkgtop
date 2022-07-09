function unit_size_to_bytes(size, unit)
{
    units["B"] = 0;
    units["KiB"] = 1;
    units["MiB"] = 2;
    units["GiB"] = 3;
    units["TiB"] = 4;

    return size * 1024 ^ units[unit];
}

{
    if ($1 == "Name") {
        name = $3;
    }

    if ($1 == "Installed" && $2 == "Size") {
        unit = $5;
        size = $4;
        bytes = unit_size_to_bytes(size, unit);

        printf("%d %s\n", bytes, name);
    }
}