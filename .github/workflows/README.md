# CI/CD Setup

This workflow builds the Docker image using **ACR Tasks** (no local Docker needed) and deploys to App Service.

## Prerequisites

Create a Microsoft Entra ID app registration with federated credentials for GitHub Actions OIDC:

```bash
az ad app create --display-name "github-actions-zava"
az ad sp create --id <APP_ID>

# Federated credential for main branch
az ad app federated-credential create --id <APP_ID> --parameters '{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:safa0907/TechWorkshop-L300-GitHub-Copilot-and-platform:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'

# Grant Contributor + AcrPush on the resource group
az role assignment create --assignee <APP_ID> --role Contributor --scope /subscriptions/<SUB_ID>/resourceGroups/rg-ghcp-demo
az role assignment create --assignee <APP_ID> --role AcrPush --scope /subscriptions/<SUB_ID>/resourceGroups/rg-ghcp-demo
```

## GitHub Secrets

| Secret | Value |
|--------|-------|
| `AZURE_CLIENT_ID` | App registration (client) ID |
| `AZURE_TENANT_ID` | Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

## GitHub Variables

| Variable | Value |
|----------|-------|
| `ACR_NAME` | `cr4mbwsntosizag` |
| `APP_NAME` | `app-4mbwsntosizag` |
| `RESOURCE_GROUP` | `rg-ghcp-demo` |
