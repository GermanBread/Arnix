alias ln='/tmp/arnix-update/bin/toybox ln'
# WARNING: toybox bug: if both files are the same amount of directories deep (or the destination is one higher), the resulting symlink is broken

# Creating some directories that will be needed
mkdir -p /arnix/var/init-hooks

# Removing garbage (old file paths; not used anymore)
rm -f /arnix/arnix-bootstrap.sha1sum /arnix/arnix-bootstrap.sha1sum.txt /arnix/changelog.txt

# Move our new config file out of the config directory
[ -e /arnix/etc/arnix.conf ] && \
	mv -f /arnix/etc/arnix.conf /arnix/arnix.conf.new
[ ! -e /arnix/arnix.conf ] && \
	mv /arnix/arnix.conf.new /arnix/arnix.conf

# Arch
if [ -x /usr/bin/pacman ]; then
	ln -sf /arnix/etc/pacman-pre.hook /etc/pacman.d/hooks/0-arnix-create-generation.hook
	ln -sf /arnix/etc/pacman-post.hook /etc/pacman.d/hooks/100-arnix-change-symlink.hook
fi

# Move the system "binary" to /bin
[ -L /usr/bin/arnixctl ] && \
	rm -f /usr/bin/arnixctl
ln -sf /arnix/bin/arnixctl.sh /bin/arnixctl