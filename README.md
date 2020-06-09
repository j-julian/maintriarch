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

