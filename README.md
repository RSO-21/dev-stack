# FRI Food Dev Stack

This folder orchestrates multiple microservices from the shared RSO workspace so that a single `docker compose up` reproduces the local topology we want to mirror on AKS. The current stack wires Partner, Offer, Order, Payment, User, Auth, and the Monitoring suite—plus the Angular frontend. You can add other services over time following the same pattern.

## Prerequisites
- Docker Desktop with Compose v2
- The sibling folders `partner-service/`, `offer-service/`, `order-service/`, `payment-service/`, `user-service/`, `auth-service/`, `frifood-frontend/`, and `monitoring/` already cloned (same root as this folder)
- `.env` files present in `partner-service/`, `offer-service`, `order-service`, `payment-service`, `user-service`, and `auth-service` (copy from their `.env.example` if needed)
- A Docker network called `fri-net` created once via `docker network create fri-net` (the compose file treats it as external so other stacks can reuse it)

## Usage
1. From this folder run `docker compose up --build` to build images from the existing Dockerfiles and start every service on the shared `fri-net` network.
2. Prometheus becomes available at http://localhost:9090 and Grafana at http://localhost:3000 (admin/admin by default).
3. Partner HTTP API: http://localhost:8000, Partner gRPC: port 50051, Offer HTTP API: http://localhost:8001, Order HTTP API: http://localhost:8002, Payment HTTP API: http://localhost:8003, User HTTP API: http://localhost:8004, Auth HTTP API: http://localhost:8005, Frontend SPA (nginx container): http://localhost:4200.
4. Keycloak admin console: http://localhost:8080 (admin/admin by default, realm auto-imported from `fri-food-realm.json`).

Note: the frontend container is a production-style nginx image (no live reload). Re-run `docker compose up --build frontend` after frontend code changes.

## Extending the stack
- Add new services by pointing the Compose `build.context` to the corresponding sibling folder and wiring its `.env` file via `env_file`.
- Reuse the same hostname you plan to expose on AKS so local and cluster configs stay aligned.
- Update `../monitoring/prometheus.yml` whenever you expose new `/metrics` endpoints so they appear in the dashboards automatically.

## Kubernetes monitoring (Prometheus + Grafana)

For Kubernetes/AKS, the recommended approach is to deploy monitoring as native Kubernetes workloads (via Helm), not to build a custom Dockerfile that bundles Prometheus+Grafana into a single image/pod.

This repo includes an ArgoCD application that deploys a Prometheus Operator stack (`kube-prometheus-stack`) into a `monitoring` namespace:

- ArgoCD app: `apps/shared/monitoring-application.yaml`
- Values: `apps/shared/monitoring-values.yaml`
- Wrapper chart: `charts/monitoring`

### How to enable
1. Apply the ArgoCD Application manifest:
	 - `kubectl apply -f dev-stack/apps/shared/monitoring-application.yaml`
2. Wait for sync to complete in ArgoCD.

### How to access
- Grafana (port-forward):
	- `kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80`
	- Then open http://localhost:3000 (default user: `admin`, password: `admin`)
- Prometheus (port-forward):
	- `kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090`
	- Then open http://localhost:9090

### Next steps (later)
- Per-microservice monitoring: expose `/metrics` (Prometheus format) in each service and add `ServiceMonitor` resources.
- Log aggregation: add Loki + Promtail (or Grafana Agent) and wire Grafana datasources.

