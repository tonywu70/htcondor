#sudo yum check-update; sudo yum install -y gcc libffi-devel python-devel openssl-devel
#curl -s -L https://aka.ms/InstallAzureCli | bash
yum -y install epel-release
yum -y install python34 python34-devel
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
pip3 install --user azure-cli