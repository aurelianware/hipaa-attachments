# Cloud Health Office - Contributor Onboarding Guide

<div align="center">
  <p><em>Just emerged from the void</em></p>
</div>

---

## Welcome, External Developer

Welcome to the **Cloud Health Office** open-source community. This guide is designed specifically for external developers who want to contribute to the #1 Azure-native multi-payer EDI platform.

Whether you're interested in claiming bounties, adding new features, or fixing bugs, this document will guide you through the complete onboarding process from zero to your first merged pull request.

---

## Table of Contents

1. [Quick Start for Contributors](#quick-start-for-contributors)
2. [Development Environment Setup](#development-environment-setup)
3. [Repository Structure](#repository-structure)
4. [Contribution Workflow](#contribution-workflow)
5. [Code Standards and Guidelines](#code-standards-and-guidelines)
6. [Testing Your Changes](#testing-your-changes)
7. [Pull Request Process](#pull-request-process)
8. [Bounty Program](#bounty-program)
9. [Getting Help](#getting-help)
10. [Recognition and Rewards](#recognition-and-rewards)

---

## Quick Start for Contributors

### The 5-Minute Setup

Get started contributing in 5 minutes:

```bash
# 1. Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/cloudhealthoffice.git
cd cloudhealthoffice

# 2. Install dependencies
npm install

# 3. Build the project
npm run build

# 4. Run tests to verify setup
npm test

# 5. Create a feature branch
git checkout -b feature/my-awesome-contribution
```

**You're ready to code!** 🚀

---

## Development Environment Setup

### Required Tools

Install these tools before you begin:

| Tool | Version | Purpose | Installation Link |
|------|---------|---------|-------------------|
| **Node.js** | 20.x LTS | Runtime for build tools | [nodejs.org](https://nodejs.org/) |
| **TypeScript** | 5.x | Type-safe development | Installed via npm |
| **Git** | 2.x+ | Version control | [git-scm.com](https://git-scm.com/) |
| **VS Code** | Latest | Recommended IDE | [code.visualstudio.com](https://code.visualstudio.com/) |
| **Azure CLI** | 2.50+ | Azure resource management | [Install Guide](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| **PowerShell** | 7.x+ | Deployment scripts | [Install Guide](https://docs.microsoft.com/powershell/scripting/install/installing-powershell) |

### Optional but Recommended

- **GitHub Copilot**: AI pair programming assistant (free for OSS contributors)
- **Docker**: For containerized testing environments
- **Postman**: For API testing
- **Azure Storage Explorer**: For Data Lake inspection

### Verify Your Setup

Run these commands to verify your environment:

```bash
# Check Node.js version (should be 20.x)
node --version

# Check npm version
npm --version

# Check Git version
git --version

# Check TypeScript (after npm install)
npx tsc --version

# Check Azure CLI (if working with Azure components)
az --version

# Check PowerShell (if working with deployment scripts)
pwsh --version
```

**Expected Output**: All commands should return version numbers without errors.

### IDE Setup (VS Code)

Install these VS Code extensions for optimal development experience:

```bash
# Install recommended extensions
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension ms-azuretools.vscode-azurelogicapps
code --install-extension ms-azure-devops.azure-pipelines
code --install-extension GitHub.copilot
```

**Workspace Settings**: The repository includes `.vscode/settings.json` with optimal configurations. No additional setup needed.

---

## Repository Structure

Understanding the repository structure helps you navigate and contribute effectively:

```
cloudhealthoffice/
├── .github/                    # GitHub configuration
│   ├── workflows/              # CI/CD pipelines
│   ├── copilot-instructions.md # AI assistant guidelines
│   └── instructions/           # Copilot detailed instructions
├── config/                     # Payer configurations
│   ├── payers/                 # Per-payer config files
│   └── schemas/                # JSON schema definitions
├── core/                       # Core TypeScript libraries
│   ├── generator/              # Config-to-workflow generator
│   ├── templates/              # Handlebars workflow templates
│   └── validators/             # Configuration validators
├── docs/                       # Documentation
│   ├── api/                    # API specifications (OpenAPI)
│   ├── examples/               # Example configurations
│   └── images/                 # Branding assets
├── infra/                      # Infrastructure as Code (Bicep)
│   ├── main.bicep              # Main infrastructure template
│   └── modules/                # Reusable Bicep modules
├── logicapps/                  # Logic Apps workflows
│   └── workflows/              # Individual workflow definitions
│       ├── ingest275/          # 275 attachment ingestion
│       ├── ingest278/          # 278 authorization processing
│       ├── replay278/          # 278 replay endpoint
│       └── rfai277/            # 277 RFAI outbound
├── sales-materials/            # Sales and marketing content
├── schemas/                    # X12 EDI schema definitions
├── scripts/                    # Utility scripts
│   ├── cli/                    # CLI tools (generator, wizard)
│   ├── utils/                  # Helper utilities
│   └── validators/             # Validation scripts
├── src/                        # TypeScript source code
│   ├── generators/             # Generator implementations
│   ├── models/                 # Data models and types
│   └── services/               # Business logic services
├── test/                       # Test files (if present)
├── CONTRIBUTING.md             # General contribution guide
├── ARCHITECTURE.md             # System architecture documentation
├── README.md                   # Project overview
└── package.json                # Node.js project configuration
```

### Key Files for Contributors

- **CONTRIBUTING.md**: High-level contribution guidelines (you're currently in CONTRIBUTOR-ONBOARDING.md for detailed steps)
- **BOUNTY-PROGRAM.md**: Available bounties and reward structure
- **ARCHITECTURE.md**: System design and component interactions
- **package.json**: Build scripts and dependencies

---

## Contribution Workflow

### Step-by-Step Process

#### 1. Find Something to Work On

**Option A: Claim a Bounty** (see [BOUNTY-PROGRAM.md](BOUNTY-PROGRAM.md))
```bash
# Find available bounties
cat BOUNTY-PROGRAM.md
# Comment on the bounty issue to claim it
```

**Option B: Pick an Open Issue**
- Browse [GitHub Issues](https://github.com/aurelianware/cloudhealthoffice/issues)
- Look for `good first issue` or `help wanted` labels
- Comment on the issue to indicate you're working on it

**Option C: Propose a New Feature**
- Check [ROADMAP.md](ROADMAP.md) for planned features
- Open a GitHub Discussion to propose your idea
- Wait for maintainer approval before starting work

#### 2. Fork and Clone the Repository

```bash
# Fork the repository on GitHub (click "Fork" button)

# Clone your fork
git clone https://github.com/YOUR_USERNAME/cloudhealthoffice.git
cd cloudhealthoffice

# Add upstream remote
git remote add upstream https://github.com/aurelianware/cloudhealthoffice.git

# Verify remotes
git remote -v
# Should show:
# origin    https://github.com/YOUR_USERNAME/cloudhealthoffice.git (fetch)
# origin    https://github.com/YOUR_USERNAME/cloudhealthoffice.git (push)
# upstream  https://github.com/aurelianware/cloudhealthoffice.git (fetch)
# upstream  https://github.com/aurelianware/cloudhealthoffice.git (push)
```

#### 3. Set Up Development Environment

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Verify build succeeded
ls -la dist/
```

#### 4. Create a Feature Branch

Use descriptive branch names following this pattern:

```bash
# For new features
git checkout -b feature/fhir-mapper-implementation

# For bug fixes
git checkout -b bugfix/fix-edi-parsing-error

# For documentation updates
git checkout -b docs/update-api-examples

# For bounty work
git checkout -b bounty/500-fhir-mapper
```

#### 5. Make Your Changes

**Follow the Code Standards** (detailed in next section):
- Write clean, readable code
- Add comments for complex logic
- Follow existing code patterns
- Update documentation as needed

**Example: Adding a New Workflow**

```typescript
// src/generators/workflow-generator.ts

export class WorkflowGenerator {
  // Existing methods...

  /**
   * Generates FHIR mapper workflow
   * @param config Payer configuration
   * @returns Workflow JSON definition
   */
  public generateFhirMapperWorkflow(config: PayerConfig): WorkflowDefinition {
    // Implementation here
    const workflow = {
      definition: {
        $schema: "...",
        actions: {
          // Define workflow actions
        },
        triggers: {
          // Define workflow trigger
        }
      },
      kind: "Stateful",
      parameters: {
        // Workflow parameters
      }
    };

    return workflow;
  }
}
```

#### 6. Test Your Changes

**Run all tests**:
```bash
# Unit tests
npm test

# Lint code
npm run lint

# Build to verify compilation
npm run build
```

**Test specific functionality**:
```bash
# Test workflow generation
npm run generate -- --config config/payers/test-payer.json

# Test validation
npm run validate
```

**Manual testing** (if applicable):
```bash
# For Azure deployments, test in a dev environment
az login
az account set --subscription "YOUR_DEV_SUBSCRIPTION"
# Deploy and test...
```

#### 7. Commit Your Changes

Use **Conventional Commits** format:

```bash
# Stage your changes
git add .

# Commit with descriptive message
git commit -m "feat(workflows): Add FHIR mapper workflow generator

- Implemented FHIR R4 resource mapping
- Added HL7 to FHIR transformation logic
- Included unit tests for mapper functions
- Updated documentation with FHIR examples

Closes #123"
```

**Commit Message Format**:
- `feat:` - New feature (minor version bump)
- `fix:` - Bug fix (patch version bump)
- `docs:` - Documentation only
- `refactor:` - Code refactoring
- `test:` - Test additions or updates
- `chore:` - Maintenance tasks

#### 8. Push to Your Fork

```bash
# Push your feature branch to your fork
git push origin feature/fhir-mapper-implementation
```

#### 9. Open a Pull Request

1. Navigate to your fork on GitHub
2. Click **"Compare & pull request"** button
3. Fill out the PR template:

```markdown
## Description
Brief description of what this PR does

## Related Issues
Closes #123
Part of #456

## Changes Made
- [ ] Added FHIR mapper workflow generator
- [ ] Implemented HL7 to FHIR R4 transformation
- [ ] Added unit tests (coverage: 95%)
- [ ] Updated documentation

## Testing Performed
- Unit tests pass (npm test)
- Manual testing in dev environment
- Generated workflow deploys successfully

## Screenshots (if applicable)
[Attach screenshots of UI changes or workflow designer]

## Checklist
- [x] Code follows project style guidelines
- [x] Tests added and passing
- [x] Documentation updated
- [x] No breaking changes
- [x] Commit messages follow Conventional Commits

## Bounty Claim (if applicable)
This PR claims bounty #500: FHIR Mapper Implementation ($500)
```

4. Click **"Create pull request"**

#### 10. Address Review Feedback

Maintainers will review your PR and may request changes:

```bash
# Make requested changes
# ... edit files ...

# Commit changes
git add .
git commit -m "fix: Address PR review feedback

- Refactored FHIR mapper for better performance
- Added error handling for invalid resources
- Updated test cases per reviewer suggestions"

# Push updates
git push origin feature/fhir-mapper-implementation
```

**PR will automatically update** with your new commits.

#### 11. Merge and Celebrate! 🎉

Once approved, a maintainer will merge your PR. Congratulations on your contribution!

```bash
# After merge, sync your fork
git checkout main
git pull upstream main
git push origin main

# Delete your feature branch (optional)
git branch -d feature/fhir-mapper-implementation
git push origin --delete feature/fhir-mapper-implementation
```

---

## Code Standards and Guidelines

### TypeScript Standards

**Type Safety**:
```typescript
// ✅ Good: Explicit types
interface PayerConfig {
  payerId: string;
  payerName: string;
  modules: ModuleConfiguration;
}

function processConfig(config: PayerConfig): WorkflowDefinition {
  // Implementation
}

// ❌ Bad: Using 'any'
function processConfig(config: any): any {
  // Implementation
}
```

**Naming Conventions**:
- **Classes**: PascalCase (`WorkflowGenerator`, `PayerConfigValidator`)
- **Functions**: camelCase (`generateWorkflow`, `validateConfiguration`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT`)
- **Interfaces**: PascalCase with 'I' prefix optional (`PayerConfig` or `IPayerConfig`)

**Code Structure**:
```typescript
// File: src/generators/fhir-mapper.ts

import { WorkflowDefinition } from '../models/workflow';
import { PayerConfig } from '../models/config';

/**
 * FHIR mapper generator for converting HL7 messages to FHIR R4 resources
 */
export class FhirMapperGenerator {
  private readonly templatePath: string;

  constructor(templatePath: string) {
    this.templatePath = templatePath;
  }

  /**
   * Generates FHIR mapper workflow definition
   * @param config Payer configuration
   * @returns Workflow definition with FHIR mapping logic
   */
  public generate(config: PayerConfig): WorkflowDefinition {
    // Implementation
    return workflowDefinition;
  }

  /**
   * Validates FHIR resource against R4 schema
   * @param resource FHIR resource object
   * @returns Validation result
   */
  private validateFhirResource(resource: any): boolean {
    // Implementation
    return true;
  }
}
```

### Logic Apps Workflow Standards

**Required Structure**:
```json
{
  "definition": {
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "actions": {
      "Action_Name": {
        "type": "Http",
        "inputs": {
          "method": "POST",
          "uri": "@parameters('apiEndpoint')"
        },
        "runAfter": {}
      }
    },
    "triggers": {
      "Trigger_Name": {
        "type": "Request",
        "kind": "Http"
      }
    },
    "parameters": {
      "apiEndpoint": {
        "type": "string"
      }
    }
  },
  "kind": "Stateful",
  "parameters": {
    "apiEndpoint": {
      "value": "{config.backendApiEndpoint}"
    }
  }
}
```

**Workflow Naming**:
- Use descriptive action names: `Parse_X12_275`, `Call_QNXT_API`, `Archive_To_DataLake`
- Avoid generic names: `Action1`, `Step2`, `Process`

**Error Handling**:
```json
{
  "actions": {
    "Try_Call_Backend_API": {
      "type": "Scope",
      "actions": {
        "Call_Backend_API": {
          "type": "Http",
          "inputs": {
            "method": "POST",
            "uri": "@parameters('backendApiUrl')"
          },
          "retry": {
            "count": 4,
            "interval": "PT15S",
            "type": "Fixed"
          }
        }
      }
    },
    "Catch_API_Errors": {
      "type": "Scope",
      "actions": {
        "Log_Error": {
          "type": "Compose",
          "inputs": "@result('Try_Call_Backend_API')"
        },
        "Send_To_Dead_Letter": {
          "type": "ServiceBus",
          "inputs": {
            "queueName": "dead-letter"
          }
        }
      },
      "runAfter": {
        "Try_Call_Backend_API": ["Failed", "TimedOut"]
      }
    }
  }
}
```

### Bicep Infrastructure Standards

**Parameter Definitions**:
```bicep
@description('Base name for all resources (3-20 alphanumeric characters)')
@minLength(3)
@maxLength(20)
param baseName string

@description('Azure region for deployment')
@allowed(['eastus', 'westus', 'centralus'])
param location string = 'eastus'
```

**Resource Naming**:
```bicep
// Follow pattern: {baseName}-{resource-type}
var storageAccountName = '${baseName}storage'
var logicAppName = '${baseName}-logicapp-std'
var serviceBusName = '${baseName}-servicebus-ns'
```

**Outputs**:
```bicep
output logicAppId string = logicApp.id
output storageAccountName string = storageAccount.name
output serviceBusEndpoint string = serviceBus.properties.serviceBusEndpoint
```

### Documentation Standards

**Code Comments**:
```typescript
/**
 * Transforms HL7 v2 ADT message to FHIR R4 Patient resource
 * 
 * @param hl7Message - Raw HL7 message string (ADT^A01)
 * @param config - Payer-specific field mappings
 * @returns FHIR Patient resource conforming to R4 specification
 * @throws {ValidationError} If HL7 message is malformed
 * 
 * @example
 * ```typescript
 * const hl7 = "MSH|^~\\&|EPIC|...";
 * const patient = transformHl7ToFhir(hl7, config);
 * console.log(patient.resourceType); // "Patient"
 * ```
 */
export function transformHl7ToFhir(
  hl7Message: string,
  config: FieldMappingConfig
): FhirPatient {
  // Implementation
}
```

**Markdown Documentation**:
- Use clear headings (H1 for title, H2 for sections, H3 for subsections)
- Include code examples with syntax highlighting
- Add diagrams where helpful (ASCII art or links to images)
- Keep line length reasonable (80-120 characters)

### Git Commit Standards

**Conventional Commits Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Examples**:
```bash
# Feature addition
git commit -m "feat(workflows): Add FHIR mapper workflow

Implemented HL7 v2 to FHIR R4 transformation workflow with:
- ADT message parsing and validation
- Patient/Encounter resource generation
- Integration Account connectivity
- Error handling and retry logic

Closes #123"

# Bug fix
git commit -m "fix(generator): Correct Service Bus topic naming

Service Bus topics were using incorrect naming pattern causing
deployment failures. Updated to follow Azure naming conventions.

Fixes #456"

# Documentation
git commit -m "docs(api): Add FHIR mapper API examples

Added comprehensive examples for:
- HL7 to FHIR transformation requests
- FHIR resource validation responses
- Error handling scenarios

Part of #789"
```

---

## Testing Your Changes

### Unit Testing

**Location**: Tests should be in `src/**/*.test.ts` or dedicated `test/` directory.

**Example Test**:
```typescript
// src/generators/fhir-mapper.test.ts

import { FhirMapperGenerator } from './fhir-mapper';
import { PayerConfig } from '../models/config';

describe('FhirMapperGenerator', () => {
  let generator: FhirMapperGenerator;
  let mockConfig: PayerConfig;

  beforeEach(() => {
    generator = new FhirMapperGenerator('./templates');
    mockConfig = {
      payerId: '123456789',
      payerName: 'Test Payer',
      modules: {
        fhirMapper: {
          enabled: true,
          hl7Version: '2.5',
          fhirVersion: 'R4'
        }
      }
    };
  });

  it('should generate valid workflow definition', () => {
    const workflow = generator.generate(mockConfig);
    
    expect(workflow).toBeDefined();
    expect(workflow.kind).toBe('Stateful');
    expect(workflow.definition.actions).toBeDefined();
  });

  it('should include FHIR validation action', () => {
    const workflow = generator.generate(mockConfig);
    
    expect(workflow.definition.actions['Validate_FHIR_Resource']).toBeDefined();
  });

  it('should handle HL7 parsing errors', () => {
    const invalidHl7 = 'INVALID|MESSAGE';
    
    expect(() => generator.parseHl7(invalidHl7)).toThrow('Malformed HL7 message');
  });
});
```

**Run Tests**:
```bash
# Run all tests
npm test

# Run specific test file
npm test -- fhir-mapper.test.ts

# Run with coverage
npm test -- --coverage

# Watch mode for development
npm test -- --watch
```

### Integration Testing

**For Azure Deployments**:
```bash
# Deploy to dev environment
az login
az account set --subscription "DEV_SUBSCRIPTION"

# Deploy infrastructure
az deployment group create \
  --resource-group cho-dev-rg \
  --template-file infra/main.bicep \
  --parameters baseName=chodev

# Deploy workflows
cd logicapps && zip -r ../workflows.zip workflows/
az webapp deploy \
  --resource-group cho-dev-rg \
  --name chodev-logicapp-std \
  --src-path ../workflows.zip \
  --type zip

# Test workflow execution
pwsh -c "./test-workflows.ps1 -TestInbound275 -ResourceGroup 'cho-dev-rg' -LogicAppName 'chodev-logicapp-std'"
```

### Validation Scripts

**Run Validation Suite**:
```bash
# Validate JSON workflows
find logicapps/workflows -name "workflow.json" -exec jq . {} \;

# Validate Bicep templates
az bicep build --file infra/main.bicep --outfile /tmp/arm.json

# Validate PowerShell scripts
pwsh -Command "Get-Content './test-workflows.ps1' | Out-Null"

# Validate configurations
npm run validate
```

### Pre-Commit Checklist

Before committing, ensure:

- [ ] All unit tests pass (`npm test`)
- [ ] No linting errors (`npm run lint`)
- [ ] TypeScript compiles without errors (`npm run build`)
- [ ] Documentation updated for new features
- [ ] No hardcoded credentials or secrets
- [ ] Code follows project style guidelines

---

## Pull Request Process

### PR Template

When you open a PR, use this template (automatically provided):

```markdown
## Description
<!-- Brief description of what this PR does -->

## Related Issues
<!-- Link to related issues -->
Closes #
Part of #

## Changes Made
<!-- Checklist of changes -->
- [ ] Item 1
- [ ] Item 2

## Testing Performed
<!-- How did you test these changes? -->
- Unit tests: [pass/fail]
- Integration tests: [pass/fail]
- Manual testing: [describe]

## Screenshots
<!-- If applicable, add screenshots -->

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Commit messages follow Conventional Commits

## Bounty Claim
<!-- If claiming a bounty -->
This PR claims bounty #[issue number]: [bounty title] ($[amount])
```

### Review Process

**What to Expect**:
1. **Automated Checks** (5-10 minutes): CI/CD runs tests, linting, validation
2. **Initial Review** (1-3 days): Maintainer provides first feedback
3. **Iteration** (as needed): Address feedback, push updates
4. **Approval** (1-2 days after last update): Maintainer approves PR
5. **Merge**: Maintainer merges your PR into main branch

**Common Review Feedback**:
- Code style inconsistencies
- Missing tests or test coverage
- Documentation gaps
- Security concerns (hardcoded secrets, etc.)
- Performance issues

**Responding to Feedback**:
```bash
# Make requested changes
git add .
git commit -m "fix: Address PR review comments

- Refactored X for better readability
- Added missing unit tests
- Updated documentation per feedback"

git push origin feature/my-branch
```

### Merge Conflicts

If your PR has merge conflicts:

```bash
# Sync with upstream main
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# Rebase your feature branch
git checkout feature/my-branch
git rebase main

# Resolve conflicts manually
# ... edit conflicting files ...

git add .
git rebase --continue

# Force push (only on your feature branch!)
git push origin feature/my-branch --force
```

---

## Bounty Program

### Overview

Cloud Health Office offers **cash bounties** for high-value contributions. This incentivizes external developers to build features that benefit the entire community.

For complete bounty details, see **[BOUNTY-PROGRAM.md](BOUNTY-PROGRAM.md)**.

### Quick Bounty Guide

**Available Bounties** (as of November 2025):

| Bounty | Value | Description | Issue |
|--------|-------|-------------|-------|
| **FHIR Mapper** | $500 | HL7 to FHIR R4 transformation workflow | #500 |
| **Prior Auth AI** | $1,000 | ML-based prior authorization prediction | #501 |
| **Claim Auto-Adjudication** | $1,500 | Automated claim decision engine | #502 |
| **Multi-Language Support** | $750 | i18n for UI and documentation | #503 |
| **Performance Dashboard** | $600 | Real-time metrics and analytics UI | #504 |

### How to Claim a Bounty

1. **Find a bounty** in [BOUNTY-PROGRAM.md](BOUNTY-PROGRAM.md) or GitHub Issues (label: `bounty`)
2. **Comment on the issue** to claim it: "I'd like to work on this bounty"
3. **Wait for approval** from maintainers (usually within 24 hours)
4. **Complete the work** following this guide
5. **Submit PR** with bounty claim in PR description
6. **Get approved and merged**
7. **Receive payment** via PayPal, GitHub Sponsors, or wire transfer

### Bounty Rules

- **One claim per person at a time**: Claim and complete one bounty before claiming another
- **30-day completion window**: Complete work within 30 days or bounty reopens
- **Quality standards**: Must meet all code standards and pass review
- **Original work**: No plagiarism or copied code
- **License agreement**: All contributions under Apache 2.0 license

---

## Getting Help

### Resources

**Documentation**:
- [CONTRIBUTING.md](CONTRIBUTING.md) - General contribution guidelines
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment procedures
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

**Community**:
- **GitHub Discussions**: [Ask questions](https://github.com/aurelianware/cloudhealthoffice/discussions)
- **GitHub Issues**: [Report bugs](https://github.com/aurelianware/cloudhealthoffice/issues)
- **Discord** (coming soon): Real-time chat with contributors

### Common Questions

**Q: I'm new to open source. Where do I start?**
A: Start with issues labeled `good first issue`. These are designed for first-time contributors and include extra guidance.

**Q: How long does PR review take?**
A: Initial review typically within 1-3 days. Total time to merge depends on iterations but usually 1-2 weeks.

**Q: Can I work on something not in the issue tracker?**
A: Yes, but please open a GitHub Discussion first to get approval. This avoids wasted effort on features that won't be accepted.

**Q: Do I need Azure access to contribute?**
A: No for most contributions (code, docs). Yes if you want to test Azure deployments end-to-end.

**Q: What if I disagree with review feedback?**
A: Discuss respectfully in the PR. Maintainers have final say, but we're open to different approaches if well-justified.

**Q: Can I claim multiple bounties?**
A: One at a time. Complete and merge your current bounty PR before claiming another.

---

## Recognition and Rewards

### Contributor Recognition

**All contributors are recognized**:

1. **Contributors List**: Your name added to CONTRIBUTORS.md
2. **Release Notes**: Significant contributions mentioned in release notes
3. **Social Media**: Feature highlights shared on project social channels
4. **Swag** (for significant contributions): Cloud Health Office Sentinel t-shirts and stickers

### Bounty Payments

**Payment Methods**:
- PayPal (preferred, fastest)
- GitHub Sponsors (for recurring contributors)
- Wire transfer (for international contributors)
- Cryptocurrency (Bitcoin, Ethereum) on request

**Payment Timeline**:
- Payment processed within 7 business days of PR merge
- Tax forms required for payments >$600 (US contributors)

### Long-Term Contributors

**Core Contributor Status**: After 5+ merged PRs, you may be invited to become a core contributor with:
- Write access to repository
- Ability to review PRs
- Voice in project direction
- Priority support for your contributions
- Exclusive swag and recognition

---

## Legal and Compliance

### Contributor License Agreement

By contributing, you agree that:

1. Your contribution is your original work
2. You grant Apache 2.0 license to your contribution
3. You grant patent license as specified in Apache 2.0
4. Your contribution does not violate any third-party rights
5. You understand this project handles PHI and have reviewed security guidelines

See [CONTRIBUTING.md](CONTRIBUTING.md) for full legal terms.

### Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).

**In summary**:
- Be respectful and inclusive
- Welcome newcomers
- Focus on what is best for the community
- Show empathy towards other community members

Violations can be reported to conduct@aurelianware.com.

---

## Next Steps

**You're ready to contribute!** Here's what to do next:

1. ✅ **Set up your development environment** (see earlier section)
2. ✅ **Pick your first contribution**:
   - Browse [good first issues](https://github.com/aurelianware/cloudhealthoffice/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
   - Check [available bounties](BOUNTY-PROGRAM.md)
3. ✅ **Fork and clone** the repository
4. ✅ **Create a feature branch**
5. ✅ **Make your changes**
6. ✅ **Submit your PR**

**Welcome to the Cloud Health Office community!**

The transformation begins.

---

**Document Version**: 1.0  
**Last Updated**: November 2025  
**Status**: Active
