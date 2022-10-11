# Arnix

Linux with generations - and a nice tool to mange those

---

## Installing

Download the newest installer [from here](https://github.com/GermanBread/Arnix/releases/latest) and execute it as root

Installer is broken again, will fix sometime. In the meantime, clone the repo, cd into `src` and run the hijack script

### Post install

- Use `arnixctl` to manage Arnix!
- Configure the behaviour of Arnix with `arnixctl edit`
- Add `quiet` to kernel parameters for quiet boot
- Add `arnix.rollback` to kernel parameters to revert to a generation from within init

### Uninstalling

- Run `arnixctl uninstall` as root

---

## Troubleshooting

See wiki
