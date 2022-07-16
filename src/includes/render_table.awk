BEGIN {
    cl_red_bold = "\033[1;41m";
    cl_green_bold = "\033[1;42m";
    cl_yellow_bold = "\033[1;43m";
    cl_default_bold = "\033[0;1m";
    cl_default = "\033[0m";

    # create a string filled with %{max_columns}d spaces
    dotted_line = sprintf(sprintf("%%%ds", max_columns), "");

    # replace spaces with dots
    gsub(" ", ".", dotted_line);

    # convert string into array for marks
    split(mark_string, mark_list, " ");

    # convert array into dict for marks
    for (name in mark_list) {
        mark_dict[mark_list[name]] = name;
    }
}

{
    bytes = $1;
    size = $2;
    unit = $3;
    name = $4;

    if (!max_bytes) {
        max_bytes = bytes;
    }

    columns = int(bytes / max_bytes * max_columns);
    margin_right = 7 + 3 + 3;  # 7 size + 3 unit + 3 space characters

    if (name in mark_dict) {
        mark = "<";
    } else {
        mark = " ";
    }

    line = sprintf(sprintf("%%.%ds %%7.2f %%.3s%%s", max_columns - margin_right), name dotted_line, size, unit, mark);

    if (tty) {
        color = cl_green_bold;
        start_line = substr(line, 1, columns);
        end_line = substr(line, columns + 1);

        if (bytes / max_bytes > 0.5) {
            color = cl_yellow_bold;
        }

        if (bytes / max_bytes > 0.75) {
            color = cl_red_bold;
        }

        printf("%s%s%s%s%s\n", color, start_line, cl_default_bold, end_line, cl_default);
    } else {
        print(line);
    }
}