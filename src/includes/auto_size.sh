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
