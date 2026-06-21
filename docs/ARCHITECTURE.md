# Architecture (fill this in)

## 1. Topology diagram
> Draw it (ASCII, Excalidraw, draw.io — anything). Show: your nodes, where each TaskApp
> tier runs, the ingress controller, and the request path.

```
Internet

│

▼

Route53/DuckDNS (josephigwe.duckdns.org → 13.61.1.134)

│

▼

AWS Security Group (ports 80, 443 open; 22 & 6443 to my IP only)

│

▼

control-plane (t3.small) 13.61.1.134 / 10.0.1.136

├── k3s server

├── ingress-nginx controller

├── cert-manager

└── Argo CD

│

├── worker-1 (t3.micro) 16.171.232.44 / 10.0.1.126

│   ├── postgres-0

│   └── taskapp-backend replica

│

└── worker-2 (t3.micro) 51.20.69.158 / 10.0.1.227

├── taskapp-backend replica

└── taskapp-frontend replicas

## How a Request Flows

1. User opens https://josephigwe.duckdns.org
2. DNS resolves to control-plane public IP (13.61.1.134)
3. nginx ingress controller receives the request on port 443
4. TLS is terminated using Let's Encrypt certificate (managed by cert-manager)
5. Ingress routes / to frontend-service → taskapp-frontend pods (nginx serving React)
6. React app makes API calls to /api → ingress routes to backend service → taskapp-backend pods (Flask)
7. Flask backend connects to postgres-service → postgres-0 StatefulSet pod
8. Response flows back to user

## Single-Server Assumptions Fixed

| Core Requirement | Single-Server Problem Fixed |
|-----------------|---------------------------|
| 2+ backend replicas across nodes | Single server = single point of failure; one crash kills the app |
| 2+ frontend replicas across nodes | No redundancy; one bad deploy takes the site down |
| Postgres StatefulSet + PVC | Data lost if container restarts on a single server |
| Migration as Job | Race condition masked on single server; breaks at 2+ replicas |
| topologySpreadConstraints | Meaningless on single node; enforces true HA on multi-node |
| HPA | Single server can't scale horizontally |
| PodDisruptionBudget | No concept of draining on a single server |
| Ingress + TLS | Single server typically runs on plain HTTP with no load balancing |
| GitOps (Argo CD) | Manual deploys don't scale across a cluster |
| NetworkPolicy | No network isolation on a single server |
EOF
