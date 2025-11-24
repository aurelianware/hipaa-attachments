# Cloud Health Office - Azure Marketplace Plugin

<div align="center">
  <p><em>Just emerged from the void</em></p>
</div>

---

## Overview

Cloud Health Office is available on the **Azure Marketplace** for rapid, one-click deployment directly into your Azure subscription. This guide covers marketplace installation, configuration, and post-deployment steps.

### Key Benefits

- **<1 Hour Deployment**: Automated infrastructure provisioning
- **Zero Manual Configuration**: Pre-configured Logic Apps workflows
- **Production-Ready Security**: HIPAA-compliant from deployment
- **Immediate Value**: Process EDI transactions within hours

---

## Prerequisites

Before deploying from Azure Marketplace, ensure you have:

### Azure Requirements

- **Azure Subscription**: Active subscription with Owner or Contributor role
- **Resource Group**: Existing or new resource group for deployment
- **Azure Region**: Select region for data residency (recommended: eastus, westus, centralus)
- **Subscription Quotas**: Sufficient quotas for Logic Apps Standard (WS1 SKU)

### Trading Partner Access

- **Availity SFTP Credentials**: Username, password, host for EDI file exchange
- **Backend System API**: Endpoint URL and authentication credentials (e.g., QNXT, FacetsRx)
- **Payer ID**: Your organization's unique payer identifier

### Network & Security

- **Managed Identity**: System-assigned managed identity enabled (automatic during deployment)
- **Private Endpoints** (Optional): For enhanced security in production
- **Azure Key Vault**: For secrets management (created automatically)

---

## Azure Marketplace Deployment

### Step 1: Find Cloud Health Office in Azure Marketplace

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Click **Create a resource** in the left sidebar
3. Search for **"Cloud Health Office"** or **"Cloud Health Office Sentinel"**
4. Click the Cloud Health Office listing
5. Click **Create**

**Screenshot Placeholder:**
```
[Azure Marketplace listing with Sentinel branding]
```

### Step 2: Configure Basic Settings

On the **Basics** tab:

| Setting | Value | Description |
|---------|-------|-------------|
| **Subscription** | Your Azure subscription | Select target subscription |
| **Resource Group** | `cho-prod-rg` | Create new or select existing |
| **Region** | `East US` | Select Azure region for deployment |
| **Deployment Name** | `cho-deployment-001` | Unique identifier for this deployment |
| **Base Name** | `chosentinel` | Base name for all resources (3-20 chars, alphanumeric) |

### Step 3: Configure Platform Settings

On the **Platform** tab:

| Setting | Value | Description |
|---------|-------|-------------|
| **Payer ID** | Your unique payer identifier | e.g., `030240928` (8-10 digits) |
| **Payer Name** | Your organization name | e.g., `Acme Health Plan` |
| **SKU Tier** | `Standard` or `Premium` | Standard: WS1, Premium: WS2 |
| **Enable Multi-Tenant** | `Yes` / `No` | Multi-tenant SaaS mode |

### Step 4: Configure Integration Settings

On the **Integration** tab:

| Setting | Value | Description |
|---------|-------|-------------|
| **Availity SFTP Host** | `sftp.availity.net` | Availity SFTP server hostname |
| **Availity SFTP Username** | Your Availity username | EDI clearinghouse credentials |
| **Backend System Type** | `QNXT` / `FacetsRx` / `Custom` | Claims system backend |
| **Backend API Endpoint** | `https://api.example.com/qnxt` | Backend system API URL |
| **Integration Account Name** | `cho-integration-account` | X12 EDI processing account |

**Security Note**: Passwords and API keys are stored in Azure Key Vault automatically. They are never logged or exposed in deployment outputs.

### Step 5: Configure Module Selection

On the **Modules** tab, select which modules to enable:

- ☑ **Inbound Attachments (275)** - Process attachment requests from Availity
- ☑ **Outbound RFAI (277)** - Send request for additional information responses
- ☑ **Health Services Review (278)** - Process authorization requests
- ☑ **Enhanced Claim Status (ECS)** - Premium claim status with ValueAdds277
- ☐ **Appeals Integration** - Connect appeals workflow to attachments
- ☐ **Prior Authorization** - Process prior auth requests (278)

### Step 6: Review and Create

1. Click **Review + create**
2. Azure validates your configuration
3. Review the terms and conditions
4. Click **Create** to begin deployment

