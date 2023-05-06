if [ -d /arnix ]; then
    alias ln='/arnix/bin/toybox ln'
    alias sha1sum='/arnix/bin/toybox sha1sum'
fi

log() {
    printf "\033[35m[-] INFO:\033(B\033[m $*\n"
}
warning() {
    printf "\033[33m[=] WARNING:\033(B\033[m $*\n"
}
error() {
    printf "\033[31m[!] ERROR:\033(B\033[m $*\n"
}
# Use $answer to retrieve the response
question() {
    printf "\033[36m[?] QUESTION:\033(B\033[m $* "
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
progress() {
    awk -v"total=${1:-0}" -v"label=$2" '
        BEGIN {
            spinner[0] = "⠁"
            spinner[1] = "⠉"
            spinner[2] = "⠙"
            spinner[3] = "⠛"
            spinner[4] = "⠟"
            spinner[5] = "⠿"
            spinner[6] = "⠟"
            spinner[7] = "⠛"
            spinner[8] = "⠙"
            spinner[9] = "⠉"
        }
        {
            printf "\r\033[35m[%s %3d%%]\033(B\033[m %s", spinner[NR % 10], (NR / total) * 100, label
        }
        END {
            printf "\r\033[35m[⠕ 100%%]\n"
        }
    ' -;
}
progress_lc() {
    awk -v"total=${1:-0}" -v"label=$2" '
        BEGIN {
            spinner[0] = "⠁"
            spinner[1] = "⠉"
            spinner[2] = "⠙"
            spinner[3] = "⠛"
            spinner[4] = "⠟"
            spinner[5] = "⠿"
            spinner[6] = "⠟"
            spinner[7] = "⠛"
            spinner[8] = "⠙"
            spinner[9] = "⠉"
        }
        {
            printf "\r\033[35m[%s %d|%d]\033(B\033[m %s", spinner[NR % 10], NR, total, label
        }
        END {
            printf "\r\033[35m[⠕ 100%%]\033(B\033[m %s\033[0K\n", label
        }
    ' -;
}
progress_unknown() {
    awk -v"label=$1" '
        BEGIN {
            spinner[0] = "⠁"
            spinner[1] = "⠉"
            spinner[2] = "⠙"
            spinner[3] = "⠛"
            spinner[4] = "⠟"
            spinner[5] = "⠿"
            spinner[6] = "⠟"
            spinner[7] = "⠛"
            spinner[8] = "⠙"
            spinner[9] = "⠉"
        }
        {
            printf "\r\033[35m[%s  ??%%]\033(B\033[m %s", spinner[NR % 10], label
        }
        END {
            printf "\r\033[35m[⠕ 100%%]\n"
        }
    ' -;
}
progress_unknown_lc() {
    awk -v"label=$1" '
        BEGIN {
            spinner[0] = "⠁"
            spinner[1] = "⠉"
            spinner[2] = "⠙"
            spinner[3] = "⠛"
            spinner[4] = "⠟"
            spinner[5] = "⠿"
            spinner[6] = "⠟"
            spinner[7] = "⠛"
            spinner[8] = "⠙"
            spinner[9] = "⠉"
        }
        {
            printf "\r\033[35m[%s %d]\033(B\033[m %s", spinner[NR % 10], NR, label
        }
        END {
            printf "\r\033[35m[⠕]\033(B\033[m %s\033[0K\n", label
        }
    ' -;
}