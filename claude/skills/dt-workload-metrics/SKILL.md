---
name: dt-workload-metrics
description: Analyze Kubernetes workload CPU and memory usage via Dynatrace dtctl. Use when investigating resource usage, performance issues, or deployment anomalies for a K8s workload.
argument-hint: <cluster> <namespace> <workload> [time-window] [context]
allowed-tools: Bash
---

# Dynatrace Workload Metrics Analysis

Analyze container resource usage for a Kubernetes workload using `dtctl`.

## Arguments

Parse `$ARGUMENTS` as follows:
- **$0** — `k8s.cluster.name` (e.g. `use1-devint-eks-app`)
- **$1** — `k8s.namespace.name` (e.g. `int`)
- **$2** — `k8s.workload.name` (e.g. `scientific-review-backend`)
- **$3** *(optional)* — time window. Accepts:
  - Relative: `30m`, `1h`, `2h`, `24h` → defaults to `30m` if omitted
  - Absolute with timezone: e.g. `"2026-03-26 21:30 to 21:40 UTC+8"` → convert to UTC and build `from:/to:` DQL range
- **$4+** *(optional)* — free-text investigation context (e.g. `"users reporting slowness after deploy"`)

## Steps

### 1. Parse & Validate Arguments
Extract cluster, namespace, workload from the arguments. Determine the time range:
- If relative (e.g. `30m`): use `from:now()-30m` in DQL
- If absolute with timezone: convert to UTC, format as `from:"YYYY-MM-DDTHH:MM:SSZ", to:"YYYY-MM-DDTHH:MM:SSZ"`
- Default to `from:now()-30m` if not provided

### 2. Query CPU & Memory per Pod
Run the following dtctl query (substitute values accordingly):

```bash
dtctl query "timeseries cpu=avg(dt.kubernetes.container.cpu_usage), mem=avg(dt.kubernetes.container.memory_working_set), by:{k8s.workload.name, k8s.pod.name}, from:now()-30m | filter k8s.workload.name == \"<workload>\" | fieldsAdd avg_cpu_m = arrayAvg(cpu), max_cpu_m = arrayMax(cpu), avg_mem_gib = arrayAvg(mem) / 1073741824, max_mem_gib = arrayMax(mem) / 1073741824 | fields k8s.pod.name, avg_cpu_m, max_cpu_m, avg_mem_gib, max_mem_gib | sort max_cpu_m desc"
```

> Note: `dt.kubernetes.container.cpu_usage` is in **millicores** (1000m = 1 core).
> The `timeseries` command does not support filtering by `k8s.cluster.name` directly — filter by `k8s.workload.name` only.

### 3. Analyze Results

Present a clean markdown table of all pods sorted by peak CPU. Then analyze:

**CPU Analysis:**
- Identify outlier pods (peak CPU significantly higher than siblings in same ReplicaSet)
- Flag pods exceeding 800m (0.8 core) peak — potential throttling risk
- Note if avg CPU is consistently high across all pods (workload-level pressure)

**Memory Analysis:**
- Flag pods near or above 1.5 GiB (context-dependent, note if limits are unknown)
- Check for memory growth trend if absolute time range was provided

**ReplicaSet Analysis:**
- Count distinct ReplicaSet hashes (middle segment of pod name, e.g. `79f5f4579b` in `scientific-review-backend-79f5f4579b-v47sk`)
- If more than 1 ReplicaSet is active → likely a **stuck rolling deployment** — flag this prominently
- List all active ReplicaSets and their pod counts

**Context-Aware Analysis:**
- If investigation context was provided, tailor the analysis:
  - "slow" / "latency" → focus on CPU-throttled pods and high avg CPU
  - "deployment" / "rollout" → focus on ReplicaSet count and new vs old pods
  - "down" / "crash" → look for pods with anomalously low metrics (may have restarted)
  - "memory" / "OOM" → focus on memory trend and high-mem pods

### 4. Recommendations

Provide prioritized actionable recommendations:
- **CRITICAL**: Stuck deployment, pod CPU at limit, potential OOMKill risk
- **HIGH**: Single pod outlier causing uneven load, rapid memory growth
- **MEDIUM**: Multiple ReplicaSets (cleanup needed), moderate CPU pressure
- **LOW**: Minor anomalies, informational observations

Suggest follow-up commands if relevant:
```bash
# Check rollout status
kubectl -n <namespace> rollout status deployment/<workload>

# List ReplicaSets
kubectl -n <namespace> get replicasets -l app=<workload>

# Check resource limits
kubectl -n <namespace> describe deployment/<workload> | grep -A5 resources
```
