# DevOps Final Project – AWS EKS + RDS + Jenkins + Argo CD + Monitoring

Цей проєкт розгортає повну DevOps-інфраструктуру в AWS за допомогою Terraform.  
Інфраструктура призначена для деплою Django-застосунку в Kubernetes з повним CI/CD циклом та моніторингом.

## Компоненти інфраструктури

Проєкт реалізує такі елементи:

- **S3 + DynamoDB backend** для Terraform стейту  
  – модуль `modules/s3-backend`
- **VPC** з публічними й приватними підмережами  
  – модуль `modules/vpc`
- **ECR** для зберігання Docker-образів  
  – модуль `modules/ecr`
- **EKS кластер**  
  – модуль `modules/eks`
- **RDS PostgreSQL / Aurora** (універсальний модуль з перемикачем `use_aurora`)  
  – модуль `modules/rds`
- **Jenkins** (CI) через Helm  
  – модуль `modules/jenkins`
- **Argo CD** (CD) через Helm  
  – модуль `modules/argo_cd`
- **Monitoring: Prometheus + Grafana** через Helm (`kube-prometheus-stack`)  
  – модуль `modules/monitoring`
- **Helm-чарт застосунку**  
  – `charts/django-app` (Deployment, Service, ConfigMap, HPA)

> ⚠️ Примітка: у моєму середовищі AWS акаунт був заблокований на етапі верифікації, тому команда `terraform apply` **не запускалась**.  
> Конфігурація перевірена локально командами `terraform init -backend=false` та `terraform validate` (успішно).

---

## Структура проєкту (скорочено)

```text
Project/
  main.tf
  backend.tf
  outputs.tf
  variables.tf
  modules/
    s3-backend/
    vpc/
    ecr/
    eks/
    rds/
    jenkins/
    argo_cd/
    monitoring/
  charts/
    django-app/
      Chart.yaml
      values.yaml
      templates/
        deployment.yaml
        service.yaml
        configmap.yaml
        hpa.yaml
  # (опціонально) Django/
  #   app/
  #   Dockerfile
  #   Jenkinsfile
  #   docker-compose.yml

Попередні вимоги

Зареєстрований та активований AWS акаунт

Налаштовані AWS credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, профіль або IAM роль)

Встановлені:

Terraform (>= 1.6.0)

kubectl

helm

Локальний kubeconfig має бути налаштований після створення EKS (Terraform виводить дані для підключення)

Змінні верхнього рівня (root)

Основні змінні (оголошені в variables.tf):

aws_region – регіон AWS (наприклад, eu-north-1)

bucket_name – імʼя S3 бакету для бекенду Terraform

table_name – імʼя DynamoDB таблиці для бекенду

create_backend_resources – чи створювати S3/DynamoDB через модуль

vpc_cidr_block – CIDR VPC

public_subnets / private_subnets – списки CIDR для підмереж

availability_zones – список AZ

ecr_name – імʼя репозиторію в ECR

project_name – префікс для ресурсів EKS

db_password – пароль користувача БД (sensitive)

Розгортання інфраструктури (стандартний сценарій)

Ці кроки розраховані на менторів / середовище з робочим AWS акаунтом.

Ініціалізувати Terraform:

terraform init


Переглянути план (опціонально):

terraform plan


Розгорнути інфраструктуру:

terraform apply


Після завершення Terraform створює:

VPC, сабнети, Internet Gateway, маршрути

ECR репозиторій

EKS кластер

RDS інстанс (або Aurora, залежно від use_aurora)

Jenkins (namespace jenkins)

Argo CD (namespace argocd)

Monitoring (Prometheus + Grafana) в namespace monitoring

Helm-чарт django-app може бути підхоплений Argo CD як application

Перевірка стану ресурсів у Kubernetes
kubectl get ns
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring

Доступ до сервісів через port-forward
Jenkins
kubectl port-forward svc/jenkins 8080:8080 -n jenkins


Після цього Jenkins доступний за адресою:

http://localhost:8080

Argo CD
kubectl port-forward svc/argocd-server 8081:443 -n argocd


Argo CD доступний за адресою:

https://localhost:8081

(можливо, знадобиться прийняти self-signed сертифікат у браузері)

Grafana (Monitoring)
kubectl port-forward svc/grafana 3000:80 -n monitoring


Grafana доступна за адресою:

http://localhost:3000

Стандартні креденшели зазвичай admin / prom-operator або ті, що задані в values-чарті (залежить від конфігурації kube-prometheus-stack).

Локальна перевірка конфігурації без AWS

Якщо немає можливості повноцінно підключитися до AWS (або для швидкої перевірки синтаксису):

terraform init -backend=false
terraform fmt
terraform validate


terraform validate підтверджує, що конфігурація коректна з точки зору Terraform.

Цей підхід було використано для тестування конфігурації в моєму середовищі.

Видалення ресурсів (cleanup)

Щоб уникнути зайвих витрат у хмарі, після перевірки інфраструктуру потрібно видалити:

terraform destroy


⚠️ Увага: terraform destroy також видалить S3 бакет і DynamoDB таблицю, які використовуються як бекенд Terraform. Якщо бекенд створювався вручну – переконайтеся, що конфігурація відповідає вашій політиці зберігання стейтів.

Нотатки

Модуль modules/rds реалізує перемикач use_aurora:

false → створюється звичайна aws_db_instance (PostgreSQL);

true → створюється aws_rds_cluster + aws_rds_cluster_instance (Aurora PostgreSQL).

Модулі jenkins, argo_cd та monitoring використовують EKS-кластер через Kubernetes + Helm провайдери Terraform.

Helm-чарт charts/django-app може бути підʼєднаний до Argo CD як GitOps application для автоматичного деплою Django-застосунку в EKS.

Цей README описує повний життєвий цикл інфраструктури: від розгортання до моніторингу та видалення ресурсів.