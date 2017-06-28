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
mkdir -p /root/scripts
case "$distro_type" in
    "centos" | "redhat")
        #Install azure cli 2.0
        sudo yum check-update
        sudo yum install -y gcc libffi-devel python-devel openssl-devel
        curl -L https://aka.ms/InstallAzureCli > InstallAzureCli.sh
        INSTALL_SCRIPT_URL="https://azurecliprod.blob.core.windows.net/install.py"
        install_script=$(mktemp -t azure_cli_install_tmp_XXXX) || exit
        echo "Downloading Azure CLI install script from $INSTALL_SCRIPT_URL to $install_script."
        curl -# $INSTALL_SCRIPT_URL > $install_script || exit
        # check for the Python installation
        if ! command -v python >/dev/null 2>&1
        then
        echo "ERROR: Python not found. 'command -v python' returned failure."
        echo "If python is available on the system, add it to PATH. For example 'sudo ln -s /usr/bin/python3 /usr/bin/python'"
        exit 1
        fi
        # make python install script executable
        chmod 775 $install_script
        echo "Running install script."
        echo $install_script
        yes "y" | $install_script
        if echo $?
        then
        echo "export PATH=\$PATH:$(pwd)/y/" >> /root/.bashrc
        echo "source '$(pwd)/y/az.completion'" >> /root/.bashrc
        exec -l $SHELL
        fi
        if ! (echo $PATH | grep '$(pwd)/y/')
        then
        echo "Installation failed"
        fi
        # Retrieve commands which were uploaded from custom data and create shell script
        base64 --decode /var/lib/waagent/CustomData > "/root/scripts/keyVault.sh"
        ;;
    "debian" | "ubuntu")
        #Install azure cli 2.0
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list
        sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
        sudo apt-get install apt-transport-https
        sudo apt-get update && sudo apt-get install azure-cli
        # Retrieve commands which were uploaded from custom data and create shell script
        cat /var/lib/cloud/instance/user-data.txt > "/root/scripts/keyVault.sh"
        ;;
esac
# Register cron tab so when machine restart it downloads the secret from azure keyVault
chmod 700 /root/scripts/keyVault.sh
crontab -l > KeyVaultcron
echo "@reboot /root/scripts/keyVault.sh >> /root/scripts/keyVault.log" >> KeyVaultcron
crontab KeyVaultcron
rm KeyVaultcron
#Execute script
/root/scripts/keyVault.sh >> /root/scripts/keyVault.log
