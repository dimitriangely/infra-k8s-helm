# Glossaire – Kubernetes & Helm

Ce glossaire regroupe les principaux termes utilisés dans ce TP Kubernetes / Helm.  
Il a pour objectif de clarifier les concepts techniques afin de faciliter la compréhension, le débogage et la reproductibilité de l’infrastructure.

---

## Kubernetes (K8s)

### Kubernetes (K8s)
Plateforme d’orchestration de conteneurs permettant de déployer, gérer, mettre à l’échelle et superviser des applications conteneurisées de manière automatisée.

---

### Cluster
Ensemble de machines (nœuds) sur lesquelles Kubernetes fonctionne.  
Un cluster comprend au minimum un **control plane** et un ou plusieurs **worker nodes**.

---

### Node
Machine (physique ou virtuelle) faisant partie du cluster Kubernetes.  
Un node exécute les **pods** et fournit des ressources (CPU, mémoire, stockage).

---

### Pod
Plus petite unité déployable dans Kubernetes.  
Un pod contient un ou plusieurs conteneurs partageant le même réseau et le même stockage.

---

### Namespace
Mécanisme d’isolation logique permettant de séparer les ressources Kubernetes (ex : `dev`, `staging`, `prod`).  
Il aide à organiser et sécuriser le cluster.

---

### Deployment
Ressource Kubernetes utilisée pour gérer des applications **stateless**.  
Elle permet de définir le nombre de réplicas, les mises à jour progressives et les rollbacks.

---

### StatefulSet
Ressource Kubernetes utilisée pour les applications **stateful** (bases de données, queues).  
Elle garantit :
- un nom stable
- un stockage persistant
- un ordre de démarrage contrôlé

---

### Replica
Instance identique d’un pod.  
Les replicas permettent la haute disponibilité et la montée en charge.

---

### Service
Abstraction réseau exposant un ou plusieurs pods via une adresse IP stable et un port.  
Types courants :
- `ClusterIP`
- `NodePort`
- `LoadBalancer`

---

### Ingress
Ressource Kubernetes permettant d’exposer des services HTTP/HTTPS vers l’extérieur du cluster via des règles de routage (host, path).

---

### Ingress Controller
Composant chargé d’appliquer concrètement les règles Ingress (ex : NGINX Ingress Controller).  
Sans ingress controller, les ressources Ingress ne fonctionnent pas.

---

### TLS / HTTPS
Protocole de chiffrement utilisé pour sécuriser les communications réseau.  
Dans Kubernetes, TLS est souvent utilisé avec Ingress pour exposer des applications en HTTPS.

---

### Secret
Objet Kubernetes permettant de stocker des données sensibles (mots de passe, clés, certificats).  
Les secrets peuvent être montés dans les pods ou injectés en variables d’environnement.

---

### ConfigMap
Objet Kubernetes utilisé pour stocker des configurations non sensibles (fichiers, variables, paramètres).

---

### Service discovery Kubernetes
Dans Kubernetes, la découverte de services permet aux composants d'une application situés dans des conteneurs ou des pods distincts de communiquer sans connaître leurs adresses IP.

---

## Stockage

### Volume
Espace de stockage accessible par un pod.  
Les volumes peuvent être éphémères ou persistants.

---

### PersistentVolume (PV)
Ressource représentant un espace de stockage physique ou réseau dans le cluster.  
Le PV est indépendant du namespace.

---

### PersistentVolumeClaim (PVC)
Demande de stockage faite par une application.  
Le PVC est lié à un PV compatible et permet à l’application d’utiliser le stockage.

---

### StorageClass
Définit la manière dont le stockage est provisionné dynamiquement (type de disque, performances, reclaim policy).

---

### Reclaim Policy
Politique définissant ce qu’il advient du stockage après suppression du PVC :
- `Delete` : le volume est supprimé
- `Retain` : le volume est conservé

---

## Helm

### Helm
Gestionnaire de packages pour Kubernetes.  
Il permet d’installer, mettre à jour, versionner et supprimer des applications Kubernetes de manière standardisée.

---

### Chart Helm
Package Helm contenant :
- des templates Kubernetes
- des valeurs par défaut
- des métadonnées

Un chart représente une application ou un service.

---

### Release Helm
Instance installée d’un chart dans un cluster Kubernetes.  
Chaque release est versionnée et peut être mise à jour ou supprimée.

---

### values.yaml
Fichier de configuration permettant de personnaliser un chart Helm sans modifier ses templates.

---

### Template Helm
Fichier YAML paramétrable utilisant le moteur de templates Helm (Go templates).  
Il est rendu en manifest Kubernetes lors de l’installation.

---

### Upgrade Helm
Mise à jour d’une release existante avec de nouvelles valeurs ou une nouvelle version du chart.

---

### Rollback Helm
Retour à une version précédente d’une release Helm en cas de problème.

---

### Helm Repository
Dépôt distant contenant des charts Helm (ex : Bitnami).  
Les repositories permettent de partager et versionner des charts.

---

## Réseau et sécurité

### DNS interne Kubernetes
Système de résolution de noms interne permettant aux services de se joindre via des noms DNS (ex : `service.namespace.svc.cluster.local`).

---

### Port
Point d’accès réseau utilisé par un service ou un conteneur pour communiquer.

---

### Certificat X.509
Certificat utilisé pour l’authentification et le chiffrement TLS.  
Il contient l’identité du service, sa clé publique et sa période de validité.

---

### Clé privée
Élément cryptographique secret associé à un certificat TLS.  
Elle ne doit jamais être exposée publiquement.

---

## Débogage & exploitation

### kubectl
Outil en ligne de commande permettant d’interagir avec un cluster Kubernetes.

---

### kubectl describe
Commande affichant les détails complets d’une ressource Kubernetes, utile pour le débogage.

---

### Logs
Sorties générées par les applications ou les conteneurs.  
Ils permettent de diagnostiquer les erreurs et le comportement du système.

---

### Reproductibilité
Capacité à recréer une infrastructure à l’identique à partir de fichiers de configuration et de commandes.

---

### Infrastructure as Code (IaC)
Approche consistant à définir l’infrastructure via des fichiers versionnés plutôt que des actions manuelles.

---

### Stateless / Stateful
- **Stateless** : application sans état persistant (ex : API)
- **Stateful** : application nécessitant des données persistantes (ex : base de données)

---

## Concepts clés

### Cycle de vie applicatif
Ensemble des étapes de vie d’une application :
- déploiement
- mise à jour
- supervision
- suppression

---

### Industrialisation
Processus visant à rendre les déploiements fiables, reproductibles et automatisés, comme en environnement professionnel.

---

### GitOps
Méthode de gestion de l’infrastructure : https://www.redhat.com/fr/topics/devops/what-is-gitops.

---

## Conclusion

Ce glossaire accompagne le TP afin de faciliter la compréhension des concepts Kubernetes et Helm,  
et de fournir un vocabulaire commun pour la documentation, l’oral et l’évaluation.
