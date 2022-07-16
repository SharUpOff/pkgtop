BEGIN {
    cl_red_bold = "\033[1;41m";
    cl_green_bold = "\033[1;42m";
    cl_yellow_bold = "\033[1;43m";
    cl_default_bold = "\033[0;1m";
    cl_default = "\033[0m";

    # 7 size + 3 unit + 3 space characters
    dotted_line_length = max_columns - (7 + 3 + 3);

    # create a string filled with %{dotted_line_length}d spaces
    dotted_line = sprintf(sprintf("%%%ds", dotted_line_length), "");

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

    if (name in mark_dict) {
        mark = "<";
    } else {
        mark = " ";
    }

    name_with_dots = sprintf(sprintf("%%.%ds", dotted_line_length), name dotted_line);
    output = sprintf("%s %7.2f %.3s%s", name_with_dots, size, unit, mark);

    if (tty) {
        colored_columns = int(bytes / max_bytes * max_columns);
        colored_output = substr(output, 1, colored_columns);
        default_output = substr(output, colored_columns + 1);
        color = cl_green_bold;

        if (bytes / max_bytes > 0.5) {
            color = cl_yellow_bold;
        }

        if (bytes / max_bytes > 0.75) {
            color = cl_red_bold;
        }

        print(color colored_output cl_default_bold default_output cl_default);
    } else {
        print(output);
    }
}