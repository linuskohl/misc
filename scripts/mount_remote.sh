#!/bin/zsh
# mount remote directory via sshfs and connect required
# vpn through NetworkManager

hostname=""
VPNConName=""
user=""
localDir=""
remoteDir=""
conOpts="reconnect,ServerAliveInterval=15,ServerAliveCountMax=3"

function vpn_connected () {
  if [[ "$(nmcli connection show --active | grep -c $VPNConName)" != "0" ]]; then
      echo 1
  else
      echo 0
  fi
}

function already_mounted () {
  if [[ "$(mount | grep -c $localDir)" != "0" ]]; then
     echo 1
  else
     echo 0
  fi
}

if [[ $1 == "mount" ]]; then
    if [[ $(already_mounted) == 0 ]]; then
        if [[ $(vpn_connected) == 1 ]]; then
            echo "VPN connected"
        else
            echo "Connecting VPN"
            nmcli c up $VPNConName
        fi
        echo "Mounting directory"
        sshfs -o "$conOpts" "$user"@"$hostname":"$remoteDir" "$localDir"
    else
        echo "Already mounted"
    fi
elif [[ $1 == "unmount" ]]; then
    if [[ $(already_mounted) == 0 ]]; then
        echo "Not mounted"
    else 
        echo "Unmounting"
            fusermount -u -z $localDir
    fi
fi
