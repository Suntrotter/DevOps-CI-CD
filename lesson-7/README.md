# 📌 Lesson 7 — AWS EKS + ECR + Helm (Django App)

Це домашнє завдання демонструє повний цикл деплойменту застосунку у Kubernetes-кластер AWS EKS із використанням Terraform, Amazon ECR, Helm-чартів та горизонтального автоскейлінгу (HPA).

---

# 🧱 Структура проєкту

```
lesson-7/
│
├── main.tf
├── backend.tf
├── outputs.tf
│
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   └── eks/
│
├── app/                     
│   └── Dockerfile
│
└── charts/
    └── django-app/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            └── hpa.yaml
```

---

# 🚀 1. Створення Kubernetes-кластера (Terraform)

Перейдіть у корінь проєкту:

```bash
cd lesson-7
terraform init
terraform apply
```

Terraform створює:

* S3 + DynamoDB для бекенду стейтів
* VPC (якщо потрібно)
* ECR репозиторій
* EKS кластер + node group

Після створення кластеру — підключіть kubectl:

```bash
aws eks update-kubeconfig \
  --region eu-north-1 \
  --name lesson-7-django-cluster
```

Перевірте:

```bash
kubectl get nodes
```

---

# 🐳 2. Створення Docker-образу та пуш до ECR

Отримати AWS Account ID:

```bash
aws sts get-caller-identity
```

Логін у ECR:

```bash
aws ecr get-login-password --region eu-north-1 \
  | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-north-1.amazonaws.com
```

Перейти в робочу директорію:

```bash
cd app
```

Зібрати Docker-образ:

```bash
docker build -t lesson-7-django .
```

Тегування:

```bash
docker tag lesson-7-django:latest <account-id>.dkr.ecr.eu-north-1.amazonaws.com/lesson-7-django-ecr:latest
```

Пуш у ECR:

```bash
docker push <account-id>.dkr.ecr.eu-north-1.amazonaws.com/lesson-7-django-ecr:latest
```

---

# ⛵ 3. Деплоймент застосунку через Helm

Перейдіть в папку Helm-чарта:

```bash
cd charts/django-app
```

Встановлення або оновлення:

```bash
helm upgrade --install django-app . --namespace default
```

Переконатися, що поди працюють:

```bash
kubectl get pods -n default
```

---

# 🌐 4. Service типу LoadBalancer

Перевірити IP:

```bash
kubectl get svc django-app -n default
```

Відкрити EXTERNAL-IP у браузері — застосунок доступний публічно.

---

# 🧩 5. ConfigMap

ConfigMap зберігає параметри середовища та підключається через:

```yaml
envFrom:
  - configMapRef:
      name: {{ include "django-app.fullname" . }}-config
```

Перевірка:

```bash
kubectl describe configmap django-app-config -n default
```

---

# 📈 6. Horizontal Pod Autoscaler (HPA)

У Helm-чарті реалізований HPA:

* minReplicas: **2**
* maxReplicas: **6**
* targetCPU: **70%**

Перевірка:

```bash
kubectl get hpa -n default
kubectl describe hpa django-app -n default
```

---

# 📘 Бонус: Ingress + TLS (опціонально)

Додайте до `values.yaml`:

```yaml
ingress:
  enabled: true
  className: nginx
  host: yourdomain.com
  tls: true
```

Потім додати cert-manager (опціонально):

```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
```

---

# ✅ Результат виконання

* Kubernetes-кластер створений Terraform'ом
* ECR містить Docker-образ
* Helm-чарт розгортає Deployment, Service, ConfigMap, HPA
* Працюючий LoadBalancer дає публічний доступ
* Кластер успішно обслуговує застосунок
* HPA масштабує поди за навантаженням

---


