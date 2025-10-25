# Open-Source Cloud Detection & Response Stack

A full open-source Cloud Detection and Response (CDR) lab stack — built with modular containers for detection, visibility, metrics, and automated response.

This environment is designed to demonstrate and experiment with modern cloud detection and response concepts using entirely free tools.
It’s ideal for security engineers, cloud defenders, and educators who want to test and visualize detection → response workflows.

## Overview

This Docker Compose deployment brings together:

| Component                                              | Role                                | Highlights                                                       |
| ------------------------------------------------------ | ----------------------------------- | ---------------------------------------------------------------- |
| **[Wazuh](https://wazuh.com)**                         | SIEM / XDR / Cloud & host detection | Cloud workload protection, log analysis, alerts, dashboards      |
| **[CloudQuery](https://cloudquery.io)**                | Cloud asset inventory & posture     | Syncs cloud configs to discover misconfigurations and drift      |
| **[Prowler](https://prowler.pro)**                     | Cloud compliance scanner            | AWS/Azure/GCP security benchmark auditing (CIS, GDPR, PCI, etc.) |
| **[Prometheus](https://prometheus.io)**                | Metrics collector                   | Gathers performance and security metrics                         |
| **[Grafana](https://grafana.com)**                     | Visualization dashboard             | Unified visualization for Wazuh, CloudQuery, and Prometheus      |
| **[Tracecat](https://github.com/TracecatHQ/tracecat)** | Cloud SOAR / automation             | Security workflow orchestration and automated response engine    |
| **[n8n](https://n8n.io)**                              | General automation / integrations   | Connects alerts to Slack, Jira, ServiceNow, and more             |

## Architecture

```bash
                ┌──────────────────────────────┐
                │        Cloud Accounts         │
                │ (AWS / Azure / GCP / etc.)    │
                └──────────────┬───────────────┘
                               │
       ┌───────────────────────────────────────────────┐
       │               Detection Layer                 │
       │  Wazuh  ←→  CloudQuery  ←→  Prowler           │
       └───────────────────────────────────────────────┘
                               │
       ┌───────────────────────────────────────────────┐
       │         Metrics & Visualization Layer          │
       │  Prometheus  ←→  Grafana                       │
       └───────────────────────────────────────────────┘
                               │
       ┌───────────────────────────────────────────────┐
       │         Response / Automation Layer            │
       │  Tracecat  ←→  n8n (notifications, tickets)    │
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

## Getting Started

1. Clone the repository

    ```bash
    git clone https://github.com/<your-username>/open-source-cdr-stack.git
    cd open-source-cdr-stack
    ```

2. Configure environment variables

    Copy .env.example to .env and fill in your cloud credentials:

    ```bash
    AWS_ACCESS_KEY_ID=YOUR_KEY
    AWS_SECRET_ACCESS_KEY=YOUR_SECRET
    AWS_DEFAULT_REGION=us-east-1
    TRACECAT_API_KEY=changeme
    ```

    > ⚠️ Use read-only IAM credentials or sandbox accounts for lab use.

    The ```TRACECAT_API_KEY``` is something you provide. You can use the following to create your own api key:

    ```bash
    openssl rand -hex 32
    ```

    When Tracecat starts, it will use this token as the API auth secret. It is an authentication token used by Tracecat’s API service layer for things such as: Trigger workflows, Query case data,Submit alerts, or Run integrations.

3. Adjust configurations (optional)

    | Directory                     | Purpose                             |
    | ----------------------------- | ----------------------------------- |
    | `wazuh/config/`               | Wazuh manager configuration         |
    | `cloudquery/config/`          | Define which cloud services to sync |
    | `prometheus/prometheus.yml`   | Metrics scrape targets              |
    | `grafana/provisioning/`       | Dashboards & data sources           |
    | `prowler/output/`             | Compliance scan results             |
    | `tracecat_data/`, `n8n_data/` | Persistent workflow data            |

4. Launch the stack

    ```bash
    docker-compose up -d
    ```

    Check logs:

    ```bash
    docker-compose logs -f wazuh-manager
    ```

5. Access Web UIs

| Tool                | URL                                            | Credentials                 |
| ------------------- | ---------------------------------------------- | --------------------------- |
| **Wazuh Dashboard** | [http://localhost:5601](http://localhost:5601) | admin / admin (default)     |
| **Grafana**         | [http://localhost:3000](http://localhost:3000) | admin / admin               |
| **Tracecat**        | [http://localhost:8080](http://localhost:8080) | configure API key in `.env` |
| **n8n**             | [http://localhost:5678](http://localhost:5678) | admin / admin               |

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

## Persistence and Volumes

Persistent volumes are defined for:

* wazuh_data
* wazuh_indexer_data
* prometheus_data
* grafana_data
* tracecat_data
* n8n_data

Back up these volumes if you rebuild the stack.

## Updating Components

```bash
docker-compose pull
docker-compose up -d
```

## Security Notes

* Avoid using production credentials in lab deployments.
* Rotate API keys periodically.
* Bind services to 127.0.0.1 or use Docker network isolation if deployed on a public host.
* Use HTTPS reverse proxy (e.g., Traefik or Nginx) for production exposure.

## License

This project aggregates open-source tools, each under its own license:

* Wazuh: GPL-v2
* CloudQuery: MPL-2.0
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
