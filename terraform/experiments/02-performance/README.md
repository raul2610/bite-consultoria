# Experimento 02 – Rendimiento

## Objetivo

Demostrar tácticas de rendimiento en AWS:

| Táctica | Implementación AWS |
|---|---|
| Distribución de carga | Application Load Balancer (ALB) entre múltiples instancias |
| Caché en memoria | ElastiCache Redis (reduce latencia de BD, aumenta throughput) |
| CDN / caché de borde | CloudFront delante del ALB (reduce latencia global) |
| Escalado horizontal reactivo | ASG con política de escalado por CPU |

## Arquitectura

```
Internet
   │
   ▼
[CloudFront CDN]
   │
   ▼
[ALB] ─── public subnets
   │
   ├──► [EC2 ASG] ── private subnet AZ-a ──► [ElastiCache Redis]
   │
   └──► [EC2 ASG] ── private subnet AZ-b
```

## Uso

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
terraform destroy   # al finalizar el experimento
```
