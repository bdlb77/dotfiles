if [ "$#" -eq 0 ]; then
  echo "USAGE: ./locked_down_cluster.sh [\$NAME] [\$Location]"
  exit 0
fi


# tr: Illegal byte sequence

if [ $# -ne 2 ]
then
  echo "Error: This script should be invoked with 2 arguments: name and location"
  exit 1
fi

PREFIX=$1
LOC=$2
RG="${PREFIX}-rg"
SP_NAME="${PREFIX}-sp"
ID_NAME="${PREFIX}-mid"
CLUSTER_NAME="${PREFIX}"
VNET_NAME="${PREFIX}vnet"
AKS_SUBNET="${PREFIX}akssubnet"
# DO NOT CHANGE FWSUBNET_NAME - This is currently a requirement for Azure Firewall.
FWSUBNET_NAME="AzureFirewallSubnet"
FWNAME="${PREFIX}fw"
FWPUBLICIP_NAME="${PREFIX}fwpublicip"
FWIPCONFIG_NAME="${PREFIX}fwconfig"
FWROUTE_TABLE_NAME="${PREFIX}fwrt"
FWROUTE_NAME="${PREFIX}fwrn"

echo "(Step 1/11) Creating resource group"
az group create -n $RG -l $LOC

echo "(Step 2/11) Create UA Managed Identity"
IDENTITY_ID=$(az identity create --name $ID_NAME --resource-group $RG --query id -o tsv)

echo "(Step 3/11) Creating VNET with aks subnet "
az network vnet create \
    --resource-group $RG \
    --name $VNET_NAME \
    --address-prefixes 10.42.0.0/16 \
    --subnet-name $AKS_SUBNET \
    --subnet-prefix 10.42.1.0/24

echo "(step 4/11) Create AzureBastionSubnet in aks vnet"
az network vnet subnet create \
    --resource-group $RG \
    --vnet-name $VNET_NAME \
    --name AzureBastionSubnet \
    --address-prefix 10.42.2.0/24

VNET_ID=$(az network vnet show --resource-group $RG --name $VNET_NAME --query id -o tsv)
SUBNET_ID=$(az network vnet subnet show --resource-group $RG --vnet-name $VNET_NAME --name $AKS_SUBNET --query id -o tsv)

echo "(Step 5/11) Creating Locked Down AKS Cluster"

    # --enable-private-cluster \
    # Enable for Private cluster
az aks create \
    --resource-group $RG \
    --name $CLUSTER_NAME \
    --load-balancer-sku standard \
    --network-plugin azure \
    --vnet-subnet-id $SUBNET_ID \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.2.0.10 \
    --service-cidr 10.2.0.0/24 \
    --enable-managed-identity \
    --assign-identity $IDENTITY_ID


az aks get-credentials --name $CLUSTER_NAME -g $RG

echo "(step 6/11) Basion Public IP"
az network public-ip create \
  --resource-group $RG \
  --name BastionPublicIP \
  --sku Standard \
  --location $LOC

echo "(step 7/11) Bastion Host"
az network bastion create \
  --name MyBastion \
  --public-ip-address BastionPublicIP \
  --resource-group $RG \
  --vnet-name $VNET_NAME \
  --location $LOC

# echo "(step 8/11) Deploy Jumpbox VM"
# az vm create \
#   --resource-group $RG \
#   --name $RG-jumpbox \
#   --vnet-name $VNET_NAME \
#   --subnet AzureBastionSubnet \
#   --public-ip-address myPublicIPAddress \
#   --image UbuntuLTS \
#   --generate-ssh-keys

# ## create vm
# echo "Creating the VM"
# az vm create \
#     --resource-group $VM_RG \
#     --name $VM_NAME \
#     --image $VM_IMAGE \
#     --size $VM_SIZE \
#     --os-disk-size-gb $VM_OSD_SIZE \
#     --subnet $SNET_ID \
#     --public-ip-address $VM_PUBIP \
#     --admin-username azureuser \
#     --generate-ssh-keys
