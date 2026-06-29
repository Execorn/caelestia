function fish_greeting
    echo -ne '\x1b[38;5;16m'  # Set colour to primary
    echo '      ___  _  _____  _________  _________ '
    echo '     / _ \| |/_/ _ \/ ___/ __ \/ ___/ __ \\'
    echo '    /  __/>  </  __/ /__/ /_/ / /  / / / /'
    echo '    \___/_/|_|\___/\___/\____/_/  /_/ /_/ '
    set_color normal
    fastfetch --key-padding-left 5

    # Show random motivational quote
    if test -f ~/.config/fastfetch/quotes.txt; and command -sq shuf
        printf '    \e[3m\e[38;5;16m"%s"\e[0m\n\n' (shuf -n 1 ~/.config/fastfetch/quotes.txt)
    end
end
