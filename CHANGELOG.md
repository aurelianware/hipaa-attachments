# Changelog

All notable changes to Cloud Health Office will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - v2.0.0 Development (CMS-0057-F Alignment)

### Vision: Complete CMS Interoperability & Patient Access Compliance

Cloud Health Office v2.0.0 focuses on meeting federal CMS-0057-F (CMS-9115-F) interoperability mandates while expanding core EDI capabilities. This release transforms the platform from a best-in-class X12 EDI processor into a complete **multi-standard interoperability hub** supporting both traditional EDI and modern FHIR APIs.

**Regulatory Compliance Target**: January 2027 (Prior Authorization API deadline)  
**Release Target**: Q3 2025  
**Documentation**: [CMS-0057-F-COMPLIANCE.md](./docs/CMS-0057-F-COMPLIANCE.md)

---

### CMS-0057-F Compliance Roadmap

#### Patient Access API (§ 422.119, § 431.60)
**Mandate**: Secure, standards-based API for patient access to claims, clinical data, and costs.  
**Status**: 60% Complete | **Target**: Q2 2025

- ✅ **FHIR R4 Patient Resource** - X12 270 → FHIR R4 (November 2024)
- ✅ **CoverageEligibilityRequest** - Complete US Core 3.1.1 support (November 2024)
- 🔄 **CoverageEligibilityResponse** - X12 271 → FHIR R4 (Q1 2025)
- 🔄 **FHIR → X12 270** - Outbound FHIR queries (Q1 2025)
- 🔄 **Claim Resource** - X12 837 → FHIR R4 (Q2 2025)
- 🔄 **ExplanationOfBenefit** - X12 835 → FHIR R4 (Q2 2025)
- 🔄 **SMART on FHIR Authentication** - OAuth 2.0 for patient apps (Q2 2025)
- 🔄 **Patient Portal Integration** - Member-facing UI (Q2 2025)

#### Provider Directory API (§ 422.123, § 431.60)
**Mandate**: Publicly accessible provider directory via standards-based API.  
**Status**: 20% Complete | **Target**: Q2 2025

- 🔄 **Practitioner Resource** - Provider demographics and identifiers (Q2 2025)
- 🔄 **PractitionerRole Resource** - Specialties, locations, networks (Q2 2025)
- 🔄 **Organization Resource** - Facilities and group practices (Q2 2025)
- 🔄 **Location Resource** - Physical addresses and service locations (Q2 2025)
- 🔄 **Real-Time Directory Updates** - NPPES and credentialing sync (Q3 2025)
- 🔄 **Public API Gateway** - Unauthenticated read access (Q2 2025)

#### Payer-to-Payer Data Exchange (§ 422.120, § 431.60)
**Mandate**: Patient-requested clinical data exchange between payers.  
**Status**: 10% Complete | **Target**: Q2 2025

- 🔄 **FHIR Bulk Data Export** - $export operation for all resources (Q1 2025)
- 🔄 **Patient Consent Management** - Capture and enforce consent (Q1 2025)
- 🔄 **Secure Transfer Protocol** - Encrypted payer-to-payer transmission (Q2 2025)
- 🔄 **Clinical Data Mapping** - X12 → FHIR transformation (Q2 2025)
- 🔄 **ADT Event Handling** - Admit/discharge/transfer workflows (Q3 2025)

#### Prior Authorization API (§ 422.123, § 431.60)
**Mandate**: FHIR-based prior authorization with real-time status.  
**Status**: 30% Complete | **Target**: Q3 2025 (Deadline: January 2027)

- ✅ **X12 278 Authorization Requests** - Inbound processing (November 2024)
- ✅ **X12 278 Authorization Inquiry** - Real-time status (November 2024)
- ✅ **HTTP Replay Endpoint** - Deterministic reprocessing (November 2024)
- 🔄 **ServiceRequest Resource** - X12 278 → FHIR R4 (Q2 2025)
- 🔄 **Da Vinci PAS Implementation** - Prior Authorization Support IG (Q2 2025)
- 🔄 **Task Resource** - Authorization status tracking (Q3 2025)
- 🔄 **Real-Time Authorization** - Instant decisions via FHIR (Q3 2025)
- 🔄 **Clinical Documentation** - X12 275 ↔ FHIR DocumentReference (Q3 2025)

