# Appeals Backend Interface Specification

## Overview

This document defines the backend interface contracts for the Claim Appeals integration system. It provides TypeScript-like interface definitions for all data structures, API contracts, and integration points with external systems (QNXT, Availity Bedlam, DMS).

## Table of Contents

- [Core Data Structures](#core-data-structures)
- [API Interfaces](#api-interfaces)
- [External System Interfaces](#external-system-interfaces)
- [Service Bus Message Contracts](#service-bus-message-contracts)
- [Error Handling](#error-handling)
- [Validation Rules](#validation-rules)

---

## Core Data Structures

### Appeal

Complete appeal entity as stored in QNXT system.

```typescript
interface Appeal {
  // Identity
  appealId: string;                    // Pattern: ^APL-[A-Z0-9]{10,20}$
  claimNumber: string;                 // Pattern: ^[A-Z0-9]{8,20}$
  memberId: string;                    // Pattern: ^[A-Z0-9]{6,15}$
  providerNpi?: string;                // Pattern: ^[0-9]{10}$
  
  // Appeal Details
  appealReason: AppealReasonCode;
  appealReasonDescription: string;     // Max length: 2000
  appealDate: Date;                    // ISO 8601 date-time
  
  // Service Period
  serviceFromDate?: Date;              // ISO 8601 date
  serviceToDate?: Date;                // ISO 8601 date
  
  // Status
  status: AppealStatus;
  submittedAt: Date;
  lastUpdatedAt: Date;
  
  // References
  availityReferenceNumber?: string;
  payerReferenceNumber?: string;
  
  // Decision (if available)
  decision?: AppealDecision;
  
  // Requesting Party
  requestedBy: RequestingParty;
  
  // Attachments
  attachments: AttachmentMetadata[];
  
  // History
  history: AppealHistoryEntry[];
  
  // Metadata
  metadata: {
    correlationId: string;             // UUID
    submissionSource: 'PORTAL' | 'API' | 'BATCH' | 'MANUAL';
    createdAt: Date;
    updatedAt: Date;
  };
}
```

### AppealReasonCode

Enumeration of valid appeal reason codes.

```typescript
type AppealReasonCode = 
  | 'DENIED_CLAIM'
  | 'PARTIAL_PAYMENT'
  | 'CODING_DISPUTE'
  | 'MEDICAL_NECESSITY'
  | 'TIMELY_FILING'
  | 'AUTHORIZATION_ISSUE'
  | 'OUT_OF_NETWORK'
  | 'COORDINATION_OF_BENEFITS'
  | 'DUPLICATE_CLAIM'
  | 'OTHER';

interface AppealReasonDefinition {
  code: AppealReasonCode;
  description: string;
  requiresAdditionalDocumentation: boolean;
  typicalTimeframeBusinessDays: number;
}
```

### AppealStatus

Enumeration of appeal status values.

```typescript
type AppealStatus =
  | 'SUBMITTED'          // Initial submission
  | 'ACCEPTED'           // Accepted by payer
  | 'REJECTED'           // Rejected by payer
  | 'PENDING_REVIEW'     // Under review
  | 'IN_PROGRESS'        // Being processed
  | 'UNDER_REVIEW'       // Clinical review in progress
  | 'APPROVED'           // Approved
  | 'DENIED'             // Denied
  | 'PARTIALLY_APPROVED' // Partially approved
  | 'WITHDRAWN'          // Withdrawn by provider
  | 'COMPLETED'          // Processing complete
  | 'FAILED';            // System failure
```

### AppealDecision

Appeal decision details from payer.

```typescript
interface AppealDecision {
  decisionCode: DecisionCode;
  decisionDate: Date;
  decisionReason: string;              // Max length: 2000
  adjustedAmount?: number;             // Payment adjustment amount
  decidedBy: string;                   // Payer or reviewer name
}

type DecisionCode =
  | 'APPROVED_FULL'
  | 'APPROVED_PARTIAL'
  | 'DENIED'
  | 'WITHDRAWN'
  | 'PENDING';
```

### RequestingParty

Information about who initiated the appeal.

```typescript
interface RequestingParty {
  name: string;                        // Max length: 100
  role: 'PROVIDER' | 'MEMBER' | 'AUTHORIZED_REPRESENTATIVE';
  contactPhone?: string;               // Pattern: ^\+?[0-9]{10,15}$
  contactEmail?: string;               // Email format, max length: 100
}
```

### AttachmentMetadata

Metadata for appeal supporting documents.

```typescript
interface AttachmentMetadata {
  fileName: string;                    // Max length: 255
  dataLakePath: string;                // Pattern: ^hipaa-attachments/
  fileSize: number;                    // Bytes, max: 10485760 (10MB)
  mimeType: 'application/pdf' | 'image/jpeg' | 'image/png' | 'image/tiff' | 'text/plain';
  uploadDate: Date;
  description?: string;                // Max length: 500
  checksumSha256?: string;             // SHA-256 hash for integrity
}
```

### AppealHistoryEntry

Audit trail entry for appeal status changes.

```typescript
interface AppealHistoryEntry {
  status: AppealStatus;
  timestamp: Date;
  note: string;
  updatedBy: string;                   // System or user identifier
  source: 'INTERNAL' | 'AVAILITY' | 'QNXT' | 'MANUAL';
}
```

---

## API Interfaces

### Appeal Submission Request

```typescript
interface SubmitAppealRequest {
  claimNumber: string;
  memberId: string;
  providerNpi?: string;
  appealReason: AppealReasonCode;
  appealReasonDescription: string;
  appealDate: Date;
  serviceFromDate?: Date;
  serviceToDate?: Date;
  requestedBy: RequestingParty;
  attachments: AttachmentMetadata[];
  dmsVerificationStatus?: 'PENDING' | 'VERIFIED' | 'FAILED' | 'NOT_REQUIRED';
  priority?: 'ROUTINE' | 'URGENT' | 'EXPEDITED';
  metadata?: {
    correlationId?: string;
    submissionSource?: string;
    submissionTimestamp?: Date;
  };
}
```

### Appeal Submission Response

```typescript
interface SubmitAppealResponse {
  // Identification
  appealId: string;
  claimNumber: string;
  memberId: string;
  
  // Status
  status: 'SUBMITTED' | 'ACCEPTED' | 'REJECTED' | 'PENDING_REVIEW' | 'FAILED';
  
  // References
  availityReferenceNumber?: string;
  payerReferenceNumber?: string;
  
  // Timestamps
  submittedAt: Date;
  expectedResponseDate?: Date;
  
  // Validation Results
  validationResults?: {
    dmsVerification?: {
      passed: boolean;
      message: string;
      verifiedAt: Date;
    };
    qnxtValidation?: {
      passed: boolean;
      claimExists: boolean;
      eligibilityVerified: boolean;
      message: string;
    };
    attachmentValidation?: {
      totalFiles: number;
      validFiles: number;
      totalSize: number;
      withinLimits: boolean;
    };
  };
  
  // Errors and Warnings
  errors?: ErrorDetail[];
  warnings?: WarningDetail[];
  
  // Next Steps
  nextSteps?: string[];
  
  // Metadata
  metadata: {
    correlationId: string;
    processingTimeMs: number;
    workflowRunId: string;
  };
}
```

### Appeal Update Request

```typescript
interface UpdateAppealRequest {
  appealId: string;
  updateType: UpdateType;
  updateReason: string;                // Max length: 1000
  updatedBy: RequestingParty;
  
  // Optional fields based on update type
  additionalAttachments?: AttachmentMetadata[];
  correctedInformation?: Partial<SubmitAppealRequest>;
  withdrawalRequest?: {
    withdrawalReason: string;
    effectiveDate: Date;
  };
  escalationRequest?: {
    escalationReason: string;
    urgencyLevel: 'URGENT' | 'EXPEDITED';
  };
  
  metadata?: {
    correlationId?: string;
    updateTimestamp?: Date;
    updateSource?: 'PORTAL' | 'API' | 'MANUAL' | 'SYSTEM';
  };
}

type UpdateType =
  | 'ADDITIONAL_DOCUMENTATION'
  | 'CORRECTED_INFORMATION'
  | 'ADDITIONAL_REASON'
  | 'STATUS_INQUIRY'
  | 'WITHDRAWAL'
  | 'ESCALATION';
```

### Get Appeal Details Request

```typescript
interface GetAppealDetailsRequest {
  appealId: string;
  claimNumber?: string;               // Optional for validation
  includeHistory?: boolean;           // Default: false
  includeAttachments?: boolean;       // Default: true
  includeCorrespondence?: boolean;    // Default: false
  metadata?: {
    correlationId?: string;
    requestedBy?: string;
  };
}
```

### Get Appeal Details Response

```typescript
interface GetAppealDetailsResponse {
  // Basic Information
  appealId: string;
  claimNumber: string;
  memberId: string;
  providerNpi?: string;
  
  // Status
  status: AppealStatus;
  appealReason: AppealReasonCode;
  appealReasonDescription: string;
  
  // Timestamps
  submittedAt: Date;
  lastUpdatedAt: Date;
  
  // Decision (if available)
  decision?: AppealDecision;
  
  // References
  availityReferenceNumber?: string;
  payerReferenceNumber?: string;
  
  // Optional Collections (based on request)
  attachments?: AttachmentMetadata[];
  history?: AppealHistoryEntry[];
  correspondence?: CorrespondenceEntry[];
  
  // Metadata
  metadata: {
    correlationId: string;
    retrievedAt: Date;
  };
}
```

---

## External System Interfaces

### QNXT API Interface

```typescript
interface QNXTClient {
  // Claim Validation
  validateClaim(request: ValidateClaimRequest): Promise<ValidateClaimResponse>;
  
  // Appeal Registration
  registerAppeal(request: RegisterAppealRequest): Promise<RegisterAppealResponse>;
  
  // Appeal Retrieval
  getAppeal(appealId: string): Promise<Appeal>;
  
  // Appeal Update
  updateAppeal(appealId: string, updates: Partial<Appeal>): Promise<void>;
  
  // Claim Payment Adjustment
  adjustClaimPayment(claimNumber: string, amount: number, reason: string): Promise<void>;
}

interface ValidateClaimRequest {
  claimNumber: string;
  memberId: string;
  providerNpi?: string;
  serviceFromDate?: Date;
  serviceToDate?: Date;
}

interface ValidateClaimResponse {
  claimExists: boolean;
  claimStatus: string;
  appealEligible: boolean;
  memberActive: boolean;
  eligibilityVerified: boolean;
  appealWindowOpen: boolean;
  appealWindowEndDate?: Date;
  message: string;
}

interface RegisterAppealRequest {
  appealId: string;
  claimNumber: string;
  memberId: string;
  appealReason: AppealReasonCode;
  appealDate: Date;
  availityReferenceNumber?: string;
  requestedBy: RequestingParty;
  attachmentPaths: string[];
}

interface RegisterAppealResponse {
  success: boolean;
  qnxtAppealId: string;
  message: string;
}
```

### Availity Bedlam API Interface

```typescript
interface AvailityClient {
  // Submit Appeal
  submitAppeal(request: AvailitySubmitAppealRequest): Promise<AvailitySubmitAppealResponse>;
  
  // Update Appeal
  updateAppeal(request: AvailityUpdateAppealRequest): Promise<AvailityUpdateAppealResponse>;
  
  // Get Appeal Status
  getAppealStatus(availityReferenceNumber: string): Promise<AvailityAppealStatus>;
  
  // Withdraw Appeal
  withdrawAppeal(availityReferenceNumber: string, reason: string): Promise<void>;
}

interface AvailitySubmitAppealRequest {
  // TODO: Define based on Availity Bedlam API specification
  // This structure will be provided by Cognizant/CTS
  claimNumber: string;
  memberId: string;
  payerId: string;
  appealReason: string;
  appealDetails: string;
  supportingDocuments: {
    documentType: string;
    documentUrl: string;
  }[];
}

interface AvailitySubmitAppealResponse {
  // TODO: Define based on Availity Bedlam API specification
  availityReferenceNumber: string;
  status: string;
  submittedAt: Date;
  message?: string;
}

interface AvailityUpdateAppealRequest {
  availityReferenceNumber: string;
  updateType: string;
  updateDetails: any; // TODO: Define structure
}

interface AvailityUpdateAppealResponse {
  updateStatus: string;
  message: string;
}

interface AvailityAppealStatus {
  availityReferenceNumber: string;
  status: string;
  payerReferenceNumber?: string;
  lastUpdated: Date;
  decision?: {
    decisionCode: string;
    decisionDate: Date;
    adjustedAmount?: number;
  };
}
```

### DMS (Document Management System) Interface

```typescript
interface DMSClient {
  // Verify Documents Exist
  verifyDocuments(paths: string[]): Promise<DocumentVerificationResult[]>;
  
  // Get Document Metadata
  getDocumentMetadata(path: string): Promise<AttachmentMetadata>;
  
  // Check Document Accessibility
  checkAccess(path: string): Promise<boolean>;
}

interface DocumentVerificationResult {
  path: string;
  exists: boolean;
  accessible: boolean;
  metadata?: AttachmentMetadata;
  error?: string;
}
```

---

## Service Bus Message Contracts

### Appeals Attachments Message

Published to `appeals-attachments` topic by `attachment_processor` workflow.

```typescript
interface AppealsAttachmentMessage {
  // Claim Information
  claimNumber: string;
  memberId: string;
  providerNpi?: string;
  
  // Attachment Details
  attachmentType: string;
  dataLakePath: string;
  fileName: string;
  fileSize?: number;
  
  // Appeal Context
  appealIndicator: string;
  appealReasonCode?: AppealReasonCode;
  isAppeal: boolean;
  
  // Service Period
  serviceFromDate?: Date;
  serviceToDate?: Date;
  
  // Tracking
  correlationId: string;
  processingTimestamp: Date;
}
```

### Appeals Updates Message

Published to `appeals-updates` topic by `appeal_update_to_availity` workflow.

```typescript
interface AppealsUpdateMessage {
  eventType: 'STATUS_UPDATE' | 'DECISION' | 'CORRESPONDENCE';
  appealId: string;
  claimNumber?: string;
  status: AppealStatus;
  decision?: AppealDecision;
  correspondence?: {
    type: 'INBOUND' | 'OUTBOUND';
    message: string;
    timestamp: Date;
  };
  timestamp: Date;
  source: 'AVAILITY' | 'QNXT' | 'SYSTEM';
  correlationId: string;
}
```

---

## Error Handling

### Error Detail Structure

```typescript
interface ErrorDetail {
  code: string;                        // Error code (e.g., "VALIDATION_ERROR", "DMS_UNAVAILABLE")
  message: string;                     // Human-readable error message
  field?: string;                      // Field name if validation error
  severity: 'ERROR' | 'WARNING' | 'INFO';
  timestamp?: Date;
}

interface WarningDetail {
  code: string;
  message: string;
  recommendation?: string;
}
```

### Common Error Codes

```typescript
enum AppealErrorCode {
  // Validation Errors
  INVALID_REQUEST = 'INVALID_REQUEST',
  MISSING_REQUIRED_FIELD = 'MISSING_REQUIRED_FIELD',
  INVALID_FIELD_FORMAT = 'INVALID_FIELD_FORMAT',
  
  // Business Logic Errors
  CLAIM_NOT_FOUND = 'CLAIM_NOT_FOUND',
  CLAIM_NOT_ELIGIBLE = 'CLAIM_NOT_ELIGIBLE',
  APPEAL_WINDOW_CLOSED = 'APPEAL_WINDOW_CLOSED',
  DUPLICATE_APPEAL = 'DUPLICATE_APPEAL',
  
  // Document Errors
  DOCUMENT_NOT_FOUND = 'DOCUMENT_NOT_FOUND',
  DOCUMENT_TOO_LARGE = 'DOCUMENT_TOO_LARGE',
  INVALID_DOCUMENT_TYPE = 'INVALID_DOCUMENT_TYPE',
  TOO_MANY_ATTACHMENTS = 'TOO_MANY_ATTACHMENTS',
  
  // External System Errors
  QNXT_UNAVAILABLE = 'QNXT_UNAVAILABLE',
  AVAILITY_UNAVAILABLE = 'AVAILITY_UNAVAILABLE',
  DMS_UNAVAILABLE = 'DMS_UNAVAILABLE',
  
  // Processing Errors
  PROCESSING_TIMEOUT = 'PROCESSING_TIMEOUT',
  INTERNAL_ERROR = 'INTERNAL_ERROR',
}
```

---

## Validation Rules

### Appeal Submission Validation

```typescript
interface AppealValidationRules {
  claimNumber: {
    required: true;
    pattern: /^[A-Z0-9]{8,20}$/;
    minLength: 8;
    maxLength: 20;
  };
  
  memberId: {
    required: true;
    pattern: /^[A-Z0-9]{6,15}$/;
    minLength: 6;
    maxLength: 15;
  };
  
  providerNpi: {
    required: false;
    pattern: /^[0-9]{10}$/;
    length: 10;
  };
  
  appealReason: {
    required: true;
    enum: AppealReasonCode[];
  };
  
  appealReasonDescription: {
    required: false;
    maxLength: 2000;
  };
  
  attachments: {
    required: false;
    maxItems: 10;
    itemValidation: {
      fileSize: { max: 10485760 };  // 10MB
      mimeType: { 
        allowed: ['application/pdf', 'image/jpeg', 'image/png', 'image/tiff', 'text/plain']
      };
    };
  };
  
  appealDate: {
    required: true;
    format: 'ISO8601';
    validation: (date: Date) => date <= new Date(); // Cannot be in future
  };
}
```

### Business Validation Rules

```typescript
interface BusinessValidationRules {
  // Appeal time window (typically 365 days from claim denial date)
  appealTimeWindow: {
    maxDaysFromDenial: 365;
  };
  
  // Total attachment size limit
  totalAttachmentSize: {
    maxBytes: 104857600;  // 100MB total
  };
  
  // Duplicate appeal check
  duplicateCheck: {
    enabled: true;
    checkFields: ['claimNumber', 'appealReason'];
    withinDays: 90;
  };
}
```

---

## TODO Items

1. **Availity Bedlam API Integration**
   - Obtain complete API specification from Cognizant/CTS
   - Define exact request/response structures
   - Document authentication mechanism (OAuth 2.0, API keys)
   - Document webhook signature validation algorithm

2. **QNXT API Integration**
   - Confirm QNXT API endpoints for DEV/UAT/PROD
   - Document authentication and authorization
   - Define error handling for QNXT failures
   - Implement retry policies

3. **DMS Integration**
   - Define DMS API endpoints
   - Document authentication mechanism
   - Implement document integrity verification (checksums)
   - Add support for document versioning

4. **X12 275/277 Requirements**
   - Document X12 275 structure for appeal attachments
   - Document X12 277 structure for appeal status responses
   - Define trading partner agreements for Availity
   - Configure Integration Account schemas

5. **Testing Requirements**
   - Create mock implementations for all external APIs
   - Define integration test scenarios
   - Create sample test data sets
   - Document performance benchmarks

---

## References

- [APPEALS-INTEGRATION.md](./APPEALS-INTEGRATION.md) - Complete implementation guide
- [APPEALS-OPENAPI.yaml](./api/APPEALS-OPENAPI.yaml) - REST API specification
- JSON Schemas: `schemas/Appeal-*.json` - Complete validation schemas
