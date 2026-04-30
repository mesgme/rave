# L1 — System Context

## What RAVE Does

RAVE sits between reliability intent and operational reality. It makes reliability claims explicit, links them to evidence from real systems, and continuously validates them — surfacing decay before it becomes an incident.

## Users

| Actor | Role |
|---|---|
| **Engineer** | Defines claims, reviews confidence scores, responds to falsifier alerts |
| **AI agent** | Reads claim and readiness state to gate deployments and operations |
| **CI pipeline** | Triggers evidence gathering; provides CI run results as evidence |
| **Community** | Views source, raises issues, forks the pattern for their own systems |

## External Systems

| System | How RAVE Uses It |
|---|---|
| **GitHub API** | Branch protection status, PR merge enforcement, repo metadata |
| **GitHub Actions** | CI run results as evidence (pass/fail, duration, timestamp) |
| **Prometheus / Thanos / VictoriaMetrics** | PromQL query results as evidence (SLO signals, error rates) |
| **Swamp** | Automation runtime — runs evidence gathering, confidence decay, falsifier sweeps |
| **Swamp Extension Registry** | Publishes `rave/*` extension models for community reuse |

## System Context Diagram

```mermaid
graph TD
    Engineer["👤 Engineer"]
    AIAgent["🤖 AI Agent"]
    CI["⚙️ CI Pipeline"]

    RAVE["RAVE System\n(rave-cli / ravegraph / rave-swamp)"]

    GitHubAPI["GitHub API"]
    GitHubActions["GitHub Actions"]
    Prometheus["Prometheus / Thanos"]
    Swamp["Swamp Runtime"]
    SwampRegistry["Swamp Extension Registry"]

    Engineer -->|"defines claims,\nreviews confidence"| RAVE
    AIAgent -->|"reads readiness,\ngates operations"| RAVE
    CI -->|"triggers evidence\ngathering"| RAVE

    RAVE -->|"queries branch protection,\nPR status"| GitHubAPI
    RAVE -->|"reads CI run results"| GitHubActions
    RAVE -->|"executes PromQL\nqueries"| Prometheus
    RAVE -->|"orchestration &\nautomation"| Swamp
    RAVE -->|"publishes rave/* models"| SwampRegistry
```
