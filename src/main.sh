#!/usr/bin/env bash
# Description: Show largest installed packages
# Author: SharUpOff<sharupoff@efstudios.org>
# License: GPLv3

source ./includes/parse_arguments.sh

source ./includes/auto_size.sh

# Output: %{bytes}d %{name}s
(
    source ./includes/distributions/*/*.sh

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
    -f ./includes/create_table.awk |

# Order filtered entries by size
sort -rn |

# Render Table
awk -v max_columns="${settings[columns]}" \
    -v mark_string="${settings[mark]}" \
    -v tty="${settings[tty]}" \
    -f ./includes/render_table.awk

exit $?
