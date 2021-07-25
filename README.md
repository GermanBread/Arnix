# Arnix

Arch Linux with generations - and a nice tool to mange those

---

## Q/A

### Why don't you just symlink the directories?

Trust me, I tried.
The OS *did* boot, though pacman didn't like that at all.
So I had to take another approach... and that was by ~~ab~~using `mount`.

### How does this work?

After you launch the script and got past the warning the script does the following (in order):
- Install `arch-install-scripts`
- Install a bare-minimum install of Arch Linux in /tmp/
- Install Arnix to /arnix and symlink busybox a bunch of times
- `pivot_root` to the install in /tmp
- Create a blank generation 1
- Move all the directories defined in `files/arnix.conf` into generation 1
- Link /usr/bin to /arnix/bin
- Apply workarounds for systemd-chainloading to work (systemd mkinitcpio hook). Turns out systemd does not like that lack of the `/etc/os-release`
- Activate generation 1 (basically spams mount --bind a few times)
and
- Uses `pivot_root` to revert the system back to a usable state

---

## Installing

- Clone this repo `git clone https://github.com/GermanBread/Arnix`
- `cd` into the directory for this script `cd /path/to/cloned/repo/src`
- Run `bash hijack.sh` as root (only bash is supported)

### Post install

- Use `arnixctl` to manage Arnix!
- Configure the behaviour of Arnix by editing `/arnix/etc/arnix.conf`
- Add `quiet` to kernel parameters for quiet boot

---

## Known issues

### 'failed to unmount /var'

Working on it

### Reverting to a previous generation throws me into emergency mode

If you see 'failed to mount /boot' after rolling back then switch back to the newest generation.
This is caused because the kernel modules in /lib/modules aren't compatible with a newer kernel.
I am looking for a fix. In the meanwhile you can either:
- copy the modules manually `cp -al {/arnix/generations/latest,}/usr/lib/modules/$(uname -r)`

In the future I want kernels to be restored too. For the time being this is an ugly workaround.

### I have another issue not mentioned in here

Open a issue and fill out the fields