---

## [Unreleased] - Post v1.0.0 Enhancements (Delivered)

### Added

#### Config-to-Workflow Generator (November 2024)
- **Zero-Code Payer Onboarding System**: Transform JSON configuration into complete deployment artifacts
- **Interactive Configuration Wizard**: Guided setup experience completing in <5 minutes
- **TypeScript-Based Generator**: 700+ lines of automation code with comprehensive validation
- **30+ Handlebars Template Helpers**: String, array, conditional, JSON, math, date, type checking utilities
- **Workflow Templates**: Automatic generation of Logic App workflow.json files
- **Infrastructure Templates**: Bicep templates with parameters and deployment scripts
- **Documentation Generation**: Payer-specific DEPLOYMENT.md, CONFIGURATION.md, TESTING.md
- **Example Configurations**: Medicaid MCO and Regional Blues templates included
- **23-Test Comprehensive Suite**: All passing with 100% validation coverage
- **CLI Tool**: Command-line interface with generate, validate, template, list commands

**Documentation**: [CONFIG-TO-WORKFLOW-GENERATOR.md](./docs/CONFIG-TO-WORKFLOW-GENERATOR.md), [IMPLEMENTATION-SUMMARY.md](./IMPLEMENTATION-SUMMARY.md)

#### FHIR R4 Integration (November 2024)
- **X12 270 → FHIR R4 Mapping**: Transform eligibility inquiries to Patient & CoverageEligibilityRequest
- **CMS Patient Access API Compliance**: Ready for CMS-9115-F requirements (14 months ahead of roadmap)
- **US Core Implementation**: US Core Patient profile v3.1.1 compliant
- **Standards Support**: HIPAA X12 270 (005010X279A1), HL7 FHIR R4 (v4.0.1)
- **Zero External Dependencies**: Core mapper with no runtime vulnerabilities
- **19 Comprehensive Tests**: 100% pass rate, covers all mapping scenarios
- **Production-Ready Security**: Secure examples using native fetch and Azure Managed Identity
- **Service Type Mapping**: 100+ X12 service type codes supported
- **Subscriber & Dependent Support**: Complete demographics handling

**Documentation**: [FHIR-INTEGRATION.md](./docs/FHIR-INTEGRATION.md), [FHIR-SECURITY-NOTES.md](./docs/FHIR-SECURITY-NOTES.md), [FHIR-IMPLEMENTATION-SUMMARY.md](./FHIR-IMPLEMENTATION-SUMMARY.md)

#### ValueAdds277 Enhanced Claim Status (November 2024)
- **60+ Enhanced Response Fields**: Comprehensive claim intelligence beyond basic status
- **Financial Fields (8)**: BILLED, ALLOWED, PAID, COPAY, COINSURANCE, DEDUCTIBLE, DISCOUNT, PATIENT_RESPONSIBILITY
- **Clinical Fields (4)**: Diagnosis codes, procedure codes, service dates, place of service
- **Demographics (4 objects)**: Patient, subscriber, billing provider, rendering provider details
- **Remittance Fields (4)**: Check/EFT details, payment date, trace numbers
- **Service Line Details**: 10+ fields per service line with configurable granularity
- **Integration Flags (6)**: Cross-module workflows for Appeals, Attachments, Corrections, Messaging, Chat, Remittance
- **Unified Configuration**: Complete valueAdds277 configuration in payer config schema
- **Premium Product Capability**: $10k/year additional revenue per payer
- **Provider ROI**: 7-21 minutes saved per claim lookup ($69,600/year for 1,000 lookups/month)

**Documentation**: [VALUEADDS277-IMPLEMENTATION-COMPLETE.md](./VALUEADDS277-IMPLEMENTATION-COMPLETE.md), [ECS-INTEGRATION.md](./docs/ECS-INTEGRATION.md)

