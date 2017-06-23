#sudo yum check-update; sudo yum install -y gcc libffi-devel python-devel openssl-devel
#curl -s -L https://aka.ms/InstallAzureCli | bash
wget https://repo.continuum.io/archive/Anaconda3-4.3.1-Linux-x86_64.sh
chmod +x Anaconda3-4.3.1-Linux-x86_64.sh
./Anaconda3-4.3.1-Linux-x86_64.sh
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
python -m pip install -U pip
pip --version
pip install --user azure-cli