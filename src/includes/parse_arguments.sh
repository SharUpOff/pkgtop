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
            echo "$(cat ../VERSION)"
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
