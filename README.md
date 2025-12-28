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

## 🏗️ Build des images Docker

Les images doivent être buildées **avant le déploiement** et poussées dans un registre accessible par le cluster.

### Exemple générique
```bash
docker build -t <registry>/webmvc:1.0.0 ./webmvc
docker build -t <registry>/jobs-api:1.0.0 ./jobs-api
docker build -t <registry>/applicants-api:1.0.0 ./applicants-api
docker build -t <registry>/identity-api:1.0.0 ./identity-api

Puis push :

docker push <registry>/webmvc:1.0.0
docker push <registry>/jobs-api:1.0.0
docker push <registry>/applicants-api:1.0.0
docker push <registry>/identity-api:1.0.0


⚠️ Adapter le registry dans le fichier values.yaml.

🚀 Déploiement sur un cluster Kubernetes vierge
1️⃣ Créer le namespace
kubectl create namespace tp-prod

2️⃣ Déployer l’infrastructure
helm upgrade --install tp-appscore-infra ./04-helm-chart/tp-appscore \
  -n tp-prod \
  --set infra.enabled=true \
  --set apps.enabled=false


Infrastructure déployée :

SQL Server

RabbitMQ

Redis

Secrets associés

3️⃣ Déployer les applications
helm upgrade --install tp-appscore-apps ./04-helm-chart/tp-appscore \
  -n tp-prod \
  --set infra.enabled=false \
  --set apps.enabled=true


Applications déployées :

webmvc

jobs-api

applicants-api

identity-api

HPA webmvc

Ingress

🌍 Accès aux applications
🔹 Ingress principal

URL : https://tp.local

Service : webmvc

Ports : 80 / 443

Classe ingress : nginx

⚠️ Certificat auto-signé : accepter l’exception TLS dans le navigateur.

🔹 Services internes (cluster)
Service	Type	Port
webmvc	ClusterIP	80
jobs-api	ClusterIP	80
applicants-api	ClusterIP	80
identity-api	ClusterIP	80
rabbitmq	ClusterIP	5672 / 15672
sql-data	ClusterIP	1433
user-data (redis)	ClusterIP	6379
🔍 Vérification de l’état du cluster
📌 État général
kubectl get nodes
kubectl get pods -n tp-prod
kubectl get svc -n tp-prod
kubectl get ingress -n tp-prod

📊 Vérifier les métriques
kubectl top nodes
kubectl top pods -n tp-prod

🔄 Vérifier le HPA
kubectl get hpa -n tp-prod
kubectl describe hpa webmvc-hpa -n tp-prod

🧠 Logs applicatifs
kubectl logs -n tp-prod deploy/webmvc
kubectl logs -n tp-prod deploy/jobs-api

📈 Observabilité graphique
Grafana
kubectl -n monitoring get svc monitoring-grafana


Dashboards : cluster, pods, CPU, mémoire, HPA

Kibana

Accès via le service Kibana

Data views basés sur les index Fluent Bit

Analyse des logs par service (webmvc, jobs-api, etc.)

🧪 Test de montée en charge (HPA)
Depuis le cluster
kubectl -n tp-prod run loadtest \
  --image=curlimages/curl:8.5.0 -it --rm -- sh


Puis :

for i in $(seq 1 500); do
  curl -s http://webmvc.tp-prod.svc.cluster.local > /dev/null
done


Observer le scaling :

kubectl get hpa -n tp-prod -w
kubectl get pods -n tp-prod -l app=webmvc -w

✅ Bonnes pratiques mises en œuvre

Séparation infra / apps

Ownership Helm propre

Autoscaling basé sur les métriques CPU

Requests / limits définis

Observabilité complète (metrics + logs)

Déploiements indépendants et rollback possibles

📌 Objectif du projet

Ce projet illustre une architecture Kubernetes proche des standards de production, destinée à :

démontrer la maîtrise du déploiement microservices

illustrer la scalabilité et l’observabilité

simuler un environnement DevOps réel

flowchart TB
  %% ====== EXTERNE ======
  U[Utilisateur / Navigateur] -->|HTTPS :443| DNS[DNS / Hosts\n(tp.local)]
  DNS -->|HTTPS :443| INGRESS[Ingress NGINX\n(webmvc-ingress)]

  %% ====== CLUSTER ======
  subgraph K8s[Cluster Kubernetes]
    direction TB

    %% Namespace
    subgraph NS[Namespace : tp-prod]
      direction TB

      %% Ingress -> Service Web
      INGRESS -->|HTTP :80| SVC_WEB[Service ClusterIP\nwebmvc:80]
      SVC_WEB --> WEB[Deployment webmvc\n(2+ replicas, HPA)]

      %% Web -> APIs
      WEB -->|HTTP :80| SVC_JOBS[Service ClusterIP\njobs-api:80]
      WEB -->|HTTP :80| SVC_APPS[Service ClusterIP\napplicants-api:80]
      WEB -->|HTTP :80| SVC_ID[Service ClusterIP\nidentity-api:80]

      SVC_JOBS --> JOBS[Deployment jobs-api]
      SVC_APPS --> APPS[Deployment applicants-api]
      SVC_ID --> ID[Deployment identity-api]

      %% APIs -> infra dependencies
      JOBS -->|TCP :1433| SQLSVC[Service ClusterIP\nsql-data:1433]
      APPS -->|TCP :1433| SQLSVC
      ID -->|TCP :1433| SQLSVC

      JOBS -->|TCP :5672| MQSVC[Service ClusterIP\nrabbitmq:5672]
      APPS -->|TCP :5672| MQSVC
      ID -->|TCP :5672| MQSVC

      JOBS -->|TCP :6379| REDISSVC[Service ClusterIP\nuser-data(redis):6379]
      APPS -->|TCP :6379| REDISSVC
      ID -->|TCP :6379| REDISSVC

      %% Stateful backends
      SQLSVC --> SQL[(StatefulSet sql-data)]
      MQSVC --> MQ[(Deployment/Stateful RabbitMQ)]
      REDISSVC --> REDIS[(Deployment Redis)]

      %% HPA / Metrics
      HPA[HPA webmvc] --> WEB
      MS[metrics-server] --> HPA

    end
  end

  %% ====== OBSERVABILITE / LOGGING (optionnel selon ton setup) ======
  subgraph Obs[Observabilité / Logging]
    direction TB
    PROM[Prometheus] --> GRAF[Grafana]
    FB[Fluent Bit DaemonSet] --> ES[Elasticsearch]
    ES --> KIB[Kibana]
  end

  %% logs flux
  WEB -. stdout/stderr logs .-> FB
  JOBS -. logs .-> FB
  APPS -. logs .-> FB
  ID -. logs .-> FB

  %% metrics flux
  MS -. metrics .-> PROM
  PROM -. dashboards .-> GRAF

2) Lecture rapide du schéma (ce que ça raconte)
Flux externe

Utilisateur → https://tp.local → Ingress NGINX → Service webmvc → Pods webmvc

Flux interne (service discovery Kubernetes)

webmvc appelle les APIs via les Services Kubernetes :

jobs-api.tp-prod.svc.cluster.local:80

applicants-api.tp-prod.svc.cluster.local:80

identity-api.tp-prod.svc.cluster.local:80

Dépendances infra (toujours internes)

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
