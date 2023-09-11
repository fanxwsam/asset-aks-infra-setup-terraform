# Create Folder
# mkdir $HOME/.ssh/aks-external-sshkeys
mkdir $HOME/../../.ssh/aks-external-sshkeys

# Create SSH Key
ssh-keygen `
    -m PEM `
    -t rsa `
    -b 4096 `
    -C "azureuser@myserver" `
    -f $HOME/../../.ssh/aks-external-sshkeys/aks-external-sshkey `
    -N mypassphrase

# List Files
ls $HOME/../../.ssh/aks-external-sshkeys

# Set SSH KEY Path
Copy the files to the corresponding folder of Terraform project

```
- Reference for [Create SSH Key](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed)