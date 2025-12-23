# Analyse docker-compose (source officielle)

Fichier: 01-compose-analysis/compose-source/docker-compose.yml

## 1) Liste des services
- user.data (redis)
- rabbitmq (rabbitmq:3-management)
- webmvc (web)
- applicants.api
- jobs.api
- identity.api
- sql.data (mssql-linux)

## 2) Ports exposés (compose -> externe)
- user.data: 6379 -> 6379
- rabbitmq: 15672 -> 15672 (UI), 5672 -> 5672 (AMQP)
- webmvc: 8080 -> 80
- applicants.api: 8081 -> 80
- jobs.api: 8083 -> 80
- identity.api: 8084 -> 80
- sql.data: 1433 -> 1433

## 3) Dépendances (depends_on)
- webmvc dépend de: applicants.api, identity.api, jobs.api
- applicants.api dépend de: sql.data, rabbitmq
- jobs.api dépend de: sql.data, rabbitmq
- identity.api dépend de: user.data, rabbitmq

## 4) Variables d'environnement (à reproduire en ConfigMap/Secret)
### applicants.api
- ConnectionString=Server=sql.data;User=sa;Password=Pass@word;Database=dotnetgigs.applicants;
- HostRabbitmq=rabbitmq

### jobs.api
- ConnectionString=Server=sql.data;User=sa;Password=Pass@word;Database=dotnetgigs.jobs;
- HostRabbitmq=rabbitmq

### identity.api
- RedisHost=user.data:6379
- HostRabbitmq=rabbitmq

## 5) Implications Kubernetes (traduction)
- Les noms utilisés (sql.data, rabbitmq, user.data) deviendront des DNS de Services Kubernetes.
- Les APIs n'ont pas besoin d'être exposées publiquement : Services internes (ClusterIP).
- Seule l'app web (webmvc) doit être exposée via Ingress (HTTPS).
- Le mot de passe SQL (Pass@word) doit aller dans un Secret (pas en clair).
- Redis + MSSQL + RabbitMQ : idéalement avec stockage persistant (PVC) en prod-like.

## 6) Schéma des communications (simplifié)

Internet (HTTPS)
   |
   v
[ Ingress ] -> [ webmvc ]
                | \
                |  \
                v   v
        [ applicants.api ]   [ jobs.api ]
                \             /
                 \           /
                  v         v
                   [ sql.data ]
                
[ identity.api ] -> [ user.data (redis) ]

Tous (web + APIs) utilisent aussi:
- rabbitmq (AMQP 5672)
- UI RabbitMQ (15672) uniquement si besoin admin


## 7) Décisions Kubernetes (choix projet)

Namespace:
- tp-prod

Exposition externe:
- webmvc: OUI (Ingress HTTPS)
- applicants.api: NON (interne)
- jobs.api: NON (interne)
- identity.api: NON (interne)
- rabbitmq UI (15672): NON par défaut (optionnel via port-forward)
- sql.data / redis: NON (interne)

Type de workload:
- webmvc / applicants.api / jobs.api / identity.api: Deployment
- rabbitmq: Deployment (ou StatefulSet si persistance)
- user.data (redis): Deployment (ou StatefulSet si persistance)
- sql.data (mssql): StatefulSet + PVC (recommandé)

Secrets:
- SQL SA password: Secret Kubernetes
