# Exercise 1: Migration Design (CAF)

## Overview

This exercise walks through the Cloud Adoption Framework (CAF) assessment process for the on-premises Contoso Retail web application. You will analyze the current environment, define the migration strategy, design the Azure Landing Zone architecture, and document all dependencies. The output of this exercise is a migration design document that guides the execution in Exercise 2.

## Task 1: Analyze Existing Application Environment

Assess the on-premises web application to understand its architecture, components, and operational characteristics.

1. Open the sample application source code and review the architecture:

   | Component | Technology | Details |
   | --- | --- | --- |
   | Web Frontend | Node.js + Express + EJS | Serves HTML pages with server-side rendering |
   | Database | SQL Server (on-prem) → Azure SQL | Relational database with Products and Orders tables |
   | Networking | On-prem LAN | Application accessible on port 8080 |
   | Authentication | None (to be added) | Will configure Entra ID in Exercise 4 |
   | Configuration | `.env` file | Connection strings and environment variables |

2. Document the application inventory:

   - **Application name**: Contoso Retail Web App
   - **Application type**: Web application (server-side rendered)
   - **Runtime**: Node.js 20 LTS
   - **Framework**: Express.js 4.x
   - **Database dependency**: Azure SQL Database (`contosodb`)
   - **External dependencies**: None (self-contained)
   - **Data volume**: ~10 products, ~10 orders (small dataset, scales to thousands)
   - **Availability requirements**: Business hours availability, 99.5% SLA target
   - **Current hosting**: On-premises IIS / PM2 on Windows/Linux server

3. Identify migration readiness factors:

   | Factor | Assessment | Notes |
   | --- | --- | --- |
   | Cloud compatibility | High | Node.js runs natively on App Service |
   | Database compatibility | High | Already using Azure SQL |
   | Statefulness | Stateless | No server-side sessions |
   | Dependency complexity | Low | Single database dependency |
   | Configuration management | Environment variables | App Service Application Settings |

Application assessment is complete.

## Task 2: Define Migration Strategy

Define the migration strategy using the CAF 5 Rs (Rehost, Refactor, Rearchitect, Rebuild, Replace) and select the appropriate approach.

1. Evaluate each strategy for the Contoso Retail Web App:

   | Strategy | Fit | Rationale |
   | --- | --- | --- |
   | **Rehost (Lift & Shift to PaaS)** | **Best fit** | App is stateless, uses standard runtime, minimal changes needed |
   | Refactor | Partial | Could containerize, but adds complexity without clear benefit |
   | Rearchitect | Not needed | App is simple enough; microservices would over-engineer |
   | Rebuild | Not needed | Existing code is functional and maintainable |
   | Replace | Not applicable | No SaaS alternative exists |

2. Document the selected strategy:

   - **Strategy**: **Rehost — PaaS-first approach using Azure App Service**
   - **Target platform**: Azure App Service (Linux, Node.js 20 LTS)
   - **App Service Plan**: Standard S1 (production) or Basic B1 (dev/test)
   - **Database**: Azure SQL Database (already provisioned)
   - **Deployment method**: ZIP deploy via Azure CLI or GitHub Actions CI/CD
   - **Estimated migration effort**: Low — configuration changes only, no code changes required

3. List the migration phases:

   | Phase | Activities | Timeline |
   | --- | --- | --- |
   | Phase 1: Plan | Assess, design landing zone, document dependencies | Exercise 1 |
   | Phase 2: Migrate | Create App Service, deploy code, configure settings | Exercise 2 |
   | Phase 3: Secure | Hybrid connectivity, backup, DR | Exercise 3 |
   | Phase 4: Govern | Policies, RBAC, monitoring, endpoint security | Exercise 4 |

Migration strategy is defined.

## Task 3: Design Azure Landing Zone Architecture

Design the Azure Landing Zone for the web application migration.

