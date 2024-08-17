#!/bin/bash

## MODIFY THOSE VARIABLES
path="../MacroLibX"
lib_name="MacroLibX" 
KEEP=0 ## set to 1 if you want to keep the lib directory and the cub3D executable
CHECKER=1 ## add norm and compilation check

## PROGRAM VARIABLES
MAGENTA='\033[0;35m'
GREEN='\033[0;32m'
BOLD_GREEN='\033[1;32m'
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
NC='\033[0m'
BOLD='\033[1m'
BOLD_CYAN='\033[1;36m'
total=0
successfull_tests=0

clean()
{
    rm invalid
    rm valid
    if [ $KEEP -eq 0 ]; then
        rm -rf MacroLibX
        rm cub3D
    fi
}
  
check_norminette()
{
    if ! command -v norminette &> /dev/null; then
        echo -e $RED"-> Norminette isn't installed on your system"$NC
    else
        norminette ../src ../includes > out
        if <out grep -q "Error"; then
            echo -e "Norminette :" $BOLD_RED"KO"$NC
        else
            echo -e "Norminette :" $BOLD_GREEN"OK"$NC
        fi
        rm out
    fi
}

check_compilation()
{
    make re -C ../ > out
    if [ $? -ne 0 ]; then
        echo -e "Compilation :" $BOLD_RED"KO"$NC
        rm out
        exit 1
    else
        echo -e "Compilation :" $BOLD_GREEN"OK"$NC
    fi
    rm out
}

setup_tester()
{
    if [ ! -d $path ]; then
        echo -e $RED"-> $lib_name directory not found"$NC
        exit 1
    fi
    if [ ! -d invalid_maps ] || [ ! -d valid_maps ]; then
        echo -e $RED"-> invalid_maps or valid_maps directory not found"$NC
        exit 1
    fi

    ls invalid_maps/* > invalid
    ls valid_maps/* > valid

    if [ ! -f invalid ] || [ ! -f valid ]; then
        echo -e $RED"-> invalid or valid file not found"$NC
        exit 1
    fi

    if [ $KEEP -eq 0 ]; then
        mv ../cub3D .
        if [ ! -f cub3D ]; then
            echo -e $RED"-> cub3D executable not found"$NC
            exit 1
        fi

        cp -R $path $lib_name
    fi
    nb_of_maps=$(wc -l invalid | awk '{print $1}')
    successfull_tests=0
    total=0
}

map_tester()
{
    setup_tester
    ## Invalid maps
    echo -e $BOLD_CYAN"\n--Invalid maps tests--\n"$NC
    while read -r line; do
        ./cub3D "$line" > out 2>&1
        if sed 's/\x1b\[[0-9;]*m//g' out | grep -q "Error"; then
            ((successfull_tests++))
            cat out
            echo -e "[ TEST $total ] : ($line)" $BOLD_GREEN"OK"$NC
        else
            echo -e "[ TEST $total ]: ($line)" $BOLD_RED"KO"$NC
        fi
        ((total++))
        rm out
    done < invalid

    ## Valid maps
    echo -e $BOLD_CYAN"\n--Valid maps tests--\n"$NC
    while read -r line; do
        ./cub3D "$line" > out 2>&1
        if sed 's/\x1b\[[0-9;]*m//g' out | grep -q "Error"; then
            echo -e "[ TEST $total ] : ($line)" $BOLD_RED"KO"$NC
        else
            ((successfull_tests++))
            echo -e "[ TEST $total ] : ($line)" $BOLD_GREEN"OK"$NC
        fi
        ((total++))
        rm out
    done < valid
    
    echo -e "\nTotal :" $MAGENTA"$successfull_tests/$total"$NC 
    clean
}

## MAIN
echo -e $BOLD_CYAN"--Starting tests--\n"$NC
if [ $CHECKER -eq 1 ]; then
    check_norminette
    check_compilation
fi
map_tester