**Deployment Timeline**: 15-30 minutes for complete infrastructure provisioning

---

## Post-Deployment Configuration

### Step 1: Verify Deployment

After deployment completes:

```bash
# Login to Azure CLI
az login

# Set subscription
az account set --subscription "<your-subscription-id>"

# Verify resource group
az group show --name cho-prod-rg

# List deployed resources
az resource list --resource-group cho-prod-rg --output table
```

**Expected Resources:**
- Logic App Standard instance (`cho-logicapp-std`)
- Storage Account with Data Lake Gen2 (`chostoragedl`)
- Service Bus Namespace (`cho-servicebus-ns`)
- Application Insights (`cho-appinsights`)
- Integration Account (`cho-integration-account`)
- Key Vault (`cho-keyvault`)

### Step 2: Configure Trading Partner Secrets

Update secrets in Azure Key Vault:

```bash
# Set Availity SFTP password
az keyvault secret set \
  --vault-name cho-keyvault \
  --name "AvilitySftpPassword" \
  --value "<your-availity-password>"

# Set backend API key
az keyvault secret set \
  --vault-name cho-keyvault \
  --name "QnxtApiKey" \
  --value "<your-qnxt-api-key>"

# Verify secrets
az keyvault secret list --vault-name cho-keyvault --output table
```

### Step 3: Upload X12 Schemas

Upload required X12 schemas to Integration Account:

```bash
# Navigate to repository
cd /path/to/cloudhealthoffice

# Upload 275 schema
az logic integration-account schema create \
  --resource-group cho-prod-rg \
  --integration-account-name cho-integration-account \
  --name "X12_005010X210_275" \
  --content-type "application/xml" \
  --schema-type "Xml" \
  --schema "@./schemas/X12_005010X210_275.xsd"

# Upload 277 schema
az logic integration-account schema create \
  --resource-group cho-prod-rg \
  --integration-account-name cho-integration-account \
  --name "X12_005010X212_277" \
  --content-type "application/xml" \
  --schema-type "Xml" \
  --schema "@./schemas/X12_005010X212_277.xsd"

# Upload 278 schema
az logic integration-account schema create \
  --resource-group cho-prod-rg \
  --integration-account-name cho-integration-account \
  --name "X12_005010X217_278" \
  --content-type "application/xml" \
  --schema-type "Xml" \
  --schema "@./schemas/X12_005010X217_278.xsd"
```

### Step 4: Configure Trading Partner Agreements

Set up trading partner agreements for X12 processing:

```bash
# Run PowerShell configuration script
pwsh -File ./configure-x12-agreements.ps1 \
  -ResourceGroup "cho-prod-rg" \
  -IntegrationAccountName "cho-integration-account" \
  -PayerId "<your-payer-id>"
```

**Script performs:**
- Creates Availity trading partner (ID: 030240928)
- Creates your payer trading partner (ID: your-payer-id)
- Configures X12 agreements for 275/277/278 transactions
- Sets envelope and acknowledgment settings

### Step 5: Test Workflows

Validate Logic App workflows are operational:

```bash
# Test 275 ingestion workflow
pwsh -c "./test-workflows.ps1 -TestInbound275 \
  -ResourceGroup 'cho-prod-rg' \
  -LogicAppName 'cho-logicapp-std'"

# Expected output:
# ✓ SFTP connection verified
# ✓ Integration Account accessible
# ✓ Service Bus topics available
# ✓ Data Lake storage accessible
# All tests passed
```

### Step 6: Monitor Deployment

Configure Application Insights alerts:

```bash
# Enable diagnostic logging
az monitor diagnostic-settings create \
  --name "cho-diagnostics" \
  --resource "/subscriptions/<sub-id>/resourceGroups/cho-prod-rg/providers/Microsoft.Web/sites/cho-logicapp-std" \
  --logs '[{"category":"WorkflowRuntime","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --workspace "/subscriptions/<sub-id>/resourceGroups/cho-prod-rg/providers/Microsoft.OperationalInsights/workspaces/cho-loganalytics"
```

---

## One-Click ARM Template Deployment

For automated deployment without Azure Marketplace:

### Deploy via Azure CLI

