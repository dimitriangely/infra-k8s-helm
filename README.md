@"
# TP Kubernetes - Microservices

## Structure
- src/ : code fourni (repo du cours)
- 01-compose-analysis/ : analyse docker-compose (liens, env vars, ports)
- 02-images/ : build/push des images
- 03-k8s-manifests/ : manifests Kubernetes (YAML)
- 04-helm-chart/ : chart Helm final
- 05-tests/ : tests de charge + preuves HPA
- docs/ : captures + bilan

## Avancement
- [x] Étape 0 : structure projet
- [ ] Étape 1 : analyse docker-compose
"@ | Set-Content -Encoding UTF8 .\README.md
