# Hands-on Labs – Day 03

## Attack Simulation, Threat Hunting, and Mitigation with Microsoft Defender XDR & Sentinel

### Estimated Duration: 4 Hours

## Overview

In this lab, you will simulate real-world attack techniques, detect and investigate incidents, hunt for threats, and mitigate risks using Microsoft Defender XDR and Microsoft Sentinel. You will begin by performing persistence and command-and-control (C2) attacks on a Windows system, generating registry-based persistence and DNS-based C2 traffic. You will then use Microsoft Sentinel to detect these attacks, configure analytics rules, and investigate incidents.

Next, you will leverage Microsoft Sentinel's hunting capabilities to proactively search for suspicious PowerShell activity, bookmark findings, and automate detection with NRT analytics rules. You will also use Microsoft Defender to perform search jobs and restore relevant data for deeper analysis.

Finally, you will mitigate threats by managing incidents and alerts in Microsoft Defender XDR, applying preset security policies, and investigating the full impact of incidents. By the end of these labs, you will have hands-on experience in simulating attacks, detecting and investigating threats, hunting for malicious activity, and mitigating risks in a Microsoft 365 environment.

## Objective

In **Day-3** of this workshop you will learn how to:

- Deploy Microsoft Defender for Identity Sensor on Domain Controllers
- Simulate and Detect Lateral Movement Attacks
- Investigate Threats and User Timelines 
- Integrate Defender for Identity with Micrososft Defender XDR Portal
- Review and Run Advanced Hunting Queries for Identity Signals
- Review and explore Sentinel workspace 
- Conduct attacks, Create Detections, Investigate an Incident
- Threat Hunting using Notebooks with Microsoft Sentinel
- Mitigate threats using Microsoft Defender
- Command and Control Attack with DNS
- Persistence Attack Detection
- Investigate an incident

## Prerequisites

Participants should have:

- Familiarity with Microsoft 365 security and compliance capabilities.
- Understanding of Microsoft Defender XDR and Microsoft Sentinel.
- Access to the lab-provided Microsoft 365 tenant and administrative permissions.
- Basic knowledge of KQL, incident management, and security policy configuration.
- Awareness of attack techniques, threat hunting, and incident response.

## Explanation of Components

- **Microsoft Defender XDR**: An integrated security suite for detecting, investigating, and responding to threats across endpoints, identities, email, and cloud apps.
- **Microsoft Sentinel**: A cloud-native SIEM and SOAR solution for proactive threat detection, hunting, and automated response.
- **Attack Simulation**: Hands-on steps to simulate persistence (registry modification) and command-and-control (DNS queries) attacks.
- **Analytics Rules**: Custom rules in Sentinel to detect suspicious activity and generate incidents.
- **Threat Hunting**: Building and running KQL queries to proactively search for threats and bookmark notable findings.
- **Incident Investigation**: Reviewing incidents, mapping entities, and analyzing evidence in Defender and Sentinel.
- **Mitigation**: Managing incidents and alerts, applying security recommendations, and restoring data for deeper analysis.

Now, click on **Next** from the lower right corner to move on to the next page.
 
  ![Start Your Azure Journey](./gs/gst9.png)

### Happy learning!