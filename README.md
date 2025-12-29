# TP AppScore – Plateforme Microservices Kubernetes

Ce projet met en place une plateforme microservices déployée sur Kubernetes, avec une séparation claire entre **infrastructure** et **applications**, incluant autoscaling, ingress HTTPS et observabilité.

---

## 🧱 Architecture générale

- **Infrastructure (release Helm `tp-appscore-infra`)**
  - Base de données SQL Server
  - RabbitMQ
  - Redis
- **Applications (release Helm `tp-appscore-apps`)**
  - `webmvc` (frontend)
  - `jobs-api`
  - `applicants-api`
  - `identity-api`
- **Scalabilité**
  - Horizontal Pod Autoscaler (HPA) sur `webmvc`
- **Exposition**
  - Ingress NGINX avec HTTPS (certificat auto-signé)
- **Observabilité**
  - Metrics Server
  - Prometheus / Grafana
  - Fluent Bit → Elasticsearch → Kibana

---

## 📦 Prérequis

- Docker
- Kubernetes (Docker Desktop, kind, k3s, AKS, etc.)
- kubectl
- Helm v3+
- (Optionnel) PowerShell / Bash

---

📌 Objectif du projet

Ce projet illustre une architecture Kubernetes proche des standards de production, destinée à :

démontrer la maîtrise du déploiement microservices

illustrer la scalabilité et l’observabilité

simuler un environnement DevOps réel

2) Explication simple 

Flux externe

Utilisateur → https://tp.local → Ingress NGINX → Service webmvc → Pods webmvc

Flux interne (service discovery Kubernetes)

webmvc appelle les APIs via les Services Kubernetes :

jobs-api.tp-prod.svc.cluster.local:80

applicants-api.tp-prod.svc.cluster.local:80

identity-api.tp-prod.svc.cluster.local:80

Dépendances infra (Toujours Flux internes)

Les APIs consomment :

SQL Server via sql-data:1433

RabbitMQ via rabbitmq:5672

Redis via user-data:6379

Observabilité

HPA se base sur metrics-server (CPU % des requests)

Fluent Bit collecte les logs des pods et envoie vers Elasticsearch, visualisable dans Kibana

Prometheus/Grafana pour métriques/dashboards 

[User Browser]
     |
     | HTTPS 443  (tp.local)
     v
[Ingress NGINX]  -----> (Cluster network)
     |
     | HTTP 80
     v
[Service webmvc] ---> [Pods webmvc] ---HTTP---> [Service jobs-api] ---> [Pods jobs-api]
                        |                         [Service applicants-api] -> [Pods applicants-api]
                        |                         [Service identity-api]    -> [Pods identity-api]
                        |
                        +---- TCP 1433 ----> [Service sql-data] ---> [SQL Server (StatefulSet)]
                        +---- TCP 5672 ----> [Service rabbitmq] ---> [RabbitMQ]
                        +---- TCP 6379 ----> [Service user-data] ---> [Redis]

[metrics-server] -> HPA(webmvc) -> scale replicas
[Fluent Bit DS] -> Elasticsearch -> Kibana  (logs)
[Prometheus] -> Grafana          (metrics)