```bash
# Clone repository
git clone https://github.com/aurelianware/cloudhealthoffice.git
cd cloudhealthoffice

# Deploy ARM template
az deployment group create \
  --resource-group cho-prod-rg \
  --template-file infra/main.bicep \
  --parameters baseName=chosentinel \
               payerId=<your-payer-id> \
               payerName="Acme Health Plan" \
               availitySftpHost="sftp.availity.net" \
               backendApiEndpoint="https://api.example.com/qnxt"
```

### Deploy via Azure Portal

1. Click the **Deploy to Azure** button below:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faurelianware%2Fcloudhealthoffice%2Fmain%2Finfra%2Fmain.json)

> **Note**: The template URL should point to the compiled ARM JSON template, not the Bicep file. Ensure `infra/main.json` is available in the repository or compile `main.bicep` to JSON before using this button.

2. Fill in the required parameters
3. Click **Review + create**
4. Click **Create**

### Deploy via PowerShell

```powershell
# Connect to Azure
Connect-AzAccount

# Set subscription
Set-AzContext -SubscriptionId "<your-subscription-id>"

# Deploy Bicep template
New-AzResourceGroupDeployment `
  -ResourceGroupName "cho-prod-rg" `
  -TemplateFile "./infra/main.bicep" `
  -baseName "chosentinel" `
  -payerId "<your-payer-id>" `
  -payerName "Acme Health Plan" `
  -availitySftpHost "sftp.availity.net" `
  -backendApiEndpoint "https://api.example.com/qnxt"
```

---

## Marketplace Listing Requirements

For partners and resellers listing Cloud Health Office on Azure Marketplace:

### Listing Details

**Publisher**: Aurelianware  
**Offer Type**: Azure Application (Managed Application)  
**Plan Type**: Solution Template or Managed App  
**Pricing Model**: BYOL (Bring Your Own License) or Pay-As-You-Go

### Required Assets

1. **Logo Images**
   - Small (48x48): `docs/images/logo-cloudhealthoffice-sentinel-small.png`
   - Medium (90x90): `docs/images/logo-cloudhealthoffice-sentinel-medium.png`
   - Large (216x216): `docs/images/logo-cloudhealthoffice-sentinel-large.png`
   - Hero (815x290): `docs/images/logo-cloudhealthoffice-sentinel-primary.png`

2. **Screenshots** (1280x720 minimum, PNG format)
   - Azure Portal deployment wizard (Basics tab)
   - Platform configuration (Module selection)
   - Logic Apps workflow designer view
   - Application Insights monitoring dashboard
   - Data Lake storage structure

3. **Videos**
   - 60-second product overview (YouTube or Vimeo)
   - 5-minute installation walkthrough
   - 10-minute configuration deep-dive

4. **Documents**
   - Installation guide (this document)
   - Getting started guide (ONBOARDING.md)
   - Architecture overview (ARCHITECTURE.md)
   - Security whitepaper (SECURITY.md)

### Marketplace Description

**Short Description (100 characters):**
```
Cloud Health Office: Multi-payer EDI integration. Zero-code onboarding. HIPAA-compliant. <1hr deploy.
```

**Long Description (3000 characters):**
```
Cloud Health Office Sentinel – The Inevitable Evolution of Healthcare EDI

Just emerged from the void.

Cloud Health Office is the #1 open-source Azure-native multi-payer EDI platform for healthcare organizations. Process HIPAA X12 transactions (275 Attachments, 277 RFAI, 278 Authorizations) with zero custom code, backend-agnostic architecture, and production-grade security.

KEY CAPABILITIES:
• Multi-Tenant SaaS: Single codebase serves unlimited payers
• Zero-Code Onboarding: Add new payers in <1 hour via configuration
• Backend Agnostic: Works with QNXT, FacetsRx, TriZetto, Epic, Cerner, or custom systems
• HIPAA Compliant: Key Vault, private endpoints, PHI masking, automated rotation
• Horizontal Scalability: Auto-scales to any transaction volume
• Complete Auditability: Full transaction tracking and compliance logging

WHAT'S INCLUDED:
✓ Azure Logic Apps Standard workflows (ingest275, rfai277, ingest278, replay278)
✓ Data Lake Gen2 storage with date-based partitioning
✓ Service Bus messaging for async processing
✓ Integration Account with X12 schema support
✓ Application Insights monitoring and alerts
✓ Key Vault for secrets management
✓ Comprehensive documentation and examples

