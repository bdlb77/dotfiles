
if [ "$#" -eq 0 ]; then
  echo "USAGE: ./basic_cluster.sh [\$RG_NAME] [\$CLUSTER_NAME] [\$K8S_VERSION]"
  exit 0
fi



# tr: Illegal byte sequence
export LC_ALL=C

export RG_NAME=$1
export CLUSTER_NAME=$2
export K8S_V=${3:-'1.18.2'}
export LOC=westus

echo "create RG"
az group create \
  --name $RG_NAME \
  --location $LOC

echo "Creating AKS Cluster"
# Create AKS Cluster
az aks create \
  --name $CLUSTER_NAME \
  --location $LOC \
  --resource-group $RG_NAME \
  --nodepool-name linux --node-count 1 \
  --enable-addons monitoring \
  --generate-ssh-keys \
  --kubernetes-version $K8S_V \
  --query "{ name: name, resourceGroup: resourceGroup }"


echo "Setting K8s Context"
# Switch Context to newly created cluster
az aks get-credentials --name $CLUSTER_NAME -g $RG_NAME
