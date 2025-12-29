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