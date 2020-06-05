#!/bin/bash

backup_pacman_database() {
	tar -cjf pacman_database.tar.bz2 /var/lib/pacman/local
}

check_for_errors() {
	echo "Checking for failed systemd services..."
	systemctl --failed
	echo "Done"
	echo "Checking for journal errors..."
	sudo journalctl -p 3 -xb
	echo "Done"
}

create_pkglists() {
	pacman -Qqe > pkglist.txt
	comm -13 <(pacman -Qqdt | sort) <(pacman -Qqdtt | sort) > optdeplist.txt
	pacman -Qqem > foreignpkglist.txt
}

delete_broken_symlinks() {
	for symlink in $(sudo find / -xtype l); do
		if [[ ! "$symlink" =~ /run/* ]] && [[ ! "$symlink" =~ /proc/* ]]; then
			read -rp "Delete \"$symlink\"? (y/N) "
			if [ "$REPLY" == "y" ]; then
				rm "$symlink"
			fi
		fi
	done
}

# accepts dir to search for as an argument
remove_old_configs() {
	for folder in "$1"/*; do
		# to ensure folder is not empty
		[ -e "$folder" ] || continue
		read -rp "Delete $folder? (y/N)"
		if [ "$REPLY" == "y" ]; then
			rm -r "${folder:?}"
		fi
	done
}

remove_orphans() {
	sudo pacman -Rns "$(pacman -Qtdq)"
}

read -rp "Check for failed systemd services & errors in journal? (y/N) "
if [ "$REPLY" == "y" ]; then
	check_for_errors
fi

read -rp "Generate pkglists? (y/N) ";
if [ "$REPLY" == "y" ]; then
	create_pkglists
fi

read -rp "Backup pacman database? (y/N) ";
if [ "$REPLY" == "y" ]; then
	backup_pacman_database
fi

read -rp "Remove orphans? (y/N) ";
if [ "$REPLY" == "y" ]; then
	remove_orphans
fi

read -rp "Clean config dirs? (y/N) ";
if [ "$REPLY" == "y" ]; then
	echo "Processing ~/.config"
	remove_old_configs ~/.config
	echo "Processing ~/.cache"
	remove_old_configs ~/.cache
	echo "Processing ~/.local/share"
	remove_old_configs ~/.local/share
fi

read -rp "Delete broken symlinks? (y/N) ";
if [ "$REPLY" == "y" ]; then
	delete_broken_symlinks
fi
