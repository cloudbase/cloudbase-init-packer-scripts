#!/usr/bin/env bash
set -e

if [[ -z $IMAGE_RG ]]; then echo "IMAGE_RG env var is not set"; exit 1; fi
if [[ -z $IMAGE_NAME ]]; then echo "IMAGE_NAME env var is not set"; exit 1; fi

if [[ -z $VM_LOCATION ]]; then echo "VM_LOCATION env var is not set"; exit 1; fi
if [[ -z $VM_RG_NAME ]]; then echo "VM_RG_NAME env var is not set"; exit 1; fi
if [[ -z $VM_NAME ]]; then echo "VM_NAME env var is not set"; exit 1; fi
if [[ -z $VM_SIZE ]]; then echo "VM_SIZE env var is not set"; exit 1; fi

if [[ -z $ADMIN_USERNAME ]]; then echo "ADMIN_USERNAME env var is not set"; exit 1; fi
if [[ -z $ADMIN_PASSWORD ]]; then echo "ADMIN_PASSWORD env var is not set"; exit 1; fi
if [[ -z $ADMIN_PUBLIC_SSH_KEY_PATH ]]; then echo "ADMIN_PUBLIC_SSH_KEY_PATH env var is not set"; exit 1; fi

#
# Get the Azure image ID
#
IMAGE_ID=$(az image show \
    -g $IMAGE_RG \
    -n $IMAGE_NAME \
    -o tsv --query "id")

#
# Create Azure resource group
#
az group create \
    -n $VM_RG_NAME \
    -l $VM_LOCATION \
    --tags DO-NOT-DELETE="Test RG"

#
# Create cloud-init file with SSH public key
#
cat > /tmp/cloud-init.yaml << EOF
#cloud-config

users:
  - name: $ADMIN_USERNAME
    ssh_authorized_keys:
      - $(cat $ADMIN_PUBLIC_SSH_KEY_PATH)
EOF

#
# Create Azure VM
#
az vm create \
    --resource-group $VM_RG_NAME \
    --location $VM_LOCATION \
    --name $VM_NAME \
    --image $IMAGE_ID \
    --public-ip-sku Standard \
    --admin-username $ADMIN_USERNAME \
    --admin-password $ADMIN_PASSWORD \
    --size $VM_SIZE \
    --nsg-rule RDP \
    --custom-data /tmp/cloud-init.yaml

#
# Cleanup cloud-init file
#
rm -f /tmp/cloud-init.yaml

#
# Allow SSH access
#
echo "Creating SSH NSG rule"
az network nsg rule create \
    --name SSHAccess \
    --resource-group $VM_RG_NAME \
    --nsg-name "${VM_NAME}NSG" \
    --priority 100 \
    --destination-port-range 22 \
    --protocol Tcp \
    --description "SSH access"
