# Arnix

Arch Linux with generations - and a nice tool to mange those

## WARNING: I am currently rewriting major parts of Arnix. Hijacking ABSOLUTELY WILL result in an unbootable system!

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

*Note: there currently are no releases, you need to clone the repo and then cd to the script. After installing you should switch to the unstable branch immediately*

## Installing

- Download the newest release
- `cd` into the directory of this script `cd /path/to/script`
- Run `bash hijack.sh` as root (only bash is supported)

### Post install

- Use `arnixctl` to manage Arnix!
- Configure the behaviour of Arnix by editing `/arnix/etc/arnix.conf`
- Add `quiet` to kernel parameters for quiet boot

---

## Known issues

### Reverting to a previous generation throws me into emergency mode

-> Fixed in this commit https://github.com/GermanBread/Arnix/commit/c6ca60405176be485dc443be7f744b098e6f4303

### My GRUB theme doesn't work!

Working on it. The script should symlink /usr/share/grub from now on.
Need to investigate if Btrfs subvolumes cause issues.

### I have another issue not mentioned in here

Open a issue and fill out the fields