# Arnix

Arch Linux with generations - and a nice tool to mange those

Current status: **STABLE**

---

## Installing

- Download the newest release and extract it somewhere
- `cd` into the extracted archive `cd extracted/src/`
- Run `./hijack.sh` as root

### Post install

- Use `arnixctl` to manage Arnix!
- Configure the behaviour of Arnix by editing `/arnix/etc/arnix.conf`
- Add `quiet` to kernel parameters for quiet boot
- Add `rollback` to kernel parameters to revert to a generation from within init

### Uninstalling

- Run `arnixctl uninstall` as root

---

## Troubleshooting

See wiki