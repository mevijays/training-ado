# Azure Bicep: First Template (VNet with one subnet)

This is a tiny, single-file Bicep that creates a virtual network with one subnet. No parameters — everything is hardcoded for simplicity.

## File
- `main.bicep`: Resource group–scope deployment that creates:
  - VNet: `demo-vnet`
  - Subnet: `default` (`10.10.1.0/24` within `10.10.0.0/16`)

## Prerequisites
- Azure CLI (`az`) installed and logged in: `az login`
- An existing resource group to deploy into (or create one below).

## Quickstart
1) Create a resource group (pick your region):
```zsh
az group create --name my-demo-rg --location eastus
```

2) Deploy the Bicep to that resource group:
```zsh
az deployment group create \
  --resource-group my-demo-rg \
  --name vnet-first-bicep \
  --template-file ./main.bicep
```

3) Verify the VNet:
```zsh
az network vnet show -g my-demo-rg -n demo-vnet -o table
```

## Clean up
```zsh
az group delete --name my-demo-rg --yes --no-wait
```

## What to change next
- Edit names or CIDRs directly in `main.bicep`.
- When you’re ready, convert to parameters for reusability.
