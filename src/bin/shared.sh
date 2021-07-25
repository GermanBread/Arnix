#!/bin/sh
error() {
    printf "$(tput setaf 1)[!] ERROR:$(tput sgr0) $*\n"
}
log() {
    printf "$(tput setaf 5)[!] INFO:$(tput sgr0) $*\n"
}
# Use $answer to retrieve the response
question() {
    printf "$(tput setaf 6)[!] QUESTION:$(tput sgr0) $* "
    read answer
}
# Checks if the requirements for the scripts are statisfied, if else exists
check_for_action_requirements() {
    if [ $(id -u) -ne 0 ]; then
        error "This script needs to run as root"
        exit 1
    fi
    if [ ! -d /arnix ]; then
        error "Arnix is not installed"
        exit 1
    fi
}