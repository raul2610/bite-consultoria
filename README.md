# Bite.Co — Consultoría de Arquitectura de Software

**Pandilla de Duendes · Sección 3 · Arquitectura y Diseño de Software**

Repositorio de experimentos y decisiones arquitectónicas para el proyecto de consultoría a Bite.Co. Cada experimento evalúa una táctica de calidad sobre infraestructura real en AWS usando Terraform.

---

## Equipo

| Nombre | GitHub |
|---|---|
| Nelson Felipe Celis | — |
| Juan Felipe Hortúa | — |
| Juan Manuel Rojas | — |
| Julián Restrepo | — |
| Raúl Ruiz | [@raul2610](https://github.com/raul2610) |

---

## Estructura del repositorio

```
bite-consultoria/
└── terraform/
    ├── experiments/
    │   ├── 01-availability/       # Táctica: Disponibilidad
    │   ├── 02-performance/        # Táctica: Rendimiento
    │   ├── 03-security/           # Táctica: Seguridad
    │   ├── 04-scalability/        # Táctica: Escalabilidad
    │   └── 05-modifiability/      # Táctica: Modificabilidad
    └── modules/
        ├── compute/               # Módulo reutilizable: cómputo (EC2, ECS, Lambda)
        ├── database/              # Módulo reutilizable: base de datos (RDS, DynamoDB)
        └── networking/            # Módulo reutilizable: red (VPC, subnets, SGs)
```

---

## Cómo usar un experimento

```bash
cd terraform/experiments/<nombre-experimento>

# Copiar y configurar variables
cp terraform.tfvars.example terraform.tfvars

# Inicializar y aplicar
terraform init
terraform plan
terraform apply
```

> Recuerde destruir los recursos al terminar para evitar costos innecesarios:
> ```bash
> terraform destroy
> ```