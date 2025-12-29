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