DEPLOYMENT:
One-click deployment from Azure Marketplace provisions complete infrastructure:
• Logic Apps Standard (WS1 SKU)
• Storage Account (Data Lake Gen2)
• Service Bus Namespace (Standard tier)
• Application Insights
• Integration Account
• Key Vault

Configuration-driven setup supports unlimited payer organizations without code changes.

PRICING:
Platform infrastructure costs ~$300-500/month per tenant on Azure consumption pricing. 
Optional managed service: $10,000/payer/year includes support, updates, and monitoring.

GET STARTED:
1. Click "Get It Now"
2. Complete deployment wizard (15 minutes)
3. Configure trading partners (30 minutes)
4. Process first EDI transaction (<1 hour from start)

SUPPORT & RESOURCES:
• GitHub Repository: https://github.com/aurelianware/cloudhealthoffice
• Documentation: Comprehensive guides included
• Community Support: GitHub Discussions
• Professional Support: Available through Aurelianware

Systems that do not fail. Capabilities beyond question.

The transformation begins.
```

### Categories

- **AI + Machine Learning** > Healthcare
- **Integration** > EDI
- **Developer Tools** > Application Integration
- **Azure Native** > Logic Apps

### Search Keywords

- HIPAA EDI
- Healthcare Integration
- Multi-Tenant SaaS
- X12 Processing
- Claims Attachments
- Prior Authorization
- Logic Apps
- Azure Integration

---

## Pricing Models

### Infrastructure Costs (Azure Consumption)

**Single-Tenant Deployment:**
- Logic Apps Standard (WS1): ~$200/month
- Storage Account: ~$20-50/month (depends on volume)
- Service Bus (Standard): ~$10/month
- Application Insights: ~$10-30/month
- Integration Account: ~$50/month
- Key Vault: ~$1/month

**Total: ~$300-350/month** per payer deployment

**Multi-Tenant Deployment:**
- Shared infrastructure across multiple payers
- Cost per payer: ~$50-100/month (depending on scale)

### Managed Service Pricing

**Bronze Tier** ($7,000/payer/year):
- Infrastructure deployment and management
- Monthly security updates
- Email support (48-hour response)
- Quarterly business reviews

**Silver Tier** ($10,000/payer/year):
- All Bronze benefits
- Priority support (24-hour response)
- Custom module development (up to 20 hours/year)
- Monthly uptime reports

**Gold Tier** ($15,000/payer/year):
- All Silver benefits
- 24/7 support hotline
- Dedicated account manager
- Custom integrations (up to 40 hours/year)
- SLA: 99.9% uptime guarantee

### Transaction-Based Pricing

**Pay-Per-Transaction** (alternative to subscription):
- $0.10 per 275 attachment processed
- $0.05 per 277 RFAI sent
- $0.08 per 278 authorization processed
- Typical volume: 10,000 transactions/month = $800/month

---

## Configuration Files and Examples

### Sample Payer Configuration

Create `config/payers/your-payer.json`:

```json
{
  "payerId": "123456789",
  "payerName": "Acme Health Plan",
  "azureRegion": "eastus",
  "baseName": "acme-cho",
  "modules": {
    "attachments": {
      "enabled": true,
      "inbound275": true,
      "outbound277": true
    },
    "authorization": {
      "enabled": true,
      "inbound278": true
    },
    "ecs": {
      "enabled": true,
      "valueAdds277": true
    },
    "appeals": {
      "enabled": false
    }
  },
  "backend": {
    "type": "QNXT",
    "apiEndpoint": "https://api.acme.com/qnxt",
    "authType": "ApiKey",
    "fieldMappings": {
      "claimId": "claimNumber",
      "memberId": "subscriberID",
      "providerId": "billingProviderNPI"
    }
  },
  "tradingPartners": {
    "availity": {
      "senderId": "030240928",
      "sftpHost": "sftp.availity.net",
      "sftpUsername": "ACME_USER"
    },
    "payer": {
      "receiverId": "123456789",
      "name": "Acme Health Plan"
    }
  }
}
```

### Generate Deployment from Configuration

```bash
# Install dependencies
npm install

# Build generator
npm run build

# Generate deployment package
npm run generate -- \
  --config config/payers/your-payer.json \
  --output generated/your-payer

