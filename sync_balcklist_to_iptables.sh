#!/bin/bash

# Set environment variables
export SHELL=/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Debugging line
echo "Script started at $(date)" >> /tmp/script_log.txt

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
	echo "Veuillez exécuter ce script en tant que superutilisateur (root)."
	exit 1
fi

BANLIST_URL="https://raw.githubusercontent.com/fgladu/SRC_IP_Blacklist/main/blacklist.txt"
CHAIN_NAME="BANLIST"

# Full paths to executables
/sbin/iptables -N $CHAIN_NAME 2>/dev/null
/sbin/iptables -F $CHAIN_NAME

# Download the banlist from the URL and read each IP to add to the BANLIST chain
while read -r IP; do
	if [[ -n "$IP" ]]; then
		/sbin/iptables -A $CHAIN_NAME -s $IP -j DROP
		echo "Added $IP to $CHAIN_NAME chain."
	fi
done < <(/usr/bin/curl -s "$BANLIST_URL")

# Redirect traffic to the BANLIST chain
/sbin/iptables -I INPUT -j $CHAIN_NAME
/sbin/iptables -I OUTPUT -j $CHAIN_NAME

# Save the iptables rules
/usr/sbin/service iptables save

# Debugging line
echo "Script finished at $(date)" >> /tmp/script_log.txt

echo "Adresses IP en liste noire depuis $BANLIST_URL ajoutées à iptables et enregistrées."
