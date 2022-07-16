#!/usr/bin/env bash

# go to the script directory
cd "$(dirname ${BASH_SOURCE[0]})" &&

# merge bash includes
awk '{
    if ($1 == "source" || $1 == ".")
    {
        path = $2;
        indent = index($0, $1) - 1;
        prefix = substr($0, 0, indent);
        cmd = sprintf("bash -c '\''cat %s'\''", path, prefix);

        while ((cmd | getline source) > 0) {
            if (source)
            {
                printf("%s%s\n", prefix, source);
            } else {
                printf("\n");
            }
        }
    }
    else
    {
        print;
    }
}' < main.sh |

# include version
sed 's/$(cat ..\/VERSION)/'"$(cat ../VERSION)"'/g' |

# merge awk includes
awk '{
    if ($1 == "-f") {
        path = $2;
        indent = index($0, $1) - 1;
        prefix = substr($0, 0, indent);
        cmd = sprintf("bash -c '\''cat %s'\''", path, prefix);
        lines = 0;

        printf("%s'\''", prefix);

        while ((cmd | getline source) > 0) {
            if (lines == 0) {
                printf(source);
            } else {
                if (source)
                {
                    printf("\n%s%s", prefix, source);
                } else {
                    printf("\n");
                }
            }
            lines++;
        }

        if ($3) {
            printf("'\'' %s\n", $3);
        } else {
            printf("'\''\n");
        }
    }
    else if ($1 == "awk" && $2 == "-f") {
        path = $3;
        indent = index($0, $1) - 1;
        prefix = substr($0, 0, indent);
        cmd = sprintf("bash -c '\''cat %s'\''", path, prefix);
        lines = 0;

        printf("%s%s '\''", prefix, $1);

        while ((cmd | getline source) > 0) {
            if (lines == 0) {
                printf(source);
            } else {
                if (source)
                {
                    printf("\n%s%s", prefix, source);
                } else {
                    printf("\n");
                }
            }
            lines++;
        }

        if ($4) {
            printf("'\'' %s\n", $4);
        } else {
            printf("'\''\n");
        }
    }
    else {
        print;
    }
}' > ../dist/pkgtop.sh

exit $?
