#/usr/bin/env bash
# Description: Show largest installed packages
# Author: SharUpOff<sharupoff@efstudios.org>
# License: GPLv3

# default lines and columns
DEFAULT_LINES=25
DEFAULT_COLUMNS=80
LIMIT_COLUMNS=80

declare -A options

# custom lines and columns
options[lines]="$(egrep '^-*[0-9]+$' <<< "${1}")"

if [ ! -z "${options[lines]}" ]; then
    options[columns]="$(egrep '^-*[0-9]+$' <<< "${2}")"
fi

options[exclude]=""
options[other]=0
options[total]=0

for arg in $@; do
    if [ ! -z "${option_name}" ]; then
        unset_option_name=1
    fi

    case $arg in
        --help|-h)
            echo -n "Usage: ${0} [lines] [columns] "
            echo "[--exclude <name>] [--show-other] [--show-total] [--show-all] [--help]"
            echo
            echo "  [lines] --lines <lines> --lines=<lines> -l <lines>"
            echo "    Show specified number of lines (results)."
            echo "    If [other] and/or [total] lines are enabled they are also included in the number of lines."
            echo
            echo "  [columns] --columns <columns> --columns=<columns> -c <columns>"
            echo "    Show specified number of columns (width)."
            echo
            echo "  --show-other -o"
            echo "    Show the total size of packages not included in the list of results."
            echo "    The result named [other] is sorted along with other results."
            echo "    <!> Excluded packages are ignored in the count."
            echo
            echo "  --show-total -t"
            echo "    Show the total size of all packages."
            echo "    The result named [total] is displayed at the end of the list."
            echo "    <!> Excluded packages are ignored in the count."
            echo
            echo "  --show-all -a"
            echo "    Do not limit the output. Display all packages instead."
            echo "    <!> Excluded packages stay hidden even if all results should be displayed."
            echo
            echo "  --exclude <name> --exclude=<name> -e <name>"
            echo "    Exclude specified package(s)."
            echo "    The argument can be specified multiple times."
            echo "    <!> Excluded packages do not count towards [total] or [other] results."
            echo "    <!> Excluded packages stay hidden even if all results should be displayed."
            echo
            echo "  --help -h"
            echo "    Show this info."
            echo
            exit 0
        ;;
        --show-other|-o)
            options[other]=1
        ;;
        --show-total|-t)
            options[total]=1
        ;;
        --show-all|-a)
            options[lines]=-1;
        ;;
        --lines|-l)
            option_name='lines'
        ;;
        --lines=*)
            options[lines]="${arg/--lines=}"
        ;;
        --columns|-c)
            option_name='columns'
        ;;
        --columns=*)
            options[columns]="${arg/--columns=}"
        ;;
        --exclude|-e)
            option_name='exclude'
            option_multiple=1
        ;;
        --exclude=*)
            options[exclude]="${options[exclude]} ${arg/--exclude=}"
        ;;
        *)
            if [ ! -z "${option_name}" ]; then
                if [ ! -z "${option_multiple}" ]; then
                    options["${option_name}"]="${options["${option_name}"]} ${arg}"
                else
                    options["${option_name}"]="${arg}"
                fi
            fi
        ;;
    esac

    if [ ! -z "${option_name}" ] && [ ! -z "${unset_option_name}" ]; then
        unset option_name
        unset option_multiple
        unset unset_option_name
    fi
done

# get terminal size if at least one of options[lines] or options[columns] is not set
if [ -z "${options[lines]}" ] || [ -z "${options[columns]}" ]; then

    # try to refresh LINES and COLUMNS if at least one of them is not set
    if [ -z "${LINES}" ] || [ -z "${COLUMNS}" ]; then
        if command -v shopt &> /dev/null; then
            # store current checkwinsize state
            RESTORE_SHOPT_CHECKWINSIZE="$(shopt -p checkwinsize)"
            # allow bash to refresh LINES and COLUMNS after every external command
            shopt -s checkwinsize
            # run any external command to refresh LINES and COLUMNS
            cat /dev/null
            # restore previous checkwinsize state
            ${RESTORE_SHOPT_CHECKWINSIZE}
        fi
    fi

    # get number of lines if the custom value is not set
    if [ -z "${options[lines]}" ]; then
        # source .bashrc (if exists) to import bash prompt if PS1 is not set
        if [ -z "${PS1}" ] && [ -f ~/.bashrc ]; then
            source ~/.bashrc &> /dev/null
        fi

        # assume prompt size as number of lines in PS1
        prompt_lines="$(echo -e "${PS1}" | wc -l)"

        # try to get the number of terminal lines or use default
        terminal_lines="${LINES:-$(command -v tput &>/dev/null && tput lines || echo "${DEFAULT_LINES}")}"

        # subtract prompt height from terminal height
        options[lines]="$[${terminal_lines} - ${prompt_lines}]"
    fi

    # get number of columns if the custom value is not set
    if [ -z "${options[columns]}" ]; then
        # try to get the number of terminal columns or use default
        options[columns]="${COLUMNS:-$(command -v tput &>/dev/null && tput cols || echo "${DEFAULT_COLUMNS}")}"

        # limit columns
        options[columns]="$((options[columns] > LIMIT_COLUMNS ? LIMIT_COLUMNS : options[columns]))"
    fi
