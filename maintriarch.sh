#!/bin/bash

#############
# Functions #
#############

backup_pacman_database() {
	[ "$(check_before_overwrite pacman_database.tar.bz2)" == "true" ] && tar -cjf pacman_database.tar.bz2 /var/lib/pacman/local
}

# Takes a filename as its first argument, then returns a boolean representing whether or not to overwrite the file
check_before_overwrite() {
	if [ -e "$1" ]; then
		read -rp "$1 already exits, would you like to overwrite it? (y/N) "
		if [ "$REPLY" == "y" ]; then
			echo "true"
		else
			echo "false"
		fi
	else
		echo "true"
	fi
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
	read -rp "Generate list of explicitly installed packages? (y/N) "
	if [ "$REPLY" == "y" ]; then
		[ "$(check_before_overwrite pkglist.txt)" == "true" ] && pacman -Qqe > pkglist.txt
	fi
	read -rp "Generate list of installed optional dependencies? (y/N) "
	if [ "$REPLY" == "y" ]; then
		[ "$(check_before_overwrite optdeplist.txt)" == "true" ] && comm -13 <(pacman -Qqdt | sort) <(pacman -Qqdtt | sort) > optdeplist.txt
	fi
	read -rp "Generate list of installed foreign packages? (y/N) "
	if [ "$REPLY" == "y" ]; then
		[ "$(check_before_overwrite foreignpkglist.txt)" == "true" ] && pacman -Qqem > foreignpkglist.txt
	fi
}

delete_broken_symlinks() {
	for symlink in $(sudo find / -xtype l); do
		if [[ ! "$symlink" =~ /run/* ]] && [[ ! "$symlink" =~ /proc/* ]] && [[ ! "$symlink" =~ /.snapshots/* ]]; then
			read -rp "Delete \"$symlink\"? (y/N) "
			if [ "$REPLY" == "y" ]; then
				rm "$symlink"
				echo "Deleted $symlink"
			fi
		fi
	done
}

# accepts dir to search for as an argument
remove_old_configs() {
	for folder in "$1"/*; do
		# to ensure folder is not empty
		[ -e "$folder" ] || continue
		read -rp "Delete $folder? (y/N) "
		if [ "$REPLY" == "y" ]; then
			rm -r "${folder:?}"
			echo "Deleted $folder"
		fi
	done
}

remove_orphans() {
	sudo pacman -Rns "$(pacman -Qtdq)"
}

#############
# Main code #
#############

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
	read -rp "Clean ~/.config? (y/N) ";
	if [ "$REPLY" == "y" ]; then
		remove_old_configs ~/.config
	fi
	read -rp "Clean ~/.cache? (y/N) ";
	if [ "$REPLY" == "y" ]; then
		remove_old_configs ~/.cache
	fi
	read -rp "Clean ~/.local/share? (y/N) ";
	if [ "$REPLY" == "y" ]; then
		remove_old_configs ~/.local/share
	fi
fi

read -rp "Delete broken symlinks? (y/N) ";
if [ "$REPLY" == "y" ]; then
	delete_broken_symlinks
fi
