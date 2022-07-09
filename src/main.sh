#/usr/bin/env bash
# Description: Show largest installed packages
# Author: SharUpOff<sharupoff@efstudios.org>
# License: GPLv3

source ./includes/parse_arguments.sh


source ./includes/auto_size.sh


# Create Table: %{bytes}d %{name}s
(
    # Ubuntu/Debian (dpkg-query)
    if command -v dpkg-query &> /dev/null; then
        dpkg-query --show --showformat='${Package} ${Installed-Size}\n' |
        awk -f ./includes/distributions/ubuntu/dpkg-query.awk

    # Fedora/RedHat/CentOS/OpenSUSE (rpm)
    elif command -v rpm &> /dev/null; then
        rpm --query --all --queryformat='%{size} %{name}\n'

    # OpenWRT (opkg)
    elif command -v opkg &> /dev/null; then
        LC_ALL=C opkg info |
        awk -f ./includes/distributions/openwrtorg/opkg.awk

    # ArchLinux (expac)
    # https://man.archlinux.org/man/community/expac/expac.1.en
    elif command -v expac &> /dev/null; then
        expac '%m %n'

    # ArchLinux (pacman)
    # https://man.archlinux.org/man/pacman.8
    elif command -v pacman &> /dev/null; then
        LC_ALL=C pacman -Qi |
        awk -f ./includes/distributions/archlinux/pacman.awk
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
    -f ./includes/create_table.awk |

# Order filtered entries by size
sort -rn |

# Render Table
awk \
    -v max_columns="${options[columns]}" \
    -v mark_string="${options[mark]}" \
    -v dotted_line="$(printf "%${options[columns]}s" | tr " " ".")" \
    -v tty="${options[tty]}" \
    -f ./includes/render_table.awk

exit $?
