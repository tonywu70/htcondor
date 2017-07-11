#!/bin/bash
distro_type=""
get_distro_type()
{
    release_info==$(cat /etc/*-release) 
    if [[ $(echo "$release_info" | grep 'Red Hat') != "" ]]; then 
        distro_type="redhat"; 
    elif [[ $(echo "$release_info" | grep 'CentOS') != "" ]] ; then 
        distro_type="centos"; 
    elif [[ $(echo "$release_info" | grep 'Ubuntu') != "" ]] ; then 
        distro_type="ubuntu"; 
    elif [[ $(echo "$release_info" | grep 'Scientfic Linux') != "" ]]; then 
        distro_type="centos";
    fi;
}
# Install jq JSON parser in CentOS or Red Hat
install_jq_redhat_centos()
{
    wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    chmod +x jq
    cp jq /usr/bin
}
# Install jq JSON parser in Ubuntu
install_jq_ubuntu()
{
    sudo apt-get install jq -y
}
# Get access token in JSON format and extract the token value
get_token()
{
    resource="https://vault.azure.net"
    authority="authority=https://login.microsoftonline.com/$tenantId&resource=$resource"
    localhost_uri="http://localhost:50342/oauth2/token"
    curl -o $temp/token.json --data "$authority" $localhost_uri
    token=$(jq -r '.access_token' $temp/token.json)
}
download_secret()
{
    mkdir -p /root/$keyvaultName
    touch /root/$keyvaultName/$secretName
    api_version="2016-10-01"
    secret_url="https://$keyvaultName.vault.azure.net/secrets/$secretName?api-version=$api_version"
    curl -G -H "Authorization: Bearer $token" -o $temp/output.json --url $secret_url
    jq -r '.value' $temp/output.json > /root/$keyvaultName/$secretName
}
remove_redundant_files()
{
    rm -rf $temp
}
main()
{
    temp=$(mktemp -d -t download_secret_tmp_XXXX) || exit
    get_distro_type
    case "$distro_type" in
        "centos" | "redhat")
        if ! command -v jq >/dev/null 2>&1
        then
            echo "Installing jq..."
            install_jq_redhat_centos
            jq --version
        fi
        # Retrieve Azure Key Vault and Secret name
        #base64 --decode /var/lib/waagent/CustomData > $temp/secret.info
        ;;
        "ubuntu")
        if ! command -v jq >/dev/null 2>&1
        then
            echo "Installing jq..."
            install_jq_ubuntu
            jq --version
        fi
        # Retrieve Azure Key Vault and Secret name
        #cat /var/lib/cloud/instance/user-data.txt > $temp/secret.info
        ;;
    esac
    source secret.info
    echo "Getting access token..."    
    get_token
    echo "Downloading secret..."
    download_secret
    echo "Deleting redundant files..."
    remove_redundant_files
}
main