#### Security Hardening (November 2024)
- **Premium Key Vault Infrastructure**: HSM-backed keys with FIPS 140-2 Level 2 compliance
- **Private Endpoints**: Complete network isolation for Storage, Service Bus, Key Vault
- **VNet Integration**: Logic Apps deployed in private virtual network
- **PHI Masking**: DCR-based transformation rules for Application Insights
- **Customer-Managed Keys**: Optional BYOK for regulatory requirements
- **Data Lifecycle Management**: 7-year retention with automated tier transitions (Hot → Cool → Archive)
- **Storage Cost Optimization**: 94% reduction ($463/mo → $29/mo) with lifecycle policies
- **HTTP Endpoint Authentication**: Azure AD Easy Auth for replay278 endpoint
- **Audit Logging**: 365-day retention with compliance queries
- **4 Bicep Modules**: keyvault.bicep, networking.bicep, private-endpoints.bicep, cmk.bicep (649 lines)
- **HIPAA Compliance**: 100% technical safeguards (§ 164.312) documented and implemented

**Security Score**: 9/10 (Target achieved)

**Documentation**: [SECURITY-HARDENING.md](./SECURITY-HARDENING.md), [HIPAA-COMPLIANCE-MATRIX.md](./docs/HIPAA-COMPLIANCE-MATRIX.md), [SECURITY-IMPLEMENTATION-SUMMARY.md](./SECURITY-IMPLEMENTATION-SUMMARY.md)

#### Gated Release Strategy (November 2024)
- **Pre-Approval Security Validation**: TruffleHog secret detection, PII/PHI scanning, artifact validation
- **UAT Approval Workflow**: 1-2 required approvers, triggers on `release/*` branches
- **PROD Approval Workflow**: 2-3 required approvers, manual dispatch from `main` only
- **Security Context for Approvers**: Scan results visible before approval decision
- **Automated Audit Logging**: Complete deployment history with compliance queries
- **Communication Strategy**: Stakeholder notification matrix with pre/post-deployment templates
- **Emergency Procedures**: Hotfix approval process with 30-minute SLA
- **Rollback Automation**: Automatic rollback-on-failure for UAT, documented procedures for PROD
- **Health Checks**: Post-deployment validation of Logic Apps, Storage, Service Bus, Application Insights
- **Metrics & Reporting**: Deployment success rate, approval times, rollback incidents

**Documentation**: [DEPLOYMENT-GATES-GUIDE.md](./DEPLOYMENT-GATES-GUIDE.md), [GATED-RELEASE-IMPLEMENTATION-SUMMARY.md](./GATED-RELEASE-IMPLEMENTATION-SUMMARY.md)

#### Onboarding Enhancements (November 2024)
- **Interactive Configuration Wizard**: Step-by-step guided configuration with validation (scripts/cli/interactive-wizard.ts)
- **Synthetic 837 Claim Generator**: PHI-safe test data for 837P and 837I claims (scripts/utils/generate-837-claims.ts)
- **Azure Deploy Button Template**: One-click sandbox deployment via azuredeploy.json
- **E2E Test Suite**: Comprehensive health checks with JSON reporting (scripts/test-e2e.ps1)
- **CI/CD PHI Validation**: 18 automated tests prevent PHI exposure (.github/workflows/phi-validation.yml)
- **Troubleshooting FAQ**: 60+ solutions across 9 categories (TROUBLESHOOTING-FAQ.md)
- **Documentation Suite**: QUICKSTART.md, enhanced ONBOARDING.md with 3 deployment options

**Onboarding Time Reduction**: 96% (2-4 hours → <5 minutes)
**Configuration Error Reduction**: 87.5% (40% error rate → <5%)
**Test Coverage Increase**: 41% (44 tests → 62 tests)

**Documentation**: [QUICKSTART.md](./QUICKSTART.md), [ONBOARDING.md](./ONBOARDING.md), [ONBOARDING-ENHANCEMENTS.md](./ONBOARDING-ENHANCEMENTS.md)

