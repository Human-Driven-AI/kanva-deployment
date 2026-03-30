# Kanva Configuration Reference

This document is the canonical reference for deployment configuration values used by Kanva pilot installations.

Primary source file:
- `linux-vm/pilot.env`

Additional runtime environment variables are also listed here, especially for cloud secret manager integrations.

## Core App Configuration (`pilot.env`)

| Variable | Required | Default / Example | Description |
|---|---|---|---|
| `AllowedHosts` | Yes | `*` | ASP.NET allowed hostnames for incoming requests. |
| `AzureAdAuthority` | If auth enabled | `https://login.microsoftonline.com/<tenant-id>/signin-oidc` | Azure AD authority URL used for OpenID Connect. |
| `AzureAdClientId` | If auth enabled | `<app-client-id>` | Azure AD app registration client ID. |
| `AzureAdClientSecret` | If auth enabled | `<app-client-secret>` | Azure AD app registration client secret. |
| `AzureAdDomain` | If auth enabled | `yourtenant.onmicrosoft.com` | Azure AD domain/tenant domain. |
| `AzureAdInstance` | If auth enabled | `https://login.microsoftonline.com/` | Azure AD login instance base URL. |
| `AzureAdResponseType` | If auth enabled | `code id_token` | OIDC response type. |
| `AzureAdScopes` | If auth enabled | `<api-scope>` | Azure AD scopes for Kanva auth. |
| `AzureAdTenantId` | If auth enabled | `<tenant-id>` | Azure AD tenant ID (GUID). |
| `BackendDB` | Yes | `Sqlite` | Database backend type. Typical values: `Sqlite`, `MSSQL`, `PostgreSql`. |
| `ConnectionStringsDefault` | Yes | `/app/data/hd.db` | Database connection string or file path depending on `BackendDB`. |
| `CorsOrigins` | Yes | `"http://localhost,http://localhost:5001,http://localhost:5002"` | Comma-separated list of allowed CORS origins. |
| `EnableAuthentication` | Yes | `false` | Enables Azure AD auth when `true`. |
| `HostDataPath` | Yes | `~/kanva-data` | Host path mounted for persistent Kanva data. |
| `RootDataPath` | Yes | `/app/data` | In-container root data path used by hub/agents. |
| `SecretsStore` | Yes | `Local` | Secret manager type. Values: `Local`, `AzureKeyVault`, `GcpSecretManager`. |
| `SecurityKey` | Yes | `<long-random-string>` | App encryption/signing key. Must be long enough (current note in `pilot.env`: 38 chars). |
| `UseHttps` | Yes | `false` | Enables HTTPS behavior in app config when `true`. |
| `WorkingDirectory` | Yes | `/app/data` | Working directory used by app services. |

## Secret Manager Configuration

Set these when `SecretsStore` is not `Local`.

### Azure Key Vault mode (`SecretsStore=AzureKeyVault`)

| Variable | Required | Example | Description |
|---|---|---|---|
| `KeyVaultUrl` | Yes | `https://kanva-dev-key-vault.vault.azure.net/` | Azure Key Vault URI used by the hub when generating secret references. |
| `ManagedIdentityClientId` | Conditional | `7fc27b0a-eeee-4c75-ab38-6a47478b7c71` | User-assigned managed identity client ID for Delphi secret fetches in Azure-hosted runtime. |

Notes:
- For local development, leave `ManagedIdentityClientId` unset so SDKs can use `DefaultAzureCredential` (Azure CLI / developer identity).
- For Azure VM/Container runtime with user-assigned MI, set `ManagedIdentityClientId` explicitly.

### GCP Secret Manager mode (`SecretsStore=GcpSecretManager`)

| Variable | Required | Example | Description |
|---|---|---|---|
| `GcpProjectId` | Yes | `kanva-dev` | GCP project ID containing secrets. |
| `GCP_PROJECT_ID` | For Delphi integration tests | `kanva-dev` | Test/runtime env var used by Delphi integration test setup. |
| `GOOGLE_APPLICATION_CREDENTIALS` | Conditional | `/path/to/adc.json` | Path to GCP service account credentials when ADC is not otherwise available. |

Notes:
- Production environments should use workload identity or platform-native ADC where possible.
- Local development can use `gcloud auth application-default login`.

## Practical Profiles

### Local pilot (default)
- `SecretsStore=Local`
- SQLite (`BackendDB=Sqlite`)
- `EnableAuthentication=false` unless explicitly configured

### Azure Key Vault pilot
- `SecretsStore=AzureKeyVault`
- Set `KeyVaultUrl`
- Use either developer credentials (local) or `ManagedIdentityClientId` (Azure runtime)

### GCP Secret Manager pilot
- `SecretsStore=GcpSecretManager`
- Set `GcpProjectId`
- Ensure ADC is available for runtime/test context

## Where to put values

- Primary deploy-time values: `linux-vm/pilot.env`
- Runtime-only auth variables (for shell/process): environment variables in host runtime, service manager, or deployment automation

