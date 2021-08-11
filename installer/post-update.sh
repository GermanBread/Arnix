alias ln='/tmp/arnix-update/bin/toybox ln'

[ ! -e /etc/pacman.d/hooks/100-arnix-change-symlink.hook ] && \
	ln -sr /arnix/etc/100-arnix-change-symlink.hook /etc/pacman.d/hooks/100-arnix-change-symlink.hook
if [ ! -e $(readlink /bin/arnixctl) ]; then
	ln -srfT /arnix/bin/arnixctl.sh /bin/arnixctl
fi