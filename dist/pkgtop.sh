#/usr/bin/env bash
# Description: Show largest installed packages
# Author: SharUpOff<sharupoff@efstudios.org>
# License: GPLv3

# default lines and columns
DEFAULT_LINES=25
DEFAULT_COLUMNS=80
LIMIT_COLUMNS=80

# the options array is used to store the values parsed from the command line arguments.
declare -A options

# set default options
options[exclude]=""
options[other]=0
options[total]=0

# detect tty
test ! -t 1
options[tty]=$?

# process positional arguments: [lines [columns]]
parse_number()
{
    ##################### the input string:
    #
    #      +------------- can contain one minus sign at the beginning;
    #      |      +------ the second character should be a digit 1 to 9;
    #      |      |    +- can only contain digits 0 to 9 until the end;
    #      |      |    |
    egrep '^-{0,1}[1-9][0-9]*$' <<< "${1}"

    return $?
}

# set the lines option if the first argument is a number
options[lines]="$(parse_number "${1}")"

# process the second argument only if lines option is set
if [ ! -z "${options[lines]}" ]; then
    # set the columns option if the second argument is a number
    options[columns]="$(parse_number "${2}")"
fi

# process keyword arguments
for arg in $@; do

    # an option context may be declared by the previous argument,
    # in which case the current argument is the value for that option
    if [ ! -z "${context[name]}" ]; then
        # mark the option context to be closed after processing the current argument
        context[close]=1
    fi

    case $arg in
        --help|-h)
            echo -n "Usage: ${0} [lines [columns]] "
            echo "[--exclude <name>] [--mark <name>] [--show-other] [--show-total] [--show-all] [--safe] [--help]"
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
            echo "  --safe -s"
            echo "    Preserve colour output."
            echo
            echo "  --exclude <name> --exclude=<name> -e <name>"
            echo "    Exclude specified package(s)."
            echo "    The argument can be specified multiple times."
            echo "    <!> Excluded packages do not count towards [total] or [other] results."
            echo "    <!> Excluded packages stay hidden even if all results should be displayed."
            echo
            echo "  --mark <name> --mark=<name> -m <name>"
            echo "    Mark specified package(s)."
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
        --safe|-s)
            options[tty]=1;
        ;;
        --lines|-l)
            declare -A context
            context[name]='lines'
        ;;
        --lines=*)
            options[lines]="${arg/--lines=}"
        ;;
        --columns|-c)
            declare -A context
            context[name]='columns'
        ;;
        --columns=*)
            options[columns]="${arg/--columns=}"
        ;;
        --exclude|-e)
            declare -A context
            context[name]='exclude'
            context[multiple]=1
        ;;
        --exclude=*)
            options[exclude]="${options[exclude]} ${arg/--exclude=}"
        ;;
        --mark|-m)
            declare -A context
            context[name]='mark'
            context[multiple]=1
        ;;
        --mark=*)
            options[mark]="${options[mark]} ${arg/--mark=}"
        ;;
        *)
            # an option context may be declared by the previous argument,
            # in which case the current argument is the value for that option
            if [ ! -z "${context[name]}" ]; then
                # the option can take multiple values if the multiple flag is set in the context
                if [ ! -z "${context[multiple]}" ]; then
                    options[${context[name]}]="${options[${context[name]}]} ${arg}"
                else
                    options[${context[name]}]="${arg}"
                fi
            fi
        ;;
    esac

    # an option context may be declared by the previous argument,
    # in which case the current argument is the value for that option
    if [ ! -z "${context[close]}" ]; then
        # now the time to close the option context
        unset context
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
        terminal_lines="${LINES:-$(command -v tput &>/dev/null && tput lines || echo ${DEFAULT_LINES})}"

        # subtract prompt height from terminal height
        options[lines]="$[${terminal_lines} - ${prompt_lines}]"
    fi

    # get number of columns if the custom value is not set
    if [ -z "${options[columns]}" ]; then
        # try to get the number of terminal columns or use default
        options[columns]="${COLUMNS:-$(command -v tput &>/dev/null && tput cols || echo ${DEFAULT_COLUMNS})}"

        # limit columns
        options[columns]="$((options[columns] > LIMIT_COLUMNS ? LIMIT_COLUMNS : options[columns]))"
    fi
fi

# Create Table: %{bytes}d %{name}s
(
    # Ubuntu/Debian (dpkg-query)
    if command -v dpkg-query &> /dev/null; then
        dpkg-query --show --showformat='${Package} ${Installed-Size}\n' |
awk '{
    name = $1;
    bytes = $2 * 1024;

    printf("%d %s\n", bytes, name);
}' 

    # Fedora/RedHat/CentOS/OpenSUSE (rpm)
    elif command -v rpm &> /dev/null; then
        rpm --query --all --queryformat='%{size} %{name}\n'

    # OpenWRT (opkg)
    elif command -v opkg &> /dev/null; then
        LC_ALL=C opkg info |
awk '{
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
}' 

    # ArchLinux (expac)
    # https://man.archlinux.org/man/community/expac/expac.1.en
    elif command -v expac &> /dev/null; then
        expac '%m %n'

    # ArchLinux (pacman)
    # https://man.archlinux.org/man/pacman.8
    elif command -v pacman &> /dev/null; then
        LC_ALL=C pacman -Qi |
awk 'function unit_size_to_bytes(size, unit)
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
}' 
    fi
) |

# Order all entries by size
sort -rn |

# Create Table: %{bytes}d %7.2{unit_size}f %{unit}s %{name}s
awk \
    -v max_lines="${options[lines]}" \
    -v show_other="${options[other]}" \
    -v show_total="${options[total]}" \
    -v exclude_string="${options[exclude]}" \
'BEGIN {
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
}' |

# Order filtered entries by size
sort -rn |

# Render Table
awk \
    -v max_columns="${options[columns]}" \
    -v mark_string="${options[mark]}" \
    -v dotted_line="$(printf "%${options[columns]}s" | tr " " ".")" \
    -v tty="${options[tty]}" \
'BEGIN {
    cl_red_bold="\033[1;41m";
    cl_green_bold="\033[1;42m";
    cl_yellow_bold="\033[1;43m";
    cl_default_bold="\033[0;1m";
    cl_default="\033[0m";

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
    margin_right = 7 + 3 + 3;  // 7 size + 3 unit + 3 space characters

    if (name in mark_dict) {
        mark = "<";
    } else {
        mark = " ";
    }

    line = sprintf(sprintf("%%.%ds %%7.2f %%3s%%s", max_columns - margin_right), name dotted_line, size, unit, mark);

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
}' 

exit $?
