#!/bin/bash

MAGENTA='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'
BOLD_CYAN='\033[1;36m'
total=0
successfull_tests=0

check_norminette()
{
    norminette ../src ../includes > out
    if <out grep -q "Error"; then
        echo -e "Norminette :" $RED"KO"$NC
    else
        echo -e "Norminette :" $GREEN"OK"$NC
    fi
    rm out
}

check_compilation()
{
    make re -C ../ > out
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
    if [ ! -f ../cub3D ]; then
        echo -e $RED"Cub3d executable not found..."$NC
        exit 1
    fi

    ls invalid_maps/* > invalid
    mv ../cub3D .
    cp -R ../MacroLibX .

    nb_of_maps=$(wc -l invalid | awk '{print $1}')

    cat invalid | while read line; do
        echo -e $BOLD_CYAN"Testing map $line"$NC
        ./cub3D $line > out
        if <out grep -q "Error"; then
            ((successfull_tests++))
            echo -e "Map $line :" $GREEN"OK"$NC
        else
            kill $(pidof cub3D)
            echo -e "Map $line :" $RED"OK"$NC
        fi
        ((total++))
        echo -e "\nTotal :" $MAGENTA"$successfull_tests/$total"$NC > total
        rm out
    done
    cat total
    rm invalid
    rm -rf MacroLibX
    rm cub3D
}

check_norminette
check_compilation
map_tester