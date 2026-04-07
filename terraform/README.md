# Terraform – Experimentos de Tácticas de Arquitectura de Software

Este directorio contiene toda la infraestructura como código (IaC) gestionada con **Terraform** sobre **AWS**.

## Estructura

```
terraform/
├── providers.tf          # Configuración del provider AWS y backend remoto
├── variables.tf          # Variables globales compartidas
├── modules/              # Módulos reutilizables de AWS
│   ├── networking/       # VPC, subnets, route tables, security groups
│   ├── compute/          # EC2, Auto Scaling Groups, Launch Templates
│   └── database/         # RDS, ElastiCache
└── experiments/          # Un directorio por táctica de arquitectura
    ├── 01-availability/  # Táctica: Disponibilidad
    ├── 02-performance/   # Táctica: Rendimiento
    ├── 03-security/      # Táctica: Seguridad
    ├── 04-scalability/   # Táctica: Escalabilidad
    └── 05-modifiability/ # Táctica: Modificabilidad
```

## Módulos

| Módulo | Descripción |
|--------|-------------|
| `modules/networking` | VPC base, subnets públicas/privadas, Internet Gateway, NAT Gateway |
| `modules/compute` | EC2 instances, Launch Templates, Auto Scaling Groups |
| `modules/database` | RDS (PostgreSQL/MySQL), ElastiCache (Redis) |

## Experimentos

| Experimento | Táctica | Descripción |
|-------------|---------|-------------|
| `01-availability` | Disponibilidad | Multi-AZ, failover automático, health checks |
| `02-performance` | Rendimiento | ALB, ElastiCache (caché), CloudFront (CDN) |
| `03-security` | Seguridad | IAM roles/policies, KMS, WAF, Security Groups estrictos |
| `04-scalability` | Escalabilidad | Auto Scaling Groups, ECS Fargate con escalado horizontal |
| `05-modifiability` | Modificabilidad | Microservicios con ECS/Lambda, API Gateway |

## Cómo empezar

### Pre-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configurado con credenciales válidas
- Bucket S3 y tabla DynamoDB para el backend remoto (opcional para desarrollo local)

### Pasos

```bash
# 1. Navegar al experimento deseado
cd experiments/01-availability

# 2. Copiar el archivo de variables de ejemplo
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con los valores correspondientes

# 3. Inicializar Terraform
terraform init

# 4. Verificar el plan de ejecución
terraform plan

# 5. Aplicar los cambios
terraform apply

# 6. Al finalizar, destruir los recursos para evitar costos
terraform destroy
```

## Convenciones

- Cada experimento es **autónomo**: puede desplegarse y destruirse de forma independiente.
- Los módulos en `modules/` son **reutilizables** entre experimentos.
- Las variables sensibles **nunca** se versionan; usar `terraform.tfvars` (ignorado por `.gitignore`) o AWS Secrets Manager.
- Los recursos se etiquetan automáticamente con `Project`, `ManagedBy` y `Environment` via `default_tags`.
