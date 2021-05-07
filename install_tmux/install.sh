#!/bin/bash
# ACTION: Install tmux and add some configs
# INFO: Install tmux and add config
# DEFAULT: y

# Config variables
base_dir="$(dirname "$(readlink -f "$0")")"
comment_mark='"DEBIAN-OPENBOX-tmux'

# Check root
[ "$(id -u)" -ne 0 ] && { echo "Must run as root" 1>&2; exit 1; }

# Install tmux
echo -e "\e[1mInstalling packages...\e[0m"
[ "$(find /var/cache/apt/pkgcache.bin -mtime 0 2>/dev/null)" ] || apt-get update
apt-get install -y tmux

# Config tmux for global (all users)
echo -e "\e[1mSetting configs to all users...\e[0m"
for d in  /etc/skel/  /home/*/ /root/; do
    [ "$(dirname "$d")" = "/home" ] && ! id "$(basename "$d")" &>/dev/null && continue	# Skip dirs that no are homes
    cp -v "${base_dir}/tmux.conf" "$d/.tmux.conf" && chown -R $(stat "$(dirname "$d/.tmux.conf")" -c %u:%g) "$d/.tmux.conf"
    echo "alias tmux='TERM=screen-256color tmux'" >> "$d/.bash_aliases"
done
