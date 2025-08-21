*IMPORTANTE*

**ESTA TASK SOLO FUNCIONA CON CUENTAS 'Pay-As-You-Go'**

# ACR Tasks: Eliminación programada de repositorios en Azure Container Registry

Este Terraform despliega una Azure Container Registry Task (ACR Task) que, de forma programada (cron en UTC), lista todos los repositorios de un ACR y los elimina. Se apoya en el módulo `modules/acr-task-delete-repos` incluido en este mismo repositorio.

> ADVERTENCIA: Esta tarea es DESTRUCTIVA. Borra todos los repositorios del ACR de destino. Úsala solo en registros destinados a pruebas/limpieza o cuando este comportamiento sea deseado.

## ¿Qué crea?
- Un recurso `azurerm_container_registry_task` asociado al ACR indicado.
- Un paso de tarea (ACR Task) que ejecuta una imagen `alpine:3`, autentica contra el ACR usando el usuario administrador y:
  - Llama al endpoint `acr/v1/_catalog` para paginar todos los repositorios.
  - Ejecuta `DELETE acr/v1/<repo>` para cada repositorio encontrado.
- Un disparador por tiempo (`timer_trigger`) con la expresión cron proporcionada (en UTC).

## Estructura
- Directorio actual: Terraform "raíz" que invoca el módulo.
- Módulo: `../modules/acr-task-delete-repos` crea la ACR Task y renderiza el YAML del paso con `templatefile`.

## Requisitos previos
- Terraform >= 1.6.0
- Provider `azurerm` ~> 3.113
- Un Azure Container Registry existente con el usuario administrador habilitado.
  - El módulo lee `login_server`, `admin_username` y `admin_password` del ACR. Si el usuario admin no está habilitado, la tarea no podrá autenticarse.
- Permisos suficientes para gestionar ACR Tasks en el ACR de destino.

## Variables de entrada (raíz)
- `resource_group_name` (string, sensible): Nombre del Resource Group del ACR.
- `acr_name` (string, sensible): Nombre del ACR de destino.
- `schedule_cron` (string, por defecto "0 1 * * *"): Cron en UTC para programar la ejecución.

El módulo adicionalmente admite:
- `task_name` (string, por defecto `delete-acr-repos-daily`): Nombre de la ACR Task.

## Salidas del módulo
- `task_id`: ID del recurso `azurerm_container_registry_task`.
- `task_name`: Nombre de la ACR Task creada.
- `schedule`: Cadena cron configurada.

## Uso rápido
1) Ajusta variables en `terraform.tfvars`

```hcl
resource_group_name = "<RESOURCE_GROUP_NAME>"
acr_name            = "<ACR_NAME>"
schedule_cron       = "0 1 * * *" # 01:00 UTC diario
```

2) Inicializa y aplica:

```bash
terraform init
terraform plan
terraform apply
```

3) Verifica en el ACR que la Task existe y su programación está activa.

## Programación (cron en UTC)
- Formato estándar de 5 campos: `minuto hora díaMes mes díaSemana`.
- Ejemplos:
  - `0 1 * * *` → cada día a las 01:00 UTC.
  - `0 */6 * * *` → cada 6 horas.

## ¿Cómo funciona la tarea?
- El YAML de la ACR Task se genera desde `acr-task.yaml.tftpl` y se inyecta codificado en base64.
- En tiempo de ejecución, la tarea:
  - Exporta variables con `login_server`, `admin_username` y una `secret` con la contraseña.
  - Usa `curl` + `jq` contra el API `acr/v1` del registro para listar y eliminar repos.
  - Itera paginando mediante la cabecera `Link` hasta vaciar el catálogo.

## Limitaciones y consideraciones
- Elimina todos los repositorios del ACR objetivo sin exclusiones. Si necesitas exclusiones, deberás extender la plantilla para filtrar por nombre/patrón antes de borrar.
- Requiere usuario administrador habilitado en el ACR. Alternativas (service principal/OIDC) requerirían cambios en la autenticación del script de la Task.
- La expresión cron se interpreta en UTC por Azure.

## Archivos relevantes
- `main.tf`: Invoca al módulo `acr-task-delete-repos` con RG, ACR y cron.
- `providers.tf`: Define versión de Terraform y proveedor `azurerm`.
- `variables.tf`: Variables de entrada del stack raíz.
- `terraform.tfvars`: Ejemplo de valores.
- `modules/acr-task-delete-repos/`:
  - `main.tf`: Recurso `azurerm_container_registry_task` y carga del YAML.
  - `data.tf`: Lectura del ACR destino.
  - `variables.tf`: Variables del módulo (`task_name`, `schedule_cron`, etc.).
  - `outputs.tf`: Salidas del módulo.
  - `acr-task.yaml.tftpl`: Plantilla YAML con el flujo de borrado.

## Eliminación
Para eliminar la ACR Task creada:

```bash
terraform destroy
```