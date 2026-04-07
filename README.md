# bite-consultoria

Repositorio de experimentos de **tácticas de arquitectura de software** implementados con **Infraestructura como Código (IaC)** usando [Terraform](https://www.terraform.io/) sobre **AWS**.

## Estructura del repositorio

```
bite-consultoria/
├── .gitignore            # Excluye artefactos de Terraform (.terraform/, *.tfstate, *.tfvars)
└── terraform/
    ├── README.md         # Guía completa de uso
    ├── providers.tf      # Provider AWS + configuración de backend remoto
    ├── variables.tf      # Variables globales compartidas
    ├── modules/          # Módulos reutilizables
    │   ├── networking/   # VPC, subnets, IGW, NAT Gateway
    │   ├── compute/      # EC2 Launch Template + Auto Scaling Group
    │   └── database/     # RDS (PostgreSQL) + ElastiCache (Redis)
    └── experiments/      # Un experimento por táctica de arquitectura
        ├── 01-availability/   # Disponibilidad: Multi-AZ, ALB, RDS Multi-AZ
        ├── 02-performance/    # Rendimiento: ALB, ElastiCache, CloudFront
        ├── 03-security/       # Seguridad: IAM, KMS, WAF, subnets privadas
        ├── 04-scalability/    # Escalabilidad: ASG + ECS Fargate auto-scaling
        └── 05-modifiability/  # Modificabilidad: microservicios ECS, Lambda, API Gateway
```

## Experimentos disponibles

| # | Táctica | Tecnologías AWS |
|---|---------|----------------|
| 01 | **Disponibilidad** | ALB health checks, ASG, RDS Multi-AZ |
| 02 | **Rendimiento** | ALB, ElastiCache Redis, CloudFront CDN |
| 03 | **Seguridad** | IAM least-privilege, KMS, WAF OWASP rules |
| 04 | **Escalabilidad** | EC2 ASG target tracking, ECS Fargate auto-scaling |
| 05 | **Modificabilidad** | ECS microservicios, Lambda, API Gateway, SSM feature flags |

## Inicio rápido

Consultar [`terraform/README.md`](terraform/README.md) para pre-requisitos y pasos detallados.

```bash
cd terraform/experiments/01-availability
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores
terraform init && terraform plan
```
