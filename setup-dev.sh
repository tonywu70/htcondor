#!/bin/bash
release_info==$(cat /etc/*-release)
 
if [[ $(echo "$release_info" | grep 'Red Hat') != "" ]]; then 
    distro_type="redhat"; 
elif [[ $(echo "$release_info" | grep 'CentOS') != "" ]] ; then 
    distro_type="centos"; 
elif [[ $(echo "$release_info" | grep 'Ubuntu') != "" ]] ; then 
    distro_type="ubuntu"; 
elif [[ $(echo "$release_info" | grep 'Debian') != "" ]]; then 
    distro_type="debian"; 
elif [[ $(echo "$release_info" | grep 'Scientfic Linux') != "" ]]; then 
    distro_type="centos";
fi;

case "$distro_type" in
    "centos" | "redhat")
        sudo yum check-update
        sudo yum install -y gcc libffi-devel python-devel openssl-devel
        curl -L https://aka.ms/InstallAzureCli > InstallAzureCli.sh
        INSTALL_SCRIPT_URL=$(grep -Eoi 'https://[^"]+install.py' InstallAzureCli.sh)
        INSTALL_SCRIPT_SHA256=$(grep -Eoi 'SHA256=[a-z0-9]+' InstallAzureCli.sh | cut -f2 -d=)
        install_script=$(mktemp -t azure_cli_install_tmp_XXXX) || exit
        echo "Downloading Azure CLI install script from $INSTALL_SCRIPT_URL to $install_script."
        curl -# $INSTALL_SCRIPT_URL > $install_script || exit
        if command -v sha256sum >/dev/null 2>&1
        then
        echo "$INSTALL_SCRIPT_SHA256  $install_script" | sha256sum -c - || exit
        elif command -v shasum >/dev/null 2>&1
        then
        echo "$INSTALL_SCRIPT_SHA256  $install_script" | shasum -a 256 -c - || exit
        fi
        if ! command -v python >/dev/null 2>&1
        then
        echo "ERROR: Python not found. 'command -v python' returned failure."
        echo "If python is available on the system, add it to PATH. For example 'sudo ln -s /usr/bin/python3 /usr/bin/python'"
        exit 1
        fi
        chmod 775 $install_script
        echo "Running install script."
        echo $install_script
        yes "y" | $install_script
        if echo $?
        then
        export PATH=$PATH:$HOME/y/
        echo $PATH
        fi
        if ! (echo $PATH | grep -Eoq '/y/')
        then
        echo "Installation failed"
        fi
        ;;
    "debian" | "ubuntu")
        #echo $distro_type

        #Install azure cli 2.0
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list
        sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
        sudo apt-get install apt-transport-https
        sudo apt-get update && sudo apt-get install azure-cli
        ;;
esac
echo $PATH
# Retrieve commands which were uploaded from custom data and create shell script
mkdir -p /root/scripts
cat /var/lib/cloud/instance/user-data.txt > "/root/scripts/keyVault.sh"

# Register cron tab so when machine restart it downloads the secret from azure keyVault
chmod 700 /root/scripts/keyVault.sh
crontab -l > KeyVaultcron
echo "@reboot /root/scripts/keyVault.sh >> /root/scripts/log.txt" >> KeyVaultcron
crontab KeyVaultcron
rm KeyVaultcron

#Execute script
/root/scripts/keyVault.sh >> /root/scripts/log.txt

exit 0
