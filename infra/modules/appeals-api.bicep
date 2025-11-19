// ==================================
// Appeals API Module
// ==================================
// This module deploys resources specific to Claim Appeals integration
// with Availity Bedlam API and QNXT appeals management.

@description('Location for all resources')
param location string = resourceGroup().location

@description('Base name for all resources')
param baseName string

@description('Tags to apply to all resources')
param tags object = {}

// ==================================
// Appeals Configuration Parameters
// ==================================

@description('Enable appeals functionality')
param appealsEnabled bool = false

@description('QNXT appeals endpoint URL')
param qnxtAppealsEndpoint string = ''

@description('Availity Bedlam API endpoint URL')
param availityBedlamEndpoint string = ''

@description('DMS (Document Management System) endpoint URL')
param dmsEndpoint string = ''

@description('Maximum attachment file size in bytes (default 10MB)')
param maxAttachmentSizeBytes int = 10485760

@description('Maximum number of attachments per appeal')
param maxAttachmentsPerAppeal int = 10

@description('Appeal submission time window in days (default 365)')
param appealTimeWindowDays int = 365

@description('Service Bus namespace name for appeals topics')
param serviceBusNamespaceName string

@description('Storage account name for appeal documents')
param storageAccountName string

@description('Key Vault name for storing API credentials')
param keyVaultName string = ''

// ==================================
// Service Bus Topics for Appeals
// ==================================

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
}

// Topic: appeals-attachments
// Purpose: Appeals-related attachments routed from attachment_processor workflow
resource appealsAttachmentsTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = if (appealsEnabled) {
  name: 'appeals-attachments'
  parent: serviceBusNamespace
  properties: {
    maxSizeInMegabytes: 1024
    defaultMessageTimeToLive: 'P14D'
    requiresDuplicateDetection: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    supportOrdering: false
    enablePartitioning: false
  }
}

resource appealsAttachmentsSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = if (appealsEnabled) {
  name: 'appeals-processor'
  parent: appealsAttachmentsTopic
  properties: {
    maxDeliveryCount: 10
    lockDuration: 'PT5M'
    requiresSession: false
    deadLetteringOnMessageExpiration: true
    deadLetteringOnFilterEvaluationExceptions: true
  }
}

// Topic: appeals-updates
// Purpose: Status updates from Availity webhook (appeal_update_to_availity workflow)
resource appealsUpdatesTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = if (appealsEnabled) {
  name: 'appeals-updates'
  parent: serviceBusNamespace
  properties: {
    maxSizeInMegabytes: 1024
    defaultMessageTimeToLive: 'P14D'
    requiresDuplicateDetection: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    supportOrdering: true
    enablePartitioning: false
  }
}

resource appealsUpdatesSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = if (appealsEnabled) {
  name: 'appeals-updates-processor'
  parent: appealsUpdatesTopic
  properties: {
    maxDeliveryCount: 10
    lockDuration: 'PT5M'
    requiresSession: false
    deadLetteringOnMessageExpiration: true
    deadLetteringOnFilterEvaluationExceptions: true
  }
}

// ==================================
// Storage Container for Appeals
// ==================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource appealsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = if (appealsEnabled) {
  name: '${storageAccount.name}/default/appeals-documents'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'Appeals supporting documentation'
      retention: '7-years-HIPAA'
    }
  }
}

// ==================================
// Outputs
// ==================================

@description('Appeals attachments topic name')
output appealsAttachmentsTopicName string = appealsEnabled ? appealsAttachmentsTopic.name : ''

@description('Appeals updates topic name')
output appealsUpdatesTopicName string = appealsEnabled ? appealsUpdatesTopic.name : ''

@description('Appeals container name')
output appealsContainerName string = appealsEnabled ? 'appeals-documents' : ''

@description('Appeals configuration')
output appealsConfiguration object = {
  enabled: appealsEnabled
  qnxtEndpoint: qnxtAppealsEndpoint
  availityEndpoint: availityBedlamEndpoint
  dmsEndpoint: dmsEndpoint
  maxAttachmentSizeBytes: maxAttachmentSizeBytes
  maxAttachmentsPerAppeal: maxAttachmentsPerAppeal
  appealTimeWindowDays: appealTimeWindowDays
  serviceBusTopics: {
    appealsAttachments: appealsEnabled ? appealsAttachmentsTopic.name : ''
    appealsUpdates: appealsEnabled ? appealsUpdatesTopic.name : ''
  }
  storage: {
    containerName: appealsEnabled ? 'appeals-documents' : ''
  }
}
