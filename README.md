# ☁️🛡️ NimbusGuard  

![NinmbusGuard Banner](./assets/nimbus_guard_banner.png)

[![Docker Compose](https://img.shields.io/badge/Docker-Compose-ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen.svg)
![Maintained](https://img.shields.io/badge/Maintained-Yes-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg)

> A modular, open-source CDR stack for modern SecOps.

## Overview

NimbusGuard is an open-source **Cloud Detection and Response (CDR)** platform that unifies cloud visibility, compliance, and automated response.

It brings together best-in-class open tools — **Wazuh**, **Prowler**, **Prometheus**, **Grafana**, **Tracecat**, and **n8n** — into one integrated, extensible stack.

With NimbusGuard, you can:

- Detect misconfigurations and threats across cloud workloads
- Visualize posture and trends with Grafana dashboards
- Automate responses with Tracecat and n8n
- Continuously improve detection and remediation across your environment

A full open-source Cloud Detection and Response (CDR) lab stack — built with modular containers for detection, visibility, metrics, and automated response.

This environment is designed to demonstrate and experiment with modern cloud detection and response concepts using entirely free tools. It’s ideal for security engineers, cloud defenders, and educators who want to test and visualize detection → response workflows.

**DISCLAIMER** This is not meant for production environments.

## Included Components

| Category | Component | Purpose | URL / Port | Default Auth |
|-----------|------------|----------|-------------|---------------|
| **Detection** | **Wazuh** | SIEM, log analysis, agent management | [http://localhost:5601](http://localhost:5601) | `admin / admin` |
| **Compliance** | **Prowler App** | CSPM, threat checks, compliance reports | [http://localhost:8082](http://localhost:8082) | Defined in `config/prowler/.env` |
| **Automation** | **Tracecat** | Cloud response workflows (SOAR-like engine) | [http://localhost:8080](http://localhost:8080) | No auth by default |
| **Orchestration** | **n8n** | Low-code workflow builder (Slack, AWS, etc.) | [http://localhost:5678](http://localhost:5678) | No auth by default |
| **Metrics** | **Prometheus** | Metrics collector | [http://localhost:9090](http://localhost:9090) | None |
| **Dashboards** | **Grafana** | Visualization of all metrics and findings | [http://localhost:3000](http://localhost:3000) | `admin / admin` |

| Component                                              | Role                                | Highlights                                                       |
| ------------------------------------------------------ | ----------------------------------- | ---------------------------------------------------------------- |
| **[Wazuh](https://wazuh.com)**                         | SIEM / XDR / Cloud & host detection | Cloud workload protection, log analysis, alerts, dashboards      |
| **[Prowler](https://prowler.pro)**                     | Cloud compliance scanner            | AWS/Azure/GCP security benchmark auditing (CIS, GDPR, PCI, etc.) |
| **[Prometheus](https://prometheus.io)**                | Metrics collector                   | Gathers performance and security metrics                         |
| **[Grafana](https://grafana.com)**                     | Visualization dashboard             | Unified visualization for Wazuh, CloudQuery, and Prometheus      |
| **[Tracecat](https://github.com/TracecatHQ/tracecat)** | Cloud SOAR / automation             | Security workflow orchestration and automated response engine    |
| **[n8n](https://n8n.io)**                              | General automation / integrations   | Connects alerts to Slack, Jira, ServiceNow, and more             |

### Folder Structure

| Directory              | Purpose                                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------------------- |
| **config/**            | Contains configuration files for each service. These are mounted into containers read-only (`:ro`).     |
| **data/**              | Persistent volumes mapped to Docker services for storage. Each subdirectory matches the container name. |
| **scripts/**           | Utility scripts — e.g., installing Docker, running backups, or health checks.                           |
| **.env**               | Environment variables like AWS credentials, Grafana passwords, API keys, etc.                           |
| **docker-compose.yml** | Main Compose definition — defines services, networks, and volumes.                                      |

## Quickstart

```bash
#copy .env_example to .env
cp .env_example .env

#Make any updates you want to .env

#Run the following python command to generate a password for tracecat db
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

#Update this var in .env with that password: TRACECAT__DB_ENCRYPTION_KEY=

#Generate certs for wazuh
docker compose -f .\docker-compose-wazuh-certs.yml up

#bring the stack up
docker compose up
```

## Architecture

```bash
                ┌──────────────────────────────┐
                │        Cloud Accounts        │
                │ (AWS / Azure / GCP / etc.)   │
                └──────────────┬───────────────┘
                               │
       ┌───────────────────────────────────────────────┐
       │               Detection Layer                 │
       │              Wazuh  ←→  Prowler               │
       └───────────────────────────────────────────────┘
                               │
       ┌───────────────────────────────────────────────┐
       │         Metrics & Visualization Layer         │
       │             Prometheus  ←→  Grafana           │
       └───────────────────────────────────────────────┘
                               │
       ┌───────────────────────────────────────────────┐
       │         Response / Automation Layer           │
       │  Tracecat  ←→  n8n (notifications, tickets)   │
       └───────────────────────────────────────────────┘
```

## Requirements

### Hardware

#### Minimum (Lab / Testing)

| Resource          | Minimum                  |
| ----------------- | ------------------------ |
| **CPU**           | 6 vCPUs                  |
| **Memory (RAM)**  | 12 GB                    |
| **Disk**          | 75 GB SSD                |
| **OS**            | Ubuntu 22.04 / Debian 12 |
| **Docker Engine** | 24.0+                    |
| **Network**       | 10 Mbps+                 |

#### Recommended (Smooth / PoC)

| Resource           | Recommended            |
| ------------------ | ---------------------- |
| **CPU**            | 10–12 vCPUs            |
| **Memory (RAM)**   | 20–24 GB               |
| **Disk**           | 150–250 GB SSD         |
| **Network**        | 100 Mbps+              |
| **Swap**           | 2–4 GB                 |
| **Storage Driver** | overlay2 (SSD backing) |

### Software Requirements

Before running the stack, ensure your system meets the following software prerequisites.

| Software                  | Minimum Version                         | Purpose                                                   |
| ------------------------- | --------------------------------------- | --------------------------------------------------------- |
| **Docker Engine**         | `24.0` or later                         | Container runtime for all services                        |
| **Docker Compose Plugin** | `v2.20` or later                        | Manages multi-container deployments (`docker compose up`) |
| **Git**                   | `2.30` or later                         | To clone and manage the repository                        |
| **Bash / PowerShell**     | Any modern version                      | Running helper scripts and environment setup              |
| **Supported OS**          | Ubuntu 22.04 / Debian 12 / macOS / WSL2 | Linux or Unix-like environment recommended                |

> **Windows users**: Run the stack inside WSL2 (Ubuntu) or Docker Desktop with Linux containers enabled. Native Windows container mode is not supported for Wazuh or Elasticsearch components.

To verify your setup:

```bash
docker --version
docker compose version
```

If you get errors like “docker-compose: command not found”, install the new Compose plugin (not the deprecated standalone binary).

## Component Breakdown

| Component       | Role               | Default Ports |
| --------------- | ------------------ | ------------- |
| Wazuh Dashboard | SIEM / XDR UI      | **5601**      |
| Wazuh API       | Alerts / ingestion | **55000**     |
| Tracecat        | SOAR / Response    | **8080**      |
| n8n             | General Automation | **5678**      |
| Grafana         | Dashboards         | **3000**      |
| Prometheus      | Metrics            | **9090**      |
| CloudQuery      | Asset inventory    | N/A (CLI)     |
| Prowler         | Compliance scanner | N/A (CLI)     |

## Deployment Summary

| Component                          | Purpose                                                          | TLS        | Auth                            | Access / URL                        | Default Login / Notes                   |
| ---------------------------------- | ---------------------------------------------------------------- | ---------- | ------------------------------- | ----------------------------------- | --------------------------------------- |
| **Wazuh Indexer (OpenSearch)**     | Stores & indexes all alerts, audit logs, and detections          | ❌ Disabled | ✅ Yes (admin user)              | `http://wazuh-indexer:9200`         | `admin / SecretPassword`                |
| **Wazuh Manager**                  | Correlates events, sends alerts, connects to Indexer             | ❌ Disabled | ✅ Yes (internal API)            | `http://wazuh-manager:55000`        | `wazuh-wui / SecretPassword`            |
| **Wazuh Dashboard**                | Web UI for Wazuh; visualize detections & rules                   | ❌ Disabled | ✅ Yes (via Indexer)             | `http://localhost:5601`             | `admin / SecretPassword`                |
| **Tracecat**                       | SOAR-like automation engine (detection → response orchestration) | ❌ Disabled | ✅ Yes (local UI login or OAuth) | `http://localhost:8080`             | Default: create user on first login     |
| **CloudQuery**                     | Cloud inventory and compliance data collector (AWS/Azure/GCP)    | ❌ Disabled | ❌ No                            | CLI only (`docker exec cloudquery`) | Config via `/config/config.yml`         |
| **Prowler**                        | Cloud security and compliance scanner                            | ❌ Disabled | ❌ No                            | CLI only (`docker exec prowler`)    | Outputs reports to `/reports/`          |
| **Prometheus**                     | Metrics and system telemetry collection                          | ❌ Disabled | ❌ No                            | `http://localhost:9090`             | Open endpoint, internal use             |
| **Grafana**                        | Dashboards for Wazuh, Tracecat, Prowler, etc.                    | ❌ Disabled | ✅ Yes                           | `http://localhost:3000`             | `admin / admin` (change at first login) |
| **Temporal (Tracecat Backend)**    | Orchestrates workflows for Tracecat                              | ❌ Disabled | ❌ No                            | Internal only (`temporal:7233`)     | No external login                       |
| **Docker Network (`cdr_backend`)** | Internal bridge connecting all services                          | N/A        | N/A                             | Not user-accessible                 | Isolated, no inbound routes             |

## Whats Next

### Example Use Cases

* Cloud visibility: CloudQuery pulls AWS configuration → Grafana visualizes cloud inventory.
* Compliance: Prowler scans AWS account for misconfigurations → outputs JSON/ASFF.
* Detection: Wazuh ingests cloud logs & agent telemetry → alerts appear in dashboard.
* Response: Tracecat automatically remediates findings (e.g., make S3 bucket private).
* Notifications: n8n posts alerts or ticket updates to Slack, Teams, or Jira.
* Metrics: Prometheus collects Wazuh + system metrics → Grafana dashboards show posture trends.

### Integrations and Ideas

* Feed Wazuh alerts into Tracecat workflows via API.
* Use n8n to auto-create Jira tickets or send Slack notifications.
* Query CloudQuery or Prowler findings via Prometheus for Grafana dashboards.
* Build “closed-loop” detection → response → verification automation.
* Tracecat / n8n Automation - Add a workflow to monitor the /prowler/output directory for new files:
  * When a new file appears → Parse JSON → Create alerts or trigger remediations (e.g., make S3 buckets private).

### Example Grafana Dashboards

* Wazuh threat and event metrics
* Prowler compliance findings by severity
* CloudQuery asset inventory and drift tracking
* Tracecat workflow execution status

To automate deployment of dashboards, ensure they are codified and placed in: ```src/grafana/provisioning/dashboards/```

## Updating Components

```bash
docker-compose pull
docker-compose up -d
```

## License

This project aggregates open-source tools, each under its own license:

* Wazuh: GPL-v2
* Prowler: Apache-2.0
* Prometheus / Grafana: Apache-2.0
* Tracecat: AGPL-3.0
* n8n: Sustainable Use License (Faircode)

Orchestration files and configs (docker-compose.yml, configs) in this repo are licensed under MIT unless otherwise noted.

## Contributing

Contributions welcome!

Ideas for improvement:

Besides the [whats next](#whats-next) section:

* Prebuilt Grafana dashboards
* Tracecat or n8n workflow templates
* Additional exporters (e.g., node_exporter)
* Scripts for auto-updating cloud queries or scans
* Adding threat intel
* Add [cloudsploit](https://github.com/aquasecurity/cloudsploit#self-hosted)
* Potentially add [gapps](https://github.com/bmarsh9/gapps)

## Queen City Con

I presented on CDR at [Queen City Con](https://queencitycon.org/)(QCC) 2025. Resources from that talk:

* [Slides](./assets/Beyond_Detection_Cloud_Response_Presentation.pdf)
* [Presentation](https://youtu.be/_tYdKv9RpOg)
* [QFD](./assets/cdr_qfd.xlsx)
* [Nimbus Guard](./nimbus_guard/)