fi


AWK_UNIT_SIZE_FUNCTION='function bytes_to_unit_size(bytes)
{
    units[0] = "B";
    units[1] = "KiB";
    units[2] = "MiB";
    units[3] = "GiB";
    units[4] = "TiB";

    for (exponent = 0; exponent < 5; exponent++)
    {
        unit_size = bytes / 1024 ^ exponent;

        if (unit_size < 1024)
        {
            break;
        }
    }

    return sprintf("%7.2f %s", unit_size, units[exponent]);
}'


# Create Table: %{bytes}d %7.2{unit_size}f %{unit}s %{name}s
(
    # Ubuntu/Debian
    if command -v dpkg-query &> /dev/null; then
        LC_ALL=C dpkg-query --show --showformat='${Package} ${Installed-Size}\n' |
        awk "${AWK_UNIT_SIZE_FUNCTION}"'{
            name = $1;
            bytes = $2 * 1024;

            printf("%d %s %s\n", bytes, bytes_to_unit_size(bytes), name);
        }'
    fi

    # Fedora/RedHat/CentOS/OpenSUSE
    if command -v rpm &> /dev/null; then
        LC_ALL=C rpm --query --all --queryformat='%{name} %{size}\n' |
        awk "${AWK_UNIT_SIZE_FUNCTION}"'{
            name = $1;
            bytes = $2;

            printf("%d %s %s\n", bytes, bytes_to_unit_size(bytes), name);
        }'
    fi

    # OpenWRT
    if command -v opkg &> /dev/null; then
        LC_ALL=C opkg info |
        awk "${AWK_UNIT_SIZE_FUNCTION}"'{
            if ($1 == "Package:") {
                name = $2;
            };

            if ($1 == "Status:") {
                status = $NF;
            }

            if ($1 == "Size:" && status == "installed") {
                bytes = $2;

                printf("%d %s %s\n", bytes, bytes_to_unit_size(bytes), name);
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
                        bytes = unit_size;
                        break;
                    case "KiB":
                        bytes = unit_size * 1024;
                        break;
                    case "MiB":
                        bytes = unit_size * 1024 * 1024;
                        break;
                    case "GiB":
                        bytes = unit_size * 1024 * 1024 * 1024;
                        break;
                }

                printf("%d %7.2f %s %s\n", bytes, unit_size, unit, name);
            }
        }'
    fi
) |

# Order all entries by size
sort -rn |

awk \
    -v max_lines="${options[lines]}" \
    -v show_other="${options[other]}" \
    -v show_total="${options[total]}" \
    -v exclude_string="${options[exclude]}" \
    "${AWK_UNIT_SIZE_FUNCTION}"'BEGIN {
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

    {
        name = $4;

        if (!(name in exclude_dict)) {
            if (lines < max_lines || max_lines == -1) {
                print $0;
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
    }' |

# Order filtered entries by size
sort -rn |

# Render Table
awk \
    -v max_columns="${options[columns]}" \
    -v dotted_line="$(printf "%${options[columns]}s" | tr " " ".")" \
    -v cl_red_bold="\033[1;41m" \
    -v cl_green_bold="\033[1;42m" \
    -v cl_yellow_bold="\033[1;43m" \
    -v cl_default_bold="\033[0;1m" \
    -v cl_default="\033[0m" \
    '{
        bytes = $1;
        size = $2;
        unit = $3;
        name = $4;

        if (!max_bytes) {
            max_bytes = bytes;
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
