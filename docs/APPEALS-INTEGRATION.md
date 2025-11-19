# Claim Appeals Integration - Implementation Guide

## Executive Summary

This document provides comprehensive guidance for implementing the Claim Appeals integration with Availity Bedlam API in the HIPAA Attachments system. The integration enables healthcare providers to submit and manage claim appeals through Azure Logic Apps workflows, with full tracking, validation, and compliance features.

**Version**: 1.0.0 (Initial Implementation)  
**Status**: Initial Scaffolding - Requires Implementation  
**Last Updated**: 2024-11-19

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Workflows](#workflows)
4. [Data Models](#data-models)
5. [External Integrations](#external-integrations)
6. [Deployment](#deployment)
7. [Configuration](#configuration)
8. [Testing Strategy](#testing-strategy)
9. [Monitoring and Observability](#monitoring-and-observability)
10. [Security and Compliance](#security-and-compliance)
11. [Troubleshooting](#troubleshooting)
12. [Acceptance Criteria](#acceptance-criteria)
13. [Implementation Roadmap](#implementation-roadmap)
14. [Appendices](#appendices)

---

## Overview

### Purpose

The Claim Appeals integration enables automated processing of claim appeals through the Availity Bedlam portal, providing:

- **Automated Submission**: Submit appeals to payers via Availity API
- **Status Tracking**: Real-time appeal status updates via webhooks
- **Document Management**: Link appeal documents from Data Lake
- **QNXT Integration**: Synchronize appeal status with QNXT system
- **Audit Trail**: Complete history of all appeal activities

### Scope

**In Scope**:
- Appeal submission workflow (appeal_to_payer)
- Appeal update workflow (appeal_update_to_payer)
- Appeal details retrieval (appeal_get_details)
- Availity webhook handler (appeal_update_to_availity)
- Attachment routing with appeal detection (attachment_processor)
- Service Bus topics for appeal events
- Integration Account schemas
- DMS document verification
- QNXT claim validation and appeal registration

**Out of Scope** (Future Enhancements):
- X12 275/277 EDI transactions (will be added based on Cognizant/CTS requirements)
- Real-time appeal status polling
- Advanced analytics and reporting
- Member portal integration
- Bulk appeal submission
- Appeal template management

### Key Stakeholders

- **Development Team**: Implementation and maintenance
- **Cognizant/CTS**: QNXT and Availity integration specifications
- **Compliance Team**: HIPAA and regulatory requirements
- **Operations Team**: Deployment and monitoring
- **Clinical/Business Users**: Appeal submission and tracking

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     External Systems                             │
│  ┌────────────┐  ┌──────────────┐  ┌─────────────────────┐    │
│  │  Availity  │  │    QNXT      │  │   DMS (Data Lake)   │    │
│  │   Bedlam   │  │  Claims API  │  │   Blob Storage      │    │
│  └─────┬──────┘  └──────┬───────┘  └─────────┬───────────┘    │
└────────┼─────────────────┼────────────────────┼─────────────────┘
         │                 │                    │
         │ HTTPS           │ HTTPS              │ Blob API
         │                 │                    │
┌────────┼─────────────────┼────────────────────┼─────────────────┐
│        │                 │                    │                  │
│  ┌─────▼──────┐    ┌────▼────┐         ┌────▼────┐            │
│  │  Webhook   │    │ QNXT    │         │   DMS   │            │
│  │  Handler   │    │Validator│         │ Verifier│            │
│  └─────┬──────┘    └────┬────┘         └────┬────┘            │
│        │                │                   │                  │
│        │     Logic App Workflows            │                  │
│  ┌─────▼─────────────────▼───────────────────▼────┐           │
│  │                                                  │           │
│  │  ┌────────────┐  ┌──────────────┐  ┌─────────┐│           │
│  │  │  appeal_   │  │  appeal_     │  │ appeal_ ││           │
│  │  │  to_payer  │  │  update_to_  │  │ get_    ││           │
│  │  │            │  │  payer       │  │ details ││           │
│  │  └─────┬──────┘  └──────┬───────┘  └────┬────┘│           │
│  │        │                │               │     │           │
│  │  ┌─────▼────────────────▼───────────────▼────┐│           │
│  │  │       Service Bus Topics                  ││           │
│  │  │  - appeals-attachments                    ││           │
│  │  │  - appeals-updates                        ││           │
│  │  └───────────────────────────────────────────┘│           │
│  │                                                 │           │
│  │  ┌──────────────────────────────────────────┐ │           │
│  │  │    attachment_processor                  │ │           │
│  │  │    (Appeal Detection & Routing)          │ │           │
│  │  └──────────────────────────────────────────┘ │           │
│  │                                                 │           │
│  └─────────────────────────────────────────────────┘           │
│                  Azure Logic Apps Standard                      │
└─────────────────────────────────────────────────────────────────┘
         │
         │ Application Insights
         ▼
┌─────────────────────────────────────────────────────────────────┐
│              Monitoring & Observability                          │
│  - Workflow run history                                         │
│  - Application Insights telemetry                               │
│  - Service Bus metrics                                          │
└─────────────────────────────────────────────────────────────────┘
```

### Component Overview

#### Workflows

1. **appeal_to_payer**
   - **Trigger**: HTTP POST request
   - **Purpose**: Submit new appeal to payer via Availity
   - **Key Actions**: Validate request, verify documents, check QNXT, submit to Availity, register in QNXT

2. **appeal_update_to_payer**
   - **Trigger**: HTTP PUT request
   - **Purpose**: Update existing appeal with additional information
   - **Key Actions**: Validate appeal exists, process update type, submit to Availity, update QNXT

3. **appeal_get_details**
   - **Trigger**: HTTP GET request
   - **Purpose**: Retrieve appeal details and status
   - **Key Actions**: Query QNXT, query Availity status, retrieve attachments/history

4. **appeal_update_to_availity**
   - **Trigger**: HTTP POST webhook
   - **Purpose**: Receive and process appeal updates from Availity
   - **Key Actions**: Validate signature, update QNXT, publish to Service Bus

5. **attachment_processor**
   - **Trigger**: Service Bus topic subscription (attachments-in)
   - **Purpose**: Detect appeal-related attachments and route appropriately
   - **Key Actions**: Parse event, detect appeal indicators, route to appeals or standard processing

#### Service Bus Topics

1. **appeals-attachments**
   - **Purpose**: Appeals-related attachments routed from attachment_processor
   - **Subscribers**: Appeals processing workflows
   - **Message TTL**: 14 days
   - **Duplicate Detection**: 10 minutes

2. **appeals-updates**
   - **Purpose**: Appeal status updates from Availity webhooks
   - **Subscribers**: Downstream systems (analytics, notifications)
   - **Message Ordering**: Enabled
   - **Message TTL**: 14 days

#### Storage

1. **appeals-documents** container
   - **Purpose**: Store appeal supporting documentation
   - **Retention**: 7 years (HIPAA compliance)
   - **Access**: Private (no public access)
   - **Path Structure**: `appeals-documents/{appealId}/{yyyy}/{MM}/{dd}/`

---

## Workflows

### 1. appeal_to_payer Workflow

**File**: `logicapps/workflows/appeal_to_payer/workflow.json`

#### Purpose
Submit a new claim appeal to a payer through Availity Bedlam API.

#### Trigger
HTTP POST endpoint with schema validation against `Appeal-ToPayer-Request.json`

#### Flow Diagram
```
HTTP Request
    ↓
Initialize Variables (correlationId, appealId)
    ↓
Log Request Received
    ↓
Validate Request Schema
    ↓
DMS Document Verification
    ├─ Check Attachments Exist
    ├─ Query DMS For Documents
    └─ Verify Document Integrity
    ↓
QNXT Claim Validation
    ├─ Call QNXT Claim API
    ├─ Validate Claim Status
    └─ Check Member Eligibility
    ↓
Submit To Availity Bedlam
    ├─ Prepare Availity Payload
    ├─ Call Availity Bedlam API
    └─ Parse Availity Response
    ↓
Update QNXT With Appeal
    ├─ Register Appeal In QNXT
    └─ Update Claim Status
    ↓
Build Success Response
    ↓
Log Success
    ↓
Response 200 OK
    
(Error Path)
    ↓
Catch Errors
    ├─ Build Error Response
    ├─ Log Error
    └─ Response 500
```

#### Key Actions (TODO Items)

1. **Schema Validation**
   ```
   TODO: Implement comprehensive validation against Appeal-ToPayer-Request.json
   - Validate all required fields
   - Check field formats (patterns, lengths)
   - Validate enums
   - Check attachment limits
   ```

2. **DMS Verification**
   ```
   TODO: Implement DMS document verification
   - Query DMS API for each attachment
   - Verify documents exist in Data Lake
   - Check file integrity (checksums)
   - Validate file sizes and types
   - Ensure total size within limits (100MB)
   ```

3. **QNXT Validation**
   ```
   TODO: Implement QNXT claim validation
   - Make HTTP call to QNXT claims API
   - Verify claim exists and status
   - Check if appeal eligible (claim denied/partially paid)
   - Verify member eligibility
   - Check appeal time window (365 days)
   - Implement retry policy (4 attempts, 15-second intervals)
   ```

4. **Availity Submission**
   ```
   TODO: Implement Availity Bedlam API integration
   - Transform internal request to Availity format
   - Retrieve bearer token from Key Vault
   - Make HTTP POST to Availity API
   - Set timeout: 60 seconds
   - Implement retry policy
   - Parse response for reference number
   ```

5. **QNXT Registration**
   ```
   TODO: Register appeal in QNXT
   - Make HTTP POST to QNXT appeals API
   - Include appealId, claimNumber, Availity reference
   - Update claim status to "APPEAL_SUBMITTED"
   - Handle errors gracefully
   ```

6. **Response Building**
   ```
   TODO: Build response per Appeal-ToPayer-Response.json
   - Include all validation results
   - Provide detailed error messages if failed
   - Include next steps recommendations
   ```

#### Parameters
- `qnxt_endpoint`: QNXT API base URL
- `availity_endpoint`: Availity Bedlam API base URL
- `dms_endpoint`: DMS API base URL

#### Error Handling
- Validation errors: Return 400 with field-specific errors
- DMS unavailable: Return 500 with DMS_UNAVAILABLE error code
- QNXT unavailable: Return 500 with QNXT_UNAVAILABLE error code
- Availity unavailable: Return 500 with AVAILITY_UNAVAILABLE error code

---

### 2. appeal_update_to_payer Workflow

**File**: `logicapps/workflows/appeal_update_to_payer/workflow.json`

#### Purpose
Update an existing appeal with additional information, corrections, or status changes.

#### Trigger
HTTP PUT endpoint with schema validation against `Appeal-UpdateToPayer-Request.json`

#### Flow Diagram
```
HTTP Request
    ↓
Initialize Variables
    ↓
Log Update Request
    ↓
Validate Appeal Exists (Query QNXT)
    ↓
Validate Update Type (Switch)
    ├─ ADDITIONAL_DOCUMENTATION → Verify Additional Documents
    ├─ WITHDRAWAL → Validate Withdrawal Request
    ├─ ESCALATION → Validate Escalation Request
    └─ Other → Process Standard Update
    ↓
Submit Update To Availity
    ↓
Update QNXT Record
    ↓
Build Success Response
    ↓
Response 200 OK
    
(Error Path) → Response 500
```

#### Update Types

1. **ADDITIONAL_DOCUMENTATION**
   - Add new supporting documents to appeal
   - Verify documents in DMS
   - Update attachment list in QNXT

2. **CORRECTED_INFORMATION**
   - Correct previously submitted information
   - Re-validate corrected data
   - Submit corrections to Availity

3. **WITHDRAWAL**
   - Withdraw appeal from consideration
   - Require withdrawal reason
   - Update status in QNXT and Availity

4. **ESCALATION**
   - Escalate to urgent/expedited status
   - Require escalation justification
   - Update priority in both systems

5. **STATUS_INQUIRY**
   - Query current status from Availity
   - Update local cache with latest status

#### Key Actions (TODO Items)

1. **Appeal Existence Validation**
   ```
   TODO: Verify appeal exists and is updatable
   - Query QNXT for appeal by appealId
   - Verify appeal status allows updates
   - Check if already WITHDRAWN or COMPLETED
   ```

2. **Update Type Processing**
   ```
   TODO: Implement branching logic for each update type
   - Route to appropriate validation
   - Prepare type-specific payload
   - Apply business rules per type
   ```

3. **Availity Update**
   ```
   TODO: Submit update to Availity
   - Transform update to Availity format
   - Make HTTP PUT/POST call
   - Parse response status
   ```

---

### 3. appeal_get_details Workflow

**File**: `logicapps/workflows/appeal_get_details/workflow.json`

#### Purpose
Retrieve detailed information about an appeal including status, history, attachments, and correspondence.

#### Trigger
HTTP GET endpoint with query parameters

#### Query Parameters
- `appealId` (required): Unique appeal identifier
- `includeHistory` (optional): Include status change history
- `includeAttachments` (optional): Include attachment metadata (default: true)
- `includeCorrespondence` (optional): Include correspondence history

#### Flow Diagram
```
HTTP Request (GET)
    ↓
Initialize Variables
    ↓
Query QNXT For Appeal Details
    ├─ Get Appeal From QNXT
    ├─ Parse QNXT Response
    └─ Validate Appeal Exists (404 if not found)
    ↓
Query Availity For Status (optional)
    ↓
Retrieve Attachments If Requested
    ↓
Retrieve History If Requested
    ↓
Build Details Response
    ↓
Response 200 OK
    
(Error Path) → Response 404 or 500
```

#### Key Actions (TODO Items)

1. **QNXT Query**
   ```
   TODO: Retrieve appeal from QNXT
   - Make HTTP GET to QNXT appeals API
   - Parse complete appeal record
   - Return 404 if not found
   ```

2. **Availity Status Sync**
   ```
   TODO: Query Availity for latest status
   - Optional: only if local cache is stale
   - Make HTTP GET to Availity status API
   - Merge with QNXT data
   ```

3. **Conditional Data Retrieval**
   ```
   TODO: Implement conditional retrieval
   - Query DMS for attachments if requested
   - Retrieve history from QNXT if requested
   - Retrieve correspondence if requested
   ```

---

### 4. appeal_update_to_availity Workflow

**File**: `logicapps/workflows/appeal_update_to_availity/workflow.json`

#### Purpose
Webhook endpoint for receiving appeal status updates from Availity Bedlam API.

#### Trigger
HTTP POST webhook with signature validation

#### Event Types
1. **STATUS_UPDATE**: General status change
2. **DECISION**: Appeal decision received (approved/denied)
3. **CORRESPONDENCE**: Message from payer

#### Flow Diagram
```
Availity Webhook (HTTP POST)
    ↓
Initialize Variables
    ↓
Log Webhook Received
    ↓
Validate Webhook Signature (X-Availity-Signature)
    ↓
Lookup Appeal In QNXT
    ↓
Process Event Type (Switch)
    ├─ STATUS_UPDATE
    │   ├─ Update Appeal Status In QNXT
    │   └─ Add Status History
    ├─ DECISION
    │   ├─ Update Appeal Decision In QNXT
    │   ├─ Adjust Claim Payment (if approved)
    │   └─ Add Decision History
    └─ CORRESPONDENCE
        └─ Store Correspondence In QNXT
    ↓
Publish Event To ServiceBus (appeals-updates topic)
    ↓
Build Acknowledgment Response
    ↓
Response 200 OK
    
(Error Path) → Response 500 (Availity may retry)
```

#### Security

**Signature Validation**:
```
TODO: Implement webhook signature validation
- Extract X-Availity-Signature header
- Retrieve shared secret from Key Vault
- Compute HMAC-SHA256 of request body
- Compare signatures
- Return 401 if invalid
```

#### Idempotency

```
TODO: Implement idempotency handling
- Use Availity-specific message ID
- Check for duplicate messages (10-minute window)
- Skip processing if duplicate
- Always return 200 OK for valid signature
```

#### Key Actions (TODO Items)

1. **Event Routing**
   ```
   TODO: Route to appropriate handler based on event type
   - STATUS_UPDATE: Update status in QNXT
   - DECISION: Update decision and possibly adjust payment
   - CORRESPONDENCE: Store message
   ```

2. **Payment Adjustment**
   ```
   TODO: Implement claim payment adjustment
   - Only for APPROVED_FULL or APPROVED_PARTIAL decisions
   - Call QNXT payment adjustment API
   - Update claim status to reflect payment
   ```

3. **Service Bus Publishing**
   ```
   TODO: Publish processed event to appeals-updates topic
   - Transform to standard event format
   - Include full context for downstream consumers
   - Set message properties for filtering
   ```

---

### 5. attachment_processor Workflow

**File**: `logicapps/workflows/attachment_processor/workflow.json`

#### Purpose
Process attachment events from Service Bus, detect appeal-related attachments, and route appropriately.

#### Trigger
Service Bus topic subscription: `attachments-in` / `attachment-processor`

#### Flow Diagram
```
Service Bus Message (attachments-in)
    ↓
Initialize Variables (isAppeal flag)
    ↓
Parse Attachment Event
    ↓
Detect Appeal Indicators
    ├─ Check Service Bus Properties (appealFlag, appealReasonCode)
    ├─ Check Attachment Metadata (attachmentType, documentCategory)
    └─ Evaluate Appeal Status
    ↓
Process Attachment
    ├─ Validate Data Lake Path
    ├─ Check File Accessibility
    └─ Extract File Metadata
    ↓
Route Based On Type (If/Else)
    ├─ IF isAppeal = true
    │   ├─ Enrich With Appeal Context
    │   ├─ Publish To appeals-attachments Topic
    │   └─ Log Routed To Appeals
    └─ ELSE
        ├─ Link To Claim (Standard Processing)
        ├─ Update Claim Status
        └─ Log Standard Processing
    ↓
Complete Processing
    ↓
Log Success
    
(Error Path)
    ├─ Build Error Details
    ├─ Log Error
    └─ Send To Dead Letter Queue
```

#### Appeal Detection Logic

```typescript
// Pseudo-code for appeal detection
function detectAppeal(event, properties): boolean {
  // Check 1: Service Bus message properties
  if (properties.appealFlag === true) {
    return true;
  }
  
  // Check 2: Appeal indicator in properties
  if (properties.appealIndicator !== null && properties.appealIndicator !== '') {
    return true;
  }
  
  // Check 3: Attachment type contains "appeal"
  if (event.attachmentType.toLowerCase().includes('appeal')) {
    return true;
  }
  
  // Check 4: Document category is appeal-related
  const appealCategories = ['APPEAL_LETTER', 'APPEAL_SUPPORTING_DOC', 'APPEAL_MEDICAL_RECORDS'];
  if (appealCategories.includes(event.documentCategory)) {
    return true;
  }
  
  return false;
}
```

#### Key Actions (TODO Items)

1. **Appeal Detection**
   ```
   TODO: Implement comprehensive appeal detection
   - Check multiple indicators
   - Support configurable detection rules
   - Log detection reasoning
   ```

2. **Appeal Routing**
   ```
   TODO: Route appeal attachments to specialized processing
   - Enrich event with appeal context
   - Publish to appeals-attachments topic
   - Include all original metadata
   ```

3. **Standard Processing**
   ```
   TODO: Maintain standard attachment processing
   - Link to claim in QNXT
   - Update claim status
   - No disruption to existing flows
   ```

---

## Data Models

See [APPEALS-BACKEND-INTERFACE.md](./APPEALS-BACKEND-INTERFACE.md) for complete data model specifications including:

- Appeal entity structure
- Request/Response schemas
- TypeScript-like interfaces
- Validation rules
- Error structures

---

## External Integrations

### 1. Availity Bedlam API

**Base URL**: `https://api.availity.com/bedlam/v1`

**Authentication**: OAuth 2.0 Bearer Token

**Endpoints** (TODO - Pending Cognizant/CTS specification):
- `POST /appeals` - Submit new appeal
- `PUT /appeals/{referenceNumber}` - Update appeal
- `GET /appeals/{referenceNumber}` - Get appeal status
- `DELETE /appeals/{referenceNumber}` - Withdraw appeal

**Webhook Configuration**:
- Webhook URL: `https://{logic-app}.azurewebsites.net/api/appeal/update-to-availity`
- Signature validation: HMAC-SHA256
- Retry policy: Exponential backoff (3 attempts)

**TODO Items**:
1. Obtain complete API specification from Availity
2. Configure OAuth 2.0 client credentials in Key Vault
3. Implement token refresh logic
4. Test webhook signature validation
5. Document error codes and retry strategies

---

### 2. QNXT Claims API

**Base URL**: (TODO - Pending Cognizant/CTS specification)

**Authentication**: (TODO - TBD)

**Endpoints** (TODO):
- `GET /claims/{claimNumber}` - Validate claim
- `POST /appeals` - Register new appeal
- `GET /appeals/{appealId}` - Retrieve appeal details
- `PUT /appeals/{appealId}` - Update appeal status
- `POST /claims/{claimNumber}/payment-adjustment` - Adjust payment

**TODO Items**:
1. Obtain QNXT API specification and credentials
2. Configure authentication in Key Vault
3. Define retry policies for each endpoint
4. Document error handling strategies
5. Create integration test harness with mock QNXT

---

### 3. DMS (Document Management System)

**Base URL**: (TODO - TBD)

**Purpose**: Verify appeal attachments exist in Data Lake

**Endpoints** (TODO):
- `GET /documents/verify` - Verify documents exist
- `GET /documents/{path}/metadata` - Get document metadata

**TODO Items**:
1. Define DMS API endpoints
2. Implement document verification logic
3. Add checksum validation
4. Configure access permissions

---

## Deployment

### Prerequisites

- Azure subscription with Contributor role
- Resource group created
- Logic App Standard deployed
- Service Bus namespace deployed
- Storage account (Data Lake Gen2) deployed
- Application Insights deployed
- Key Vault deployed (for secrets)

### Infrastructure Deployment

#### 1. Enable Appeals Module

Update `infra/main.parameters.json`:

```json
{
  "appealsEnabled": {
    "value": true
  },
  "qnxtAppealsEndpoint": {
    "value": "https://qnxt-dev.example.com/api/appeals"
  },
  "availityBedlamEndpoint": {
    "value": "https://api-sandbox.availity.com/bedlam/v1/appeals"
  },
  "dmsEndpoint": {
    "value": "https://dms-dev.example.com/api/documents"
  }
}
```

#### 2. Deploy Infrastructure

```bash
# Deploy with appeals enabled
az deployment group create \
  --resource-group rg-hipaa-attachments-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json

# Verify appeals resources created
az servicebus topic show \
  --resource-group rg-hipaa-attachments-dev \
  --namespace-name hipaa-logic-svc \
  --name appeals-attachments

az servicebus topic show \
  --resource-group rg-hipaa-attachments-dev \
  --namespace-name hipaa-logic-svc \
  --name appeals-updates
```

#### 3. Deploy Workflows

```bash
# Create workflow deployment package
cd logicapps
zip -r ../workflows.zip workflows/

# Deploy to Logic App
az webapp deploy \
  --resource-group rg-hipaa-attachments-dev \
  --name hipaa-attachments-la \
  --src-path workflows.zip \
  --type zip

# Restart Logic App
az webapp restart \
  --resource-group rg-hipaa-attachments-dev \
  --name hipaa-attachments-la
```

#### 4. Configure Secrets in Key Vault

```bash
# Availity OAuth credentials
az keyvault secret set \
  --vault-name hipaa-kv-dev \
  --name availity-client-id \
  --value "{client-id}"

az keyvault secret set \
  --vault-name hipaa-kv-dev \
  --name availity-client-secret \
  --value "{client-secret}"

# Availity webhook signature secret
az keyvault secret set \
  --vault-name hipaa-kv-dev \
  --name availity-webhook-secret \
  --value "{webhook-secret}"

# QNXT API credentials
az keyvault secret set \
  --vault-name hipaa-kv-dev \
  --name qnxt-api-key \
  --value "{api-key}"
```

---

## Configuration

### Logic App Application Settings

Add the following application settings to Logic App:

```bash
# Appeals endpoints
QNXT_APPEALS_ENDPOINT=https://qnxt-dev.example.com/api/appeals
AVAILITY_BEDLAM_ENDPOINT=https://api-sandbox.availity.com/bedlam/v1
DMS_ENDPOINT=https://dms-dev.example.com/api/documents

# Service Bus topics
APPEALS_ATTACHMENTS_TOPIC=appeals-attachments
APPEALS_UPDATES_TOPIC=appeals-updates

# Limits
MAX_ATTACHMENT_SIZE_BYTES=10485760
MAX_ATTACHMENTS_PER_APPEAL=10
APPEAL_TIME_WINDOW_DAYS=365
```

---

## Testing Strategy

### Unit Testing

1. **Schema Validation Tests**
   ```
   TODO: Create tests for schema validation
   - Valid request passes validation
   - Invalid field formats fail validation
   - Missing required fields fail validation
   - Attachment limits enforced
   ```

2. **Business Logic Tests**
   ```
   TODO: Test business rules
   - Appeal time window validation
   - Duplicate appeal detection
   - Total attachment size limits
   ```

### Integration Testing

1. **Mock External APIs**
   ```
   TODO: Create mock implementations
   - Mock QNXT API (success/failure scenarios)
   - Mock Availity API (success/failure scenarios)
   - Mock DMS API (document found/not found)
   ```

2. **End-to-End Workflow Tests**
   ```
   TODO: Test complete workflows
   - Submit appeal → verify in QNXT and Availity
   - Update appeal → verify updates propagated
   - Receive webhook → verify QNXT updated
   - Process attachment → verify routing
   ```

### Test Data

See `test-data/` directory for sample test files:
- `test-appeal-to-payer-request.json`
- `test-appeal-update-request.json`
- `test-availity-webhook-status-update.json`
- `test-availity-webhook-decision.json`

---

## Monitoring and Observability

### Application Insights

**Custom Events** (TODO):
- `AppealSubmitted`: Appeal submitted to Availity
- `AppealUpdated`: Appeal updated
- `AppealDecisionReceived`: Decision received from Availity
- `AppealAttachmentRouted`: Attachment routed to appeals processing

**Custom Metrics** (TODO):
- `AppealsSubmitted`: Count of appeals submitted
- `AppealsApproved`: Count of approved appeals
- `AppealsDenied`: Count of denied appeals
- `AppealProcessingTime`: Time to process appeal

**Queries**:

```kusto
// Failed appeal submissions in last 24 hours
customEvents
| where name == "AppealSubmitted"
| where customDimensions.status == "FAILED"
| where timestamp > ago(24h)
| project timestamp, appealId, claimNumber, error
| order by timestamp desc

// Average appeal processing time
customMetrics
| where name == "AppealProcessingTime"
| summarize avg(value), percentile(value, 95) by bin(timestamp, 1h)

// Appeal decision breakdown
customEvents
| where name == "AppealDecisionReceived"
| where timestamp > ago(30d)
| summarize count() by tostring(customDimensions.decisionCode)
```

---

## Security and Compliance

### HIPAA Compliance

1. **PHI Protection**
   - All appeal data contains PHI (member ID, claim number)
   - Encryption at rest (Azure Storage, Service Bus)
   - Encryption in transit (TLS 1.2+)
   - No PHI in logs (Application Insights masking)

2. **Access Control**
   - Logic App uses managed identity
   - RBAC for all Azure resources
   - Key Vault for secrets
   - OAuth 2.0 for API authentication

3. **Audit Trail**
   - Complete appeal history in QNXT
   - Workflow run history (90-day retention)
   - Service Bus message tracking
   - Application Insights custom events

### Data Retention

- **Appeals data**: 7 years (HIPAA requirement)
- **Workflow logs**: 90 days
- **Application Insights**: 365 days
- **Service Bus messages**: 14 days

---

## Troubleshooting

### Common Issues

1. **Appeal Submission Fails - QNXT_UNAVAILABLE**
   - Check QNXT API endpoint is accessible
   - Verify QNXT credentials in Key Vault
   - Check network connectivity from Logic App
   - Review QNXT API logs for errors

2. **Availity Webhook Not Received**
   - Verify webhook URL configured in Availity portal
   - Check webhook signature validation logic
   - Review Logic App run history for failures
   - Ensure Logic App endpoint is publicly accessible

3. **Attachment Routing Not Working**
   - Verify Service Bus topic subscriptions
   - Check appeal detection logic
   - Review Service Bus message properties
   - Ensure attachment_processor workflow is enabled

---

## Acceptance Criteria

This implementation satisfies the following acceptance criteria:

- [ ] appeal_to_payer workflow created (skeleton with TODOs)
- [ ] appeal_update_to_payer workflow created (skeleton with TODOs)
- [ ] appeal_get_details workflow created (skeleton with TODOs)
- [ ] appeal_update_to_availity workflow created (skeleton with TODOs)
- [ ] attachment_processor workflow updated with appeal handling hooks
- [ ] Integration Account schemas added (Appeal-*.json)
- [ ] Bicep module created (infra/modules/appeals-api.bicep)
- [ ] Bicep module referenced in infra/main.bicep (conditional on appealsEnabled)
- [ ] Parameter file created (infra/main.parameters.json)
- [ ] APPEALS-INTEGRATION.md documentation created (600+ lines)
- [ ] APPEALS-BACKEND-INTERFACE.md documentation created
- [ ] APPEALS-OPENAPI.yaml skeleton created
- [ ] README.md updated with Appeals integration
- [ ] DEPLOYMENT.md updated with appeals deployment steps
- [ ] .github/copilot-instructions.md updated with appeals guidance
- [ ] All Bicep files compile without errors
- [ ] All JSON schemas validate successfully
- [ ] All workflow.json files have valid structure
- [ ] OpenAPI YAML validates successfully

### Additional Acceptance Criteria (Implementation Phase)

- [ ] QNXT API integration completed
- [ ] Availity Bedlam API integration completed
- [ ] DMS integration completed
- [ ] Webhook signature validation implemented
- [ ] OAuth 2.0 token management implemented
- [ ] Unit tests created (80%+ coverage)
- [ ] Integration tests created with mocks
- [ ] Application Insights custom events implemented
- [ ] Monitoring dashboards created
- [ ] Production deployment completed
- [ ] User acceptance testing (UAT) completed

---

## Implementation Roadmap

### Phase 1: Initial Scaffolding (Current)

**Status**: ✅ Complete

- [x] Create workflow skeleton files
- [x] Define JSON schemas
- [x] Create Bicep infrastructure module
- [x] Write comprehensive documentation
- [x] Create OpenAPI specification

**Deliverables**: Initial PR with scaffolding

---

### Phase 2: External System Integration (Next)

**Duration**: 2-3 weeks

**Tasks**:
1. Obtain QNXT API specification from Cognizant/CTS
2. Obtain Availity Bedlam API specification
3. Implement QNXT client library
4. Implement Availity client library
5. Implement DMS document verification
6. Configure OAuth 2.0 authentication
7. Test against DEV environments

**Dependencies**:
- QNXT API credentials and endpoints (Cognizant/CTS)
- Availity API credentials and endpoints
- DMS API specification

**Deliverables**:
- Working QNXT integration
- Working Availity integration
- DMS document verification

---

### Phase 3: Workflow Implementation (3-4 weeks)

**Tasks**:
1. Implement appeal_to_payer workflow logic
2. Implement appeal_update_to_payer workflow logic
3. Implement appeal_get_details workflow logic
4. Implement appeal_update_to_availity webhook handler
5. Enhance attachment_processor with appeal routing
6. Add Application Insights custom events
7. Implement error handling and retry policies

**Deliverables**:
- Fully functional workflows
- Complete error handling
- Application Insights integration

---

### Phase 4: Testing & Validation (2-3 weeks)

**Tasks**:
1. Create unit tests for all workflows
2. Create integration test harness
3. Perform end-to-end testing
4. Load testing
5. Security testing (penetration testing)
6. HIPAA compliance audit

**Deliverables**:
- Test suite with 80%+ coverage
- Test results documentation
- Security audit report
- HIPAA compliance checklist

---

### Phase 5: UAT & Production Deployment (2 weeks)

**Tasks**:
1. Deploy to UAT environment
2. User acceptance testing
3. Fix UAT issues
4. Deploy to PROD environment
5. Monitor production deployment
6. Create runbooks and operational procedures

**Deliverables**:
- UAT sign-off
- Production deployment
- Operational runbooks
- Production monitoring dashboards

---

## Appendices

### Appendix A: References

- [APPEALS-BACKEND-INTERFACE.md](./APPEALS-BACKEND-INTERFACE.md) - Complete interface specifications
- [APPEALS-OPENAPI.yaml](./api/APPEALS-OPENAPI.yaml) - REST API specification
- JSON Schemas: `schemas/Appeal-*.json` - Request/response schemas
- [DEPLOYMENT.md](../DEPLOYMENT.md) - General deployment guide
- [SECURITY.md](../SECURITY.md) - Security practices and HIPAA compliance

### Appendix B: Glossary

- **Appeal**: Request to reconsider a claim denial or partial payment
- **Availity Bedlam**: Availity's portal and API for claim appeals
- **QNXT**: Claims management system
- **DMS**: Document Management System (Azure Data Lake)
- **X12 275**: EDI transaction for additional information request
- **X12 277**: EDI transaction for claim status response

### Appendix C: Contact Information

- **Development Team**: dev-team@aurelianware.com
- **Cognizant/CTS Liaison**: [TBD]
- **Availity Support**: support@availity.com
- **On-Call Rotation**: [See PagerDuty]

---

**Document Version**: 1.0.0  
**Last Updated**: 2024-11-19  
**Next Review Date**: 2024-12-19  
**Owner**: Development Team