# Deploy generated package
cd generated/your-payer
./deploy.sh
```

---

## Troubleshooting Marketplace Deployment

### Issue: Deployment Failed

**Symptom**: Deployment fails with validation errors

**Solution**:
1. Check resource naming conflicts (base name must be globally unique)
2. Verify subscription quotas for Logic Apps Standard
3. Ensure region supports all required services
4. Review Azure Activity Log for specific error messages

```bash
# Check deployment errors
az deployment group show \
  --resource-group cho-prod-rg \
  --name cho-deployment-001 \
  --query "properties.error" -o json
```

### Issue: Logic App Not Starting

**Symptom**: Logic App is deployed but workflows don't trigger

**Solution**:
1. Verify API connections are authenticated
2. Check managed identity has correct RBAC roles
3. Review Application Insights for startup errors

```bash
# Check Logic App status
az webapp show \
  --resource-group cho-prod-rg \
  --name cho-logicapp-std \
  --query "state"

# Restart Logic App
az webapp restart \
  --resource-group cho-prod-rg \
  --name cho-logicapp-std
```

### Issue: SFTP Connection Fails

**Symptom**: Ingest275 workflow fails to connect to Availity SFTP

**Solution**:
1. Verify SFTP credentials in Key Vault
2. Check firewall rules allow outbound SFTP (port 22)
3. Test SFTP connection manually

```bash
# Test SFTP connection
sftp -P 22 username@sftp.availity.net

# Update SFTP password in Key Vault
az keyvault secret set \
  --vault-name cho-keyvault \
  --name "AvilitySftpPassword" \
  --value "<new-password>"
```

### Issue: Integration Account Schema Errors

**Symptom**: X12 decoding fails with schema validation errors

**Solution**:
1. Verify schemas are uploaded to Integration Account
2. Check schema names match workflow references
3. Validate X12 message format

```bash
# List Integration Account schemas
az logic integration-account schema list \
  --resource-group cho-prod-rg \
  --integration-account-name cho-integration-account

# Re-upload schema if needed
az logic integration-account schema update \
  --resource-group cho-prod-rg \
  --integration-account-name cho-integration-account \
  --name "X12_005010X210_275" \
  --schema "@./schemas/X12_005010X210_275.xsd"
```

---

## Next Steps

After successful marketplace deployment:

1. **Complete Onboarding**: Follow [ONBOARDING.md](ONBOARDING.md) for detailed configuration
2. **Configure Workflows**: Review [DEPLOYMENT.md](DEPLOYMENT.md) for workflow customization
3. **Set Up Monitoring**: Configure alerts in [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
4. **Test End-to-End**: Use test files in repository to validate complete workflow
5. **Production Hardening**: Review [SECURITY-HARDENING.md](SECURITY-HARDENING.md) for production checklist

---

## Support and Resources

### Documentation

- [Architecture Overview](ARCHITECTURE.md) - System design and data flows
- [Deployment Guide](DEPLOYMENT.md) - Complete deployment procedures
- [Security Guide](SECURITY.md) - HIPAA compliance and security
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions
- [Contributing Guide](CONTRIBUTING.md) - How to contribute to the project

### Community Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/aurelianware/cloudhealthoffice/issues)
- **GitHub Discussions**: [Ask questions and share ideas](https://github.com/aurelianware/cloudhealthoffice/discussions)
- **Documentation**: [Complete reference documentation](https://github.com/aurelianware/cloudhealthoffice)

### Professional Support

- **Email**: support@aurelianware.com
- **Managed Service**: Available through Aurelianware
- **Custom Development**: Contact sales@aurelianware.com

---

## Legal and Compliance

### License

Cloud Health Office is licensed under **Apache License 2.0**. See [LICENSE](LICENSE) for details.

### HIPAA Compliance

This deployment includes HIPAA-compliant infrastructure patterns. Organizations must complete their own HIPAA compliance validation and Business Associate Agreements (BAA) with Microsoft Azure. See [HIPAA Compliance Guide](https://docs.microsoft.com/azure/compliance/offerings/offering-hipaa-us) for Azure HIPAA compliance details.

### Support Agreement

Azure Marketplace deployments include:
- 90-day installation support (community)
- Access to documentation and examples
- GitHub community support

Paid support available through managed service tiers.

---

**The transformation begins.**

Systems that do not fail. Capabilities beyond question.

---

**Document Version**: 1.0  
**Last Updated**: November 2025  
**Status**: Active
