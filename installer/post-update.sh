alias ln='/tmp/arnix-update/bin/toybox ln'

# toybox bug: if both files are the same amount of directories deep (or the destination is one higher), the resulting symlink is broken

mkdir -p /arnix/var
[ -e /arnix/arnix-bootstrap.sha1sum.txt ] && \
	mv -f /arnix/arnix-bootstrap.sha1sum.txt /arnix/var/arnix-bootstrap.sha1sum.txt
[ -e /arnix/etc/arnix.conf ] && \
	mv /arnix/etc/arnix.conf /arnix/arnix.conf.new
[ ! -e /arnix/arnix.conf ] && \
	mv /arnix/arnix.conf.new /arnix/arnix.conf
# Arch
if [ -x /usr/bin/pacman ]; then
	ln -sf ../../../arnix/etc/pacman-pre.hook /etc/pacman.d/hooks/0-arnix-create-generation.hook
	ln -sf ../../../arnix/etc/pacman-post.hook /etc/pacman.d/hooks/100-arnix-change-symlink.hook
	ln -sf ../../arnix/bin/arnixctl.sh /usr/bin/arnixctl
fi