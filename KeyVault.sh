az login --service-principal -u 93dcd535-5b11-4e7b-9d36-6a3692e53b38 --password PvEmAlNijknOr/0QySAhzzpPRstRcWjZO1xWUWJkxeE= --tenant 72f988bf-86f1-41af-91ab-2d7cd011db47
az keyvault secret download --file "key.txt" --vault-name HTCondorKeyVault --name Key1 --encoding utf-8