1. Review the target architecture components:

   ```
   ┌──────────────────────────────────────────────────────┐
   │                  Azure Subscription                   │
   │  ┌─────────────────────────────────────────────────┐ │
   │  │           rg-migration-lab                       │ │
   │  │                                                  │ │
   │  │  ┌────────────────┐   ┌──────────────────────┐  │ │
   │  │  │ App Service     │   │ Azure SQL Database    │  │ │
   │  │  │ Plan (S1)       │   │ contosodb             │  │ │
   │  │  │  ┌────────────┐│   │                        │  │ │
   │  │  │  │ Web App    ││   │                        │  │ │
   │  │  │  │ contoso-web││──→│                        │  │ │
   │  │  │  └────────────┘│   └──────────────────────┘  │ │
   │  │  └───────┬────────┘                              │ │
   │  │          │ VNet Integration                       │ │
   │  │  ┌───────┴──────────────────────────────────┐    │ │
   │  │  │        vnet-migration-lab                 │    │ │
   │  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ │    │ │
   │  │  │  │snet-app  │ │snet-pvt  │ │snet-def  │ │    │ │
   │  │  │  │service   │ │endpoints │ │ault      │ │    │ │
   │  │  │  └──────────┘ └──────────┘ └──────────┘ │    │ │
   │  │  └──────────────────────────────────────────┘    │ │
   │  │                                                  │ │
   │  │  ┌──────────────┐  ┌─────────────────────────┐  │ │
   │  │  │ Azure Monitor │  │ Microsoft Defender      │  │ │
   │  │  │ App Insights  │  │ for Cloud               │  │ │
   │  │  └──────────────┘  └─────────────────────────┘  │ │
   │  └─────────────────────────────────────────────────┘ │
   └──────────────────────────────────────────────────────┘
   ```

2. Document the Landing Zone design decisions:

   | Decision Area | Choice | Justification |
   | --- | --- | --- |
   | Resource organization | Single resource group | Small workload, single team ownership |
   | Networking | VNet with delegated subnet | Enables private database connectivity |
   | Identity | Managed Identity + Entra ID | Passwordless access to Azure SQL |
   | Compute | App Service S1 (Linux) | Cost-effective for stateless web apps |
   | Data | Azure SQL Database Basic | Sufficient for low-throughput workload |
   | Monitoring | Azure Monitor + App Insights | Centralized observability |
   | Security | Defender for Cloud + Azure Policy | Continuous compliance monitoring |
   | DR | Backup + Traffic Manager | Regional resilience for web tier |

Landing zone architecture is designed.

## Task 4: Identify Dependencies

Document all application dependencies that must be addressed during migration.

1. Complete the dependency matrix:

   | Dependency | Type | Source | Target | Migration Action |
   | --- | --- | --- | --- | --- |
   | Azure SQL Database | Data | On-prem SQL Server | Azure SQL | Already migrated / pre-provisioned |
   | Connection string | Configuration | `.env` file | App Service Application Settings | Reconfigure as App Settings |
   | Node.js runtime | Platform | On-prem Node.js 20 | App Service Node.js 20 | Built-in runtime support |
   | Port configuration | Networking | Port 8080 | Port 80/443 | App Service handles port binding |
   | DNS | Networking | On-prem hostname | `*.azurewebsites.net` | Custom domain optional |
   | TLS/SSL | Security | Self-signed or none | App Service managed certificate | Free managed certificate |
   | Identity | Authentication | None | Microsoft Entra ID | Configure in Exercise 4 |

2. Identify risks and mitigations:

   | Risk | Impact | Mitigation |
   | --- | --- | --- |
   | Database connectivity failure | Application down | VNet integration + private endpoint |
   | Configuration drift | Incorrect settings | Infrastructure as Code (ARM/Bicep) |
   | Cold start latency | Slow first request | Always On setting in App Service |
   | Data loss | Business impact | Automated backups + geo-restore |

Dependency analysis is complete.

Evidence to capture:

- Screenshot of the completed dependency matrix document.
- Screenshot or diagram of the target Azure Landing Zone architecture.

![Landing Zone architecture diagram showing App Service, Azure SQL, VNet, and monitoring components](../media/ex1-landing-zone-architecture.png)
> Save your screenshot as `media/ex1-landing-zone-architecture.png`

## Success Criteria

- Application assessment completed with all components, dependencies, and readiness factors documented.
- Migration strategy selected as **Rehost — PaaS-first** targeting Azure App Service with clear justification.
- Azure Landing Zone architecture designed with networking, identity, compute, monitoring, and security decisions documented.
- Dependency matrix completed covering database, configuration, networking, identity, and risk mitigations.

## Learning Outcomes

- Apply the Cloud Adoption Framework (CAF) assessment methodology to evaluate an on-premises web application.
- Select and justify a migration strategy from the 5 Rs framework.
- Design an Azure Landing Zone that incorporates networking, identity, monitoring, and security.
- Perform dependency analysis and risk assessment for cloud migration planning.

## References

- Cloud Adoption Framework for Azure: https://learn.microsoft.com/azure/cloud-adoption-framework/
- CAF Migration methodology: https://learn.microsoft.com/azure/cloud-adoption-framework/migrate/
- Azure Landing Zones: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/
- App Service migration overview: https://learn.microsoft.com/azure/app-service/app-service-migration-overview
- Azure Well-Architected Framework: https://learn.microsoft.com/azure/well-architected/
