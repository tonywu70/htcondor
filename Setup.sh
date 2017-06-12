echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli

chmod 700 /root/keyVault.sh
	crontab -l > KeyVaultcron
	echo "@reboot /root/keyVault.sh >>/root/log.txt" >> KeyVaultcron
	crontab KeyVaultcron
	rm KeyVaultcron