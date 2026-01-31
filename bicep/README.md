# Azure Bicep: Resource Group + VNet Deployment

This Bicep project creates a resource group and a virtual network with one subnet. Everything is hardcoded for simplicity.

## Files
- `main.bicep`: Subscription-scope deployment that creates the resource group (`demo-rg`)
- `vnet.bicep`: Resource group–scope module that creates:
  - VNet: `demo-vnet`
  - Subnet: `default` (`10.10.1.0/24` within `10.10.0.0/16`)

## Prerequisites
- Azure CLI (`az`) installed and logged in: `az login`

## CLI Commands

### 1. Validate
Validates the Bicep template syntax and checks for deployment issues:
```zsh
az deployment sub validate \
  --location eastus \
  --template-file ./main.bicep
```

### 2. What-If (Plan)
Shows what resources will be created/modified/deleted without deploying:
```zsh
az deployment sub what-if \
  --location eastus \
  --template-file ./main.bicep
```

### 3. Apply (Deploy)
Deploys the resources to Azure:
```zsh
az deployment sub create \
  --location eastus \
  --name bicep-demo-deployment \
  --template-file ./main.bicep
```

### 4. Verify
Check the created resources:
```zsh
az network vnet show -g demo-rg -n demo-vnet -o table
```

## Clean Up
```zsh
az group delete --name demo-rg --yes --no-wait
```

## What to Change Next
- Edit names or CIDRs directly in `main.bicep` and `vnet.bicep`
- When you're ready, convert to parameters for reusability
