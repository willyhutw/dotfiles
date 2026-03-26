---
name: dt-workload-logs
description: Analyze Kubernetes workload logs via Dynatrace dtctl. Use when investigating errors, service degradation, or user-reported issues for a K8s workload.
argument-hint: <cluster> <namespace> <workload> [status] [time-window] [context]
allowed-tools: Bash
---

# Dynatrace Workload Log Analysis

Analyze and summarize workload logs for a Kubernetes workload using `dtctl`.

## Arguments

Parse `$ARGUMENTS` as follows:
- **$0** — `k8s.cluster.name` (e.g. `use1-devint-eks-app`)
- **$1** — `k8s.namespace.name` (e.g. `int`)
- **$2** — `k8s.workload.name` (e.g. `scientific-review-backend`)
- **$3** *(optional)* — log status filter: `ERROR`, `WARN`, `INFO` → defaults to `ERROR` if omitted
- **$4** *(optional)* — time window. Accepts:
  - Relative: `30m`, `1h`, `2h`, `24h` → defaults to `30m` if omitted
  - Absolute with timezone: e.g. `"2026-03-26 21:30 to 21:40 UTC+8"` → convert to UTC and build `from:/to:` DQL range
- **$5+** *(optional)* — free-text investigation context (e.g. `"QA reported service down at 9:30pm"`)

## Steps

### 1. Parse & Validate Arguments
Extract cluster, namespace, workload, status, and time range from arguments.
- If status looks like a time value or free text, treat it as omitted and shift remaining args
- Default status: `ERROR`, default time window: `30m`
- For absolute time ranges with timezone: convert to UTC

### 2. Query Error Summary by Category
Run the following dtctl query (substitute values accordingly):

```bash
dtctl query "fetch logs, from:now()-30m | filter k8s.cluster.name == \"<cluster>\" and k8s.namespace.name == \"<namespace>\" and k8s.workload.name == \"<workload>\" and status == \"<status>\" | parse content, \"json:parsed\" | fieldsAdd category = parsed[categoryName], errtype = parsed[attributes][error.type], errmsg = parsed[attributes][error.message] | summarize count = count(), by:{category, errtype, errmsg} | sort count desc"
```

### 3. Query Error Volume Over Time (for trend analysis)
Run a second query to see error distribution across time:

```bash
dtctl query "fetch logs, from:now()-30m | filter k8s.cluster.name == \"<cluster>\" and k8s.namespace.name == \"<namespace>\" and k8s.workload.name == \"<workload>\" and status == \"<status>\" | summarize count = count(), by:{bin(timestamp, 5m)} | sort timestamp asc"
```

This reveals whether errors are a constant drip, a sudden spike, or a burst tied to an event (deployment, traffic surge, etc.).

### 4. Analyze Results

**Error Summary Table:**
Present a clean prioritized table grouping errors by type. Short-form category names (trim namespace prefixes for readability).

**Priority Classification:**

| Priority | Criteria |
|----------|----------|
| CRITICAL | Infrastructure failures: DB connection refused, permission denied, service unreachable |
| HIGH | Transient failures at high volume (>10 occurrences), operation timeouts, cascading errors |
| MEDIUM | Missing config/data (settings not found, null references), message processing failures |
| LOW | Individual data issues, bad request payloads, single-occurrence anomalies |

**Pattern Recognition — identify and call out:**
- **Cascading errors**: Multiple categories with identical counts (e.g. EF Core + Middleware both at 21) → same root cause propagating through layers
- **Infrastructure issues**: Redis, PostgreSQL, RabbitMQ, external HTTP errors
- **Data/config gaps**: "not found", "does not exist", "cannot be null" errors
- **Version mismatches**: "unknown subcommand", "unsupported feature" errors
- **Deployment artifacts**: Concurrency exceptions, optimistic locking failures (often appear after deploys)
- **Time pattern**: Constant rate = persistent bug; spike then calm = event-triggered; periodic = scheduled job

**Context-Aware Analysis:**
If investigation context was provided, tailor the focus:
- "login slow" / "users can't login" → highlight auth, Redis cache, `/users` endpoint errors
- "service down" → highlight CRITICAL errors, check for permission denied or connection refused
- "after deployment" → highlight concurrency errors, new error patterns in latest ReplicaSet pods
- "QC sync failing" → focus on sync handler and domain errors
- "job failing" → focus on Quartz/scheduled job errors

### 5. Root Cause Hypotheses

For each distinct error group (not each individual row), provide a concise root cause hypothesis and suggested fix. Format:

**[Error Type] — [Count] occurrences**
- **Root cause:** ...
- **Fix:** ...

### 6. Recommendations

Prioritized action list (CRITICAL → LOW). End with suggested follow-up queries if useful:

```bash
# Drill into a specific error with full stack trace
dtctl query "fetch logs, from:now()-30m | filter k8s.workload.name == \"<workload>\" and status == \"ERROR\" | parse content, \"json:parsed\" | filter parsed[attributes][error.type] == \"<ErrorType>\" | fields timestamp, content | sort timestamp desc | limit 5"

# Check logs for a specific pod
dtctl query "fetch logs, from:now()-30m | filter k8s.pod.name == \"<pod-name>\" and status == \"ERROR\" | fields timestamp, content | sort timestamp desc | limit 20"
```
