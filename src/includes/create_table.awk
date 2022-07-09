BEGIN {
    other_bytes = 0;
    total_bytes = 0;
    lines = show_other + show_total;

    # convert string into array for excludes
    split(exclude_string, exclude_list, " ");

    # convert array into dict for excludes
    for (name in exclude_list) {
        exclude_dict[exclude_list[name]] = name;
    }
}

function bytes_to_unit_size(bytes)
{
    units[0] = "B";
    units[1] = "KiB";
    units[2] = "MiB";
    units[3] = "GiB";
    units[4] = "TiB";

    for (exponent = 0; exponent < 5; exponent++)
    {
        size = bytes / 1024 ^ exponent;

        if (size < 1024)
        {
            break;
        }
    }

    return sprintf("%7.2f %s", size, units[exponent]);
}

{
    bytes = $1;
    name = $2;

    if (!(name in exclude_dict)) {
        if (lines < max_lines || max_lines == -1) {
            printf("%d %s %s\n", bytes, bytes_to_unit_size(bytes), name);
            lines++;
        } else {
            other_bytes += $1;
        }

        total_bytes += $1;
    }
}

END {
    if (show_other && other_bytes > 0) {
        printf("%d %s %s\n", other_bytes, bytes_to_unit_size(other_bytes), "[other]");
    }

    if (show_total) {
        printf("%d %s %s\n", 0, bytes_to_unit_size(total_bytes), "[total]");
    }
}