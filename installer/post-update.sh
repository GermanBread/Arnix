alias ln='/tmp/arnix-update/bin/toybox ln'

command -v pacman &>/dev/null && \
	ln -srfT /arnix/etc/100-arnix-change-symlink.hook /etc/pacman.d/hooks/100-arnix-change-symlink.hook
ln -srfT /arnix/bin/arnixctl.sh /usr/bin/arnixctl