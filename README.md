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
3. Partner HTTP API: http://localhost:8000, Partner gRPC: port 50051, Offer HTTP API: http://localhost:8001, Order HTTP API: http://localhost:8002, Payment HTTP API: http://localhost:8003, User HTTP API: http://localhost:8004, Auth HTTP API: http://localhost:8005, Frontend SPA: http://localhost:4200.
4. Keycloak admin console: http://localhost:8080 (admin/admin by default, realm auto-imported from `fri-food-realm.json`).

## Extending the stack
- Add new services by pointing the Compose `build.context` to the corresponding sibling folder and wiring its `.env` file via `env_file`.
- Reuse the same hostname you plan to expose on AKS so local and cluster configs stay aligned.
- Update `../monitoring/prometheus.yml` whenever you expose new `/metrics` endpoints so they appear in the dashboards automatically.
