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
awk -v max_lines="${options[lines]}" \
    -v skip_lines="${options[skip]}" \
    -v show_other="${options[other]}" \
    -v show_total="${options[total]}" \
    -v exclude_string="${options[exclude]}" \
    -f ./includes/create_table.awk |

# Order filtered entries by size
sort -rn |

# Render Table
awk -v max_columns="${options[columns]}" \
    -v mark_string="${options[mark]}" \
    -v tty="${options[tty]}" \
    -f ./includes/render_table.awk

exit $?
