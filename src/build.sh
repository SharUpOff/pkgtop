#!/usr/bin/env bash

# go to the script directory
cd "$(dirname ${BASH_SOURCE[0]})" &&

# merge bash includes
awk '{
    if ($1 == "source" || $1 == ".")
    {
        system("cat "$2);
    }
    else
    {
        print($0);
    }
}' < main.sh |

# merge awk includes
awk '{
    if ($1 == "-f") {
        printf("'\''");
        system("cat "$2);
        printf("'\'' %s\n", $3);
    }
    else if ($1 == "awk" && $2 == "-f") {
        printf("%s '\''", $1);
        system("cat "$3);
        printf("'\'' %s\n", $4);
    }
    else {
        print($0);
    }
}' > ../dist/pkgtop.sh

exit $?
