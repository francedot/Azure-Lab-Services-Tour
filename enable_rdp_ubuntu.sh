cat > install_rdp.sh <<EOF
sudo apt-get update
sudo apt-get install xfce4
sudo apt-get -y install xrdp
sudo systemctl enable xrdp
echo xfce4-session >~/.xsession
sudo service xrdp restart
sudo netstat -plnt | grep rdp
EOF

chmod 0777 install_rdp.sh

./install_rdp.sh

#####

sudo apt-get update
sudo apt-get install xfce4
sudo apt-get -y install xrdp
sudo systemctl enable xrdp

echo xfce4-session >~/.xsession
sudo service xrdp restart
sudo netstat -plnt | grep rdp
tail -f /var/log/syslog

# Add network rule so that I am able to access port 3389 which is standard for rdp traffic.
# With Azure Cloud Shell
az vm open-port --resource-group "<RG_GROUP_NAME>" --name "centosmongovm" --port 3389
# or
# For more control over the rules, such as defining a source IP address range, Create the network security group with az network nsg create.
az network nsg create --resource-group "<RG_GROUP_NAME>" --location "West Europe" --name "<SECURITY_GROUP_NAME>"
az network nsg rule create --resource-group "<RG_GROUP_NAME>" --nsg-name "<SECURITY_GROUP_NAME>" --name "<SECURITY_GROUP_RULE_NAME>" --protocol tcp --priority 1000 --destination-port-range 3389
az network nic update --resource-group "<RG_GROUP_NAME>" --name "<VM_NIC_NAME>" --network-security-group "<SECURITY_GROUP_NAME>"

# or on Azure
# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/nsg-quickstart-portal
