# maintriarch
A small script to simplify Arch maintenance. Based on recommendations from the ArchWiki [System Maintenance](https://wiki.archlinux.org/index.php/System_maintenance) page

## Available maintenance actions

- check for failed systemd services & errors in journal
- generate pkglists
  + ```pkglist.txt``` for all explicitly installed packages
  + ```optdeplist.txt``` for all installed optional dependencies
  + ```foreignpkglist.txt``` for all AUR packages
- backup pacman database
- remove orphaned packages
- clean ```~/,config```, ```~/.cache``` and ```~/.local/share``` dirs (prompts for deletion of each file/dir inside)
- delete broken symlinks (prompts for each one found - very tedious)

## To do

- [x] ignore symlinks in /run/** and /proc/**
- [ ] create config file to store e.g. location for pkglists
- [ ] create a menu so that the user isn't prompted for each possible action
- [x] allow user to choose which pkglists to generate
- [ ] prompt before overriding any files
- [ ] provide output when deleting a file
- [ ] allow user to choose which dirs to clean
- [ ] auto-skip config files for packages which are still installed
- [ ] stop writing to dos and actually code
