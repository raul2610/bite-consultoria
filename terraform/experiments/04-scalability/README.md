# Experimento 04 – Escalabilidad

## Objetivo

Demostrar tácticas de escalabilidad en AWS:

| Táctica | Implementación AWS |
|---|---|
| Escalado horizontal de VMs | EC2 ASG con Target Tracking (CPU al 50 %) |
| Escalado horizontal de contenedores | ECS Fargate + Application Auto Scaling |
| Punto de entrada elástico | ALB distribuyendo entre instancias EC2 y tareas ECS |
| Observabilidad del escalado | CloudWatch Container Insights en el clúster ECS |

## Arquitectura

```
Internet
   │
   ▼
[ALB]
   │
   ├──► [EC2 ASG]          (min=1, max=10, target CPU 50 %)
   │         ▲ scale out/in
   │    CloudWatch Alarm
   │
   └──► [ECS Fargate]       (min=1, max=10, target CPU 50 %)
              ▲ scale out/in
         App Auto Scaling
```

## Uso

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply

# Simular carga para observar el escalado
# e.g. ab -n 10000 -c 100 http://<alb_dns_name>/

terraform destroy   # al finalizar el experimento
```
