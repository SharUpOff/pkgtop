#/usr/bin/env bash

max_lines="${1-$[${LINES-$(command -v tput &>/dev/null && tput lines || echo 25)} - 2]}"
max_columns="${2-${COLUMNS-$(command -v tput &>/dev/null && tput cols || echo 80)}}"

# Create Table: %{size}d %7.2{unit_size}f %{unit}s %{name}s
(
    # Ubuntu/Debian
    if command -v dpkg-query &> /dev/null; then
        LC_ALL=C dpkg-query --show --showformat='${Package} ${Installed-Size}\n' |
        awk '{
            name = $1;
            size = $2;
            unit_size = size;
            unit = "KiB";

            if (unit_size > 1024) {
                unit = "MiB";
                unit_size = unit_size / 1024;
            }

            if (unit_size > 1024) {
                unit = "GiB";
                unit_size = unit_size / 1024;
            }

            printf("%d %7.2f %s %s\n", size, unit_size, unit, name);
        }'
    fi

    # OpenWRT
    if command -v opkg &> /dev/null; then
        LC_ALL=C opkg info |
        awk '{
            if ($1 == "Package:") {
                name = $2;
            };

            if ($1 == "Status:") {
                status = $NF;
            }

            if ($1 == "Size:" && status == "installed") {
                size = $2;
                unit_size = size;
                unit = "B";

                if (unit_size > 1024) {
                    unit = "KiB";
                    unit_size = unit_size / 1024;
                }

                if (unit_size > 1024) {
                    unit = "MiB";
                    unit_size = unit_size / 1024;
                }

                if (unit_size > 1024) {
                    unit = "GiB";
                    unit_size = unit_size / 1024;
                }

                printf("%d %7.2f %s %s\n", size, unit_size, unit, name);
            }
        }'
    fi

    # ArchLinux
    if command -v pacman &> /dev/null; then
        LC_ALL=C pacman -Qi |
        awk '{
            if ($1 == "Name") {
                name = $3;
            }

            if ($1 == "Installed" && $2 == "Size") {
                unit = $5;
                unit_size = $4;

                switch (unit) {
                    case "B":
                        size = unit_size;
                        break;
                    case "KiB":
                        size = unit_size * 1024;
                        break;
                    case "MiB":
                        size = unit_size * 1024 * 1024;
                        break;
                    case "GiB":
                        size = unit_size * 1024 * 1024 * 1024;
                        break;
                }

                printf("%d %7.2f %s %s\n", size, unit_size, unit, name);
            }
        }'
    fi
) |

# Order by Size
sort -rn |

# Limit Output
head -n "${max_lines}" |

# Render Table
awk -v max_columns=${max_columns} -v dotted_line="$(printf "%${max_columns}s" | tr " " ".")" '{
    bytes = $1;
    size = $2;
    unit = $3;
    name = $4;

    cl_red_bold = "\033[1;41m";
    cl_green_bold = "\033[1;42m";
    cl_yellow_bold = "\033[1;43m";
    cl_default_bold = "\033[0;1m";
    cl_default = "\033[0m";

    if (!max_bytes) {
        max_bytes = bytes;
    }

    if (max_columns > 80) {
        max_columns = 80;
    }

    columns = int(bytes / max_bytes * max_columns);
    margin_right = 7 + 3 + 3;  // 7 size + 3 unit + 3 space characters
    line = sprintf(sprintf("%%.%ds %%7.2f %%3s ", max_columns - margin_right), name dotted_line, size, unit);
    color = cl_green_bold;

    if (bytes / max_bytes > 0.5) {
        color = cl_yellow_bold;
    }

    if (bytes / max_bytes > 0.75) {
        color = cl_red_bold;
    }

    printf("%s%s%s%s%s\n", color, substr(line, 1, columns), cl_default_bold, substr(line, columns + 1), cl_default);
}'

exit $?
