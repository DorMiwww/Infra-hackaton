# Infrastructure Hackathon — Plan

## 1. Мета

Розгорнути K8s кластер на публічному cloud-провайдері з двома середовищами (**Staging** та **Production**) у окремих namespaces, використовуючи Terraform (IaC).

---

## 2. Архітектура (високий рівень)

```
Cloud Provider (GCP / AWS / Azure)
  └── Kubernetes Cluster (1 кластер)
        ├── namespace: staging
        │     └── додаток (Deployment, Service, Ingress)
        └── namespace: production
              └── додаток (Deployment, Service, Ingress)
```

---

## 3. Розподіл завдань по команді

| # | Завдання | Відповідальний | Залежності |
|---|----------|---------------|------------|
| 1 | Створити cloud-акаунт, налаштувати billing та IAM | DevOps Lead | — |
| 2 | Написати Terraform-код: VPC/Network, K8s кластер | Infra Engineer | #1 |
| 3 | Написати Terraform-код: namespaces (staging, production) | Infra Engineer | #2 |
| 4 | Підготувати K8s маніфести (Deployment, Service, Ingress) | K8s Engineer | — |
| 5 | Налаштувати CI/CD pipeline (GitHub Actions / GitLab CI) | CI/CD Engineer | #2 |
| 6 | Тестування: деплой в staging, перевірка, деплой в production | QA / вся команда | #3, #4, #5 |
| 7 | Документація + cleanup інфраструктури (`terraform destroy`) | Вся команда | #6 |

---

## 4. Етапи виконання

### Етап 1 — Підготовка (30 хв)
- Створити акаунт у обраному cloud-провайдері (GCP рекомендовано — є готовий Terraform-код)
- Активувати безкоштовні кредити (GCP: $300 free trial)
- Встановити CLI інструменти: `gcloud` / `aws` / `az`, `terraform`, `kubectl`
- Налаштувати автентифікацію (`gcloud auth login`, service account)

### Етап 2 — Terraform: інфраструктура (1-2 год)
- Створити структуру проєкту:
  ```
  terraform/
    ├── main.tf          # provider, backend
    ├── variables.tf     # змінні
    ├── outputs.tf       # виходи (cluster endpoint, kubeconfig)
    ├── vpc.tf           # мережа
    ├── gke.tf           # K8s кластер (GKE / EKS / AKS)
    └── namespaces.tf    # staging & production namespaces
  ```
- Ресурси для створення:
  - VPC + Subnets
  - GKE кластер (або EKS/AKS) з мінімальним node pool (e2-medium, 2 ноди)
  - Kubernetes namespaces: `staging`, `production`

### Етап 3 — Kubernetes маніфести (1 год)
- Створити директорії `k8s/staging/` та `k8s/production/`
- Deployment, Service (ClusterIP / LoadBalancer), Ingress для кожного середовища
- Використати kustomize або Helm для параметризації між середовищами

### Етап 4 — CI/CD (опціонально, 1 год)
- GitHub Actions workflow: build -> deploy staging -> deploy production
- Використовувати окремі steps для кожного середовища

### Етап 5 — Cleanup
- `terraform destroy` — видалити всю інфраструктуру
- Перевірити що в cloud console не залишилось ресурсів

---

## 5. Способи реалізації та платформи

### Cloud-провайдер (обрати один)

| Провайдер | K8s сервіс | Безкоштовно | Складність |
|-----------|-----------|-------------|------------|
| **GCP** (рекомендовано) | GKE | $300 кредит на 90 днів | Низька |
| AWS | EKS | Free tier (обмежений) | Середня |
| Azure | AKS | $200 кредит на 30 днів | Середня |

### Інструменти

| Інструмент | Призначення | Версія |
|-----------|-------------|--------|
| Terraform | IaC, створення cloud-ресурсів | >= 1.5 |
| kubectl | Управління K8s кластером | >= 1.28 |
| Helm / Kustomize | Шаблонізація K8s маніфестів | Helm 3 / Kustomize v5 |
| gcloud CLI | Взаємодія з GCP | latest |

---

## 6. Best Practices

### Terraform
- Використовувати **remote backend** (GCS bucket) для зберігання state
- Розділяти код по файлах (`vpc.tf`, `gke.tf`, `namespaces.tf`)
- Використовувати `terraform.tfvars` для змінних середовища
- Додати `.gitignore` для `*.tfstate`, `.terraform/`
- Використовувати `terraform plan` перед `terraform apply`
- Мінімальні IAM permissions (principle of least privilege)

### Kubernetes
- Окремі namespaces для staging/production — ізоляція ресурсів
- ResourceQuota та LimitRange на кожен namespace
- Network Policies для обмеження трафіку між namespaces
- Labels та annotations для всіх ресурсів
- Liveness/Readiness probes для кожного Deployment

### Безпека
- Не зберігати credentials в коді — використовувати Secret Manager або Sealed Secrets
- RBAC: окремі ServiceAccount для кожного середовища
- Приватний кластер (private GKE cluster) якщо можливо
- Увімкнути Workload Identity (GKE)

### CI/CD
- GitOps підхід: зміни через PR -> merge -> auto-deploy
- Staging деплоїться автоматично, Production — через manual approval
- Використовувати окремі service accounts для CI/CD

---

## 7. Корисні ресурси та документація

### Terraform
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform GKE Module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

### Kubernetes
- [Kubernetes Docs — Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Kubernetes Best Practices (Google)](https://cloud.google.com/blog/products/containers-kubernetes/your-guide-kubernetes-best-practices)
- [Kustomize](https://kustomize.io/)
- [Helm](https://helm.sh/docs/)

### GCP / GKE
- [GKE Quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart)
- [GCP Free Tier](https://cloud.google.com/free)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)

### CI/CD
- [GitHub Actions + GKE](https://docs.github.com/en/actions/use-cases-and-examples/deploying/deploying-to-google-kubernetes-engine)
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)

---

## 8. Мінімальний Terraform приклад (GCP/GKE)

```hcl
# main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name     = "hackathon-cluster"
  location = var.region

  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "kubernetes_namespace" "staging" {
  metadata { name = "staging" }
  depends_on = [google_container_cluster.primary]
}

resource "kubernetes_namespace" "production" {
  metadata { name = "production" }
  depends_on = [google_container_cluster.primary]
}
```

---

> **Нагадування:** Після завершення роботи обов'язково виконати `terraform destroy` та перевірити cloud console.
