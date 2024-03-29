#!/usr/bin/env bash
# Description: Show largest installed packages
# Author: SharUpOff<sharupoff@efstudios.org>
# License: GPLv3

# default lines and columns
DEFAULT_LINES=25
DEFAULT_COLUMNS=80
LIMIT_COLUMNS=80

# the settings array is used to store the values parsed from the command line arguments.
declare -A settings

# set default settings
settings[exclude]=""
settings[other]=0
settings[total]=0
settings[skip]=0

# detect tty
test ! -t 1
settings[tty]=$?

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
settings[lines]="$(parse_number "${1}")"

# process the second argument only if lines option is set
if [ ! -z "${settings[lines]}" ]; then
    # set the columns option if the second argument is a number
    settings[columns]="$(parse_number "${2}")"
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
            echo "[--skip <count>] [--exclude <name>] [--mark <name>] "
            echo "[--other] [--total] [--all] [--raw] [--version] [--help]"
            echo
            echo "  [lines] --lines <lines> --lines=<lines> -l <lines>"
            echo "    Show specified number of lines (results)."
            echo "    If [other] and/or [total] lines are enabled they are also included in the number of lines."
            echo
            echo "  [columns] --columns <columns> --columns=<columns> -c <columns>"
            echo "    Show specified number of columns (width)."
            echo
            echo "  --other --show-other -o"
            echo "    Show the total size of packages not included in the list of results."
            echo "    The result named [other] is sorted along with other results."
            echo "    <!> Excluded packages are ignored in the count."
            echo
            echo "  --total --show-total -t"
            echo "    Show the total size of all packages."
            echo "    The result named [total] is displayed at the end of the list."
            echo "    <!> Excluded packages are ignored in the count."
            echo
            echo "  --all --show-all -a"
            echo "    Do not limit the output. Display all packages instead."
            echo "    <!> Excluded packages stay hidden even if all results should be displayed."
            echo
            echo "  --raw -r"
            echo "    Preserve colour output even if tty is not detected."
            echo
            echo "  --skip <count> --skip=<count> -s <count>"
            echo "    Skip specified number of first package(s)."
            echo "    The argument can be specified multiple times."
            echo "    <!> Skipped packages do not count towards [total] or [other] results."
            echo "    <!> Skipped packages stay hidden even if all results should be displayed."
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
            echo "  --version -v"
            echo "    Show version info and exit."
            echo
            echo "  --help -h"
            echo "    Show this info and exit."
            echo
            exit 0
        ;;
        --version|-v)
            echo "1.1.0"
            exit 0
        ;;
        --other|--show-other|-o)
            settings[other]=1
        ;;
        --total|--show-total|-t)
            settings[total]=1
        ;;
        --all|--show-all|-a)
            settings[lines]=-1;
        ;;
        --raw|-r)
            settings[tty]=1;
        ;;
        --lines|-l)
            declare -A context
            context[name]='lines'
        ;;
        --lines=*)
            settings[lines]="${arg/--lines=}"
        ;;
        --columns|-c)
            declare -A context
            context[name]='columns'
        ;;
        --columns=*)
            settings[columns]="${arg/--columns=}"
        ;;
        --skip|-s)
            declare -A context
            context[name]='skip'
        ;;
        --skip=*)
            settings[skip]="${arg/--skip=}"
        ;;
        --exclude|-e)
            declare -A context
            context[name]='exclude'
            context[multiple]=1
        ;;
        --exclude=*)
            settings[exclude]="${settings[exclude]} ${arg/--exclude=}"
        ;;
        --mark|-m)
            declare -A context
            context[name]='mark'
            context[multiple]=1
        ;;
        --mark=*)
            settings[mark]="${settings[mark]} ${arg/--mark=}"
        ;;
        *)
            # an option context may be declared by the previous argument,
            # in which case the current argument is the value for that option
            if [ ! -z "${context[name]}" ]; then
                # the option can take multiple values if the multiple flag is set in the context
                if [ ! -z "${context[multiple]}" ]; then
                    settings[${context[name]}]="${settings[${context[name]}]} ${arg}"
                else
                    settings[${context[name]}]="${arg}"
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

# get terminal size if at least one of settings[lines] or settings[columns] is not set
if [ -z "${settings[lines]}" ] || [ -z "${settings[columns]}" ]; then

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
    if [ -z "${settings[lines]}" ]; then
        # if PS1 is not set
        if [ -z "${PS1}" ]; then
            SHELL_NAME="${SHELL-$(ps $$ -o comm="")}"

            case "${SHELL_NAME}" in
                */bash)
                    # source .bashrc (if exists) to import bash prompt
                    if [ -f "${HOME}/.bashrc" ]; then
                        source "${HOME}/.bashrc" &> /dev/null
                    fi
                ;;
                */zsh)
                    # source .zshrc (if exists) to import zsh prompt
                    if [ -f "${HOME}/.zshrc" ]; then
                        source "${HOME}/.zshrc" &> /dev/null
                    fi
                ;;
            esac
        fi

        # assume prompt size as number of lines in PS1
        prompt_lines="$(echo -e "${PS1}" | wc -l)"

        # try to get the number of terminal lines or use default
        terminal_lines="${LINES:-$(command -v tput &>/dev/null && tput lines || echo ${DEFAULT_LINES})}"

        # subtract prompt height from terminal height
        settings[lines]="$[${terminal_lines} - ${prompt_lines}]"
    fi

    # get number of columns if the custom value is not set
    if [ -z "${settings[columns]}" ]; then
        # try to get the number of terminal columns or use default
        settings[columns]="${COLUMNS:-$(command -v tput &>/dev/null && tput cols || echo ${DEFAULT_COLUMNS})}"

        # limit columns
        settings[columns]="$((settings[columns] > LIMIT_COLUMNS ? LIMIT_COLUMNS : settings[columns]))"
    fi
