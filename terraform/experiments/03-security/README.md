# Experimento 03 – Seguridad

## Objetivo

Demostrar tácticas de seguridad en AWS:

| Táctica | Implementación AWS |
|---|---|
| Mínimo privilegio | IAM Role para EC2 con política específica (solo KMS + SSM) |
| Cifrado en reposo | KMS CMK para RDS y cualquier dato almacenado |
| Protección de capa 7 | AWS WAF con reglas OWASP (Common + SQLi) asociado al ALB |
| Transporte seguro | HTTP → HTTPS redirect en ALB, TLS en tránsito a ElastiCache |
| Aislamiento de red | Recursos en subnets privadas; ALB en subnet pública |

## Arquitectura

```
Internet
   │
   ▼
[WAF Web ACL]
   │
   ▼
[ALB] ─── public subnets (HTTP→HTTPS redirect)
   │
   ▼
[EC2 ASG + IAM Role] ── private subnets
   │
   ├──► [RDS (KMS encrypted, Multi-AZ)]
   │
   └──► [SSM Parameter Store] (secrets)
```

## Uso

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
terraform destroy   # al finalizar el experimento
```
