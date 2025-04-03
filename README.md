# Project README

## Prerequisites

Ensure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup Instructions

1. Run `az login` to authenticate to Azure.
2. Check your account details with `az account show`.
3. Set the first subscription if necessary by running `az account set --subscription <your-subscription-id>`.
4. Navigate to your Terraform directory and initialize it with `terraform init`.
5. Apply the Terraform configuration with `terraform apply`.
6. Retrieve the AKS cluster credentials using `az aks get-credentials --resource-group my-aks-rg --name my-aks-cluster`.
7. Verify your Kubernetes cluster connection by running `kubectl get nodes`.

## Notes

- Ensure your Azure subscription and AKS resource group are correctly set in the commands above.
- Ensure you have the necessary permissions for deploying to Azure and interacting with AKS.


### Manual Troubleshooting Guide
If you're encountering issues with Docker images or Kubernetes secrets, you can use the following script to manually troubleshoot:

# Log in to Azure Container Registry (ACR)
docker login makusyakarabay.azurecr.io

# Build and push Docker image to ACR
docker build -t makusyakarabay.azurecr.io/my-image:v1 .
docker push makusyakarabay.azurecr.io/my-image:v1

# Pull the Docker image from ACR to verify
docker pull makusyakarabay.azurecr.io/my-image:v1

# Create Kubernetes secret for ACR authentication
kubectl create secret docker-registry acr-secret \
  --docker-server=makusyakarabay.azurecr.io \
  --docker-username=makusyakarabay \
  --docker-password=<your-password> \
  --docker-email=makmal.karabaeva@gmail.com

# If you encounter "failed to solve: failed to read dockerfile", ensure the Dockerfile is in the correct directory and properly named.
# If Helm release fails, check the Helm release status and logs:
helm status <release-name>
helm logs <release-name>
