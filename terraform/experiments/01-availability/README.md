# Experimento 01 – Disponibilidad

## Objetivo

Demostrar tácticas de disponibilidad en AWS:

| Táctica | Implementación AWS |
|---|---|
| Redundancia activa | Auto Scaling Group con mínimo 2 instancias en 2 AZs distintas |
| Failover automático | ALB health checks + reemplazo automático de instancias no saludables |
| Replicación de datos | RDS Multi-AZ con réplica síncrona y failover automático |
| Detección de fallos | ELB health checks cada 30 s, umbral de 3 fallos consecutivos |

## Arquitectura

```
Internet
   │
   ▼
[ALB] ─── public subnets (AZ-a, AZ-b)
   │
   ├──► [EC2 ASG] ── private subnet AZ-a
   │
   └──► [EC2 ASG] ── private subnet AZ-b
              │
              ▼
         [RDS Multi-AZ]  (primary AZ-a, standby AZ-b)
```

## Uso

```bash
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars

terraform init
terraform plan
terraform apply
terraform destroy   # al finalizar el experimento
```
