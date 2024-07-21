#!/bin/bash

MAGENTA='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'
BOLD_CYAN='\033[1;36m'
total_tests=0
successfull_tests=0

check_norminette()
{
    norminette $(pwd) > out
    if <out grep -q "Error"; then
        echo -e "Norminette :" $RED"KO"$NC
    else
        echo -e "Norminette :" $GREEN"OK"$NC
    fi
    rm out
}

check_compilation()
{
    make re > out
    if [ $? -ne 0 ]; then
        echo -e "Compilation :" $RED"KO"$NC
        rm out
        exit 1
    else
        echo -e "Compilation :" $GREEN"OK"$NC
    fi
    rm out
}

map_tester()
{
    if [ ! -f cub3D ]; then
        echo -e $RED"Cub3d executable not found..."$NC
        exit 1
    fi

    ls invalid_maps/* > invalid

    cat invalid | while read line; do
        ((total_tests++))
        echo -e $BOLD_CYAN"Testing map $line"$NC
        ./cub3D $line > out
        if <out grep -q "Error"; then
            echo -e "Map $line :" $RED"KO"$NC
            ((successfull_tests++))
        else
            kill $(pidof cub3D)
            echo -e "Map $line :" $GREEN"OK"$NC
        fi
        rm out
        rm invalid
    done
    echo -e $BOLD_CYAN_CYAN $successfull_tests "/" $total_tests " tests passed"$NC
}

check_norminette
check_compilation
map_tester