<div align="center">
  <picture>
    <img alt="Cloud Health Office Sentinel" 
         src="docs/images/logo-cloudhealthoffice-sentinel-primary.png" 
         width="800">
  </picture>
  
  <p><em>Just emerged from the void</em></p>
</div>

---

# Cloud Health Office
## The #1 Open-Source Azure-Native Multi-Payer EDI Platform

**Zero-code onboarding. Backend-agnostic. HIPAA-compliant. <1 hour to production.**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Azure](https://img.shields.io/badge/Azure-Logic%20Apps-0089D6?logo=microsoft-azure)](https://azure.microsoft.com/services/logic-apps/)
[![HIPAA](https://img.shields.io/badge/HIPAA-Compliant-green)](SECURITY.md)
[![Build](https://img.shields.io/github/workflow/status/aurelianware/cloudhealthoffice/CI)](https://github.com/aurelianware/cloudhealthoffice/actions)

---

## Overview

Cloud Health Office is a **configuration-driven multi-tenant SaaS platform** that processes HIPAA X12 EDI transactions (275 Attachments, 277 RFAI, 278 Authorizations) for unlimited health plans without custom code.

### Key Capabilities

- **<1 Hour Onboarding**: Add new payers via configuration, not code
- **Backend Agnostic**: Works with QNXT, FacetsRx, TriZetto, Epic, Cerner, custom systems
- **Multi-Tenant SaaS**: Single codebase serves unlimited payers
- **Production HIPAA**: Key Vault, private endpoints, PHI masking, automated rotation
- **Azure Marketplace**: One-click deployment from Azure Marketplace
- **Open Source**: Apache 2.0 licensed, community-driven development

---

## Quick Start

### Option 1: Azure Marketplace (Recommended)

1. Azure Marketplace listing pending approval – deployment available via manual installation (see Option 2 below)
2. Search for "Cloud Health Office Sentinel"
3. Click "Get It Now"
4. Complete deployment wizard (15 minutes)
5. Configure trading partners (30 minutes)
6. Process your first EDI transaction (<1 hour total)

**[📘 Full Marketplace Guide](AZURE-MARKETPLACE-PLUGIN.md)**

### Option 2: Manual Deployment

```bash
# Clone repository
git clone https://github.com/aurelianware/cloudhealthoffice.git
cd cloudhealthoffice

# Install dependencies
npm install

# Build project
npm run build

# Deploy infrastructure
az deployment group create \
  --resource-group cho-prod-rg \
  --template-file infra/main.bicep \
  --parameters baseName=chosentinel

# See DEPLOYMENT.md for complete guide
```

---

## Documentation

### Getting Started

- **[🚀 Azure Marketplace Plugin](AZURE-MARKETPLACE-PLUGIN.md)** - One-click deployment guide
- **[�� Onboarding Guide](ONBOARDING.md)** - Complete setup and configuration
- **[🏗️ Architecture Overview](ARCHITECTURE.md)** - System design and data flows
- **[🔧 Deployment Guide](DEPLOYMENT.md)** - Manual deployment procedures

### For Contributors

- **[👥 Contributor Onboarding](CONTRIBUTOR-ONBOARDING.md)** - External developer guide
- **[💰 Bounty Program](BOUNTY-PROGRAM.md)** - Earn rewards for contributions
- **[🤝 Contributing Guidelines](CONTRIBUTING.md)** - How to contribute
- **[📋 Roadmap](ROADMAP.md)** - Planned features and milestones

### Technical Documentation

- **[🔐 Security Guide](SECURITY.md)** - HIPAA compliance and security
- **[🌿 Branching Strategy](BRANCHING-STRATEGY.md)** - Git workflow and conventions
- **[📊 API Reference](docs/api/)** - OpenAPI specifications

---

## Features

### Core Workflows

- **Inbound 275**: Process attachment requests from Availity
- **Outbound 277**: Send request for additional information (RFAI) responses
- **Inbound 278**: Process health care services review (prior authorization)
- **Replay 278**: Deterministic HTTP endpoint for transaction replay

### Platform Capabilities

- **Multi-Tenant**: Configuration-driven isolation for unlimited payers
- **Data Lake Storage**: Hierarchical namespace with date-based partitioning
- **Service Bus**: Async processing with dead-letter queues
- **Integration Account**: X12 EDI encoding/decoding with schema validation
- **Application Insights**: Real-time monitoring, alerts, and diagnostics
- **Key Vault**: Secrets management with managed identity access

### Configuration-Driven

```json
{
  "payerId": "123456789",
  "payerName": "Acme Health Plan",
  "modules": {
    "attachments": { "enabled": true },
    "authorization": { "enabled": true },
    "ecs": { "enabled": true, "valueAdds277": true }
  },
  "backend": {
    "type": "QNXT",
    "apiEndpoint": "https://api.acme.com/qnxt"
  }
}
```

**No code changes required.** Platform generates complete deployment.

---

## Contributing

We welcome contributions! Cloud Health Office has an active **[Bounty Program](BOUNTY-PROGRAM.md)** that rewards external developers for high-value contributions.

### Available Bounties

| Bounty | Value | Difficulty |
|--------|-------|-----------|
| FHIR Mapper Implementation | $500 | Medium |
| Prior Authorization AI | $1,000 | Hard |
| Claim Auto-Adjudication | $1,500 | Hard |
| Multi-Language Support | $750 | Medium |
| Performance Dashboard | $600 | Medium |

**[💰 View All Bounties](BOUNTY-PROGRAM.md)**

### How to Contribute

1. Read **[Contributor Onboarding Guide](CONTRIBUTOR-ONBOARDING.md)**
2. Pick an issue or bounty
3. Fork and clone repository
4. Make your changes
5. Submit pull request

**[🤝 Full Contributing Guide](CONTRIBUTING.md)**

---

## Support

### Community Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/aurelianware/cloudhealthoffice/issues)
- **GitHub Discussions**: [Ask questions and share ideas](https://github.com/aurelianware/cloudhealthoffice/discussions)
- **Documentation**: [Comprehensive reference docs](https://github.com/aurelianware/cloudhealthoffice)

### Professional Support

- **Email**: support@aurelianware.com
- **Managed Services**: Available through Aurelianware
- **Custom Development**: contact sales@aurelianware.com

---

## Pricing

### Infrastructure Costs

**Azure Consumption** (single-tenant):
- Logic Apps Standard (WS1): ~$200/month
- Storage, Service Bus, Insights: ~$100/month
- **Total: ~$300-350/month**

**Multi-Tenant** (shared infrastructure):
- Cost per payer: ~$50-100/month

### Managed Services

- **Bronze**: $7,000/payer/year (deployment + monthly updates)
- **Silver**: $10,000/payer/year (priority support + custom dev)
- **Gold**: $15,000/payer/year (24/7 support + dedicated AM)

**[💵 Full Pricing Details](docs/COMMERCIALIZATION.md)**

---

## Technology Stack

- **Azure Logic Apps Standard**: Workflow orchestration
- **Azure Data Lake Gen2**: HIPAA-compliant storage
- **Azure Service Bus**: Async messaging and integration
- **Azure Integration Account**: X12 EDI processing
- **Azure Application Insights**: Monitoring and analytics
- **Azure Key Vault**: Secrets and certificate management
- **Bicep**: Infrastructure as Code
- **TypeScript**: Configuration-to-workflow generation
- **PowerShell**: Deployment automation

---

## License

Cloud Health Office is licensed under **Apache License 2.0**.

- ✅ Commercial use permitted
- ✅ Modification and distribution allowed
- ✅ Patent grant included
- ✅ HIPAA-compliant licensing

See [LICENSE](LICENSE) for full terms.

---

## Compliance

- **HIPAA**: Complete HIPAA compliance patterns included
- **SOC 2**: Azure infrastructure is SOC 2 certified
- **HITRUST**: Compatible with HITRUST framework
- **HL7/X12**: Standards-compliant EDI processing

**[🔐 Security Documentation](SECURITY.md)**

---

## Roadmap

**Current Version**: 1.0.0

**Coming Soon**:
- FHIR R4 transformation workflows
- Prior authorization AI prediction
- Claim auto-adjudication engine
- Multi-language support (ES, FR, PT)
- Real-time performance dashboard

**[📋 Full Roadmap](ROADMAP.md)**

---

## Recognition

### Contributors

Thank you to all our contributors! See [CONTRIBUTORS.md](CONTRIBUTORS.md) for the full list.

**Top Bounty Earners** will be featured here.

### Sponsors

This project is sponsored by **Aurelianware** and supported by the open-source community.

---

## AI-Assisted Development

Contributors: Install GitHub Copilot in VS Code. Prefix code blocks with detailed comments like '// Implement [feature] with [constraints]'. Review AI-generated code for security and compliance—never commit secrets. Run 'npm test' before submitting PRs.  
All output must remain HIPAA-safe—redact PHI, never log confidential info, and validate AI completions before merging.

---

**The transformation begins.**

Systems that do not fail. Capabilities beyond question.

---

<div align="center">
  <p>Made with ⚡ by <a href="https://aurelianware.com">Aurelianware</a></p>
  <p>Licensed under Apache 2.0 | <a href="SECURITY.md">Security</a> | <a href="CONTRIBUTING.md">Contributing</a> | <a href="BOUNTY-PROGRAM.md">Bounties</a></p>
</div>