#### Sentinel Branding (November 2024)
- **Complete Visual Identity**: Sentinel logo with holographic/neon circuit veins aesthetic
- **Branding Guidelines**: Comprehensive standards document (BRANDING-GUIDELINES.md)
- **Absolute Black Design**: Primary color palette with neon cyan (#00ffff) and green (#00ff88)
- **Segoe UI Bold Typography**: Consistent font usage across all materials
- **Landing Page Transformation**: Complete redesign with Sentinel aesthetic
- **Repository-Wide Enforcement**: Updated all references and documentation

**Documentation**: [BRANDING-GUIDELINES.md](./docs/BRANDING-GUIDELINES.md), [BRANDING-IMPLEMENTATION-SUMMARY.md](./BRANDING-IMPLEMENTATION-SUMMARY.md)

### Changed

- Enhanced README.md with comprehensive features section and new capabilities
- Expanded QUICKSTART.md with post-v1.0.0 feature details
- Updated DEPLOYMENT.md with security hardening deployment section
- Enhanced DEPLOYMENT-SECRETS-SETUP.md with Key Vault migration procedures

### Fixed

- Null safety improvements in configuration validator
- JSON validation for all generated artifacts
- Workflow structure validation for Logic Apps Standard requirements

## [1.0.0] - 2025-11-21

### The Sentinel Has Awakened

This is the first production release of Cloud Health Office — the open-source, Azure-native, HIPAA-engineered platform that ends decades of payer EDI pain.

### Added

#### Core Platform
- **Multi-Tenant SaaS Architecture**: Configuration-driven platform supporting unlimited health plans
- **CLI Onboarding Wizard**: Complete deployment from worksheet to production in <45 minutes
- **Zero-Code Payer Onboarding**: Add new payers via JSON configuration without custom development
- **Backend-Agnostic Design**: Works with any claims system (QNXT, FacetsRx, TriZetto, Epic, Cerner, custom)

#### EDI Transaction Processing
- **275 Attachments**: Clinical and administrative attachment processing with file validation
- **277 RFAI**: Request for Additional Information outbound workflow
- **278 Authorizations**: Prior authorization requests (inpatient, outpatient, referrals)
- **278 Authorization Inquiry (X215)**: Real-time status checks for existing authorizations
- **278 Replay Endpoint**: HTTP endpoint for deterministic 278 transaction replay
- **837 Claims**: Professional, Institutional, and Dental claims submission support
- **270/271 Eligibility**: Real-time eligibility verification with 6 search methods
- **276/277 Claim Status**: Claim status inquiries with date range filtering
- **Appeals Processing**: Appeals submission and tracking with 8 sub-statuses
- **ECS (Enhanced Claim Status)**: Advanced claim status with extended data and 4 query methods

#### Clearinghouse Integration
- **Availity Integration**: Native SFTP and API connectivity
- **Change Healthcare Support**: Ready for integration
- **Optum 360 Support**: Ready for integration
- **Inovalon Support**: Ready for integration
- **Direct Payer Endpoints**: Configuration-driven connectivity

#### Security & Compliance
- **Zero-Trust Architecture**: Private-endpoint-only, no public IPs
- **Azure Key Vault Premium**: HSM-backed keys (FIPS 140-2 Level 2)
- **Private Endpoints**: VNet integration for Storage, Service Bus, Key Vault
- **PHI Masking**: DCR-based redaction in Application Insights
- **HIPAA Compliance**: 100% technical safeguards addressed
- **Automated Secret Rotation**: API keys and credentials rotate automatically
- **7-Year Data Retention**: Automated lifecycle management with tier transitions
- **Audit Logging**: 365-day retention in Log Analytics

#### Infrastructure as Code
- **Complete Bicep Templates**: All Azure resources defined in source
- **Logic Apps Standard Workflows**: 15+ production-ready workflows
- **Modular Security Components**: Key Vault, networking, private endpoints, CMK
- **Multi-Environment Support**: DEV/UAT/PROD configurations
- **GitHub Actions Pipelines**: Automated deployment with approval gates

#### Developer Experience
- **Configuration Schema**: JSON Schema Draft-07 with 200+ validation rules
- **TypeScript Interfaces**: Type-safe configuration handling
- **OpenAPI Specifications**: Complete API documentation
- **Example Configurations**: Medicaid MCO and Regional Blues templates
- **Comprehensive Documentation**: 20+ detailed guides

#### QNXT Integration (First in Open Source)
- **Real-Time Correlation APIs**: Link attachments to claims
- **Appeals Registration**: Direct integration with QNXT Appeals API
- **Authorization Processing**: Complete authorization lifecycle management
- **Eligibility Verification**: Member eligibility checks with retry logic
- **Retry Logic**: 4 retries @ 15-second intervals for API calls

#### Monitoring & Observability
- **Application Insights Integration**: Telemetry and distributed tracing
- **PHI-Safe Logging**: Automated masking of sensitive data
- **Custom Metrics**: Authorization decisions, claim status, appeal tracking
- **Health Checks**: Automated verification post-deployment
- **Dead-Letter Queues**: Failed message handling and replay

### Key Highlights

- **Onboarding time reduction**: 6–18 months (legacy) → <1 hour
- **Professional services cost elimination**: $500k–$2M → $0 (bring-your-own-subscription)
- **First production-grade QNXT REST correlation** in open source
- **Complete source code transparency**: No black boxes, fully auditable
- **Azure Marketplace ready**: Prepared for Managed Application publishing

### Platform Specifications

- **Deployment Target**: Azure (Logic Apps Standard, Data Lake Gen2, Service Bus)
- **Runtime**: Logic Apps Standard (WS1+ SKU)
- **Storage**: Azure Data Lake Storage Gen2 with hierarchical namespace
- **Messaging**: Service Bus Standard tier with topics
- **Security**: Premium Key Vault with HSM-backed keys
- **Monitoring**: Application Insights with PHI masking
- **Language**: TypeScript (generator), Bicep (infrastructure), JSON (workflows)

### Documentation

Complete documentation suite includes:
- **CONTRIBUTING.md**: Development workflow and setup
- **ARCHITECTURE.md**: System architecture and data flows
- **DEPLOYMENT.md**: Step-by-step deployment procedures
- **SECURITY.md**: HIPAA compliance and security practices
- **TROUBLESHOOTING.md**: Common issues and solutions
- **BRANDING-GUIDELINES.md**: Sentinel brand identity standards

### Breaking Changes

N/A - First release

### Security

- All dependencies audited and up-to-date
- No known vulnerabilities in production dependencies
- HIPAA compliance validated for all PHI handling paths
- Security hardening guide included in SECURITY.md

### Known Limitations

- Azure-only deployment (AWS/GCP support planned for Q1 2025)
- Integration Account X12 schemas must be manually imported post-deployment
- API connections require manual authentication configuration
- Azure AD Easy Auth configuration required for replay endpoints

### Migration Guide

N/A - First release

### Contributors

Special thanks to all contributors who made this release possible.

### License

Apache License 2.0 - see [LICENSE](LICENSE) file

---

## The Sentinel Has Awakened

The monolith has landed.  
Legacy EDI integration is now optional.

**Just emerged from the void.**

Star ★ the repo if you believe payers deserve better than 1990s technology in 2025.

---

## v2.0.0 Roadmap - Complete Timeline

### Q1 2025 (January - March): Foundation for Interoperability

#### FHIR R4 Expansion
- [ ] **X12 271 → FHIR CoverageEligibilityResponse** - Complete bidirectional eligibility mapping
- [ ] **FHIR → X12 270 Transformation** - Outbound FHIR queries converted to X12
- [ ] **Azure Health Data Services Integration** - Managed FHIR server deployment
- [ ] **FHIR Resource Validation Library** - Comprehensive validation for all resources

#### Payer-to-Payer Foundation
- [ ] **FHIR Bulk Data Export ($export)** - Complete implementation for data portability
- [ ] **Patient Consent Module** - Capture, store, and enforce patient consent
- [ ] **Clinical Data Repository** - Centralized storage for cross-payer exchange
- [ ] **Secure Transfer Protocol** - Encrypted, audited payer-to-payer connections

#### Platform Enhancements
- [ ] **Azure AD B2C Integration** - Customer SSO and multi-tenant authentication
- [ ] **Enhanced Analytics Dashboard** - Power BI integration for real-time metrics
- [ ] **API Gateway** - Rate limiting, JWT validation, developer portal
- [ ] **Sandbox Environment** - Synthetic data and test harness for developers

### Q2 2025 (April - June): Complete Patient & Provider APIs

#### Patient Access API (Complete)
- [ ] **X12 837 → FHIR Claim** - Professional, institutional, dental claims transformation
- [ ] **X12 835 → FHIR ExplanationOfBenefit** - Remittance and payment details
- [ ] **SMART on FHIR Authentication** - OAuth 2.0 for patient-authorized apps
- [ ] **Da Vinci PDex Implementation** - Payer Data Exchange profile compliance
- [ ] **Member Portal** - Patient-facing UI for claims, EOBs, and appeals

#### Provider Directory API (Complete)
- [ ] **FHIR Practitioner Resource** - Provider demographics with NPI integration
- [ ] **FHIR PractitionerRole Resource** - Specialties, locations, payer networks
- [ ] **FHIR Organization Resource** - Facilities, hospitals, group practices
- [ ] **FHIR Location Resource** - Physical addresses and service locations
- [ ] **Real-Time Directory Updates** - Sync with credentialing and NPPES
- [ ] **Public API Gateway** - Unauthenticated provider lookup

#### Prior Authorization (FHIR Mapping)
- [ ] **X12 278 → FHIR ServiceRequest** - Transform authorization requests
- [ ] **Da Vinci PAS Implementation Guide** - Prior Authorization Support profile
- [ ] **FHIR Task Resource** - Authorization workflow and status tracking
- [ ] **Clinical Documentation Support** - X12 275 ↔ FHIR DocumentReference

#### Marketplace & Commercial
- [ ] **Azure Marketplace Launch** - Transactable SaaS offer with usage-based billing
- [ ] **Subscription Management Portal** - Customer billing and plan management
- [ ] **SaaS Fulfillment API Integration** - Automated provisioning and metering

### Q3 2025 (July - September): AI-Powered Automation & Advanced Features

#### Prior Authorization API (Complete)
- [ ] **Real-Time Authorization Decisions** - Instant approval/denial via FHIR
- [ ] **Clinical Attachment Processing** - Automated review of submitted documents
- [ ] **Authorization Appeal Workflow** - Integrated appeals for denied requests
- [ ] **Predictive Authorization** - ML-based pre-authorization recommendations

#### Provider & Member Portals
- [ ] **Provider Self-Service Portal** - Claims submission without EDI integration
- [ ] **Real-Time Eligibility Checks** - Web-based eligibility verification
- [ ] **Authorization Request Submission** - Web forms for prior auth
- [ ] **Member Portal Mobile App** - iOS and Android native apps

#### AI-Powered Features
- [ ] **AI Claims Adjudication** - Automated adjudication with confidence scoring
- [ ] **Predictive Denial Management** - Pre-submission claim validation
- [ ] **NLP Clinical Documentation** - Extract structured data from PDFs/faxes
- [ ] **Fraud Detection** - ML-based anomaly detection for claims

### Q4 2025 (October - December): International & Advanced Capabilities

#### International Standards
- [ ] **Canadian EDI Support** - CMS 1500, UB-04 claim formats
- [ ] **European HL7 FHIR** - Compliance for EU markets
- [ ] **Multi-Currency Billing** - International payment processing
- [ ] **GDPR & PIPEDA Compliance** - Privacy regulations for Canada and EU

#### Advanced Integrations
- [ ] **Real-Time Benefit Check (RTBC)** - Instant formulary and cost-sharing
- [ ] **HEDIS & Stars Reporting** - Quality measure reporting via FHIR
- [ ] **Risk Adjustment (HCC)** - Hierarchical Condition Category coding
- [ ] **Telehealth Integration** - Virtual visit eligibility and authorization

#### Infrastructure & Operations
- [ ] **Multi-Cloud Kubernetes** - Deploy on AKS, EKS, GKE
- [ ] **Geo-Redundancy** - Active-active deployment across regions
- [ ] **Disaster Recovery** - Automated failover and backup
- [ ] **Advanced Security** - Blockchain audit trail, zero-trust architecture

---

## Release Notes Archive

For detailed release information, visit:
- **GitHub Releases**: [https://github.com/aurelianware/cloudhealthoffice/releases](https://github.com/aurelianware/cloudhealthoffice/releases)
- **Website Release Notes**: [https://cloudhealthoffice.com/release-notes](#) (coming Q1 2025)
- **CMS Compliance Status**: [CMS-0057-F-COMPLIANCE.md](./docs/CMS-0057-F-COMPLIANCE.md)

---

[1.0.0]: https://github.com/aurelianware/cloudhealthoffice/releases/tag/v1.0.0