fi

# Output: %{bytes}d %{name}s
(
    # homebrew
    if command -v brew &> /dev/null; then
        # get installed packages
        brew list --formula |
        # get installed directories
        xargs brew --prefix |
        # get directories size
        xargs du -Lks |
        # format output: %{bytes}d %{name}\n
        awk '{
            sub("^.+/", "", $2);

            bytes = $1 * 1024;
            name = sprintf("homebrew/%s", $2);

            printf("%d %s\n", bytes, name);
        }'
    fi

    # ArchLinux (expac)
    # https://man.archlinux.org/man/community/expac/expac.1.en
    if command -v expac &> /dev/null; then
        # get installed packages in format: %{bytes}d %{name}\n
        expac '%m %n'

        # prevent other plugins from running
        exit $?
    fi
    # ArchLinux (pacman)
    # https://man.archlinux.org/man/pacman.8
    if command -v pacman &> /dev/null; then
        # get installed packages
        LC_ALL=C pacman -Qi |
        # format output: %{bytes}d %{name}\n
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

        # prevent other plugins from running
        exit $?
    fi
    # Fedora/RedHat/CentOS/OpenSUSE (rpm)
    if command -v rpm &> /dev/null; then
        # get installed packages in format: %{bytes}d %{name}\n
        rpm --query --all --queryformat='%{size} %{name}\n'

        # prevent other plugins from running
        exit $?
    fi
    # macOS (Applications)
    if [[ -d /Applications ]]; then
        # get directories size
        du -Lks /Applications/*.app |
        # format output: %{bytes}d %{name}\n
        awk '{
            sub("^.+/", "", $2);
            sub(".app$", "", $2);

            bytes = $1 * 1024;
            name = $2;

            printf("%d %s\n", bytes, name);
        }'

        # prevent other plugins from running
        exit $?
    fi
    # OpenWRT (opkg)
    if command -v opkg &> /dev/null; then
        # get installed packages
        LC_ALL=C opkg info |
        # format output: %{bytes}d %{name}\n
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

        # prevent other plugins from running
        exit $?
    fi
    # Ubuntu/Debian (dpkg-query)
    if command -v dpkg-query &> /dev/null; then
        # get installed packages
        dpkg-query --show --showformat='${Package} ${Installed-Size}\n' |
        # format output: %{bytes}d %{name}\n
        awk '{
            name = $1;
            bytes = $2 * 1024;

            printf("%d %s\n", bytes, name);
        }'

        # get installed packages
        exit $?
    fi

    echo "It seems your distribution is not supported." >&2
    echo "However, you are welcome to add the support:" >&2
    echo "https://github.com/SharUpOff/pkgtop#contribution" >&2
    exit 1
) |

# Order all entries by size
sort -rn |

# Output: %{bytes}d %7.2{size}f %{unit}s %{name}s
awk -v max_lines="${settings[lines]}" \
    -v skip_lines="${settings[skip]}" \
    -v show_other="${settings[other]}" \
    -v show_total="${settings[total]}" \
    -v exclude_string="${settings[exclude]}" \
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
        if (skipped_lines < skip_lines) {
            skipped_lines++;
        } else {
            name = $2;

            if (!(name in exclude_dict)) {
                bytes = $1;

                if (lines < max_lines || max_lines == -1) {
                    printf("%d %s %s\n", bytes, bytes_to_unit_size(bytes), name);
                    lines++;
                } else {
                    other_bytes += bytes;
                }

                total_bytes += bytes;
            }
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

# Output: %{bytes}d %7.2{size}f %{unit}s %{name}s %{name_bytes}d %{name_characters}d
awk '{
    name = $4;
    char_count = "wc -m";

    printf("%s %s ", $0, length(name));
    printf(name) | char_count;
    close(char_count);
}' |

# Render Table
awk -v max_columns="${settings[columns]}" \
    -v mark_string="${settings[mark]}" \
    -v tty="${settings[tty]}" \
    'BEGIN {
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
        name_bytes = $5;
        name_characters = $6;

        if (!max_bytes) {
            max_bytes = bytes;
        }

        if (name in mark_dict) {
            mark = "<";
        } else {
            mark = " ";
        }

        output = sprintf("%s %7.2f %-3s%s", dotted_line, size, unit, mark);

        if (tty && max_bytes) {
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

            output = (color colored_output cl_default_bold default_output cl_default);
        }

        char_size = name_bytes / name_characters;

        for (i = 1; i <= name_bytes; i += char_size) {
            sub("\\.", substr(name, i, char_size), output);
        }

        print(output);
    }'

exit $?
