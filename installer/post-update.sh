alias ln='/tmp/arnix-update/bin/toybox ln'

if command -v pacman &>/dev/null; then
	ln -srfT /arnix/etc/pacman-pre.hook /etc/pacman.d/hooks/0-arnix-create-generation.hook
	ln -srfT /arnix/etc/pacman-post.hook /etc/pacman.d/hooks/100-arnix-change-symlink.hook
fi
ln -srfT /arnix/bin/arnixctl.sh /usr/bin/arnixctl