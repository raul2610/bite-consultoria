# Experimento 05 – Modificabilidad

## Objetivo

Demostrar tácticas de modificabilidad en AWS:

| Táctica | Implementación AWS |
|---|---|
| Descomposición en microservicios | ECS Fargate: `users-service` y `orders-service` independientes |
| Encapsulamiento detrás de interfaz | API Gateway HTTP API como única puerta de entrada |
| Despliegue independiente | Cada servicio tiene su propia task definition y puede actualizarse sin downtime |
| Lógica intercambiable sin infraestructura | AWS Lambda para procesamiento; reemplazable con nueva imagen |
| Feature flags | SSM Parameter Store para activar/desactivar funcionalidades en caliente |

## Arquitectura

```
Internet
   │
   ▼
[API Gateway HTTP API]
   │
   ├──► POST /process ──► [Lambda: processor]
   │
   └──► (extensible: agregar rutas a nuevos microservicios)

[ECS Fargate Cluster]
   ├── users-service  (task definition independiente)
   └── orders-service (task definition independiente)

[SSM Parameter Store]
   └── /<name>/<env>/feature/new_checkout  (feature flag)
```

## Cómo cambiar un microservicio sin afectar a los otros

1. Construir y subir la nueva imagen al ECR.
2. Actualizar solo la variable `users_service_image` o `orders_service_image` en `terraform.tfvars`.
3. Ejecutar `terraform apply` → solo la task definition del servicio afectado se actualiza.

## Uso

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply

# Activar feature flag en caliente (sin redeploy)
aws ssm put-parameter \
  --name "/bite/dev/feature/new_checkout" \
  --value "true" \
  --overwrite

terraform destroy   # al finalizar el experimento
```
